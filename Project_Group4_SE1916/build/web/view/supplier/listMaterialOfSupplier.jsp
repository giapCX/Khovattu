
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>List material of supplier</title>
        <!-- Tailwind CSS -->
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>

        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

        <!-- Liên kết đến file CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_list.css">

    </head>
    <body class="bg-gray-50 min-h-screen font-sans antialiased">

        <%
            String role = (String) session.getAttribute("role");
            if (role == null) {
                response.sendRedirect(request.getContextPath() + "/view/accessDenied.jsp");
                return;
            }
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
            <div class="max-w-6xl mx-auto">
                <div class="flex justify-between items-center mb-6">
                    <div class="flex items-center gap-4">
                        <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                            <i class="fas fa-bars text-2xl"></i>
                        </button>
                        <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Detail Of Supplier : ${supplier.supplierName}</h2>
                    </div>
                </div>

                <!-- Supplier Info Section -->
                <div class="w-full flex justify-center">
                    <div class="w-full max-w-6xl bg-white dark:bg-gray-800 shadow-md rounded-lg p-6 mb-6">
                        <h3 class="text-xl font-bold text-gray-800 dark:text-white mb-4">Supplier Information</h3>
                        <div class="flex flex-col gap-2 text-gray-700 dark:text-gray-300">
                            <div>
                                <span class="font-semibold">Supplier ID:</span> ${supplier.supplierId}
                            </div>
                            <div>
                                <span class="font-semibold">Supplier Name:</span> ${supplier.supplierName}
                            </div>
                            <div>
                                <span class="font-semibold">Supplier Phone:</span> ${supplier.supplierPhone}
                            </div>
                            <div>
                                <span class="font-semibold">Supplier Address:</span> ${supplier.supplierAddress}
                            </div>
                            <div>
                                <span class="font-semibold">Supplier Email:</span> ${supplier.supplierEmail}
                            </div>
                            <div>
                                <span class="font-semibold">Status:</span> 
                                <c:choose>
                                    <c:when test="${supplier.supplierStatus == 'active'}">
                                        <span class="text-green-600 font-medium">Active</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-red-600 font-medium">Inactive</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <c:if test="${role == 'admin' || role == 'direction'}">
                            <div class="mt-4">
                                <a href="EditSupplierServlet?supplierId=${supplierId}" 
                                   class="btn-secondary text-white px-5 py-2 rounded w-fit inline-block flex items-center">
                                    <i class="fas fa-pen mr-2"></i> Edit
                                </a>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
            <div class="w-full flex justify-center">
                <div class="w-full max-w-6xl bg-white dark:bg-gray-800 shadow-md rounded-lg p-6 mb-6">
                    <h3 class="text-xl font-bold text-gray-800 dark:text-white mb-4">List material of supplier</h3>
                    <!-- Search and Filter Form -->
                    <form action="FilterSupplierServlet" method="get" class="mb-6 flex flex-wrap gap-4 items-center">
                        <input type="hidden" name="supplierName" value="${supplierName}" />
                        <input type="hidden" name="supplierId" value="${supplierId}" />
                        <input type="hidden" name="searchCategory" />

                        <!-- Ô tìm kiếm -->
                        <div class="flex-1 min-w-[200px]">
                            <input type="text" name="searchName" value="${param.searchName}" placeholder="Search name of material"
                                   class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                        </div>

                        <!-- Nút search -->
                        <button type="submit" class="btn-primary text-white px-6 py-2 rounded-lg flex items-center">
                            <i class="fas fa-search mr-2"></i> Search
                        </button>

                        <!-- Nút reset -->
                        <a href="FilterSupplierServlet?supplierId=${param.supplierId}&supplierName=${param.supplierName}"
                           onclick="event.preventDefault(); document.querySelector('form').reset(); window.location.href = this.href;"
                           class="bg-yellow-500 text-white px-6 py-2 rounded-lg flex items-center">
                            <i class="fas fa-undo mr-2"></i> Reset form
                        </a>

                        <!-- Dropdown xuống dòng -->
                        <div class="w-full flex items-center gap-2 mt-2">
                            <span class="text-gray-700 dark:text-gray-300">Items per page:</span>
                            <select name="recordsPerPage" onchange="this.form.submit()"
                                    class="border border-gray-300 dark:border-gray-600 rounded-lg py-2 px-4 focus:outline-none focus:ring-2 focus:ring-primary-500 search-input">
                                <option value="5" ${recordsPerPage == '5' ? 'selected' : ''}>5 materials/page</option>
                                <option value="10" ${recordsPerPage == '10' ? 'selected' : ''}>10 materials/page</option>
                                <option value="15" ${recordsPerPage == '15' ? 'selected' : ''}>15 materials/page</option>
                            </select>
                        </div>
                    </form>

                    <!-- Table -->
                    <div class="table-container bg-white dark:bg-gray-800">
                        <div class="overflow-x-auto">
                            <table class="w-full table-auto">
                                <thead>
                                    <tr class="bg-primary-600 text-white">
                                        <th class="p-4 text-left">Category</th>
                                        <th class="p-4 text-left">Code</th>
                                        <th class="p-4 text-left">Material Name</th>
                                        <th class="p-4 text-left">Description</th>
                                        <th class="p-4 text-left">Image</th>
                                        <th class="p-4 text-left">Unit</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty materials}">
                                            <c:forEach var="item" items="${materials}">
                                                <tr class="border-b border-gray-200 dark:border-gray-700">
                                                    <td class="p-4 font-medium">${item.category.name}</td>
                                                    <td class="p-4 font-medium">${item.code}</td>
                                                    <td class="p-4 font-medium">${item.name}</td>
                                                    <td class="p-4 font-medium">${item.description}</td>
                                                    <td class="p-4 font-medium">
                                                        <img src="${item.imageUrl}" alt="${item.imageUrl}" class="w-16 h-16 object-cover" />
                                                    </td>
                                                    <td class="p-4 font-medium">${item.unit}</td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="7" class="p-4 text-center text-gray-500 dark:text-gray-400">
                                                    No materials found
                                                </td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div><br/>

            <!-- Pagination -->
            <div class="pagination flex items-center justify-center space-x-1">
                <!-- Nút trang trước -->
                <c:choose>
                    <c:when test="${currentPage > 1}">
                        <a href="FilterSupplierServlet?page=${currentPage - 1}&recordsPerPage=${param.recordsPerPage}&searchName=${param.searchName}&searchCategory=${param.searchCategory}&supplierId=${supplierId}&supplierName=${supplierName}" class="px-3 py-1 rounded bg-gray-300 hover:bg-gray-400">&lt;</a>
                    </c:when>
                    <c:otherwise>
                        <span class="px-3 py-1 rounded bg-gray-200 text-gray-500 cursor-not-allowed">&lt;</span>
                    </c:otherwise>
                </c:choose>

                <!-- Trang 1 luôn hiện -->
                <c:choose>
                    <c:when test="${currentPage == 1}">
                        <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">1</span>
                    </c:when>
                    <c:otherwise>
                        <a href="FilterSupplierServlet?page=1&recordsPerPage=${param.recordsPerPage}&searchName=${param.searchName}&searchCategory=${param.searchCategory}&supplierId=${supplierId}&supplierName=${supplierName}" class="px-3 py-1 rounded border hover:border-blue-500">1</a>
                    </c:otherwise>
                </c:choose>

                <!-- Dấu ... nếu khoảng cách trang hiện tại > 3 với trang 1 -->
                <c:if test="${currentPage > 4}">
                    <span class="px-3 py-1">...</span>
                </c:if>

                <!-- Hiển thị các trang giữa: từ max(2, currentPage-1) đến min(totalPages-1, currentPage+1) -->
                <c:forEach var="i" begin="${currentPage - 1 > 1 ? currentPage - 1 : 2}" end="${currentPage + 1 < totalPages ? currentPage + 1 : totalPages - 1}">
                    <c:choose>
                        <c:when test="${i == currentPage}">
                            <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">${i}</span>
                        </c:when>
                        <c:otherwise>
                            <a href="FilterSupplierServlet?page=${i}&recordsPerPage=${param.recordsPerPage}&searchName=${param.searchName}&searchCategory=${param.searchCategory}&supplierId=${supplierId}&supplierName=${supplierName}" class="px-3 py-1 rounded border hover:border-blue-500">${i}</a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>

                <!-- Dấu ... nếu khoảng cách trang hiện tại < totalPages - 3 -->
                <c:if test="${currentPage < totalPages - 3}">
                    <span class="px-3 py-1">...</span>
                </c:if>

                <!-- Trang cuối (nếu > 1) -->
                <c:if test="${totalPages > 1}">
                    <c:choose>
                        <c:when test="${currentPage == totalPages}">
                            <span class="px-3 py-1 rounded border border-blue-500 text-blue-500 font-bold">${totalPages}</span>
                        </c:when>
                        <c:otherwise>
                            <a href="FilterSupplierServlet?page=${totalPages}&recordsPerPage=${param.recordsPerPage}&searchName=${param.searchName}&searchCategory=${param.searchCategory}&supplierId=${supplierId}&supplierName=${supplierName}" class="px-3 py-1 rounded border hover:border-blue-500">${totalPages}</a>
                        </c:otherwise>
                    </c:choose>
                </c:if>

                <!-- Nút trang sau -->
                <c:choose>
                    <c:when test="${currentPage < totalPages}">
                        <a href="FilterSupplierServlet?page=${currentPage + 1}&recordsPerPage=${param.recordsPerPage}&searchName=${param.searchName}&searchCategory=${param.searchCategory}&supplierId=${supplierId}&supplierName=${supplierName}" class="px-3 py-1 rounded bg-gray-300 hover:bg-gray-400">&gt;</a>
                    </c:when>
                    <c:otherwise>
                        <span class="px-3 py-1 rounded bg-gray-200 text-gray-500 cursor-not-allowed">&gt;</span>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="mt-6 flex justify-center space-x-4">
            <a href="${pageContext.request.contextPath}/ListSupplierServlet" class="btn-secondary text-white px-6 py-3 rounded-lg">Back to list supplier</a>
            <c:choose>
                <c:when test="${role == 'admin'}">
                    <a href="${pageContext.request.contextPath}/view/admin/adminDashboard.jsp" class="btn-secondary text-white px-6 py-3 rounded-lg">Back to home</a>
                </c:when>
                <c:when test="${role == 'direction'}">
                    <a href="${pageContext.request.contextPath}/view/direction/directionDashboard.jsp" class="btn-secondary text-white px-6 py-3 rounded-lg">Back to home</a>
                </c:when>
                <c:when test="${role == 'warehouse'}">
                    <a href="${pageContext.request.contextPath}/view/warehouse/warehouseDashboard.jsp" class="btn-secondary text-white px-6 py-3 rounded-lg">Back to home</a>
                </c:when>
                <c:when test="${role == 'employee'}">
                    <a href="${pageContext.request.contextPath}/view/employee/employeeDashboard.jsp" class="btn-secondary text-white px-6 py-3 rounded-lg">Back to home</a>
                </c:when>
            </c:choose>
        </div>
    </div>
</main>

<!-- JavaScript -->
<script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
</body>
</html>