<?php
$host = "localhost";
$user = "root";
$pass = "";
$db   = "pocket_library";

$koneksi = mysqli_connect($host, $user, $pass, $db);

if (!$koneksi) {
    echo "Koneksi Database Gagal: " . mysqli_connect_error() . "\n";
    exit();
}

echo "--- TABLES ---\n";
$q = mysqli_query($koneksi, 'SHOW TABLES');
while($r = mysqli_fetch_row($q)) {
    echo $r[0]."\n";
}

echo "\n--- USERS SCHEMA ---\n";
$q = mysqli_query($koneksi, 'DESCRIBE users');
while($r = mysqli_fetch_assoc($q)) {
    print_r($r);
}

echo "\n--- USERS ROWS ---\n";
$q = mysqli_query($koneksi, 'SELECT * FROM users');
while($r = mysqli_fetch_assoc($q)) {
    print_r($r);
}
?>
