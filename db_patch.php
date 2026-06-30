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
    "ALTER TABLE users ADD COLUMN full_name VARCHAR(100) NULL AFTER email",
    "ALTER TABLE users ADD COLUMN phone VARCHAR(20) NULL AFTER full_name",
    "ALTER TABLE users ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
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
