<?php

// Include this in all pages that require the user to be logged in. 

// retrieve session data
session_start();


// if there is no user_id, kick the user back to login page
if(!isset($_SESSION['user_id']) || empty($_SESSION['user_id'])){
	header("location: login.php");
	exit;
}
?>