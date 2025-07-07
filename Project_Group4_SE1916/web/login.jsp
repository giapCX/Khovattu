<%-- 
    Document   : Login
    Created on : 27 May 2025, 12:51:54 am
    Author     : Giap
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login - Material Management System</title>

    <!-- Bootstrap 5 CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome for icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #6b48ff, #00d2ff);
            height: 100vh;
            margin: 0;
            overflow: hidden;
            display: flex;
            justify-content: center;
            align-items: center;
            animation: gradientBG 10s ease infinite;
        }

        @keyframes gradientBG {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }

        .login-wrapper {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 100%;
            max-width: 1200px;
            height: 70vh;
            margin: 0 auto;
            flex-direction: row;
        }

        .login-container {
            flex: 1;
            max-width: 450px;
            padding: 40px;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px 0 0 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            backdrop-filter: blur(10px);
            text-align: center;
            transition: transform 0.3s ease;
            height: 100%;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .login-container:hover {
            transform: scale(1.02);
        }

        .image-container {
            flex: 1;
            height: 100%;
            overflow: hidden;
            border-radius: 0 15px 15px 0;
        }

        .image-container img {
            width: 100%;
            height: 100%;
            object-fit: fill;
            opacity: 0.8;
        }

        .login-title {
            font-size: 2.8rem; /* Larger and more elegant size */
            font-weight: 700;
            margin-bottom: 30px;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            background: linear-gradient(90deg, #ffffff, #00d2ff); /* Elegant white to cyan gradient */
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
            text-shadow: 1px 1px 3px rgba(107, 72, 255, 0.3); /* Subtle shadow for depth */
            position: relative;
            animation: slideFade 3s ease-in-out infinite; /* Smooth sliding animation */
        }

        @keyframes slideFade {
            0% { transform: translateX(0); opacity: 0.9; }
            50% { transform: translateX(5px); opacity: 1; }
            100% { transform: translateX(0); opacity: 0.9; }
        }

        .login-title::after {
            content: '';
            position: absolute;
            bottom: -5px;
            left: 0;
            width: 0;
            height: 2px;
            background: linear-gradient(90deg, #6b48ff, #00d2ff);
            transition: width 0.3s ease;
        }

        .login-title:hover::after {
            width: 100%;
        }

        .form-label {
            font-weight: 500;
            color: #444;
        }

        .form-control {
            border-radius: 10px;
            border: 1px solid #ced4da;
            padding: 12px 45px 12px 15px;
            font-size: 1rem;
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
            position: relative;
        }

        .form-control:focus {
            border-color: #6b48ff;
            box-shadow: 0 0 8px rgba(107, 72, 255, 0.4);
            outline: none;
        }

        .btn-login {
            width: 100%;
            padding: 12px;
            font-size: 1.1rem;
            font-weight: 600;
            background: linear-gradient(90deg, #6b48ff, #00d2ff);
            border: none;
            border-radius: 10px;
            color: #fff;
            transition: background 0.3s ease, transform 0.2s ease;
        }

        .btn-login:hover {
            background: linear-gradient(90deg, #5a3de5, #00b5e2);
            transform: translateY(-2px);
        }

        .btn-login:active {
            transform: translateY(0);
        }

        .alert-danger {
            border-radius: 10px;
            font-size: 0.9rem;
            text-align: left;
            padding: 10px 15px;
        }

        .forget-password {
            color: #6b48ff;
            text-decoration: none;
            font-weight: 500;
            transition: color 0.3s ease;
        }

        .forget-password:hover {
            color: #5a3de5;
            text-decoration: underline;
        }

        @keyframes float {
            0% { transform: translateY(0px); }
            50% { transform: translateY(-20px); }
            100% { transform: translateY(0px); }
        }

        .particle {
            position: absolute;
            width: 10px;
            height: 10px;
            background: rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            animation: float 6s infinite;
        }

        .particle:nth-child(1) { top: 10%; left: 20%; animation-delay: 0s; }
        .particle:nth-child(2) { top: 30%; left: 70%; animation-delay: 2s; }
        .particle:nth-child(3) { top: 60%; left: 40%; animation-delay: 4s; }

        /* Enhanced password toggle styles */
        .password-container {
            position: relative;
            margin-bottom: 1rem;
        }

        .password-toggle {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            background: linear-gradient(90deg, #6b48ff, #00d2ff);
            border: none;
            border-radius: 50%;
            width: 30px;
            height: 30px;
            cursor: pointer;
            color: #fff;
            font-size: 1.2rem;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: transform 0.3s ease, background 0.3s ease;
        }

        .password-toggle:hover {
            background: linear-gradient(90deg, #5a3de5, #00b5e2);
            transform: translateY(-50%) scale(1.1);
        }

        .password-toggle i {
            margin: 0;
        }
    </style>
</head>
<body>
    <!-- Background particles -->
    <div class="particle"></div>
    <div class="particle"></div>
    <div class="particle"></div>

    <div class="login-wrapper">
        <!-- Login Form -->
        <div class="login-container">
            <h4 class="login-title">Login to Material Management System</h4>
            <form action="login" method="post">
                <div class="mb-3">
                    <label for="username" class="form-label"><i class="fas fa-user"></i> Username</label>
                    <input type="text" class="form-control" id="username" name="username" required autofocus>
                </div>

                <div class="mb-3 password-container">
                    <label for="password" class="form-label"><i class="fas fa-lock"></i> Password</label>
                    <input type="password" class="form-control" id="password" name="password" required>
                    <button type="button" class="password-toggle" onclick="togglePassword()">
                        <i class="fas fa-eye-slash" id="toggleIcon"></i>
                    </button>
                </div>

                <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger" role="alert">
                        <%= request.getAttribute("error") %>
                    </div>
                <% } %>

                <button type="submit" class="btn btn-login mt-4"><i class="fas fa-sign-in-alt"></i> Login</button>
            </form>

            <div class="mt-3 text-center">
                <a href="forgetPassword/forgetPassword.jsp" class="forget-password">Forget Password?</a>
            </div>
        </div>

        <!-- Image Container -->
        <div class="image-container">
            <img src="<%=request.getContextPath()%>/resources/videos/vat_tu_xay_dung.png" alt="Login Background">
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function togglePassword() {
            const passwordField = document.getElementById("password");
            const toggleIcon = document.getElementById("toggleIcon");
            if (passwordField.type === "password") {
                passwordField.type = "text";
                toggleIcon.classList.remove("fa-eye-slash");
                toggleIcon.classList.add("fa-eye");
            } else {
                passwordField.type = "password";
                toggleIcon.classList.remove("fa-eye");
                toggleIcon.classList.add("fa-eye-slash");
            }
        }
    </script>
</body>
</html>