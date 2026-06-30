<?php
$conn = new mysqli('localhost', 'root', '', 'pocket_library');
$res = $conn->query("SHOW TABLES");
while($row = $res->fetch_array()) {
    echo $row[0] . "\n";
}
?>
