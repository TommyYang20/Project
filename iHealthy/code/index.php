 <?php
session_start();
?>

<!DOCTYPE html>
<html>
<head>
	<title> iHealthy </title>
	<meta name="viewport" content="width=device-width,initial-scale=1">
	<link href="https://fonts.googleapis.com/css?family=Oswald:400,700" rel="stylesheet" type="text/css">
    <link href="http://fonts.googleapis.com/css?family=Open+Sans" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <script defer src="https://use.fontawesome.com/releases/v5.0.8/js/all.js" integrity="sha384-SlE991lGASHoBfWbelyBPLsUlwY1GwNDJo3jSJO04KZ33K2bwfV9YBauFfnzvynJ" crossorigin="anonymous"></script>

	<link rel="stylesheet" href="main.css">
</head>

<body>
	<nav>

		<?php    
			if(empty($_SESSION['uid']))
	    	{

	     	   echo '<a href="login.php" class="button"><button type="submit">Log-in</button></a>
	     	   <a href="register.php" class="button"><button type="submit">Sign-up</button></a>'; 
	    	}
	    	else
	    	{
	    		echo '<a href="list/history.php" class="button"><button type="submit">Search History</button></a>'; 
	    	}
	    	

		?>
		
	</nav>

	<h1 class="">iHealthy</h1>


<div class="topnav">
	<form method="post">
<p style="text-align:center;">
	<label><input type="text" name="content"></label>

    <button type="submit" name="submit"><img class="icon" src=img/icon.png></button>
</p>
</form>
</div>

<?php

$servername = "213.190.6.127";
$username = "u207738006_root";
$password = "123456";
$dbname = "u207738006_ihealthy";
// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
} 

if (isset($_POST['submit'])){

if(empty($_SESSION['uid'])){}
else{
	$sqlHistory = "INSERT INTO history (search_content,user_id) 
	VALUES ('{$_POST['content']}','{$_SESSION['uid']}')";
	if ($conn->query($sqlHistory) === TRUE) 
	{
	} 
}



	$sqlIn = "INSERT INTO gcp_search_key (search_key) VALUES ('{$_POST['content']}')";
	if ($conn->query($sqlIn) === TRUE) 
	{
		header("Location: list/result.php"); 
	} 
}

?>



<form action="check.php" method="post" enctype="multipart/form-data">
                    <input type="file" name="image" accept="image/*" class="form-control">
                    <br>
                    <button type="submit" style="border-radius: 0px;" class="btn btn-lg btn-block btn-outline-success">Analyse Image</button>
                </form>


</body>

</html>

