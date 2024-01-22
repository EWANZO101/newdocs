<!-- register.php -->
<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Retrieve user input
    $username = $_POST['username'];
    $password = $_POST['password'];

    // Generate a unique database name for each user
    $dbName = 'user_db_' . strtolower($username);

    // Connect to MySQL server (assuming localhost, modify as needed)
    $mysqli = new mysqli('90.247.138.228', 'userreg', '33&wZxh%sNk', 'user reg', 3306);

    // Check connection
    if ($mysqli->connect_error) {
        die('Connection failed: ' . $mysqli->connect_error);
    }

    // Create user table with limited privileges
    $createUserTableSQL = "CREATE TABLE IF NOT EXISTS `$dbName`.`user_table` (
                            `id` INT AUTO_INCREMENT PRIMARY KEY,
                            `data` TEXT
                          )";
    $mysqli->query($createUserTableSQL);

    // Grant specific privileges for the user on their database
    $grantPrivilegesSQL = "GRANT SELECT, INSERT, UPDATE, DELETE ON `$dbName`.* TO '$username'@'localhost'";
    $mysqli->query($grantPrivilegesSQL);

    // Store user information in a main users table (for simplicity)
    $insertUserSQL = "INSERT INTO `users` (`username`, `password`, `database_name`) VALUES ('$username', '$password', '$dbName')";
    $mysqli->query($insertUserSQL);

    // Close connection
    $mysqli->close();

    echo 'User registered successfully!';
} else {
    header('Location: index.html');
    exit();
}
?>
