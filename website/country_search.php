<!doctype html>
<html>
<head>
  <title>Country Search</title>
  <link rel="stylesheet" href="mystyle.css">
</head>
<body>
<?php

// Open a connection to the database
function get_conn() {
    return new PDO('pgsql:host=localhost;port=5432;dbname=coursedb', 'student', 'student', [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_NUM,
    ]);
}

$sql_continents = "SELECT DISTINCT Continent 
                   FROM world.country
                   ORDER BY Continent";

$stmt = get_conn()->prepare($sql_continents);
$stmt->execute();
$continents = $stmt->fetchAll();

print_r($continents);


// get the search string from the url
$searchstring = $_GET['searchstring'];
$continent = $_GET['continent'];

if (!empty($searchstring)) {
    // prepare the query with a placeholder for the search string
    // this is a parameterized query, which is safer than concatenating the search string directly into the query
    $sql = "
        SELECT name
        FROM world.country
        WHERE name LIKE :pattern AND continent = :continent
        ORDER BY name
    ";
    $pattern = "%$searchstring%";

    // execute the query with the search string as a parameter
    $stmt = get_conn()->prepare($sql);
    $stmt->execute([':pattern' => $pattern,':continent'=>$continent]);
    // fetch all the results as an array of arrays
    $countries = $stmt->fetchAll();
}
?>

<nav>
<ul>
  <li><a href="index.html">Home</a></li>
  <li><a href="gardner.html">Gardner</a></li>
  <li><a href="form.php">Form 1</a></li>
  <li><a href="country_search.php" class="active">Form 2</a></li>
</ul>
</nav>
<div class="mainpage">
    <form method="get" action="country_search.php">
        <input type="text" name="searchstring" value="<?php echo $searchstring; ?>">
        <select name="continent">
        <?php
        foreach($continents as $c){
            echo '<option value="'.$c[0].'"';
            if ($c[0] == $continent)
                echo ' selected ';
            echo '>'.$c[0].'</option>';
        } 
        ?>
        </select>
     <input type="submit" value="Search">
    </form>

    <?php 
    // display the results, with a new line after each country name
    // $c[0] retrieves the value of the first column (name) of the row $c
    foreach ($countries as $c){ 
       echo $c[0]."<br>"; 
    }  
    ?> 
</div>    
</body>
</html>