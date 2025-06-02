<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý vật tư - Danh mục vật tư</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.datatables.net/1.13.4/css/dataTables.bootstrap5.min.css" rel="stylesheet">
    <style>
        body { padding-top: 70px; }
        .navbar-brand { font-weight: bold; }
        .thumbnail { width: 50px; height: 50px; object-fit: cover; }
        .action-btn { margin-right: 5px; }
        .filter-group { margin-bottom: 15px; }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">Quản lý vật tư</a>
            <div class="navbar-nav ms-auto">
                <span class="navbar-text me-3">Xin chào, Admin One (Admin)</span>
                <a class="btn btn-outline-light" href="#">Đăng xuất</a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <div class="row filter-group">
            <div class="col-md-4">
                <input type="text" id="searchInput" class="form-control" placeholder="Tìm kiếm theo mã vật tư">
            </div>
            <div class="col-md-2">
                <select id="filterCategory" class="form-select">
                    <option value="">Tất cả danh mục</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.name}">${cat.name}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-md-2">
                <select id="filterBrand" class="form-select">
                    <option value="">Tất cả nhãn hiệu</option>
                    <c:forEach var="brand" items="${brands}">
                        <option value="${brand.name}">${brand.name}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-md-2">
                <select id="filterSupplier" class="form-select">
                    <option value="">Tất cả nhà cung cấp</option>
                    <c:forEach var="sup" items="${suppliers}">
                        <option value="${sup.supplierName}">${sup.supplierName}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-md-2">
                <a href="${pageContext.request.contextPath}/AddMaterialController" class="btn btn-primary w-100">Thêm vật tư</a>
            </div>
        </div>

        <table id="materialTable" class="table table-striped">
            <thead>
                <tr>
                    <th>Mã vật tư</th>
                    <th>Tên vật tư</th>
                    <th>Nhãn hiệu</th>
                    <th>Danh mục</th>
                    <th>Đơn vị</th>
                    <th>Nhà cung cấp</th>
                    <th>Hình ảnh</th>
                    <th>Hành động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="mat" items="${materials}">
                    <tr>
                        <td>${mat.code}</td>
                        <td>${mat.name}</td>
                        <td>${mat.brand.name}</td>
                        <td>${mat.brand.category.name}</td>
                        <td>${mat.unit}</td>
                        <td>
                            <c:forEach var="sup" items="${mat.suppliers}" varStatus="status">
                                ${sup.supplierName}<c:if test="${!status.last}">, </c:if>
                            </c:forEach>
                        </td>
                        <td>
                            <img src="${mat.imageUrl}" class="thumbnail" alt="Hình ảnh vật tư">
                        </td>
                        <td>
                            <a href="${pageContext.request.contextPath}/EditMaterialController?id=${mat.materialId}" class="btn btn-sm btn-warning action-btn">Sửa</a>
                            <form action="${pageContext.request.contextPath}/ListMaterialController" method="post" style="display:inline;">
                                <input type="hidden" name="action" value="delete"/>
                                <input type="hidden" name="id" value="${mat.materialId}"/>
                                <button type="submit" class="btn btn-sm btn-danger action-btn" onclick="return confirm('Bạn có chắc muốn xóa?')">Xóa</button>
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
                    <h5 class="modal-title" id="detailModalLabel">Chi tiết vật tư</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-4">
                            <img id="detailImage" class="img-fluid" src="${material.imageUrl}" alt="Hình ảnh vật tư">
                        </div>
                        <div class="col-md-8">
                            <p><strong>Mã vật tư:</strong> <span id="detailCode">${material.code}</span></p>
                            <p><strong>Tên vật tư:</strong> <span id="detailName">${material.name}</span></p>
                            <p><strong>Danh mục:</strong> <span id="detailCategory">${material.brand.category.name}</span></p>
                            <p><strong>Nhãn hiệu:</strong> <span id="detailBrand">${material.brand.name}</span></p>
                            <p><strong>Đơn vị:</strong> <span id="detailUnit">${material.unit}</span></p>
                            <p><strong>Mô tả:</strong> <span id="detailDescription">${material.description}</span></p>
                            <p><strong>Nhà cung cấp:</strong> <span id="detailSuppliers">
                                <c:forEach var="sup" items="${material.suppliers}" varStatus="status">
                                    ${sup.supplierName}<c:if test="${!status.last}">, </c:if>
                                </c:forEach>
                            </span></p>
                            <p><strong>Tồn kho:</strong> <span id="detailInventory">${inventory}</span></p>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    <a href="${pageContext.request.contextPath}/material/edit?id=${material.materialId}" class="btn btn-primary">Sửa</a>
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

            $('#searchInput').on('keyup', function () {
                table.search(this.value).draw();
            });

            $('#filterCategory').on('change', function () {
                table.column(3).search(this.value).draw();
            });

            $('#filterBrand').on('change', function () {
                table.column(2).search(this.value).draw();
            });

            $('#filterSupplier').on('change', function () {
                table.column(5).search(this.value).draw();
            });
        });
        
        // Hiển thị thông báo thành công từ session
            <c:if test="${not empty sessionScope.successMessage}">
                Swal.fire({
                    icon: 'success',
                    title: 'Successful',
                    text: '${sessionScope.successMessage}',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'animated fadeInDown'
                    }
                });
                // Xóa thông báo sau khi hiển thị
                <% session.removeAttribute("successMessage"); %>
            </c:if>
    </script>
</body>
</html>