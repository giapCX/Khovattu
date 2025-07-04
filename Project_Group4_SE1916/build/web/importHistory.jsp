<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Material Import History</title>

    <!-- Tailwind -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>

    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>

    <!-- Custom styles -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_list.css">

    <style>
        body{background:#f9fafb;color:#1f2937;font-family:'Inter',sans-serif}
        .max-w-6xl{max-width:72rem;margin:0 auto}
        table{width:100%;border-collapse:collapse;background:#fff;border-radius:.5rem;overflow:hidden;box-shadow:0 1px 3px rgb(0 0 0 / .1)}
        thead tr{background:#2563eb;color:#fff}
        th,td{padding:.75rem 1rem;text-align:left;border-bottom:1px solid #e5e7eb}
        tbody tr:hover{background:#f3f4f6}
        .btn{padding:.5rem 1rem;background:#2563eb;color:#fff;border:none;border-radius:.375rem;font-size:.875rem}
        .btn:hover{background:#1d4ed8}
        .btn-back{background:#6b7280}.btn-back:hover{background:#4b5563}
        .pagination{display:flex;justify-content:center;gap:.5rem}
        .pagination a{padding:.5rem .75rem;border:1px solid #d1d5db;border-radius:.375rem;text-decoration:none;color:#2563eb;font-size:.875rem}
        .pagination a:hover{background:#f3f4f6}
        .pagination a.active{background:#2563eb;color:#fff;border-color:#2563eb}
        .filter-form{display:flex;align-items:center;gap:.5rem;flex-wrap:wrap;margin-bottom:1rem}
        .form-control{padding:.5rem;border:1px solid #d1d5db;border-radius:.375rem;font-size:.875rem}
        .form-control:focus{outline:none;border-color:#2563eb;box-shadow:0 0 0 2px rgba(37,99,235,.2)}
    </style>
</head>
<body class="bg-gray-50 min-h-screen antialiased">

<%
    String role = (String) session.getAttribute("role");
%>

<c:choose>
    <c:when test="${role == 'admin'}">
        <jsp:include page="/view/sidebar/sidebarAdmin.jsp"/>
    </c:when>
    <c:when test="${role == 'direction'}">
        <jsp:include page="/view/sidebar/sidebarDirection.jsp"/>
    </c:when>
    <c:when test="${role == 'warehouse'}">
        <jsp:include page="/view/sidebar/sidebarWarehouse.jsp"/>
    </c:when>
    <c:when test="${role == 'employee'}">
        <jsp:include page="/view/sidebar/sidebarEmployee.jsp"/>
    </c:when>
</c:choose>

<main class="flex-1 p-8 lg:ml-72 transition-all duration-300">
    <div class="max-w-6xl mx-auto">
        <div class="flex items-center gap-4 mb-6">
            <button id="toggleSidebarMobile" class="text-gray-700 hover:text-blue-600">
                <i class="fas fa-bars text-2xl"></i>
            </button>
            <h2 class="text-2xl font-bold">Material Import History</h2>
        </div>

        <form method="get" action="importhistory" class="filter-form">
            <input type="date" name="fromDate" value="${fromDate}" class="form-control"/>
            <input type="date" name="toDate"   value="${toDate}"   class="form-control"/>
            <input type="text" name="importer" value="${importer}" placeholder="Importer" class="form-control"/>
            <button type="submit" class="btn">Search</button>
        </form>

        <div class="table-container bg-white">
            <div class="overflow-x-auto">
                <table class="w-full table-auto">
                    <thead>
                        <tr>
                            <th class="p-4">Voucher ID</th>
                            <th class="p-4">Total</th>
                            <th class="p-4">Import Date</th>
                            <th class="p-4">Importer</th>
                            <th class="p-4">Note</th>
                            <th class="p-4">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="item" items="${historyData}">
                            <tr class="border-b border-gray-200">
                                <td class="p-4">${item.voucherId}</td>
                                <td class="p-4">${item.total}</td>
                                <td class="p-4">${item.importDate}</td>
                                <td class="p-4">${item.importerName}</td>
                                <td class="p-4">${item.note}</td>
                                <td class="p-4">
                                    <a href="importhistorydetail?importId=${item.importId}&page=1">View</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="pagination mt-4">
            <c:forEach begin="1" end="${totalPages}" var="i">
                <a href="importhistory?page=${i}&fromDate=${param.fromDate}&toDate=${param.toDate}&importer=${param.importer}"
                   class="${i == currentPage ? 'active' : ''}">${i}</a>
            </c:forEach>
        </div>

        <button onclick="history.back()" class="btn btn-back mt-4">Back</button>
    </div>
</main>

<script>
document.addEventListener('DOMContentLoaded', () => {
    const sidebar  = document.getElementById('sidebar');
    const openBtn  = document.getElementById('toggleSidebarMobile');
    const closeBtn = document.getElementById('toggleSidebar');
    if (openBtn)  openBtn.addEventListener('click', () => sidebar.classList.toggle('-translate-x-full'));
    if (closeBtn) closeBtn.addEventListener('click', () => sidebar.classList.add('-translate-x-full'));
});
</script>
<script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
</body>
</html>
