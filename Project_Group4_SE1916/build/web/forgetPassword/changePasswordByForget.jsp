<%-- 
    Document   : changePasswordByForget
    Created on : Jun 1, 2025, 2:49:56 AM
    Author     : ASUS
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="icon" href="../Assets/icon/favicon.png"/>
        <title>Change Password</title>
        <style>
            body {
                background: linear-gradient(135deg, #6B7280, #1F2937);
                min-height: 100vh;
                display: flex;
                justify-content: center;
                align-items: center;
                font-family: 'Inter', sans-serif;
            }
            .signup {
                background: white;
                border-radius: 1rem;
                box-shadow: 0 10px 15px rgba(0, 0, 0, 0.1);
                padding: 2rem;
                width: 100%;
                max-width: 400px;
            }
            .signup-heading {
                font-size: 1.875rem;
                font-weight: 700;
                color: #1F2937;
                text-align: center;
                margin-bottom: 1.5rem;
            }
            .signup-label {
                color: #374151;
                font-size: 0.875rem;
                font-weight: 500;
                margin-bottom: 0.5rem;
                display: block;
            }
            .signup-input {
                width: 100%;
                padding: 0.75rem;
                border: 1px solid #D1D5DB;
                border-radius: 0.5rem;
                font-size: 1rem;
                color: #1F2937;
                transition: border-color 0.2s ease-in-out;
            }
            .signup-input:focus {
                outline: none;
                border-color: #3B82F6;
                box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
            }
            .signup-submit {
                width: 100%;
                padding: 0.75rem;
                margin-top:1.75rem;
                margin-bottom: 0.75rem;
                background: #3B82F6;
                color: white;
                font-weight: 600;
                border-radius: 0.5rem;
                border: none;
                cursor: pointer;
                transition: background 0.3s ease;
            }
            .signup-submit:hover {
                background: #2563EB;
            }
            .alert {
                color: #DC2626;
                font-size: 0.875rem;
                text-align: center;
                margin-bottom: 1rem;
            }
            .signup-cancel:hover {
                color: red;
                text-decoration: underline;
            }
            .relative {
                position: relative;
            }
            .toggle-eye {
                position: absolute;
                right: 0.75rem;
                top: 50%;
                transform: translateY(-50%);
                cursor: pointer;
                color: #9CA3AF;
            }
        </style>
    </head>
    <body>
        <div class="signup">
            <h1 class="signup-heading">Change Password</h1>
            <form action="changePasswordByForget" method="POST" class="signup-form" autocomplete="off">

                <!-- New Password -->
                <label for="password" class="signup-label">New password</label>
                <div class="relative">
                    <input type="password" name="password" id="password" class="signup-input pr-10" required>
                    <i class="fa-solid fa-eye toggle-eye" onclick="togglePassword('password', this)"></i>
                </div>

                <!-- Confirm New Password -->
                <label for="cfpassword" class="signup-label">Re-enter new password</label>
                <div class="relative">
                    <input type="password" name="cfpassword" id="cfpassword" class="signup-input pr-10" required>
                    <i class="fa-solid fa-eye toggle-eye" onclick="togglePassword('cfpassword', this)"></i>
                </div>

                <input class="signup-submit" type="submit" value="OK">
            </form>

            <% if (request.getAttribute("mess1") != null) { %>
            <div class="alert alert-danger" role="alert">${mess1}</div>
            <% } %>
            <% if (request.getAttribute("mess2") != null) { %>
            <div class="alert alert-danger" role="alert">${mess2}</div>
            <% }%>

            <a href="../login.jsp" class="signup-cancel block text-center mt-2">Cancel</a>
        </div>

        <!-- Toggle password visibility -->
        <script>
            function togglePassword(id, icon) {
                const input = document.getElementById(id);
                if (input.type === "password") {
                    input.type = "text";
                    icon.classList.remove("fa-eye");
                    icon.classList.add("fa-eye-slash");
                } else {
                    input.type = "password";
                    icon.classList.remove("fa-eye-slash");
                    icon.classList.add("fa-eye");
                }
            }
        </script>
    </body>
</html>


