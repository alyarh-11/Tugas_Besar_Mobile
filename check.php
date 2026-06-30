<?php
$conn = new mysqli('localhost', 'root', '', 'pocket_library');
$res = $conn->query("DESCRIBE books");
while($row = $res->fetch_assoc()) {
    echo $row['Field'] . "\n";
}
?>
