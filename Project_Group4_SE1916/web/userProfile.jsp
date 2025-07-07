<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>User Profile</title>
        <!-- Font Awesome for Icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
        <!-- Bootstrap CSS -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
        <!-- Toastify CSS -->
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">
        <!-- Tailwind CSS for Sidebar -->
        <script src="https://cdn.tailwindcss.com"></script>
        <script>
            tailwind.config = {
                theme: {
                    extend: {
                        colors: {
                            primary: {
                                50: '#f0f9ff', 100: '#e0f2fe', 200: '#bae6fd', 300: '#7dd3fc',
                                400: '#38bdf8', 500: '#0ea5e9', 600: '#0284c7', 700: '#0369a1',
                                800: '#075985', 900: '#0c4a6e'
                            },
                            secondary: {
                                50: '#f5f3ff', 100: '#ede9fe', 200: '#ddd6fe', 300: '#c4b5fd',
                                400: '#a78bfa', 500: '#8b5cf6', 600: '#7c3aed', 700: '#6d28d9',
                                800: '#5b21b6', 900: '#4c1d95'
                            }
                        },
                        fontFamily: {
                            sans: ['Inter', 'sans-serif']
                        }
                    }
                }
            }
        </script>
        <style>
            /* Bootstrap-based styles for profile content */
            body {
                background-color: #f8f9fa;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
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
                border: 4px solid #007bff;
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
            }
            .form-control:focus {
                border-color: #007bff;
                box-shadow: 0 0 5px rgba(0, 123, 255, 0.3);
            }
            .form-control[readonly] {
                background-color: #e9ecef;
                cursor: not-allowed;
            }
            .btn-primary {
                background-color: #007bff;
                border: none;
                padding: 10px 20px;
                border-radius: 6px;
                transition: background-color 0.3s ease;
            }
            .btn-primary:hover {
                background-color: #0056b3;
            }
            .btn-secondary {
                background-color: #6c757d;
                border: none;
                padding: 10px 20px;
                border-radius: 6px;
                transition: background-color 0.3s ease;
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
            /* Tailwind-based styles for sidebar */
            .sidebar {
                background: linear-gradient(195deg, #1e3a8a, #3b82f6);
                box-shadow: 0 4px 20px rgba(0, 0, 0, 0.14), 0 7px 10px -5px rgba(59, 130, 246, 0.4);
                transition: all 0.3s cubic-bezier(0.645, 0.045, 0.355, 1);
                transform: translateX(-100%);
            }
            .sidebar.active {
                transform: translateX(0);
            }
            main {
                transition: all 0.3s ease;
            }
            .sidebar.active ~ main {
                margin-left: 18rem;
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
    <body>
        <!-- Session Validation -->
        <%
            String username = (String) session.getAttribute("username");
            String role = (String) session.getAttribute("role");
            if (username == null || role == null) {
                response.sendRedirect(request.getContextPath() + "/Login.jsp");
                return;
            }
            // Determine sidebar file based on role
            String sidebarFile;
            switch (role != null ? role.toLowerCase() : "") {
                case "admin":
                    sidebarFile = "/view/sidebar/sidebarAdmin.jsp";
                    break;
                case "direction":
                    sidebarFile = "/view/sidebar/sidebarDirection.jsp";
                    break;
                case "warehouse":
                    sidebarFile = "/view/sidebar/sidebarWarehouse.jsp";
                    break;
                case "employee":
                    sidebarFile = "/view/sidebar/sidebarEmployee.jsp";
                    break;
                default:
                    sidebarFile = "/view/sidebar/sidebarEmployee.jsp"; // Default to employee sidebar
            }
        %>

        <!-- Dynamic Sidebar Inclusion with Error Handling -->
        <c:catch var="includeError">
            <jsp:include page="<%= sidebarFile%>" />
        </c:catch>
        <c:if test="${not empty includeError}">
            <div class="alert alert-danger m-4">
                Error loading sidebar: ${includeError.message}. Please contact the administrator.
            </div>
        </c:if>

        <!-- Main Content -->
        <main class="flex-1 p-8 transition-all duration-300">
            <!-- Header with Sidebar Toggle -->
            <header class="flex items-center mb-8">
                <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600 mr-4">
                    <i class="fas fa-bars text-2xl"></i>
                </button>
                <h1 class="text-3xl font-bold text-gray-800">User Profile</h1>
            </header>

            <!-- Profile Content -->
            <div class="container ${param.edit == 'true' ? 'edit-mode' : ''}">
                <div class="profile-header">
                    <c:if test="${not empty user.image}">
                        <img src="${pageContext.request.contextPath}/${user.image}" alt="Profile Picture" class="profile-pic">
                    </c:if>
                    <c:if test="${empty user.image}">
                        <img src="${pageContext.request.contextPath}/images/default-profile.png" alt="Default Profile Picture" class="profile-pic">
                    </c:if>
                </div>

                <!-- Read-only View -->
                <div class="info-section">
                    <div class="info-group">
                        <label>Username:</label>
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
                        <label>Phone Number:</label>
                        <span class="info-value">${user.phone}</span>
                    </div>
                    <div class="info-group">
                        <label>Address:</label>
                        <span class="info-value">${user.address}</span>
                    </div>
                    <div class="info-group">
                        <label>Date of Birth:</label>
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
                        <span class="info-value">${not empty user.image ? user.image : 'Default'}</span>
                    </div>
                    <div class="button-group mt-3">
                        <a href="${pageContext.request.contextPath}/userprofile?edit=true" class="btn btn-primary btn-edit">Edit</a>
                        <%
                            String backUrl = request.getContextPath() + "/Login.jsp"; // Default to Login.jsp
                            if (role != null) {
                                switch (role.toLowerCase()) {
                                    case "admin":
                                        backUrl = request.getContextPath() + "/view/admin/adminDashboard.jsp";
                                        break;
                                    case "direction":
                                        backUrl = request.getContextPath() + "/view/direction/directionDashboard.jsp";
                                        break;
                                    case "warehouse":
                                        backUrl = request.getContextPath() + "/view/warehouse/warehouseDashboard.jsp";
                                        break;
                                    case "employee":
                                        backUrl = request.getContextPath() + "/view/employee/employeeDashboard.jsp";
                                        break;
                                }
                            }
                        %>
                        <a href="<%= backUrl%>" class="btn btn-secondary btn-back">
                            <i class="fas fa-arrow-left me-2"></i>Back
                        </a>
                    </div>
                </div>

                <!-- Editable Form -->
                <form action="${pageContext.request.contextPath}/userprofile" method="post" enctype="multipart/form-data" class="form-section">
                    <div class="form-group">
                        <label for="username">Username</label>
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
                        <label for="dateOfBirth">Date of Birth</label>
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
                        <input type="file" class="form-control" id="profilePic" name="profilePic" accept="image/*">
                    </div>
                    <div class="button-group mt-3">
                        <button type="submit" class="btn btn-primary btn-update">Update Profile</button>
                        <a href="${pageContext.request.contextPath}/userprofile" class="btn btn-secondary btn-cancel">Cancel</a>
                    </div>
                </form>
            </div>
        </main>

        <!-- Toastify JS -->
        <script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
        <script>
            // Sidebar Toggle
            const sidebar = document.getElementById('sidebar');
            const toggleSidebar = document.getElementById('toggleSidebar');
            const toggleSidebarMobile = document.getElementById('toggleSidebarMobile');

            function toggleSidebarVisibility() {
                if (sidebar) {
                    sidebar.classList.toggle('active');
                    sidebar.classList.toggle('hidden');
                }
            }

            if (toggleSidebar && toggleSidebarMobile) {
                toggleSidebar.addEventListener('click', toggleSidebarVisibility);
                toggleSidebarMobile.addEventListener('click', toggleSidebarVisibility);
            }

            // Submenu Toggle
            document.addEventListener('DOMContentLoaded', () => {
                const toggles = document.querySelectorAll('.toggle-submenu');
                toggles.forEach(toggle => {
                    toggle.addEventListener('click', () => {
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
            });

            // Initialize sidebar as hidden
            if (sidebar) {
                sidebar.classList.add('hidden');
            }

            // Toast Notifications
            <c:if test="${not empty message}">
            Toastify({
            text: "${message}",
                duration: 3000,
                gravity: "top",
                position: "right",
                backgroundColor: "#28a745"
            }).showToast();
            </c:if>
            <c:if test="${not empty error}">
            Toastify({
            text: "${error}",
                duration: 3000,
                gravity: "top",
                position: "right",
                backgroundColor: "#dc3545"
            }).showToast();
            </c:if>
        </script>
    </body>
</html>