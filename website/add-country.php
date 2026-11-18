<?php
$active = basename($_SERVER['PHP_SELF']);
include 'topstuff.php'; 

// get the list of continents
$sql_continents = "SELECT DISTINCT continent 
                   FROM country
                   ORDER BY continent";

$stmt = $pdo->prepare($sql_continents);
$stmt->execute();
$continents = $stmt->fetchAll(PDO::FETCH_NUM);

if ($_GET['submit']=="yes") {
try {
    // 1. Start the transaction
    $pdo->beginTransaction();

    // 2. Insert the main record (Parent)
    $countrysql = "INSERT INTO country (code, name, local_name, continent, region, government_form, population, indep_year) 
                VALUES (:code, :name, :local_name, :continent, :region, :government_form, :population, :indep_year)";
    $countrydata = [
        'code' => $_GET['code'] ?? null,
        'name'  => $_GET['name']  ?? null,
        'local_name'  => $_GET['local_name']      ?? null,
        'continent' => $_GET['continent']      ?? null,
        'region' => $_GET['region']      ?? null,
        'government_form' => $_GET['government_form']      ?? null,
        'population' => $_GET['population'] ?? null, 
        'indep_year' => $_GET['indep_year'] ?? null
    ];

    // Uncomment the line below if your query fails and you want to test it in SQL:
    dumpSqlForDebugging($pdo, $countrysql, $countrydata);

    $stmt = $pdo->prepare($countrysql);
    $stmt->execute($countrydata);


    // 3. Insert the child records
  
    // prepare the query once
    $childSql = "INSERT INTO world.countrylanguage (country_code, language, is_official, percentage) 
                     VALUES (:country_code, :language, :is_official, :percentage)";
    $childStmt = $pdo->prepare($childSql);
    // iterate over the elements of the arrays holding child info
    for ($i = 0; $i < count($_GET["language"]); $i++) {
            // Skip completely blank rows if the user left extra form inputs empty
            if (!empty($_GET["language"][$i])){
              $childStmt->execute([
                  'country_code' => $_GET["code"],
                  'language'   => $_GET["language"][$i] ?? null,
                  'is_official'   => $_GET["is_official"][$i] ?? false,
                  'percentage'    => $_GET["percentage"][$i] ?? null,
              ]);
            }
    }

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
  <div class="mainpage">

    <form action="add-country.php" method="get">
  
        <label for="code">Country code</label>
        <input type="text" id="code" name="code" required minlength="3" maxlength="3"
               pattern="[A-Za-z]{3}" placeholder="e.g. NLD">
 
        <label for="name">Name</label>
        <input type="text" id="name" name="name" required maxlength="52">

        <label for="local_name">Local name (optional) </label>
        <input type="text" id="local_name" name="local_name" maxlength="45">

        <label for="continent">Continent</label>
        <select id="continent" name="continent" required>
         <option value=""></option>
         <?php
        
         foreach($continents as $c){
            echo '<option value="'.$c[0].'"';
            //if ($c[0] == $continent) {
            //    echo ' selected ';}
            echo '>'.$c[0].'</option>';
         }     
         ?>
        </select>

        <label for="region">Region</label>
        <input type="text" id="region" name="region" required maxlength="26">

        <label for="government_form">Government form</label>
        <input type="text" id="government_form" name="government_form" required maxlength="45">

        <label for="population">Population</label>
        <input type="number" id="population" name="population" required
               min="0" max="10000000000" step="1" value="0">

        <label for="indep_year">Independence year (optional)</label>
        <input type="number" id="indep_year" name="indep_year" 
               min="-32768" max="32767" step="1">

      <fieldset>
        <legend>Languages spoken</legend>
        <table>
            <tr>
              <th>Language</th>
              <th>Official</th>
              <th>Percentage of population</th>
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
            <tr>
              <td><input type="text" name="language[]" maxlength="30"></td>
              <td><input type="checkbox" name="is_official[]" value="true"></td>
              <td><input type="number" name="percentage[]" min="0" max="100" step="0.1"></td>
            </tr>
        </table>
      </fieldset>

      <button type="submit" name="submit" value="yes">Submit</button>

    </form>
  </div>
</body>
</html>
