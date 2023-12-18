<?php
session_start();

// Database connection details
$servername = "90.247.138.228";
$username = "swiftdev";
$password = "swiftdev6532";
$dbname = "www.";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

function createUser($username, $password, $role) {
    global $conn;
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);

    $stmt = $conn->prepare("INSERT INTO users (username, password, role) VALUES (?, ?, ?)");
    $stmt->bind_param("sss", $username, $hashedPassword, $role);

    if ($stmt->execute()) {
        return true;
    } else {
        return false;
    }
}

function getUserByUsername($username) {
    global $conn;

    $stmt = $conn->prepare("SELECT * FROM users WHERE username = ?");
    $stmt->bind_param("s", $username);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        return $result->fetch_assoc();
    } else {
        return null;
    }
}

function authenticateUser($username, $password) {
    $user = getUserByUsername($username);

    if ($user && password_verify($password, $user['password'])) {
        // Passwords match, user is authenticated
        return $user;
    } else {
        // Passwords do not match, authentication fails
        return null;
    }
}

// Example usage:
// createUser('admin', 'adminpassword', 'admin');
// $authenticatedUser = authenticateUser('admin', 'adminpassword');
// var_dump($authenticatedUser);

$conn->close();
?>
