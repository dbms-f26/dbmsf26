<!DOCTYPE html>
<html>
<head>
<title>My First Form</title>
<link rel="stylesheet" href="mystyle.css">
</head>
<body>
<nav>
<ul>
  <li><a href="index.html">Home</a></li>
  <li><a href="gardner.html">Gardner</a></li>
  <li><a href="form.php" class="active">Form 1</a></li>
  <li><a href="country_search.php">Form 2</a></li>
</ul>
</nav>
<div class="mainpage">
<p>Hello php!</p>
<form action="form.php" method="get">
  <p>My name is <input type="text" id="myname" name="myname"></p>
  <p>My favorite color is <input type="text" name="mycolor"></p>
  <p>Please compute the factorial of <input type="text" name="N"></p>
  <input type="submit" value="Submit">
</form> 

<?php 
if (isset($_GET["myname"]) && !empty($_GET["myname"])) { // the $_GET array contains the variables passed through the url
													 // if we don't enter anything in the "myname" field, it will still pass an empty string
													 // so in addition to checking whether a value has been set, we check that it is not empty
	echo '<p>Hi, '.$_GET["myname"].".</p>"; // strings are surrounded with '' or "" and concatenated with .
}	

if (isset($_GET["mycolor"]) && !empty($_GET["mycolor"])) {
	echo '<p>'.$_GET["mycolor"]." is a beautiful color.</p>"; 									
} 

if (isset($_GET["N"]) && !empty($_GET["N"])) { 
	$n = $_GET["N"]; //variables are identified with $
	$fact = 1;		// initialization is optional. All variables are automatically initialized to 0/FALSE/blank string on creation
	for ($i=2;$i<=$n;$i++){  // the for loop (starting value; stopping condition; increment rule)
		$fact = $fact*$i;	
	}	
	echo '<p>Did you know that '.$n.'! = <b>'.$fact.'</b>?</p>';
} 	

?>
</div>
</body>
</html>