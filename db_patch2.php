<?php
$host = "localhost";
$user = "root";
$pass = "";
$db   = "pocket_library";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Database Connection Failed: " . $conn->connect_error . "\n");
}

$queries = [
    "ALTER TABLE users ADD COLUMN profile_image VARCHAR(255) NULL AFTER phone"
];

foreach ($queries as $q) {
    if ($conn->query($q) === TRUE) {
        echo "Success: $q\n";
    } else {
        echo "Error: " . $conn->error . " ($q)\n";
    }
}

$conn->close();
?>
