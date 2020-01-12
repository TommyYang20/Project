<?php
session_start();
?>
<!DOCTYPE html>
<html lang="en">

<head>

  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="">
  <meta name="author" content="">

  <title>Search History</title>

  <!-- Bootstrap core CSS -->
  <link href="vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">

  <!-- Custom styles for this template -->
  <link href="css/business-frontpage.css" rel="stylesheet">

</head>

<body>

  <!-- Navigation -->

<div style="background-color: #91D52B; width: 101%
            ; height: -100px;
            margin : 0px;
            border :0px;">
</div>
<div style="background-color: #91D52B; width: 101%
            ; height: 200px;
            margin : 0px;
            border :0px;">
  <p style="text-align:center;">
    <br>

    <div align="center" vertical-align="middle">

 <h1 class="display-4 text-white mt-5 mb-2">Search History</h1>
</div>


</p>


</div>
<br>


  <!-- Header -->


  <!-- Page Content -->
    <!-- /.row -->
 
     
   

      

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


$sql = "select * from history where user_id ='{$_SESSION['uid']}'";
$result = $conn->query($sql);

if ($result->num_rows <= 0)
{
  echo'No Search History';
} 

if ($result->num_rows > 0)
{
  echo ' <div class="container">
    <div class="row">';
  while($row = $result->fetch_assoc())
  {
  $str = $row['search_content'];
  $sql2 = "select * from medicine where medicine_name = '{$str}'";
  $result2 = $conn->query($sql2);
  if ($result2->num_rows <= 0)
  {
    echo'<div class="col-md-4 mb-5">
        <div class="card h-100">
          <img class="card-img-top" src="http://placehold.it/300x200" alt="">
          <div class="card-body">';
  }
  else
  { 
    while($row2 = $result2->fetch_assoc())
    {
      $str2 = $row2['medicine_image'];
      $str3 = $row2['food'];
     
    echo'<div class="col-md-4 mb-5">
        <div class="card h-100">
          <img class="card-img-top" src="'.$str2.'" alt="">
          <div class="card-body">';
    }

  }



  echo ' 
            <h4 class="card-title">'.$str.'</h4>
            '.$str3.'
           
          </div>
          <div class="card-footer">
            <a href="../index.php" class="btn btn-primary">Search it again</a>
          </div>
        </div>
      </div>';
  }
  echo' </div>
    <!-- /.row -->
  </div>';
}
$conn->close();


?>


  <!-- /.container -->

  <!-- Footer -->
  

  <!-- Bootstrap core JavaScript -->
  <script src="vendor/jquery/jquery.min.js"></script>
  <script src="vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

</body>

</html>
