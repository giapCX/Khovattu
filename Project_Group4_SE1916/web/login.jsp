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

        .video-container {
            flex: 1;
            height: 100%;
            overflow: hidden;
            border-radius: 0 15px 15px 0;
        }

        .video-container video {
            width: 100%;
            height: 100%;
            object-fit: fill; /* Thay cover bằng fill để full màn hình */
            opacity: 0.8; /* Giảm độ sáng để nổi bật form */
        }

        .login-title {
            color: #333;
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 30px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .form-label {
            font-weight: 500;
            color: #444;
        }

        .form-control {
            border-radius: 10px;
            border: 1px solid #ced4da;
            padding: 12px 15px;
            font-size: 1rem;
            transition: border-color 0.3s ease;
        }

        .form-control:focus {
            border-color: #6b48ff;
            box-shadow: 0 0 5px rgba(107, 72, 255, 0.5);
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
            <h4 class="login-title">Login to Inventory System</h4>
            <form action="login" method="post">
                <div class="mb-3">
                    <label for="username" class="form-label"><i class="fas fa-user"></i> Username</label>
                    <input type="text" class="form-control" id="username" name="username" required autofocus>
                </div>

                <div class="mb-3">
                    <label for="password" class="form-label"><i class="fas fa-lock"></i> Password</label>
                    <input type="password" class="form-control" id="password" name="password" required>
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

        <!-- Video Container -->
        <div class="video-container">
            <video autoplay loop muted playsinline>
                <source src="<%=request.getContextPath()%>/resources/videos/login_background.mp4" type="video/mp4">
                <p>Trình duyệt của bạn không hỗ trợ video hoặc tệp không tồn tại.</p>
            </video>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>