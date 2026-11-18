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

// when form is submitted, either searchstring or continent should be present in the _GET array
$searchstring = $_GET['searchstring'];
$continent = $_GET['continent'];

// show results even when no filters are applied

$sql = "
SELECT c.name, c.population, c.head_of_state, ci.name as city_name, 
string_agg(cb.points::text, ',' ORDER BY cb.badge_id) AS badgepoints
FROM country c JOIN city ci on c.capital = ci.id
JOIN countrybadges cb ON c.code = cb.country_code
WHERE C.name ILIKE :pattern";

$params = ['pattern' => "%".$searchstring."%"];

// if continent is present, add it to the where clause and the list of parameters
if (!empty($continent)){
    $sql = $sql." AND C.continent = :continent ";

    $params['continent'] = $continent;
}

$sql = $sql." GROUP BY c.name, c.population, c.head_of_state, ci.name 
ORDER BY c.name";  

$stmt = $pdo->prepare($sql);

//dumpSqlForDebugging($pdo, $sql, $params);

$stmt->execute($params);
$countries = $stmt->fetchAll(PDO::FETCH_NUM);
    
?>
<div class="mainpage">
    <form method="get" action="country_search.php">
        <label for="searchstring">Country name</label>
        <input type="text" name="searchstring" 
               value="<?php echo htmlspecialchars($searchstring); ?>">
        <label for="continent">Continent</label>       
        <select name="continent">
            <option></option> -- Add an empty option
        <?php
        
         foreach($continents as $c){
            echo '<option value="'.$c[0].'"';
            if ($c[0] == $continent) {
                echo ' selected ';}
            echo '>'.$c[0].'</option>';
        }     
        ?>
        </select>
        <input type="submit" value="Search">
    </form>
<?php

if (!empty($countries)) {   
    echo "<table>";
    echo "<tr>
        <th>Name</th><th>Population</th>
        <th>Head of State</th><th>Capital City</th>
        <th>World Explorer</th><th>Polyglot</th>
        <th>Asian Traveler</th><th>Old Europe</th>
        </tr>";

    foreach ($countries as $row){ 
        echo '<tr>';
        for ($i = 0; $i < 4; $i++) {
    	     echo '<td>'.$row[$i].'</td>';}
        $row[4] = explode(',', $row[4]); // turns the comma-delimited list back into an array
        foreach ($row[4] as $points) {
           echo '<td>'.$points.'</td>';
        }   
        echo '</tr>';
    }
    echo "</table>";    
}    
   
?> 
</div>    
</body>
</html>
