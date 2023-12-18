<?php
include 'config.php'; // Include configuration and authentication logic

if (!isset($_SESSION['username'])) {
    header("Location: login.php"); // Redirect to login if not authenticated
    exit();
}

// Check user role for access control
if ($_SESSION['role'] !== 'admin') {
    // For non-admin users, restrict access to certain pages
    $restrictedPages = ['teams', 'tnc', 'urls']; // Pages restricted for non-admin users

    // Get the requested page from the URL
    $currentPage = basename($_SERVER['PHP_SELF'], '.php');

    if (in_array($currentPage, $restrictedPages)) {
        header("Location: unauthorized.php");
        exit();
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Dashboard</title>
    <!-- Add your CSS styles -->
</head>
<body>
    <h1>Welcome to Dashboard, <?php echo $_SESSION['username']; ?></h1>
    <!-- Dashboard content -->
    <ul>
        <li><a href="customerdocs.html" class="menu-btn">Customer Docs</a></li>
        <li><a href="about.html" class="menu-btn">About</a></li>
        <li><a href="services.html" class="menu-btn">Services</a></li>
        <li><a href="coming_soon.html" class="menu-btn">Staff Docs</a></li>
        <?php if ($_SESSION['role'] === 'admin') { ?>
            <li><a href="#teams" class="menu-btn">#Teams</a></li>
            <li><a href="tnc.html" class="menu-btn">T&C</a></li>
            <li><a href="urls.html" class="menu-btn">Links</a></li>
        <?php } ?>
        <!-- Add logout link -->
        <li><a href="logout.php" class="menu-btn">Logout</a></li>
    </ul>
</body>
</html>
