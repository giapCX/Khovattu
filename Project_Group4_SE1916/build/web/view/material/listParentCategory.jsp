<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Parent Category List</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.datatables.net/1.13.4/css/dataTables.bootstrap5.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f4f6f9;
            padding-top: 20px;
        }
        .container {
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            padding: 2rem;
        }
        .header-actions .btn {
            border-radius: 8px;
            padding: 10px 20px;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        .header-actions .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }
        .table th, .table td {
            vertical-align: middle;
            font-size: 0.95rem;
        }
        .table th {
            background-color: #bfdbfe;
            color: #1e3a8a;
            font-weight: 600;
        }
        .table tbody tr {
            background-color: #eff6ff;
        }
        .table tbody tr:hover {
            background-color: #dbeafe;
            transition: background-color 0.2s ease;
        }
        .action-btn {
            border-radius: 6px;
            padding: 6px 12px;
            font-size: 0.9rem;
            transition: all 0.3s ease;
        }
        .action-btn:hover {
            transform: translateY(-1px);
        }
        .dataTables_paginate {
            display: flex;
            justify-content: center;
            margin-top: 1rem;
        }
        .dataTables_paginate .paginate_button {
            margin: 0 5px;
            padding: 8px 12px;
            border-radius: 6px;
            background-color: transparent;
            color: #1e3a8a;
            transition: all 0.3s ease;
        }
        .dataTables_paginate .paginate_button:hover {
            background-color: #60a5fa;
            color: white;
        }
        .dataTables_paginate .paginate_button.current {
            background-color: #60a5fa;
            color: white;
            font-weight: 600;
        }
        .status-active {
            color: #28a745;
            font-weight: 500;
        }
        .status-inactive {
            color: #dc3545;
            font-weight: 500;
        }
        .filter-section {
            margin-bottom: 1rem;
            display: flex;
            gap: 1rem;
            align-items: center;
        }
        .search-group {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
    </style>
</head>
<body>
    <div class="container mt-4">
        <div class="header-actions flex justify-between items-center mb-6">
            <a href="${pageContext.request.contextPath}/view/admin/adminDashboard.jsp" class="btn btn-secondary">Back to Home</a>
            <a href="${pageContext.request.contextPath}/AddParentCategoryController" class="btn btn-primary">Add Parent Category</a>
        </div>

        <c:if test="${not empty successMessage}">
            <div class="alert alert-success" role="alert">${successMessage}</div>
        </c:if>

        <div class="filter-section">
            <div class="search-group">
                <input type="text" id="searchName" class="form-control" placeholder="Search by Name Parent Category" style="width: 300px;">
                <button id="searchBtn" class="btn btn-primary">Search</button>
            </div>
            <div>
                <select id="filterStatus" class="form-select" style="width: 150px;">
                    <option value="">All Status</option>
                    <option value="active">Active</option>
                    <option value="inactive">Inactive</option>
                </select>
            </div>
        </div>

        <div class="table-responsive">
            <table id="parentCategoryTable" class="table table-striped" style="width:100%">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Category Name</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="cat" items="${parentCategories}" varStatus="loop">
                        <tr>
                            <td>${loop.index + 1}</td>
                            <td>${cat.name}</td>
                            <td class="${cat.status == 'active' ? 'status-active' : 'status-inactive'}">${cat.status}</td>
                            <td>
                                <a href="${pageContext.request.contextPath}/ListMaterialController?filterParentCategory=${cat.categoryId}" 
                                   class="btn btn-sm btn-info action-btn">View Details</a>
                                <a href="${pageContext.request.contextPath}/EditParentCategoryController?categoryId=${cat.categoryId}" 
                                   class="btn btn-sm btn-warning action-btn">Edit</a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.4/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.4/js/dataTables.bootstrap5.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        $(document).ready(function () {
            var table = $('#parentCategoryTable').DataTable({
                dom: '<"top"lf>rt<"bottom"p><"clear">',
                pagingType: 'full_numbers',
                pageLength: 10,
                lengthMenu: [5, 10, 25, 50],
                order: [[1, 'asc']] // Sắp xếp theo cột tên mặc định
            });

            // Lọc theo trạng thái
            $('#filterStatus').on('change', function () {
                var status = this.value;
                var name = $('#searchName').val();
                table.column(1).search(name).column(2).search(status).draw();
            });

            // Nút Search để áp dụng cả tên và trạng thái
            $('#searchBtn').on('click', function () {
                var name = $('#searchName').val();
                var status = $('#filterStatus').val();
                table.column(1).search(name).column(2).search(status).draw();
            });

            <c:if test="${not empty sessionScope.successMessage}">
                Swal.fire({
                    icon: 'success',
                    title: 'Success',
                    text: '${sessionScope.successMessage}',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: { popup: 'animated fadeInDown' }
                });
                <% session.removeAttribute("successMessage"); %>
            </c:if>
        });
    </script>
</body>
</html>