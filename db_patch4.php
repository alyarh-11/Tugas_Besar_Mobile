<?php
$host = "localhost";
$user = "root";
$pass = "";
$db = "pocket_library";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Tambah kolom book_url ke tabel books
$sql = "ALTER TABLE books ADD COLUMN book_url VARCHAR(255) DEFAULT NULL AFTER cover_url";

if ($conn->query($sql) === TRUE) {
    echo "Column book_url added successfully\n";
} else {
    echo "Error adding column: " . $conn->error . "\n";
}

$conn->close();
?>
