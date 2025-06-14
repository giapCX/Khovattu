<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Material Management - Material List</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.datatables.net/1.13.4/css/dataTables.bootstrap5.min.css" rel="stylesheet">
    <style>
        body { padding-top: 20px; }
        .thumbnail { width: 50px; height: 50px; object-fit: cover; }
        .action-btn { margin-right: 5px; }
        .filter-group { margin-bottom: 15px; }
        .header-actions { margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="container mt-4">
        <div class="header-actions">
            <a href="${pageContext.request.contextPath}/view/admin/adminDashboard.jsp" class ="btn btn-secondary">Back to Home</a>
            <a href="${pageContext.request.contextPath}/AddMaterialController" class="btn btn-primary">Add Material</a>
        </div>

        <div class="row filter-group">
            <div class="col-md-4">
                <div class="input-group">
                    <input type="text" id="searchInput" class="form-control" placeholder="Search by material code">
                    <button id="searchButton" class="btn btn-primary">Search</button>
                </div>
            </div>
            <div class="col-md-2">
                <select id="filterCategory" class="form-select">
                    <option value="">All categories</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.categoryId}">${cat.name}</option>
                    </c:forEach>
                </select>
            </div>
        </div>

        <table id="materialTable" class="table table-striped">
            <thead>
                <tr>
                    <th>Material Code</th>
                    <th>Category</th>
                    <th>Material Name</th>
                    <th>Unit</th>
                    <th>Image</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="mat" items="${materials}">
                    <tr>
                        <td>${mat.code}</td>
                        <td>${mat.category.name}</td>
                        <td>${mat.name}</td>
                        <td>${mat.unit}</td>
                        <td>
                            <img src="${mat.imageUrl}" class="thumbnail" alt="Material image">
                        </td>
                        <td>
                            <a href="${pageContext.request.contextPath}/EditMaterialController?id=${mat.materialId}" class="btn btn-sm btn-warning action-btn">Edit</a>
                            <form action="${pageContext.request.contextPath}/ListMaterialController" method="post" style="display:inline;">
                                <input type="hidden" name="action" value="delete"/>
                                <input type="hidden" name="id" value="${mat.materialId}"/>
                                <button type="submit" class="btn btn-sm btn-danger action-btn" onclick="return confirm('Are you sure you want to delete?')">Delete</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <div class="modal fade" id="detailModal" tabindex="-1" aria-labelledby="detailModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="detailModalLabel">Material Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-4">
                            <img id="detailImage" class="img-fluid" src="${material.imageUrl}" alt="Material image">
                        </div>
                        <div class="col-md-8">
                            <p><strong>Material Code:</strong> <span id="detailCode">${material.code}</span></p>
                            <p><strong>Material Name:</strong> <span id="detailName">${material.name}</span></p>
                            <p><strong>Category:</strong> <span id="detailCategory">${material.category.name}</span></p>
                            <p><strong>Unit:</strong> <span id="detailUnit">${material.unit}</span></p>
                            <p><strong>Description:</strong> <span id="detailDescription">${material.description}</span></p>
                            <p><strong>Inventory:</strong> <span id="detailInventory">${inventory}</span></p>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <a href="${pageContext.request.contextPath}/material/edit?id=${material.materialId}" class="btn btn-primary">Edit</a>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.4/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.4/js/dataTables.bootstrap5.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        $(document).ready(function () {
            var table = $('#materialTable').DataTable({
                language: { url: '//cdn.datatables.net/plug-ins/1.13.4/i18n/vi.json' }
            });

            $('#searchButton').on('click', function () {
                var searchValue = $('#searchInput').val();
                table.column(0).search(searchValue).draw();
            });

            $('#filterCategory').on('change', function () {
                var selectedCategoryId = $(this).val();
                var categoryName = selectedCategoryId ? getCategoryName(selectedCategoryId) : '';
                if (!selectedCategoryId) {
                    table.columns().search('').draw();
                } else {
                    table.column(1).search(categoryName).draw();
                }
            });

            var categories = [
                <c:forEach var="cat" items="${categories}" varStatus="status">
                    { categoryId: ${cat.categoryId}, name: "${fn:escapeXml(cat.name)}" }<c:if test="${!status.last}">,</c:if>
                </c:forEach>
            ];

            function getCategoryName(categoryId) {
                var cat = categories.find(c => c.categoryId == categoryId);
                return cat ? cat.name : '';
            }

            <c:if test="${not empty sessionScope.successMessage}">
                Swal.fire({
                    icon: 'success',
                    title: 'Success',
                    text: '${sessionScope.successMessage}',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'animated fadeInDown'
                    }
                });
                <% session.removeAttribute("successMessage"); %>
            </c:if>
        });
    </script>
</body>
</html>