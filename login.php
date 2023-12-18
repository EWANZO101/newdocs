<?php
    session_start();
    
    // Check login credentials and set developer_logged_in session variable upon successful login
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $username = $_POST['username']; // Retrieve username from the form
        $password = $_POST['password']; // Retrieve password from the form
        
        // Your authentication logic here
        // For demonstration, a simple check is used (replace this with your authentication logic)
        if ($username === 'swiftadmin' && $password === 'swiftdev6532') {
            $_SESSION['developer_logged_in'] = true; // Set session variable upon successful login
            header('customerdocs.html'); // Redirect to the protected page
            exit();
        } else {
            // Handle invalid credentials (redirect back to login page or display an error)
            // ...
        }
    }
?>
