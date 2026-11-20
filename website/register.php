<?php
$active = basename($_SERVER['PHP_SELF']);
include 'topstuff.php'; 
?>

<div class="mainpage">

<?php

// Check if the form is submitted
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Get the form data
    $fname = $_POST["fname"];
    $lname = $_POST["lname"];
    $password = $_POST["password"];
    $confirm_password = $_POST["confirm_password"];
    $accesslvl = $_POST["accesslvl"];   

    // Validate the form data
    if ($password !== $confirm_password) {
        echo "<p>Passwords do not match.</p>";

    } else {
        // Hash the password
        $hashed_password = password_hash($password, PASSWORD_DEFAULT);  
        
        // Prepare the SQL statement to insert the new user
        $sql = "INSERT INTO users (fname, lname, password, accesslvl) VALUES (:fname, :lname, :password, :accesslvl)";
        $stmt = $pdo->prepare($sql);
        $params = [
            ':fname' => $fname,
            ':lname' => $lname,
            ':password' => $hashed_password,
            ':accesslvl' => $accesslvl
        ];

        //dumpSqlForDebugging($pdo, $sql, $params) ;
        $stmt->execute($params);

        echo '<p>Registration successful. Redirecting to login page...</p>';
        echo '<meta http-equiv="refresh" content="3;url=login.php">';
    }
}

?>
    <form action="register.php" method="post">
        <label for="fname">First Name:</label>
        <input type="text" id="fname" name="fname" required>
        <label for="lname">Last Name:</label>
        <input type="text" id="lname" name="lname" required>
        <label for="password">Password:</label>     
        <input type="password" id="password" name="password" required>
        <label for="confirm_password">Confirm Password:</label>
        <input type="password" id="confirm_password" name="confirm_password" required>
        <label for="accesslvl">Access Level:</label>
        <select id="accesslvl" name="accesslvl" required>
            <option value="1">Traveler</option>
            <option value="2">Travel Agent</option>
        </select>
        <input type="submit" value="Register">
    </form>
</div>