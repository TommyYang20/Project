<?php

session_start();

require "vendor/autoload.php";


use Google\Cloud\Vision\VisionClient;
$vision = new VisionClient(['keyFile' => json_decode(file_get_contents("key.json"), true)]);

$familyPhotoResource = fopen($_FILES['image']['tmp_name'], 'r');

$image = $vision->image($familyPhotoResource, 
    ['FACE_DETECTION',
     'WEB_DETECTION',
     'LABEL_DETECTION',
     'IMAGE_PROPERTIES',
     'SAFE_SEARCH_DETECTION',
     'LANDMARK_DETECTION',
     'LOGO_DETECTION'
    ]);
$result = $vision->annotate($image);

if ($result) {
    $imagetoken = random_int(1111111, 999999999);
    move_uploaded_file($_FILES['image']['tmp_name'], __DIR__ . '/feed/' . $imagetoken . ".jpg");
} else {
    header("location: index.php");
    die();
}

$faces = $result->faces();
$logos = $result->logos();
$labels = $result->labels();
$text = $result->text();
$fullText = $result->fullText();
$properties = $result->imageProperties();
$cropHints = $result->cropHints();
$web = $result->web();
$safeSearch = $result->safeSearch();
$landmarks = $result->landmarks();


?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Google Cloud Vision API</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous">
    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"></script>
    <style>
        body, html {
            height: 100%;
        }
        .bg {
            background-image: url("images/bg.jpg");
            height: 100%;
            /*background-position: center;*/
            background-repeat: no-repeat;
            /*background-size: cover;*/
        }
        .container-fluid  {
            margin-bottom: 50px;
        }
    </style>
</head>
<body class="bg">
    <div class="container-fluid" style="max-width: 1080px;">
        <br><br><br>
        <div class="row">
            <div class="col-md-12" style="margin: auto; background: white; padding: 20px; box-shadow: 10px 10px 5px #888">
                <div class="panel-heading">
                    <h2><a href="/">Google Cloud Vision API</a></h2>
                    <p style="font-style: italic;">Coolest Image Processing Engine on Earth</p>
                </div>
                <hr>
                <div class="row">
                    <div class="col-md-4" style="text-align: center;">
                        <img class="img-thumbnail" src="<?php 
                            if ($faces == null) {
                                echo "/feed/" . $imagetoken . ".jpg";
                            } else {
                                echo "image.php?token=$imagetoken";
                            }
                        ?>" alt="Analysed Image">
                        
                    </div>
                 


<div class="tab-pane fade show" id="pills-web" role="tabpanel" aria-labelledby="pills-web-tab">
                                <div class="row">
                                    <div class="col-12">
                                          <hr>
									        <ol>
									            <?php foreach ($web->entities() as $key => $entity): ?>
									                <li><h6><?php echo 'hello:'.ucfirst($entity->info()['description']) ?></h6> Confidence: <strong><?php echo number_format($entity->info()['score'] * 100 , 2) ?></strong></li>

<?php $key = ucfirst($entity->info()['description']);


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


$sql = "select * from medicine where medicine_name ='$key'";
$result = $conn->query($sql);


if ($result->num_rows > 0)
{
	
	$sql2 = "INSERT INTO gcp_search_key (search_key) VALUES ('{$key}')";
	if ($conn->query($sql2) === TRUE) 
	{
		header("location:list/result.php"); 
	} 

		

}

if ($result->num_rows <= 0)
{
	//header("location:list/noresult.php"); 
} 



 ?>

									            <?php endforeach ?>
									        </ol>
                                    </div>
                                </div>
                            </div>


                           

                      
                </div>
            </div>
        </div>
    </div>
</body>
</html>