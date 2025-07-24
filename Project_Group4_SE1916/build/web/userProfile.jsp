<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông tin cá nhân - Hệ thống Quản lý Vật tư</title>
    <!-- Font Awesome for Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>
    <!-- Toastify CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">
    <!-- Style CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_list.css">
    <style>
        /* Profile content styles */
        body {
            background-color: #f8f9fa;
            font-family: 'Inter', sans-serif;
            color: #333;
        }
        .container {
            max-width: 750px;
            margin: 40px auto;
            padding: 25px;
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
        }
        .profile-header {
            text-align: center;
            margin-bottom: 25px;
        }
        .profile-pic {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            object-fit: cover;
            border: 4px solid #3b82f6;
            margin-bottom: 15px;
            transition: transform 0.3s ease;
        }
        .profile-pic:hover {
            transform: scale(1.05);
        }
        .info-group {
            margin-bottom: 20px;
        }
        .info-group label {
            font-weight: 600;
            color: #495057;
            margin-right: 15px;
            min-width: 120px;
            display: inline-block;
        }
        .info-value {
            color: #212529;
            font-size: 1.1em;
        }
        .form-group {
            margin-bottom: 20px;
            display: none;
        }
        .form-group label {
            font-weight: 600;
            color: #495057;
        }
        .form-control {
            border-radius: 6px;
            border: 1px solid #ced4da;
            padding: 8px 12px;
        }
        .form-control:focus {
            border-color: #3b82f6;
            box-shadow: 0 0 5px rgba(59, 130, 246, 0.3);
        }
        .form-control[readonly] {
            background-color: #e9ecef;
            cursor: not-allowed;
        }
        .btn-primary {
            background-color: #3b82f6;
            border: none;
            padding: 10px 20px;
            border-radius: 6px;
            transition: background-color 0.3s ease;
            color: white;
        }
        .btn-primary:hover {
            background-color: #1d4ed8;
        }
        .btn-secondary {
            background-color: #6c757d;
            border: none;
            padding: 10px 20px;
            border-radius: 6px;
            transition: background-color 0.3s ease;
            color: white;
        }
        .btn-secondary:hover {
            background-color: #5a6268;
        }
        .edit-mode .info-group {
            display: none;
        }
        .edit-mode .form-group {
            display: block;
        }
        .edit-mode .btn-edit, .edit-mode .btn-back {
            display: none;
        }
        .edit-mode .btn-update, .edit-mode .btn-cancel {
            display: inline-block;
        }
        .btn-edit, .btn-back {
            margin-right: 10px;
        }
        .btn-update, .btn-cancel {
            display: none;
            margin-right: 10px;
        }
        /* Sidebar styles */
        .sidebar {
            width: 18rem;
            background: linear-gradient(to bottom, #1e40af, #3b82f6);
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.14);
            transition: transform 0.3s cubic-bezier(0.645, 0.045, 0.355, 1);
            transform: translateX(-100%);
            position: fixed;
            top: 0;
            bottom: 0;
            left: 0;
            z-index: 50;
        }
        .sidebar.active {
            transform: translateX(0);
        }
        .nav-item {
            transition: all 0.2s ease;
            border-radius: 0.5rem;
        }
        .nav-item:hover {
            background: linear-gradient(to right, #3b82f6, #8b5cf6);
            transform: translateX(5px) scale(1.02);
        }
        .nav-item.active {
            background-color: rgba(255, 255, 255, 0.2);
            font-weight: 600;
        }
        /* Responsive Adjustments */
        @media (max-width: 768px) {
            .sidebar {
                width: 100%;
                max-width: 280px;
                z-index: 50;
            }
            .sidebar.active ~ main {
                margin-left: 0;
            }
        }
        @media (max-width: 576px) {
            .container {
                margin: 20px;
                padding: 15px;
            }
            .profile-pic {
                width: 120px;
                height: 120px;
            }
            .info-group label {
                min-width: 100px;
            }
        }
    </style>
</head>
<body class="bg-gray-50 min-h-screen font-sans antialiased">
    <!-- Session Validation -->
    <%
        String username = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("role");
        if (username == null || role == null) {
            response.sendRedirect(request.getContextPath() + "/view/login.jsp");
            return;
        }
    %>

    <div class="flex">
        <!-- Sidebar -->
        <c:choose>
            <c:when test="${role == 'admin'}">
                <jsp:include page="/view/sidebar/sidebarAdmin.jsp" />
            </c:when>
            <c:when test="${role == 'direction'}">
                <jsp:include page="/view/sidebar/sidebarDirection.jsp" />
            </c:when>
            <c:when test="${role == 'warehouse'}">
                <jsp:include page="/view/sidebar/sidebarWarehouse.jsp" />
            </c:when>
            <c:when test="${role == 'employee'}">
                <jsp:include page="/view/sidebar/sidebarEmployee.jsp" />
            </c:when>
        </c:choose>

        <!-- Main Content -->
        <main class="flex-1 p-8 transition-all duration-300">
            <!-- Header with Sidebar Toggle -->
            <header class="flex items-center mb-8">
                <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600 mr-4">
                    <i class="fas fa-bars text-2xl"></i>
                </button>
                <h1 class="text-3xl font-bold text-gray-800 dark:text-white">My Information</h1>
            </header>

            <!-- Profile Content -->
            <div class="container ${param.edit == 'true' ? 'edit-mode' : ''}">
                <div class="profile-header">
                    <c:if test="${not empty user.image}">
                        <img src="${pageContext.request.contextPath}/${user.image}" alt="Ảnh đại diện" class="profile-pic">
                    </c:if>
                    <c:if test="${empty user.image}">
                        <img src="${pageContext.request.contextPath}/images/default-profile.png" alt="Ảnh đại diện mặc định" class="profile-pic">
                    </c:if>
                </div>

                <!-- Read-only View -->
                <div class="info-section">
                    <div class="info-group">
                        <label>User Name:</label>
                        <span class="info-value">${user.username}</span>
                    </div>
                    <div class="info-group">
                        <label>Full Name:</label>
                        <span class="info-value">${user.fullName}</span>
                    </div>
                    <div class="info-group">
                        <label>Email:</label>
                        <span class="info-value">${user.email}</span>
                    </div>
                    <div class="info-group">
                        <label>Phone number:</label>
                        <span class="info-value">${user.phone}</span>
                    </div>
                    <div class="info-group">
                        <label>Address:</label>
                        <span class="info-value">${user.address}</span>
                    </div>
                    <div class="info-group">
                        <label>Date of birth:</label>
                        <span class="info-value">${user.dateOfBirth}</span>
                    </div>
                    <div class="info-group">
                        <label>Status:</label>
                        <span class="info-value">${user.status}</span>
                    </div>
                    <div class="info-group">
                        <label>Role:</label>
                        <span class="info-value">${role}</span>
                    </div>
                    <div class="info-group">
                        <label>Profile Picture:</label>
                        <span class="info-value">${not empty user.image ? user.image : 'Mặc định'}</span>
                    </div>
                    <div class="button-group mt-3">
                        <a href="${pageContext.request.contextPath}/userprofile?edit=true" class="btn btn-primary btn-edit">Edit</a>
                        <%
                            String backUrl = request.getContextPath() + "/view/login.jsp";
                            if (role != null) {
                                switch (role.toLowerCase()) {
                                    case "admin":
                                        backUrl = request.getContextPath() + "/AdminDashboard";
                                        break;
                                    case "direction":
                                        backUrl = request.getContextPath() + "/DirectionDashboard";
                                        break;
                                    case "warehouse":
                                        backUrl = request.getContextPath() + "/WarehouseDashboard";
                                        break;
                                    case "employee":
                                        backUrl = request.getContextPath() + "/EmployeeDashboard";
                                        break;
                                }
                            }
                        %>
                        <a href="<%= backUrl%>" class="btn btn-secondary btn-back">
                            <i class="fas fa-arrow-left me-2"></i>Back to Dashboard
                        </a>
                    </div>
                </div>

                <!-- Editable Form -->
                <form action="${pageContext.request.contextPath}/userprofile" method="post" enctype="multipart/form-data" class="form-section">
                    <div class="form-group">
                        <label for="username">User Name</label>
                        <input type="text" class="form-control" id="username" name="username" value="${user.username}" readonly>
                    </div>
                    <div class="form-group">
                        <label for="fullName">Full Name</label>
                        <input type="text" class="form-control" id="fullName" name="fullName" value="${user.fullName}">
                    </div>
                    <div class="form-group">
                        <label for="email">Email</label>
                        <input type="email" class="form-control" id="email" name="email" value="${user.email}">
                    </div>
                    <div class="form-group">
                        <label for="phone">Phone Number</label>
                        <input type="text" class="form-control" id="phone" name="phone" value="${user.phone}">
                    </div>
                    <div class="form-group">
                        <label for="address">Address</label>
                        <input type="text" class="form-control" id="address" name="address" value="${user.address}">
                    </div>
                    <div class="form-group">
                        <label for="dateOfBirth">Birth of Date</label>
                        <input type="date" class="form-control" id="dateOfBirth" name="dateOfBirth" value="${user.dateOfBirth}">
                    </div>
                    <div class="form-group">
                        <label for="status">Status</label>
                        <input type="text" class="form-control" id="status" name="status" value="${user.status}" readonly>
                    </div>
                    <div class="form-group">
                        <label for="role">Role</label>
                        <input type="text" class="form-control" id="role" value="${role}" readonly>
                    </div>
                    <div class="form-group">
                        <label for="profilePic">Profile Picture</label>
                        <div class="input-group">
                            <input type="text" class="form-control" id="currentImage" name="currentImage" value="${not empty user.image ? user.image : 'Mặc định'}" readonly>
                            <input type="file" class="form-control" id="profilePic" name="profilePic" accept="image/*">
                        </div>
                    </div>
                    <div class="button-group mt-3">
                        <button type="submit" class="btn btn-primary btn-update">Update Profile</button>
                        <a href="${pageContext.request.contextPath}/userprofile" class="btn btn-secondary btn-cancel">Cancel</a>
                    </div>
                </form>
            </div>
        </main>
    </div>

    <!-- JavaScript -->
    <script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const toggleButton = document.getElementById('toggleSidebarMobile');
            const closeButton = document.getElementById('toggleSidebar');
            const sidebar = document.querySelector('.sidebar');

            // Toggle sidebar visibility
            if (toggleButton && sidebar) {
                toggleButton.addEventListener('click', () => {
                    sidebar.classList.toggle('active');
                });
            }
            if (closeButton && sidebar) {
                closeButton.addEventListener('click', () => {
                    sidebar.classList.toggle('active');
                });
            }

            // Close sidebar when clicking outside on mobile
            document.addEventListener('click', (event) => {
                if (window.innerWidth <= 768 && sidebar.classList.contains('active') && 
                    !sidebar.contains(event.target) && !toggleButton.contains(event.target)) {
                    sidebar.classList.remove('active');
                }
            });

            // Submenu Toggle
            const toggles = document.querySelectorAll('.toggle-submenu');
            toggles.forEach(toggle => {
                toggle.addEventListener('click', (event) => {
                    event.stopPropagation();
                    const submenu = toggle.parentElement.querySelector('.submenu');
                    if (submenu) {
                        submenu.classList.toggle('hidden');
                        const icon = toggle.querySelector('.fa-chevron-down');
                        if (icon) {
                            icon.classList.toggle('rotate-180');
                        }
                    }
                });
            });

            // Toast Notifications
            <c:if test="${not empty message}">
            Toastify({
                text: "${message}",
                duration: 3000,
                gravity: "top",
                position: "right",
                backgroundColor: "#28a745",
                stopOnFocus: true,
                className: "rounded-lg shadow-lg",
                style: { borderRadius: "0.5rem" }
            }).showToast();
            </c:if>
            <c:if test="${not empty error}">
            Toastify({
                text: "${error}",
                duration: 3000,
                gravity: "top",
                position: "right",
                backgroundColor: "#dc3545",
                stopOnFocus: true,
                className: "rounded-lg shadow-lg",
                style: { borderRadius: "0.5rem" }
            }).showToast();
            </c:if>
        });
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/sidebar_darkmode.js"></script>
</body>
</html>