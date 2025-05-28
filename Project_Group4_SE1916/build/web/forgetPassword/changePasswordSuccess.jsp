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
            <h1 class="signup-heading">Đổi mật khẩu thành công!</h1>
            <% if (request.getAttribute("mess1") != null) { %>
            <div class="alert alert-danger" role="alert">${mess1}</div>
            <% } %>
            <% if (request.getAttribute("mess2") != null) { %>
            <div class="alert alert-danger" role="alert">${mess2}</div>
            <% } %>
            <%
                
                String role = (String) session.getAttribute("role");
                String redirectUrl = "../login.jsp"; // Default fallback
                if (role != null) {
                    switch (role.toLowerCase()) {
                        case "director":
                            redirectUrl = ".../directionDashboard.jsp";
                            break;
                        case "employee":
                            redirectUrl = ".../employeeDashboard.jsp";
                            break;
                        case "warehouse":
                            redirectUrl = ".../warehouseDashboard.jsp";
                            break;
                    }
                }
            %>
            <a href="<%= redirectUrl%>" class="signup-submit">Về đăng nhập</a>
        </div>
    </body>
</html>