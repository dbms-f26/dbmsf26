<?php

    // define a function for debugging parametrized sql
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
    // define a function to initialize connection to the database
    function get_conn($db, $username, $password) {
       return new PDO($db, $username, $password, [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_BOTH,
       ]);
    }

    // get the connection vars and initialize connection to the database
    include '../dbconnect/vars.php';
    $pdo = get_conn($db, $username, $password);

    // so we don't have to put world. before every table name and function name:
    $stmt = $pdo->prepare('SET search_path TO world');
    $stmt ->execute(); 

?>    

<!DOCTYPE html>
<html>
<head>
    <title></title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <nav>
        <ul>
<?php
    // make the top menu
    $linkaddresses = array("index.php","country_search.php", "add-country.php");
    $linknames = array("Home Page","Country Search", "Add Country");
    for ($i = 0; $i < count($linknames); $i++){
        echo '<li><a href="'.$linkaddresses[$i].'"';
            if ($linkaddresses[$i] == $active) {
                echo 'class="active"';
            };
        echo '>'.$linknames[$i].'</a></li>';
    }
?>

        </ul>
    </nav>

