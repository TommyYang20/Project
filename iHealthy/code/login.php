
 <?php
session_start();
?>



<html>
<head>
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta charset="UTF-8">
  <title>Sign-In</title>

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
    <h2 class="form-signin-heading">Sign-In</h2>
    <label for="inputEmail" class="sr-only">email</label>
    <br>
    <input type="email" name="id" id="inputEmail" class="form-control" placeholder="Enter your email" required autofocus>
    <br>
    <label for="inputPassword" class="sr-only">password</label>
    <input type="password" name="password" id="inputPassword" class="form-control" placeholder="Enter your password" required>
    <br>
    <input type="submit" name="submit" class="btn btn-lg btn-primary btn-block" type="submit" value="Next">
    <br>
 <a href="register.php">
  <input  class="btn btn-lg btn-primary btn-block"  value="Create account">
</a>


    
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






if (isset($_POST['submit']))
{




    $sql = "SELECT * FROM user
    WHERE user_id='{$_POST['id']}' AND user_password='{$_POST['password']}'";

    $result = $conn->query($sql);

    if($result->num_rows > 0)
    {
         header("Location: index.php"); 
         $_SESSION['uid']=$_POST['id'];

    }
    else
    {
         echo "<script>alert('Wrong password. Please try again.');</script>";
    }



}

$conn->close();



?>




</body>
</html>