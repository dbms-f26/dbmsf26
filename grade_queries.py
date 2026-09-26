#!/usr/bin/env python3
"""
grade_queries.py

Collects a `queries.sql` file from every student repo in a GitHub organization,
runs each student's SELECT queries against a reference PostgreSQL database,
and compares the output to an instructor-maintained answer key.

--------------------------------------------------------------------------
HOW STUDENTS SHOULD FORMAT queries.sql
--------------------------------------------------------------------------
No markers or labels required. Students just write their queries in order,
one per semicolon, e.g.:

    SELECT name FROM world.country WHERE continent = 'Africa';

    SELECT name, population FROM world.city ORDER BY population DESC LIMIT 5;

The 1st query in the file is graded against the 1st query in your answer
key, the 2nd against the 2nd, and so on -- order is everything here, so
make sure students know not to skip a question by leaving it blank (an
empty/missing query shifts every question after it out of alignment).

--------------------------------------------------------------------------
HOW YOU (THE INSTRUCTOR) PROVIDE THE ANSWER KEY
--------------------------------------------------------------------------
Write your own answer key file in the same format -- one query per
semicolon, in the order you want them graded.

--------------------------------------------------------------------------
USAGE
--------------------------------------------------------------------------
    python3 grade_queries.py <file_to_grade> <answer_key> <schema>

Example:
    python3 grade_queries.py query1.sql query1_answer_key.sql world

<file_to_grade> is the filename to look for in every student's repo.
<answer_key> is the path to your own reference SQL file, read locally
(not fetched from GitHub).
<schema> is the Postgres schema every query (student and answer key alike)
should run against, e.g. world or northwind.

--------------------------------------------------------------------------
CONFIGURATION
--------------------------------------------------------------------------
GITHUB_ORG, GITHUB_TOKEN, REPO_PREFIX, and the DB_* settings are still
read from the CONFIG block below, or from environment variables of the
same name (recommended for GITHUB_TOKEN, so it isn't hardcoded).
"""

import os
import re
import csv
import sys
import base64
import argparse
import psycopg2
import urllib.request
import json
from datetime import datetime

# ============================== CONFIG ====================================

GITHUB_ORG = os.environ.get("GITHUB_ORG", "dbms-f26")
GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN", "")  # a fine-grained PAT with read access to the org's repos
REPO_PREFIX = os.environ.get("REPO_PREFIX", "dbmsf26-")  # only repos starting with this are graded

# FILE_PATH_IN_REPO and ANSWER_KEY_PATH are no longer set here -- they're
# passed in on the command line each time you run the script (see main()),
# so the same script works for query1.sql, query2.sql, etc. without editing
# this file.

DB_HOST = os.environ.get("DB_HOST", "localhost")
DB_PORT = os.environ.get("DB_PORT", "5432")
DB_NAME = os.environ.get("DB_NAME", "coursedb")
DB_USER = os.environ.get("DB_USER", "student")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "student")

# Results are written under a per-run folder (see main()), not a fixed path --
# no OUTPUT_CSV constant needed here anymore.

# A query is rejected if it contains any of these keywords (case-insensitive,
# whole-word). This is a basic safety net, not a full SQL parser -- it's here
# to stop an accidental or malicious non-SELECT statement from touching your
# reference database, not to catch every possible bypass.
FORBIDDEN_KEYWORDS = [
    "INSERT", "UPDATE", "DELETE", "DROP", "ALTER", "TRUNCATE",
    "GRANT", "REVOKE", "CREATE", "COPY", "VACUUM", "REINDEX",
]

# ============================================================================


def parse_queries(sql_text):
    """
    Splits a queries.sql file into {question_number: query_string} by
    position -- the 1st statement in the file becomes question 1, the 2nd
    becomes question 2, and so on. No markers/labels required.

    Splitting is done on ';' (a plain statement separator). This is a simple
    approach, not a full SQL parser -- it will mis-split a query that
    contains a literal ';' inside a string value, but that's rare enough
    for this kind of assignment that it isn't worth a heavier dependency.
    """
    # Strip full-line comments so a comment-only line between queries
    # doesn't accidentally get treated as a (blank) statement.
    for ln in sql_text.splitlines():
      if !ln.strip().startswith("--") and !ln.strip().startswith("SET"):
        lines[] = ln
    cleaned = "\n".join(lines)

    statements = [s.strip() for s in cleaned.split(";")]
    statements = [s for s in statements if s]  # drop empty fragments (e.g. trailing newline after last ';')

    return {i + 1: stmt for i, stmt in enumerate(statements)}


def is_safe_select(query):
    """
    Returns True if the query looks like a read-only SELECT with no
    forbidden keywords. This is intentionally simple -- adjust
    FORBIDDEN_KEYWORDS above if you need something stricter.
    """
    stripped = query.strip()
    if not re.match(r"^\s*SELECT\b", stripped, re.IGNORECASE):
        return False
    for kw in FORBIDDEN_KEYWORDS:
        if re.search(rf"\b{kw}\b", stripped, re.IGNORECASE):
            return False
    return True


def run_query(conn, query, schema):
    """
    Executes a query with `schema` (then "public" as a fallback) on the
    search path, and returns (rows, has_order_by).
    Rows are returned as a list of tuples, with all values coerced to str
    for reliable comparison across types.
    Raises the underlying exception on SQL errors -- the caller decides
    how to report that.
    """
    has_order_by = bool(re.search(r"\border\s+by\b", query, re.IGNORECASE))
    with conn.cursor() as cur:
        cur.execute(f'SET search_path TO "{schema}", public; {query};')
        rows = cur.fetchall()
    rows = [tuple(str(v) for v in row) for row in rows]
    return rows, has_order_by


def compare_results(expected_rows, expected_ordered, actual_rows, actual_ordered):
    """
    Compares two result sets.
    If the expected query had ORDER BY, row order must match exactly.
    Otherwise, rows are compared as an unordered multiset (so students
    aren't marked wrong just for a different row order).
    """
    if expected_ordered:
        return expected_rows == actual_rows
    else:
        return sorted(expected_rows) == sorted(actual_rows)


def build_answer_key(conn, answer_key_path, schema):
    """
    Reads the answer key file at `answer_key_path`, runs every query in it
    against `schema`, and returns {question_number: (rows, has_order_by)}.
    """
    with open(answer_key_path, "r", encoding="utf-8") as f:
        text = f.read()
    parsed = parse_queries(text)
    key = {}
    for qnum, query in parsed.items():
        if not is_safe_select(query):
            print(f"WARNING: answer key Q{qnum} failed the safety check -- skipping.")
            continue
        rows, ordered = run_query(conn, query, schema)
        key[qnum] = (rows, ordered)
    return key


def github_api_get(path, token):
    """Minimal GitHub REST API GET helper using only the standard library."""
    url = f"https://api.github.com{path}"
    req = urllib.request.Request(url)
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("Accept", "application/vnd.github+json")
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode("utf-8"))


def list_org_repos(org, token, prefix):
    """Returns a list of repo names in the org that start with `prefix`."""
    repos = []
    page = 1
    while True:
        data = github_api_get(f"/orgs/{org}/repos?per_page=100&page={page}", token)
        if not data:
            break
        for repo in data:
            if repo["name"].startswith(prefix):
                repos.append(repo["name"])
        page += 1
    return repos


def fetch_file_from_repo(org, repo, path, token):
    """
    Returns the decoded text content of `path` in `org/repo`, or None if the
    file doesn't exist (e.g. the student never created it).
    """
    try:
        data = github_api_get(f"/repos/{org}/{repo}/contents/{path}", token)
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        raise
    content = base64.b64decode(data["content"]).decode("utf-8")
    return content


def parse_args():
    parser = argparse.ArgumentParser(
        description="Grade a SQL file collected from every student repo in a GitHub organization."
    )
    parser.add_argument(
        "file_to_grade",
        help="Name of the file to fetch from each student's repo, e.g. query1.sql",
    )
    parser.add_argument(
        "answer_key",
        help="Path to your own answer-key SQL file (same format as students' files), e.g. query1_answer_key.sql",
    )
    parser.add_argument(
        "schema",
        help="Schema the queries should run against, e.g. world or northwind",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    file_to_grade = args.file_to_grade
    answer_key_path = args.answer_key
    schema = args.schema

    if not GITHUB_TOKEN:
        print("ERROR: set the GITHUB_TOKEN environment variable to a token with read access to the org.")
        sys.exit(1)

    if not os.path.isfile(answer_key_path):
        print(f"ERROR: answer key file not found: {answer_key_path}")
        sys.exit(1)

    conn = psycopg2.connect(host=DB_HOST, port=DB_PORT, dbname=DB_NAME, user=DB_USER, password=DB_PASSWORD)
    conn.autocommit = True

    print(f"Grading '{file_to_grade}' against answer key '{answer_key_path}' (schema: {schema})...")
    print("Building answer key...")
    answer_key = build_answer_key(conn, answer_key_path, schema)
    print(f"Answer key has {len(answer_key)} question(s): {sorted(answer_key.keys())}\n")

    print(f"Listing repos in '{GITHUB_ORG}' starting with '{REPO_PREFIX}'...")
    repos = list_org_repos(GITHUB_ORG, GITHUB_TOKEN, REPO_PREFIX)
    print(f"Found {len(repos)} repo(s).\n")

    # One subfolder per run, named after the file being graded and the
    # exact time this run started, e.g. submissions_query1_092526_1413.
    # Every student's raw file AND this run's grading_results.csv both land
    # in here, so a single folder is a complete, self-contained record of
    # one grading pass -- nothing gets overwritten by the next run.
    file_stem = os.path.splitext(os.path.basename(file_to_grade))[0]
    timestamp = datetime.now().strftime("%m%d%y_%H%M")
    run_dir = f"submissions_{file_stem}_{timestamp}"
    os.makedirs(run_dir, exist_ok=True)
    print(f"This run's files will be saved under: {run_dir}/\n")

    results = []  # rows for the CSV: student, question, status, detail

    for repo in repos:
        student = repo[len(REPO_PREFIX):] or repo
        print(f"--- {repo} ---")
        content = fetch_file_from_repo(GITHUB_ORG, repo, file_to_grade, GITHUB_TOKEN)

        if content is None:
            print(f"  {file_to_grade} not found.")
            for qnum in answer_key:
                results.append([student, qnum, "MISSING_FILE", "", ""])
            continue

        # Save a copy of exactly what was graded, in this run's subfolder.
        # This is your audit trail: what the student actually submitted,
        # independent of whatever they push to GitHub afterward.
        with open(os.path.join(run_dir, f"{student}_{file_stem}.sql"), "w", encoding="utf-8") as f:
            f.write(content)

        submitted = parse_queries(content)

        for qnum, (expected_rows, expected_ordered) in answer_key.items():
            if qnum not in submitted:
                print(f"  Q{qnum}: not answered")
                results.append([student, qnum, "NOT_ANSWERED", "", ""])
                continue

            query = submitted[qnum]

            if not is_safe_select(query):
                print(f"  Q{qnum}: REJECTED (not a plain SELECT, or contains a forbidden keyword)")
                results.append([student, qnum, "REJECTED", "", query])
                continue

            try:
                actual_rows, actual_ordered = run_query(conn, query, schema)
            except Exception as e:
                print(f"  Q{qnum}: SQL ERROR -- {e}")
                results.append([student, qnum, "SQL_ERROR", str(e).replace("\n", " "), query])
                conn.rollback()
                continue

            ok = compare_results(expected_rows, expected_ordered, actual_rows, actual_ordered)
            status = "PASS" if ok else "FAIL"
            print(f"  Q{qnum}: {status}")
            detail = "" if ok else f"expected {len(expected_rows)} row(s), got {len(actual_rows)} row(s)"
            results.append([student, qnum, status, detail, query])

        print()

    # Build a one-row-per-student summary from the same results, preserving
    # the order questions were graded in (so the results string reads
    # left-to-right as Q1, Q2, Q3, ...).
    summary = {}  # student -> list of statuses, in question order
    for student, qnum, status, detail, query in results:
        summary.setdefault(student, []).append(status)

    summary_path = os.path.join(run_dir, "summary_results.csv")
    with open(summary_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["student", "total", "passed", "results"])
        for student, statuses in summary.items():
            total = len(statuses)
            passed = sum(1 for s in statuses if s == "PASS")
            writer.writerow([student, total, passed, ", ".join(statuses)])
    print(f"Summary written to {summary_path}")

    csv_path = os.path.join(run_dir, "grading_results.csv")
    with open(csv_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["student", "question", "status", "detail", "submitted_query"])
        writer.writerows(results)

    print(f"Done. Results written to {csv_path}")


if __name__ == "__main__":
    main()
