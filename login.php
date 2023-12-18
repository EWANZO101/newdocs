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
            header('Location: customerdocs.html'); // Redirect to the protected page
            exit();
        } else {
            // Handle invalid credentials (redirect back to login page or display an error)
            // ...
        }
    }
?>
<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
    <style>
        body {
            background-color: #222;
            color: #fff;
            font-family: Arial, sans-serif;
        }
        h2 {
            color: #fff;
            text-align: center; /* Center align h2 */
        }
        /* Box styles */
        .message-box {
            border: 2px solid #ccc;
            padding: 10px;
            border-radius: 5px;
            width: 75%; /* Adjusted box width */
            margin: 20px auto;
            font-size: 16px; /* Adjusted font size */
            line-height: 1.5; /* Adjust line height */
        }
        /* Rest of the styles remain unchanged */
        form {
            background-color: #333;
            padding: 20px;
            border-radius: 5px;
            width: 300px;
            margin: 0 auto;
        }
        label {
            display: block;
            margin-bottom: 10px;
            color: #fff;
        }
        input[type="text"],
        input[type="password"] {
            width: calc(100% - 12px);
            padding: 6px;
            margin-bottom: 15px;
            border-radius: 3px;
            border: 1px solid #ccc;
            background-color: #fff;
        }
        input[type="submit"] {
            width: 100%;
            padding: 8px;
            border-radius: 3px;
            border: none;
            background-color: #4CAF50;
            color: white;
            cursor: pointer;
        }
        input[type="submit"]:hover {
            background-color: #45a049;
        }
        /* Footer styles */
        footer {
            text-align: center;
            margin-top: 50px;
            color: #ccc;
            font-size: 17px; /* Adjusted font size */
        }
    </style>
</head>
<body>
    <!-- Message enclosed in a box -->
    <div class="message-box">
        <p>Dear Visitors,</p>
        <p>Please note that our services are currently unavailable due to the holiday season. We will resume operations on the 15th of January. During this time, new client setups may experience delays of more than 24 hours.</p>
        <p>Additionally, we'll be undergoing a move at the beginning of January, resulting in potential service outages. These outages could last a few hours or up to 3 days. Your patience and understanding during this transition period are greatly appreciated.</p>
        <p>Thank you for your understanding, and we apologize for any inconvenience caused.</p>
        <p>Warm regards,<br>Swift Peak Hosting</p>
    </div>

    <!-- Rest of the content remains unchanged -->
    <h2>Developer Login</h2>
    <!-- Your login form -->
    <form action="login.php" method="post">
        <h3 style="text-align: center;">THIS PAGE IS ONLY ACCESSIBLE BY DEVELOPERS</h3>
        <label for="username">Username:</label>
        <input type="text" id="username" name="username" required><br><br>
        <label for="password">Password:</label>
        <input type="password" id="password" name="password" required><br><br>
        <input type="submit" value="Login">
    </form>

    <!-- Footer -->
    <footer>
        &copy; Swift Peak Hosting
    </footer>
</body>
</html>

