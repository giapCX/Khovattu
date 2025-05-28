<%-- 
    Document   : changePassword
    Created on : May 24, 2025, 10:17:31 PM
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
            .signup-already {
                text-align: center;
                margin-top: 1rem;
            }
            .signup-login-link {
                color: #3B82F6;
                font-weight: 500;
                text-decoration: none;
                transition: color 0.2s ease;
            }
            .signup-login-link:hover {
                color: #2563EB;
                text-decoration: underline;
            }
        </style>
    </head>
    <body>
        <div class="signup">
            <h1 class="signup-heading">Change Password</h1>
            <form action="change_password" method="POST" class="signup-form" autocomplete="off">
                <label for="password" class="signup-label">Mật khẩu mới</label>
                <input type="password" name="password" class="signup-input" required>

                <label for="cfpassword" class="signup-label">Nhập lại mật khẩu mới</label>
                <input type="password" name="cfpassword" class="signup-input" required>
               

                <input class="signup-submit" type="submit" value="Xác nhận">
            </form>
            <% if (request.getAttribute("mess1") != null) { %>
            <div class="alert alert-danger" role="alert">${mess1}</div>
            <% } %>
            <% if (request.getAttribute("mess2") != null) { %>
            <div class="alert alert-danger" role="alert">${mess2}</div>
            <% } %>
            <%
                String role = (String) session.getAttribute("role");
                String redirectUrl = "home.jsp"; // Default fallback
                if (role != null) {
                    switch (role.toLowerCase()) {
                        case "director":
                            redirectUrl = "view/direction/directionDashboard.jsp";
                            break;
                        case "employee":
                            redirectUrl = "view/employee/employeeDashboard.jsp";
                            break;
                        case "warehouse":
                            redirectUrl = "view/warehouse/warehouseDashboard.jsp";
                            break;
                    }
                }
            %>
            <a href="<%= redirectUrl%>" class="signup-submit">Hủy</a>
        </div>
    </body>
</html>


