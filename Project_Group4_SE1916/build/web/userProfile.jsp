<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Profile - Material Management System</title>

    <!-- Tailwind CSS -->
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
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Toastify CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

        body {
            font-family: 'Inter', sans-serif;
            background-color: #f8fafc;
        }

        .card {
            transition: all 0.3s ease;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            border-radius: 1rem;
            border: 1px solid #e5e7eb;
        }

        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
        }

        .btn-primary {
            background: linear-gradient(to right, #3b82f6, #6366f1);
            transition: all 0.3s ease;
        }

        .btn-primary:hover {
            transform: scale(1.05);
            box-shadow: 0 10px 15px -3px rgba(59, 130, 246, 0.3), 0 4px 6px -2px rgba(59, 130, 246, 0.1);
        }

        .btn-secondary {
            background: linear-gradient(to right, #9ca3af, #6b7280);
            transition: all 0.3s ease;
        }

        .btn-secondary:hover {
            transform: scale(1.05);
            box-shadow: 0 10px 15px -3px rgba(107, 114, 128, 0.3), 0 4px 6px -2px rgba(107, 114, 128, 0.1);
        }

        .dark-mode {
            background-color: #1a202c;
            color: #e2e8f0;
        }

        .dark-mode .card {
            background-color: #2d3748;
            color: #e2e8f0;
            border-color: #4a5568;
        }

        .profile-pic {
            width: 120px;
            height: 120px;
            object-fit: cover;
            border: 4px solid #e5e7eb;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        .dark-mode .profile-pic {
            border-color: #4a5568;
        }
    </style>
</head>
<body class="bg-gray-50 min-h-screen font-sans antialiased">
    <!-- Session Check -->
    <c:if test="${empty sessionScope.username}">
        <c:redirect url="login.jsp"/>
    </c:if>

    <!-- Main Content -->
    <main class="flex-1 p-6 md:p-8">
        <div class="max-w-3xl mx-auto card bg-white dark:bg-gray-800 p-6 md:p-8">
            <c:set var="isEditMode" value="${param.edit == 'true'}"/>
            <c:set var="profilePicUrl" value="${empty user.img ? 'https://via.placeholder.com/120' : user.img}"/>

            <div class="flex flex-col items-center mb-6">
                <img id="profilePicPreview" src="${profilePicUrl}" alt="Ảnh đại diện" class="profile-pic rounded-full mb-4">
                <div id="profilePicInput" class="space-y-2 ${isEditMode ? '' : 'hidden'}">
                    <label for="profilePic" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Profile picture</label>
                    <input type="file" id="profilePic" name="profilePic" accept="image/*" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                </div>
                <h2 class="text-2xl font-bold text-gray-800 dark:text-white text-center">User Profile</h2>
            </div>

            <!-- Determine the homepage based on the user's role -->
            <c:set var="homePage" value="${pageContext.request.contextPath}/home.jsp"/>
            <c:choose>
                <c:when test="${user.role.roleName == 'direction'}">
                    <c:set var="homePage" value="${pageContext.request.contextPath}/view/direction/directionDashboard.jsp"/>
                </c:when>
                <c:when test="${user.role.roleName == 'admin'}">
                    <c:set var="homePage" value="${pageContext.request.contextPath}/view/admin/adminDashboard.jsp"/>
                </c:when>
                <c:when test="${user.role.roleName == 'employee'}">
                    <c:set var="homePage" value="${pageContext.request.contextPath}/view/employee/employeeDashboard.jsp"/>
                </c:when>
                <c:when test="${user.role.roleName == 'warehouse'}">
                    <c:set var="homePage" value="${pageContext.request.contextPath}/view/warehouse/warehouseDashboard.jsp"/>
                </c:when>
                <c:otherwise>
                    <c:set var="error" value="Không thể xác định vai trò cho người dùng: ${sessionScope.username}"/>
                </c:otherwise>
            </c:choose>

            <form id="profileForm" action="${pageContext.request.contextPath}/userprofile" method="post" enctype="multipart/form-data" class="space-y-6">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div class="space-y-2">
                        <label for="username" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Username</label>
                        <input type="text" id="username" name="username" value="${user.username}" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-gray-100 dark:bg-gray-700 dark:text-white" readonly>
                    </div>

                    <div class="space-y-2">
                        <label for="fullName" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Full Name*</label>
                        <input type="text" id="fullName" name="fullName" value="${user.fullName != null ? user.fullName : 'Chưa cập nhật'}" 
                               class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" 
                               ${isEditMode ? 'required' : 'readonly'}>
                    </div>

                    <div class="space-y-2">
                        <label for="email" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Email *</label>
                        <input type="email" id="email" name="email" value="${user.email}" 
                               class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" 
                               ${isEditMode ? 'required' : 'readonly'}>
                    </div>

                    <div class="space-y-2">
                        <label for="phone" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Phone number</label>
                        <input type="text" id="phone" name="phone" value="${user.phone}" 
                               class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" 
                               ${isEditMode ? '' : 'readonly'}>
                    </div>

                    <div class="space-y-2 md:col-span-2">
                        <label for="address" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Address *</label>
                        <input type="text" id="address" name="address" value="${user.address}" 
                               class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" 
                               ${isEditMode ? 'required' : 'readonly'}>
                    </div>

                    <div class="space-y-2">
                        <label for="dateOfBirth" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Date of birth</label>
                        <input type="date" id="dateOfBirth" name="dateOfBirth" value="${user.dateOfBirth}" 
                               class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" 
                               ${isEditMode ? '' : 'readonly'}>
                    </div>

                    <div class="space-y-2">
                        <label for="status" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Status</label>
                        <select id="status" name="status" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-gray-100 dark:bg-gray-700 dark:text-white" ${isEditMode ? '' : 'disabled'}>
                            <option value="active" ${user.status == 'active' ? 'selected' : ''}>Active</option>
                            <option value="inactive" ${user.status == 'inactive' ? 'selected' : ''}>Inactive</option>
                        </select>
                    </div>

                    <div class="space-y-2">
                        <label for="role" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Role</label>
                        <input type="text" id="role" name="role" value="${user.role.roleName}" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg bg-gray-100 dark:bg-gray-700 dark:text-white" readonly>
                    </div>
                </div>

                <div class="flex space-x-4">
                    <c:choose>
                        <c:when test="${isEditMode}">
                            <button type="submit" id="saveButton" class="btn-primary text-white px-6 py-3 rounded-lg flex-1">Save</button>
                            <button type="button" id="cancelButton" class="btn-secondary text-white px-6 py-3 rounded-lg flex-1 text-center" onclick="window.location.href='${pageContext.request.contextPath}/userprofile'">Cancel</button>
                        </c:when>
                        <c:otherwise>
                            <button type="button" id="editButton" class="btn-primary text-white px-6 py-3 rounded-lg flex-1" onclick="window.location.href='${pageContext.request.contextPath}/userprofile?edit=true'">Edit</button>
                        </c:otherwise>
                    </c:choose>
                </div>
            </form>

            <div class="mt-6 flex justify-center space-x-4">
                <%
                String role = (String) session.getAttribute("role");
                String redirectUrl = "../login.jsp"; // Default fallback
                if (role != null) {
                    switch (role.toLowerCase()) {
                        case "director":
                            redirectUrl = request.getContextPath() + "/view/direction/directionDashboard.jsp";
                            break;
                        case "admin":
                            redirectUrl = request.getContextPath() + "/view/admin/adminDashboard.jsp";
                            break;
                        case "employee":
                            redirectUrl = request.getContextPath() + "/view/employee/employeeDashboard.jsp";
                            break;
                        case "warehouse":
                            redirectUrl = request.getContextPath() + "/view/warehouse/warehouseDashboard.jsp";
                            break;
                    }
                }
                %>
                <a href="<%= redirectUrl%>" class="text-primary-600 dark:text-primary-400 hover:underline">Return to the Homepage</a>
                <a href="${pageContext.request.contextPath}/logout" class="text-red-500 hover:underline">Logout</a>
            </div>
        </div>
    </main>

    <!-- Toastify JS -->
    <script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
    <script>
        // Show toast notifications for errors or messages
        <c:if test="${not empty error}">
            Toastify({
                text: "${error.replaceAll("\"", "'")}",
                duration: 3000,
                gravity: "top",
                position: "center",
                backgroundColor: "#ef4444",
                stopOnFocus: true
            }).showToast();
        </c:if>
        <c:if test="${not empty message}">
            Toastify({
                text: "${message.replaceAll("\"", "'")}",
                duration: 3000,
                gravity: "top",
                position: "center",
                backgroundColor: "#22c55e",
                stopOnFocus: true
            }).showToast();
        </c:if>

        // Image Preview on File Selection
        const profilePic = document.getElementById('profilePic');
        const profilePicPreview = document.getElementById('profilePicPreview');
        profilePic.addEventListener('change', (event) => {
            const file = event.target.files[0];
            if (file) {
                // Validate file type
                const validTypes = ['image/jpeg', 'image/png', 'image/gif'];
                if (!validTypes.includes(file.type)) {
                    Toastify({
                        text: "Vui lòng chọn file ảnh (JPEG, PNG, GIF)!",
                        duration: 3000,
                        gravity: "top",
                        position: "center",
                        backgroundColor: "#ef4444",
                        stopOnFocus: true
                    }).showToast();
                    profilePic.value = '';
                    return;
                }

                // Validate file size (e.g., max 5MB)
                const maxSize = 5 * 1024 * 1024; // 5MB in bytes
                if (file.size > maxSize) {
                    Toastify({
                        text: "Kích thước ảnh tối đa là 5MB!",
                        duration: 3000,
                        gravity: "top",
                        position: "center",
                        backgroundColor: "#ef4444",
                        stopOnFocus: true
                    }).showToast();
                    profilePic.value = '';
                    return;
                }

                const reader = new FileReader();
                reader.onload = (e) => {
                    profilePicPreview.src = e.target.result;
                };
                reader.readAsDataURL(file);
            }
        });

        // Form Validation on Submit
        const profileForm = document.getElementById('profileForm');
        profileForm.addEventListener('submit', (event) => {
            const requiredFields = [
                { id: 'fullName', label: 'Họ và tên' },
                { id: 'email', label: 'Email' },
                { id: 'address', label: 'Địa chỉ' }
            ];

            for (const field of requiredFields) {
                const input = document.getElementById(field.id);
                const value = input.value;
                if (!value || value.trim() === '') {
                    event.preventDefault();
                    Toastify({
                        text: `Vui lòng nhập ${field.label}!`,
                        duration: 3000,
                        gravity: "top",
                        position: "center",
                        backgroundColor: "#ef4444",
                        stopOnFocus: true
                    }).showToast();
                    input.focus();
                    return;
                }
            }

            // Additional email format validation
            const emailInput = document.getElementById('email');
            const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailPattern.test(emailInput.value)) {
                event.preventDefault();
                Toastify({
                    text: "Vui lòng nhập email hợp lệ!",
                    duration: 3000,
                    gravity: "top",
                    position: "center",
                    backgroundColor: "#ef4444",
                    stopOnFocus: true
                }).showToast();
                emailInput.focus();
                return;
            }
        });

        // Dark Mode Toggle
        const toggleDarkMode = document.createElement('button');
        toggleDarkMode.id = 'toggleDarkMode';
        toggleDarkMode.className = 'bg-gray-100 dark:bg-gray-700 p-2 rounded-full hover:bg-gray-200 dark:hover:bg-gray-600 fixed top-4 right-4 z-50';
        toggleDarkMode.innerHTML = '<i class="fas fa-moon text-gray-700 dark:text-yellow-300 text-xl"></i>';
        document.body.appendChild(toggleDarkMode);

        toggleDarkMode.addEventListener('click', () => {
            document.body.classList.toggle('dark-mode');
            const icon = toggleDarkMode.querySelector('i');
            icon.classList.toggle('fa-moon');
            icon.classList.toggle('fa-sun');
            localStorage.setItem('darkMode', document.body.classList.contains('dark-mode'));
        });

        // Load Dark Mode Preference
        if (localStorage.getItem('darkMode') === 'true') {
            document.body.classList.add('dark-mode');
            toggleDarkMode.querySelector('i').classList.replace('fa-moon', 'fa-sun');
        }
    </script>
</body>
</html>