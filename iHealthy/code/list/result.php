
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

 <h1 class="display-4 text-white mt-5 mb-2">Results</h1>

 <div align="center" vertical-align="middle">
<div class="topnav">
  <form method="post">

     <label><input type="text" name="content"></label>
    <button type="submit" name="submit">Search</button>
</form>
</div>


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

$end = 0;

if (isset($_POST['submit'])){

	$sqlIn = "INSERT INTO gcp_search_key (search_key) VALUES ('{$_POST['content']}')";
	if ($conn->query($sqlIn) === TRUE) 
	{
		$end = 1;
		header("Location: result.php"); 
	} 
}





$sql = "select * from gcp_search_key ";
$result = $conn->query($sql);
while($row = $result->fetch_assoc())
{
	$med_key = $row['search_key'];
	//echo"$med_key";
}
if($end==0)
{
	$sql3 = "DELETE FROM gcp_search_key WHERE search_key = '$med_key'"; 
	$result3 = $conn->query($sql3);
}

echo ' <div class="container">
    <div class="row">';


$sql2 = "select * from medicine where medicine_name = '$med_key'"; 
$result2 = $conn->query($sql2);
while($row2 = $result2->fetch_assoc())
{	
  // if($result2->num_rows == 0)
  // {
  //     echo '<center>No results</center>';
  // }
	$med_name = $row2['medicine_name'];//show in front-end
	$med_image = $row2['medicine_image'];//show in front-end
	$med_sideeffect = $row2['medicine_sideeffect']; //show in front-end

	$med_food = $row2['food'];


       echo'<div class="col-md-4 mb-5">
            <div class="card h-100">
              <img class="card-img-top" src="'.$med_image.'" alt="">
              <div class="card-body">
                <h4 class="card-title">'.$med_name.'</h4>
               side effect: '.$med_sideeffect.'
              </div>
             
            </div>
          </div>';




}
$array  = explode(", ", $med_food);
$arrlength=count($array);	




for($x=0;$x<$arrlength;$x++)
{
	$sql4 = "select * from food where food_name = '$array[$x]'"; 
	$result4 = $conn->query($sql4);
   

	while($row4 = $result4->fetch_assoc())
	{	
		$food_name = $row4['food_name'];//show in front-end
		$food_img = $row4['food_img'];//show in front-end
		$food_component = $row4['food_component'];//show in front-end


       echo'<div class="col-md-4 mb-5">
            <div class="card h-100">
              <img class="card-img-top" src="'.$food_img.'" alt="">
              <div class="card-body">
                <h4 class="card-title"> '.$food_name.'</h4>
               components: '.$food_component.'
              </div>
             
            </div>
          </div>';


	}
   
}

 echo' </div>
  <!-- /.row -->
  </div>';
  
?>

  <!-- /.container -->

  <!-- Footer -->
  

  <!-- Bootstrap core JavaScript -->
  <script src="vendor/jquery/jquery.min.js"></script>
  <script src="vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

</body>

</html>



