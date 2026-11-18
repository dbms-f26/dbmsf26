#!/usr/bin/env python3
"""
download_repos.py

Downloads a snapshot of every repository in a GitHub organization. Each
repository goes into its own folder, named <repo-name>_<YYYY-MM-DD>, inside
a destination folder (default: student_repos, in the folder you run this from).

--------------------------------------------------------------------------
USAGE
--------------------------------------------------------------------------
    python3 download_repos.py [--org ORG] [--dest DIR]
                              [--prefix PREFIX ...] [--exclude NAME ...]
                              [--force] [--dry-run]

Examples:
    python3 download_repos.py --dry-run
    python3 download_repos.py --exclude dbmsf26 --exclude course-template
    python3 download_repos.py --prefix group- --prefix dbmsf26-

Folders are created like:
    student_repos/group-3-project_2026-11-13/

--------------------------------------------------------------------------
WHAT YOU GET
--------------------------------------------------------------------------
The files of each repository's default branch as they are right now,
including hidden folders such as .devcontainer. You do NOT get the git
history (no .git folder). Re-running on the same day skips folders that
already exist; add --force to replace them.

The organization also contains your own repositories (the template, your
working repo), so use --exclude or --prefix to leave them out. Use --dry-run
first to see exactly which repositories would be downloaded.

--------------------------------------------------------------------------
AUTHENTICATION
--------------------------------------------------------------------------
Set the GITHUB_TOKEN environment variable, or log in with `gh auth login`
(the script runs `gh auth token`). The token needs read access to the
contents of the organization's private repositories.

--------------------------------------------------------------------------
PRIVACY
--------------------------------------------------------------------------
The script writes a .gitignore containing "*" into the destination folder,
so if that folder sits inside one of your own repositories, git will never
commit your students' work by accident.
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
import urllib.error
import urllib.parse
import urllib.request
import zipfile
from datetime import date

API_BASE = os.environ.get("GITHUB_API_URL", "https://api.github.com").rstrip("/")
DEFAULT_ORG = os.environ.get("GITHUB_ORG", "dbms-f26")


class _DropAuthOnRedirect(urllib.request.HTTPRedirectHandler):
    """
    GitHub answers a zipball request with a redirect to a different host
    (codeload.github.com). Python's urllib would forward our token there;
    this handler removes it whenever the redirect leaves the original host.
    """

    def redirect_request(self, req, fp, code, msg, headers, newurl):
        new = super().redirect_request(req, fp, code, msg, headers, newurl)
        if new is not None:
            old_host = urllib.parse.urlparse(req.full_url).netloc
            new_host = urllib.parse.urlparse(newurl).netloc
            if old_host != new_host:
                new.remove_header("Authorization")
        return new


_opener = urllib.request.build_opener(_DropAuthOnRedirect)


def get_token():
    """Returns a token from GITHUB_TOKEN or `gh auth token`, or None."""
    token = os.environ.get("GITHUB_TOKEN", "").strip()
    if token:
        return token
    try:
        out = subprocess.check_output(["gh", "auth", "token"], text=True, stderr=subprocess.DEVNULL)
        return out.strip() or None
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None


def _request(url, token):
    req = urllib.request.Request(url)
    req.add_header("Accept", "application/vnd.github+json")
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    return req


def list_org_repos(org, token):
    """Returns the sorted names of all repositories in the organization."""
    names, page = [], 1
    while True:
        url = f"{API_BASE}/orgs/{org}/repos?per_page=100&page={page}"
        with _opener.open(_request(url, token)) as resp:
            data = json.loads(resp.read().decode("utf-8"))
        names.extend(repo["name"] for repo in data)
        if len(data) < 100:
            break
        page += 1
    return sorted(names)


def filter_repos(names, prefixes, excludes):
    """Keeps names starting with any prefix (if given) and drops excluded names."""
    kept = []
    for name in names:
        if name in excludes:
            continue
        if prefixes and not any(name.startswith(p) for p in prefixes):
            continue
        kept.append(name)
    return kept


def download_repo(org, repo, dest_root, date_str, token, force=False):
    """
    Downloads the default branch of org/repo as a zip, extracts it, and moves
    it to <dest_root>/<repo>_<date_str>. Returns a short status string.
    Raises urllib.error.HTTPError or other exceptions on failure; the caller
    decides how to report them.
    """
    final = os.path.join(dest_root, f"{repo}_{date_str}")
    if os.path.exists(final) and not force:
        return "skipped (folder already exists; use --force to replace)"

    # Work in a temporary folder so a failed download never leaves a half-made
    # result (and never destroys an older copy when using --force).
    tmpdir = tempfile.mkdtemp(prefix=".tmp_", dir=dest_root)
    try:
        zip_path = os.path.join(tmpdir, "repo.zip")
        with _opener.open(_request(f"{API_BASE}/repos/{org}/{repo}/zipball", token)) as resp, \
                open(zip_path, "wb") as out:
            shutil.copyfileobj(resp, out)

        extract_dir = os.path.join(tmpdir, "extracted")
        with zipfile.ZipFile(zip_path) as zf:
            zf.extractall(extract_dir)

        # GitHub wraps everything in one top-level folder named like
        # "<org>-<repo>-<commit>". Move that folder to its final name.
        entries = os.listdir(extract_dir)
        if len(entries) != 1 or not os.path.isdir(os.path.join(extract_dir, entries[0])):
            raise RuntimeError("unexpected archive layout")

        if os.path.exists(final):
            shutil.rmtree(final)
        os.rename(os.path.join(extract_dir, entries[0]), final)
        return "downloaded"
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)


def parse_args():
    p = argparse.ArgumentParser(
        description="Download a dated snapshot of every repository in a GitHub organization."
    )
    p.add_argument("--org", default=DEFAULT_ORG, help=f"organization name (default: {DEFAULT_ORG})")
    p.add_argument("--dest", default="student_repos", help="destination folder (default: student_repos)")
    p.add_argument("--prefix", action="append", default=[], metavar="PREFIX",
                   help="only download repositories whose name starts with PREFIX (repeatable)")
    p.add_argument("--exclude", action="append", default=[], metavar="NAME",
                   help="skip the repository with exactly this name (repeatable)")
    p.add_argument("--force", action="store_true",
                   help="replace a folder that already exists for today's date")
    p.add_argument("--dry-run", action="store_true",
                   help="list the repositories that would be downloaded, then stop")
    return p.parse_args()


def main():
    args = parse_args()

    token = get_token()
    if not token:
        print("ERROR: no GitHub credentials found. Run 'gh auth login' or set GITHUB_TOKEN.")
        return 1

    try:
        names = list_org_repos(args.org, token)
    except urllib.error.HTTPError as e:
        print(f"ERROR: could not list repositories in '{args.org}' (HTTP {e.code}). "
              "Check the organization name and that your token can read it.")
        return 1

    repos = filter_repos(names, args.prefix, set(args.exclude))
    print(f"Organization '{args.org}' has {len(names)} repositories; {len(repos)} selected.")

    if args.dry_run:
        for name in repos:
            print(f"  would download: {name}")
        return 0

    os.makedirs(args.dest, exist_ok=True)
    gitignore = os.path.join(args.dest, ".gitignore")
    if not os.path.exists(gitignore):
        with open(gitignore, "w", encoding="utf-8") as f:
            f.write("*\n")

    today = date.today().isoformat()
    failures = []
    for i, repo in enumerate(repos, start=1):
        print(f"[{i}/{len(repos)}] {repo} ... ", end="", flush=True)
        try:
            status = download_repo(args.org, repo, args.dest, today, token, args.force)
        except urllib.error.HTTPError as e:
            hint = " (the repository may be empty)" if e.code == 404 else ""
            print(f"FAILED: HTTP {e.code}{hint}")
            failures.append(repo)
        except Exception as e:  # keep going; report at the end
            print(f"FAILED: {e}")
            failures.append(repo)
        else:
            print(status)

    print(f"\nDone. Files are under {os.path.abspath(args.dest)}")
    if failures:
        print(f"{len(failures)} repository(ies) failed: {', '.join(failures)}")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
