<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Chỉnh sửa Nhà Cung Cấp - Hệ thống Quản lý Vật tư</title>
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
                background: linear-gradient(to right, #6b7280, #9ca3af);
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
        </style>
    </head>
    <body class="bg-gray-50 min-h-screen font-sans antialiased">
        <!-- Main Content -->
        <main class="flex-1 p-8">
            <div class="max-w-md mx-auto card bg-white dark:bg-gray-800 p-6">
                <h2 class="text-2xl font-bold text-gray-800 dark:text-white mb-6 text-center">Chỉnh sửa Nhà cung cấp</h2>

                <form action="EditSupplierServlet" method="post" class="space-y-4">
                    <input type="hidden" name="supplierId" value="${supplier.supplierId}" />

                    <div class="space-y-2">
                        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Tên nhà cung cấp</label>
                        <input type="text" name="supplierName" value="${supplier.supplierName}" 
                               class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg dark:bg-gray-700 dark:text-white" required />
                    </div>

                    <div class="space-y-2">
                        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Số điện thoại</label>
                        <input type="text" name="supplierPhone" value="${supplier.supplierPhone}" 
                               class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg dark:bg-gray-700 dark:text-white" required />
                    </div>

                    <div class="space-y-2">
                        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Địa chỉ</label>
                        <input type="text" name="supplierAddress" value="${supplier.supplierAddress}" 
                               class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg dark:bg-gray-700 dark:text-white" required />
                    </div>

                    <div class="space-y-2">
                        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Email</label>
                        <input type="email" name="supplierEmail" value="${supplier.supplierEmail}" 
                               class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg dark:bg-gray-700 dark:text-white" required />
                    </div>

                    <div class="space-y-2">
                        <label for="status" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Trạng thái</label>
                        <select id="status" name="supplierStatus" 
                                class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                            <option value="active" ${supplier.supplierStatus == 'active' ? 'selected' : ''}>Active</option>
                            <option value="inactive" ${supplier.supplierStatus == 'inactive' ? 'selected' : ''}>Inactive</option>
                        </select>
                    </div>

                    <button type="submit" class="btn-primary text-white px-6 py-3 rounded-lg w-full">Cập nhật</button>
                </form>
                <c:if test="${not empty errorMessage}">
                    <div class="mb-4 p-3 rounded
                         ${errorMessage == 'Cập nhật nhà cung cấp thành công!' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}">
                        ${errorMessage}
                    </div>
                </c:if>


                <div class="mt-4 flex justify-center">
                    <a href="${pageContext.request.contextPath}/FilterSupplierServlet" class="btn-secondary text-white px-6 py-3 rounded-lg">Quay lại Danh sách</a>
                </div>
            </div>
        </main>

        <!-- JavaScript for Dark Mode -->
        <script>
            // Dark Mode Toggle
            const toggleDarkMode = document.createElement('button');
            toggleDarkMode.id = 'toggleDarkMode';
            toggleDarkMode.className = 'bg-gray-200 dark:bg-gray-700 p-2 rounded-full hover:bg-gray-300 dark:hover:bg-gray-600 fixed top-4 right-4 z-50';
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