<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
        <link rel="icon" href="../Assets/icon/favicon.png"/>
        <title>Change Password Success</title>
        <style>
            body {
                background: linear-gradient(135deg, #8B5CF6, #3B82F6);
                min-height: 100vh;
                display: flex;
                justify-content: center;
                align-items: center;
                font-family: 'Inter', sans-serif;
                overflow: hidden;
            }
            .signup {
                background: white;
                border-radius: 1.5rem;
                box-shadow: 0 15px 30px rgba(0, 0, 0, 0.2);
                padding: 2.5rem;
                width: 100%;
                max-width: 450px;
                text-align: center;
                animation: slideUp 0.5s ease-out;
            }
            @keyframes slideUp {
                from {
                    transform: translateY(50px);
                    opacity: 0;
                }
                to {
                    transform: translateY(0);
                    opacity: 1;
                }
            }
            .signup-heading {
                font-size: 2rem;
                font-weight: 800;
                color: lightgreen;
                margin-bottom: 1rem;
                position: relative;
            }
            .signup-heading::before {
                content: '✅';
                display: block;
                font-size: 3rem;
                margin-bottom: 1rem;
            }
            .alert {
                color: #EF4444;
                font-size: 0.9rem;
                text-align: center;
                margin-bottom: 1rem;
                animation: fadeIn 0.5s ease-in;
            }
            @keyframes fadeIn {
                from {
                    opacity: 0;
                }
                to {
                    opacity: 1;
                }
            }
            .signup-submit {
                display: inline-block;
                width: 100%;
                padding: 0.85rem;
                background: linear-gradient(90deg, #3B82F6, #8B5CF6);
                color: white;
                font-weight: 600;
                border-radius: 0.75rem;
                text-decoration: none;
                text-align: center;
                cursor: pointer;
                transition: transform 0.3s ease, box-shadow 0.3s ease;
            }
            .signup-submit:hover {
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(59, 130, 246, 0.4);
            }
            .signup-submit:active {
                transform: translateY(0);
            }
            .bg {
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: url('https://www.transparenttextures.com/patterns/subtle-white-feathers.png');
                opacity: 0.1;
                z-index: -1;
            }
        </style>
    </head>
    <body>
        <div class="bg"></div>
        <div class="signup">
            <h1 class="signup-heading">Change Password Successful!</h1>
            <% if (request.getAttribute("mess1") != null) { %>
            <div class="alert alert-danger" role="alert">${mess1}</div>
            <% } %>
            <% if (request.getAttribute("mess2") != null) { %>
            <div class="alert alert-danger" role="alert">${mess2}</div>
            <% } %>
            <%

                String role = (String) session.getAttribute("role");
                String redirectUrl = "../login.jsp"; // Default fallback
//                if (role != null) {
//                    switch (role.toLowerCase()) {
//                        case "director":
//                            redirectUrl = request.getContextPath() + "/view/direction/directionDashboard.jsp";
//                            break;
//                        case "employee":
//                            redirectUrl = request.getContextPath() + "/view/employee/employeeDashboard.jsp";
//                            break;
//                        case "warehouse":
//                            redirectUrl = request.getContextPath() + "/view/warehouse/warehouseDashboard.jsp";
//                            break;
//                    }
//                }
            %>
            <a href="<%= redirectUrl%>" class="signup-submit">Back to login</a>
        </div>
    </body>
</html>