
 <?php
session_start();
?>
<html>
<head>
  <meta name="viewport" content="width=device-width,initial-scale=1">
 



  <meta charset="UTF-8">
  <title>Create your iHealthy Account</title>

  <link rel="stylesheet" href="https://cdn.bootcss.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
  <style>
    body {
     padding-top: 40px;
     padding-bottom: 40px;
     background-color: #eee;
    }
 
    .form-signin {
     max-width: 330px;
     padding: 15px;
     margin: 0 auto;
    }
  </style>
</head>
<body>
    <div class="container">
   <form class="form-signin" action="" method="post">
    <h2 class="form-signin-heading">Create your iHealthy Account</h2>
    <label for="inputEmail" class="sr-only">email</label>
    <br>
    <input type="email" name="id" id="inputEmail" class="form-control" placeholder="Enter your email" required autofocus>
    <br>


    <label for="inputPassword" class="sr-only">password</label>
    <input type="password" name="password" id="inputPassword" class="form-control" placeholder="Enter your password" required>
    <br>


    <label for="inputPassword" class="sr-only">password2</label>
    <input type="password" name="password2" id="inputPassword" class="form-control" placeholder="Confirm your password" required>
    <br>


    <input type="submit" name="submit" class="btn btn-lg btn-primary btn-block" type="submit" value="Create Now">

   </form>
  </div>








<?php

error_reporting(0);


$servername = "213.190.6.127";
$username = "u207738006_root";
$password = "123456";
$dbname = "u207738006_ihealthy";


$idnum = "{$_POST['id']}";
$passwordnum = "{$_POST['password']}";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
} 



if (isset($_POST['submit'])){


$sql = "INSERT INTO user (user_id, user_password)

VALUES ('{$_POST['id']}','{$_POST['password']}')";

if (empty($idnum)=== TRUE)
{
  
 echo "<script>alert('id or password cannot be empty');</script>";
}
else if(empty($passwordnum)=== TRUE)
{
     echo "<script>alert('id or password cannot be empty');</script>";
}
else{

	if ($conn->query($sql) === TRUE) {


       

    header("location:index.php"); 


       $_SESSION['uid']=$_POST['id'];






} 
else {
    echo "Error: " . $sql . "<br>" . $conn->error;
}

}
}



$conn->close();



?>


</body>
</html>