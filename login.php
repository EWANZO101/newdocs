<?php
include 'config.php'; // Include configuration and authentication logic

// Redirect to dashboard if already logged in
if (isset($_SESSION['username'])) {
    header("Location: dashboard.php");
    exit();
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    if (isset($_POST['username']) && isset($_POST['password'])) {
        $username = $_POST['username'];
        $password = $_POST['password'];

        foreach ($users as $user) {
            if ($username === $user['username'] && $password === $user['password']) {
                $_SESSION['username'] = $username;
                $_SESSION['role'] = $user['role'];
                header("Location: dashboard.php"); // Redirect to dashboard upon successful login
                exit();
            }
        }
        $error = "Invalid username or password. Please try again.";
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login</title>
    <!-- Add your CSS styles -->
</head>
<body>
    <div class="login-container">
        <form class="login-form" method="post" action="">
            <h2>Login</h2>
            <?php if(isset($error)) { ?>
                <p class="error"><?php echo $error; ?></p>
            <?php } ?>
            <div class="input-group">
                <label for="username">Username:</label>
                <input type="text" id="username" name="username" required>
            </div>
            <div class="input-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
            </div>
            <button type="submit">Login</button>
        </form>
    </div>
</body>
</html>
