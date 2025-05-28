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
    <title>Login - Inventory Management</title>

    <!-- Bootstrap 5 CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f1f3f5;
        }

        .login-container {
            max-width: 400px;
            margin: 80px auto;
            background-color: #fff;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
        }

        .login-title {
            text-align: center;
            margin-bottom: 25px;
            font-weight: bold;
        }

        .btn-login {
            width: 100%;
        }

        .form-control {
            border-radius: 0.5rem;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <h4 class="login-title">Login to the System</h4>

        <form action="login" method="post">
            <div class="mb-3">
                <label for="username" class="form-label">Username</label>
                <input type="text" class="form-control" id="username" name="username" required autofocus>
            </div>

            <div class="mb-3">
                <label for="password" class="form-label">Password</label>
                <input type="password" class="form-control" id="password" name="password" required>
            </div>

            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-danger" role="alert">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>

            <button type="submit" class="btn btn-primary btn-login">Login</button>
        </form>

        <!-- Thêm nút Forget Password -->
        <div class="mt-3 text-center">
            <a href="forgetPassword/forgetPassword.jsp" class="btn btn-link">Forget Password</a>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
