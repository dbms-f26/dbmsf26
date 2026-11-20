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
 
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);  

    // Prepare the SQL statement to check the user's credentials
    $sql = "SELECT * FROM users WHERE fname = :fname AND lname = :lname";
    $stmt = $pdo->prepare($sql);
    $params = [
        ':fname' => $fname,
        ':lname' => $lname
    ];
    $stmt->execute($params);
    $user = $stmt->fetch(PDO::FETCH_ASSOC); 
    if ($user && password_verify($password, $user['password'])) {
        // Start the session and store user information
        session_start();
        $_SESSION['user_id'] = $user['user_id'];
        $_SESSION['fname'] = $user['fname'];
        $_SESSION['lname'] = $user['lname'];
        $_SESSION['accesslvl'] = $user['accesslvl'];

        echo '<p>Login successful. Redirecting to home page...</p>';
        echo '<meta http-equiv="refresh" content="3;url=country_search.php">';
    } else {
        echo "<p>Invalid credentials. Please try again.</p>";
    }
}

?>
    <form action="login.php" method="post">
        <label for="fname">First Name:</label>
        <input type="text" id="fname" name="fname" required>
        <label for="lname">Last Name:</label>
        <input type="text" id="lname" name="lname" required>
        <label for="password">Password:</label>     
        <input type="password" id="password" name="password" required>
        <input type="submit" value="Login">
    </form>
</div>