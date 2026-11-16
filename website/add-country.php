<?php

// Open a connection to the database
function get_conn() {
    return new PDO('pgsql:host=localhost;port=5432;dbname=coursedb', 'student', 'student', [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_OBJ,
    ]);
}

if ($_GET['submit']=="yes") {

    print_r($_GET);
function dumpSqlForDebugging($pdo, $sql, $params) {
    foreach ($params as $key => $value) {
        $placeholder = str_starts_with($key, ':') ? $key : ':' . $key;
        if (is_int($value) || is_float($value)) {
            $formatted = (string) $value;
        } else {
            $formatted = $pdo->quote((string) $value);
        }
        $sql = preg_replace('/' . preg_quote($placeholder, '/') . '\b/', $formatted, $sql);
    }
    echo htmlspecialchars($sql);
}

$pdo = get_conn();

try {
    // 1. Start the transaction
    $pdo->beginTransaction();

    // 2. Insert the main record (Parent)
    $userSql = "INSERT INTO world.country (code, name, local_name, continent, region, government_form, population, indep_year) 
                VALUES (:code, :name, :local_name, :continent, :region, :government_form, :population, :indep_year)";
    $userData = [
        'code' => $_GET['code'] ?? null,
        'name'  => $_GET['name']  ?? null,
        'local_name'  => $_GET['local_name']      ?? null,
        'continent' => $_GET['continent']      ?? null,
        'region' => $_GET['region']      ?? null,
        'government_form' => $_GET['govenrment_form']      ?? null,
        'population' => $_GET['population'] ?? null, 
        'indep_year' => $_GET['indep_year'] ?? null
    ];

    // Uncomment the line below if your query fails and you want to test it in SQL:
    dumpSqlForDebugging($pdo, $userSql, $userData);

    $userStmt = $pdo->prepare($userSql);
    $userStmt->execute($userData);

    // 4. Everything worked! Save all changes permanently.
    $pdo->commit();
    echo "<p>Success! User and dependents saved.</p>";

} catch (PDOException $e) {
    // 5. Something broke! Undo everything back to step 1.
    $pdo->rollBack();

    // Show the exact database error
    echo "<p>Database Error:" . htmlspecialchars($e->getMessage())."</p>";
}
}
?>


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
              <td><input type="text" name="language[]" maxlength="30"></td>
              <td><input type="checkbox" name="is_official[]" value="true"></td>
              <td><input type="number" name="percentage[]" min="0" max="100" step="0.1"></td>
            </tr>
            <tr>
<td><input type="text" name="language[]" maxlength="30"></td>
              <td><input type="checkbox" name="is_official[]" value="true"></td>
              <td><input type="number" name="percentage[]" min="0" max="100" step="0.1"></td>
            </tr>
            <tr>
<td><input type="text" name="language[]" maxlength="30"></td>
              <td><input type="checkbox" name="is_official[]" value="true"></td>
              <td><input type="number" name="percentage[]" min="0" max="100" step="0.1"></td>
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
