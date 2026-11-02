<?php

// Open a connection to the database
function get_conn() {
    return new PDO('pgsql:host=localhost;port=5432;dbname=coursedb', 'student', 'student', [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_OBJ,
    ]);
}


$searchstring = $_GET['searchstring'];

if ($searchstring !== '') {
    $sql = "
        SELECT name
        FROM world.country
        WHERE name LIKE :pattern
        ORDER BY name
    ";
    $pattern = "%$searchstring%";

    $stmt = get_conn()->prepare($sql);
    $stmt->execute([':pattern' => $pattern]);
    $countries = $stmt->fetchAll();
}
?>
<!doctype html>
<html>
<head>
  <title>Country Search</title>
</head>
<nav>
<ul>
  <li><a href="index.html">Home</a></li>
  <li><a href="gardner.html">Gardner</a></li>
  <li><a href="form.php" class="active">Form 1</a></li>
  <li><a href="country_search.php">Form 2</a></li>
</ul>
</nav>
<div class="mainpage">
<body>
    <form method="get" action="country_search.php">
        <input type="text" name="searchstring" value="<?php echo $searchstring; ?>">
        <input type="submit" value="Search">
    </form>

    <?php 
    foreach ($countries as $c){ 
       echo $c->name."<br>"; 
    }  
    ?> 
</div>    
</body>
</html>