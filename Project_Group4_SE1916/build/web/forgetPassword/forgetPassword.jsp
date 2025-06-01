<%-- 
    Document   : forgetPassword
    Created on : May 24, 2025, 10:19:02 PM
    Author     : ASUS
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="../Assets/css/styleLogin.css"/>
        <link rel="icon" href="../Assets/icon/favicon.png"/>
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet">
        <title>Forget Password</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
                font-family: 'Poppins', sans-serif;
            }

            body {
                display: flex;
                justify-content: center;
                align-items: center;
                min-height: 100vh;
                background: linear-gradient(135deg, #6e8efb, #a777e3);
                padding: 20px;
            }

            .login {
                background: white;
                padding: 40px 30px;
                border-radius: 15px;
                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
                width: 100%;
                max-width: 400px;
                transition: transform 0.3s ease;
            }

            .login:hover {
                transform: translateY(-5px);
            }

            .login-heading {
                text-align: center;
                font-size: 1.8rem;
                color: #333;
                margin-bottom: 20px;
                font-weight: 600;
            }

            .alert-danger {
                background-color: #ffe6e6;
                color: #d32f2f;
                padding: 10px;
                border-radius: 8px;
                text-align: center;
                margin-bottom: 20px;
                font-size: 0.9rem;
            }

            .login-label {
                color: #555;
                font-size: 0.9rem;
                margin-bottom: 8px;
                display: block;
                font-weight: 500;
            }

            .login-input {
                width: 100%;
                padding: 12px;
                margin-bottom: 15px;
                border: 1px solid #ddd;
                border-radius: 8px;
                font-size: 1rem;
                outline: none;
                transition: border-color 0.3s ease, box-shadow 0.3s ease;
            }

            .login-input:focus {
                border-color: #6e8efb;
                box-shadow: 0 0 8px rgba(110, 142, 251, 0.3);
            }

            .login-submit {
                width: 100%;
                padding: 12px;
                background: #6e8efb;
                border: none;
                border-radius: 8px;
                color: white;
                font-size: 1rem;
                font-weight: 500;
                cursor: pointer;
                transition: background 0.3s ease, transform 0.2s ease;
            }

            .login-submit:hover {
                background: #5a78e0;
                transform: translateY(-2px);
            }

            .login-submit:active {
                transform: translateY(0);
            }

            .login-already {
                text-align: center;
                margin-top: 20px;
                font-size: 0.9rem;
                color: #555;
            }

            .login-signup-link {
                color: #6e8efb;
                text-decoration: none;
                font-weight: 500;
            }

            .login-signup-link:hover {
                text-decoration: underline;
            }

            #loading {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.5);
                z-index: 10000;
                justify-content: center;
                align-items: center;
            }

            .loader {
                border: 4px solid #f3f3f3;
                border-top: 4px solid #6e8efb;
                border-radius: 50%;
                width: 50px;
                height: 50px;
                animation: spin 1s linear infinite;
            }

            @keyframes spin {
                0% {
                    transform: rotate(0deg);
                }
                100% {
                    transform: rotate(360deg);
                }
            }

            @media (max-width: 480px) {
                .login {
                    padding: 20px;
                }

                .login-heading {
                    font-size: 1.5rem;
                }

                .login-input, .login-submit {
                    font-size: 0.9rem;
                }
            }
        </style>
    </head>
    <body>
        <div id="loading">
            <div class="loader"></div>
        </div>
        <div class="login">
            <h1 class="login-heading">Reset Password</h1>
            <div class="alert alert-danger" role="alert">
                ${mess}
            </div>
            <form id="myForm" action="./forget_password" method="POST" class="login-form" autocomplete="off">
                <label for="username" class="login-label">Username</label>
                <input type="text" name="username" class="login-input" placeholder="VD: abc" required>

                <label for="Email" class="login-label">Email</label>
                <input type="email" name="Email" class="login-input" placeholder="VD: abc@gmail.com" required>

                <input class="login-submit" type="submit" value="Lấy lại mật khẩu">
            </form>
            <p class="login-already">
                <a href="../login.jsp" class="login-signup-link">Back to login</a>
            </p>
        </div>
        <script>
            const loading = document.getElementById("loading");
            const form = document.getElementById("myForm");

            form.addEventListener("submit", function () {
                loading.style.display = "flex";
            });
        </script>
    </body>
</html>
