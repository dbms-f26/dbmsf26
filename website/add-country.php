<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Add a country</title>
</head>
<body>
  <main>

    <form action="add-country.php" method="get">
      <!-- country.code: char(3), primary key -->
      <p>
        <label for="code">Country code</label><br>
        <input type="text" id="code" name="code" required minlength="3" maxlength="3"
               pattern="[A-Za-z]{3}" placeholder="e.g. NLD">
      </p>

      <!-- country.name: char(52) -->
      <p>
        <label for="name">Name</label><br>
        <input type="text" id="name" name="name" required maxlength="52">
      </p>

      <!-- country.local_name: char(45) -->
      <p>
        <label for="local_name">Local name</label><br>
        <input type="text" id="local_name" name="local_name" maxlength="45">
      </p>

      <!-- country.continent: constrained to the CHECK list -->
      <p>
        <label for="continent">Continent</label><br>
        <select id="continent" name="continent" required>
          <option value="" disabled selected>Select a continent</option>
          <option value="Asia">Asia</option>
          <option value="Europe">Europe</option>
          <option value="North America">North America</option>
          <option value="Africa">Africa</option>
          <option value="Oceania">Oceania</option>
          <option value="Antarctica">Antarctica</option>
          <option value="South America">South America</option>
        </select>
      </p>

      <!-- country.region: char(26) -->
      <p>
        <label for="region">Region</label><br>
        <input type="text" id="region" name="region" required maxlength="26">
      </p>

      <!-- country.government_form: char(45) -->
      <p>
        <label for="government_form">Government form</label><br>
        <input type="text" id="government_form" name="government_form" required maxlength="45">
      </p>

      <!-- country.population: integer -->
      <p>
        <label for="population">Population</label><br>
        <input type="number" id="population" name="population"
               min="0" max="2147483647" step="1" value="0">
      </p>

      <!-- country.indep_year: smallint, nullable (leave blank for NULL) -->
      <p>
        <label for="indep_year">Independence year (optional)</label><br>
        <input type="number" id="indep_year" name="indep_year"
               min="-32768" max="32767" step="1">
      </p>

      <!-- countrylanguage rows: country_code comes from the "code" field above.
           Rows left blank should be ignored by the server. -->
      <fieldset>
        <legend>Languages spoken</legend>
        <table>
          <thead>
            <tr>
              <th>Language</th>
              <th>Official</th>
              <th>Percentage of population</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><input type="text" name="languages[0][language]" maxlength="30" aria-label="Language 1"></td>
              <td><input type="checkbox" name="languages[0][is_official]" value="true" aria-label="Language 1 is official"></td>
              <td><input type="number" name="languages[0][percentage]" min="0" max="100" step="0.1" aria-label="Language 1 percentage"></td>
            </tr>
            <tr>
              <td><input type="text" name="languages[1][language]" maxlength="30" aria-label="Language 2"></td>
              <td><input type="checkbox" name="languages[1][is_official]" value="true" aria-label="Language 2 is official"></td>
              <td><input type="number" name="languages[1][percentage]" min="0" max="100" step="0.1" aria-label="Language 2 percentage"></td>
            </tr>
            <tr>
              <td><input type="text" name="languages[2][language]" maxlength="30" aria-label="Language 3"></td>
              <td><input type="checkbox" name="languages[2][is_official]" value="true" aria-label="Language 3 is official"></td>
              <td><input type="number" name="languages[2][percentage]" min="0" max="100" step="0.1" aria-label="Language 3 percentage"></td>
            </tr>
            <tr>
              <td><input type="text" name="languages[3][language]" maxlength="30" aria-label="Language 4"></td>
              <td><input type="checkbox" name="languages[3][is_official]" value="true" aria-label="Language 4 is official"></td>
              <td><input type="number" name="languages[3][percentage]" min="0" max="100" step="0.1" aria-label="Language 4 percentage"></td>
            </tr>
            <tr>
              <td><input type="text" name="languages[4][language]" maxlength="30" aria-label="Language 5"></td>
              <td><input type="checkbox" name="languages[4][is_official]" value="true" aria-label="Language 5 is official"></td>
              <td><input type="number" name="languages[4][percentage]" min="0" max="100" step="0.1" aria-label="Language 5 percentage"></td>
            </tr>
          </tbody>
        </table>
      </fieldset>

      <p>
        <button type="submit" name="submit" value="yes">Add country</button>
        <button type="reset">Clear</button>
      </p>
    </form>
  </main>
</body>
</html>
