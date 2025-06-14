<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Add supplier</title>
        <!-- Tailwind CSS -->
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>

        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_add_edit.css">
    </head>
    <body class="bg-gray-50 min-h-screen font-sans antialiased">

        <%
            String role = (String) session.getAttribute("role");
        %>
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
            <div class="max-w-md mx-auto card bg-white dark:bg-gray-800 p-6">
                <div class="flex items-center gap-4 mb-6">
                    <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                        <i class="fas fa-bars text-2xl"></i>
                    </button>
                    <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Add new supplier</h2>
                </div>

                <form action="AddSupplierServlet" method="post" class="space-y-4">
                    <div class="space-y-2">
                        <label for="supplierName" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Name</label>
                        <input type="text" id="supplierName" name="supplierName" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white"  >
                    </div>

                    <div class="space-y-2">
                        <label for="supplierPhone" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Phone number</label>
                        <input type="text" id="supplierPhone" name="supplierPhone" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white"  >
                    </div>

                    <div class="space-y-2">
                        <label for="supplierAddress" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Address</label>
                        <input type="text" id="supplierAddress" name="supplierAddress" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white"  >
                    </div>
                    <div class="space-y-2">
                        <label for="supplierEmail" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Email</label>
                        <input type="email" id="supplierEmail" name="supplierEmail" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white"  >
                    </div>
                    <div class="space-y-2">
                        <label for="supplierStatus" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Status</label>
                        <select id="supplierStatus" name="supplierStatus" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                            <option value="active">Active</option>
                            <option value="inactive">Inactive</option>
                        </select>
                    </div>
                    <button type="submit" class="btn-primary text-white px-6 py-3 rounded-lg w-full flex items-center justify-center">
                        <i class="fas fa-plus-circle mr-2"></i> Add 
                    </button>
                </form>
                <c:if test="${not empty errorMessage}">
                    <div class="mb-4 p-3 rounded
                         ${errorMessage == 'Add supplier successful!' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}">
                        ${errorMessage}
                    </div>
                </c:if>

                <div class="mt-4 flex justify-center">
                    <a href="${pageContext.request.contextPath}/ListSupplierServlet" class="btn-secondary text-white px-6 py-3 rounded-lg">Back to list supplier</a>
                </div>
            </div>
        </main>

        <!--JavaScript -->
        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
        <script>
            // Client-side validation
            const form = document.querySelector('form');
            form.addEventListener('submit', (e) => {
                const email = document.getElementById('supplierEmail').value.trim();
                const phone = document.getElementById('supplierPhone').value.trim();
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                const phoneRegex = /^\d{10}$/;

                if (!emailRegex.test(email)) {
                    e.preventDefault();
                    alert('Please re-enter the correct email format.');
                    return;
                }

                if (!phoneRegex.test(phone)) {
                    e.preventDefault();
                    alert('Phone number must have 10 number. Please re-enter the correct phone number format.');
                    return;
                }
            });
        </script>
    </body>
</html>