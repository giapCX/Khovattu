<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý vật tư - Danh mục vật tư</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- DataTables CSS -->
    <link href="https://cdn.datatables.net/1.13.4/css/dataTables.bootstrap5.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <style>
        body { padding-top: 70px; }
        .navbar-brand { font-weight: bold; }
        .thumbnail { width: 50px; height: 50px; object-fit: cover; }
        .action-btn { margin-right: 5px; }
        .filter-group { margin-bottom: 15px; }
    </style>
</head>
<body>
    <!-- Header -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">Quản lý vật tư</a>
            <div class="navbar-nav ms-auto">
                <span class="navbar-text me-3">Xin chào, Admin One (Admin)</span>
                <a class="btn btn-outline-light" href="#">Đăng xuất</a>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="container mt-4">
        <!-- Toolbar -->
        <div class="row filter-group">
            <div class="col-md-4">
                <input type="text" id="searchInput" class="form-control" placeholder="Tìm kiếm vật tư...">
            </div>
            <div class="col-md-2">
                <select id="filterCategory" class="form-select">
                    <option value="">Tất cả danh mục</option>
                    <c:forEach var="cat" items="${categories}">
                        <option value="${cat.categoryId}">${cat.name}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-md-2">
                <select id="filterBrand" class="form-select">
                    <option value="">Tất cả nhãn hiệu</option>
                    <option value="1">Xuân Thành</option>
                    <option value="2">Vanlock</option>
                    <option value="3">DULUX</option>
                    <option value="4">Prime</option>
                    <option value="5">Cadivi</option>
                </select>
            </div>
            <div class="col-md-2">
                <select id="filterSupplier" class="form-select">
                    <option value="">Tất cả nhà cung cấp</option>
                    <option value="1">Minh Hạnh</option>
                    <option value="2">Điện Tr</option>
                    <option value="3">DULUX</option>
                    <option value="4">Prime</option>
                    <option value="5">Hải Âu</option>
                </select>
            </div>
            <div class="col-md-2">
                <button class="btn btn-primary w-100" data-bs-toggle="modal" data-bs-target="#materialModal">Thêm vật tư</button>
            </div>
        </div>

        <!-- Data Table -->
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
                        <td>${mat.category.name}</td>
                        <td>${mat.unit}</td>
                        <td>
                            <c:forEach var="sup" items="${mat.suppliers}">
                                ${sup.name}<c:if test="${!fn:endsWith(mat.suppliers[mat.suppliers.size()-1].name, sup.name)}">, </c:if>
                            </c:forEach>
                        </td>
                        <td>
                            <img src="${mat.imageUrl}" class="thumbnail" alt="Hình ảnh vật tư">
                        </td>
                        <td>
                            <button class="btn btn-sm btn-info action-btn view-btn" data-id="${mat.id}">Xem</button>
                            <button class="btn btn-sm btn-warning action-btn edit-btn" data-id="${mat.id}">Sửa</button>
                            <form action="material" method="post" style="display:inline;">
                                <input type="hidden" name="action" value="delete"/>
                                <input type="hidden" name="id" value="${mat.id}"/>
                                <button type="submit" class="btn btn-sm btn-danger action-btn" onclick="return confirm('Bạn có chắc muốn xóa?')">Xóa</button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <!-- Modal Thêm/Sửa vật tư -->
    <div class="modal fade" id="materialModal" tabindex="-1" aria-labelledby="materialModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="materialModalLabel">Thêm vật tư</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="materialForm">
                        <div class="mb-3">
                            <label for="code" class="form-label">Mã vật tư</label>
                            <input type="text" class="form-control" id="code" required>
                        </div>
                        <div class="mb-3">
                            <label for="name" class="form-label">Tên vật tư</label>
                            <input type="text" class="form-control" id="name" required>
                        </div>
                        <div class="mb-3">
                            <label for="category" class="form-label">Danh mục</label>
                            <select class="form-select" id="category" required>
                                <option value="">Chọn danh mục</option>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.categoryId}">${cat.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="brand" class="form-label">Nhãn hiệu</label>
                            <select class="form-select" id="brand" required>
                                <option value="">Chọn nhãn hiệu</option>
                                <option value="1">Xuân Thành</option>
                                <option value="2">Vanlock</option>
                                <option value="3">DULUX</option>
                                <option value="4">Prime</option>
                                <option value="5">Cadivi</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="unit" class="form-label">Đơn vị</label>
                            <input type="text" class="form-control" id="unit" required>
                        </div>
                        <div class="mb-3">
                            <label for="description" class="form-label">Mô tả</label>
                            <textarea class="form-control" id="description" rows="4"></textarea>
                        </div>
                        <div class="mb-3">
                            <label for="imageUrl" class="form-label">Hình ảnh (URL)</label>
                            <input type="url" class="form-control" id="imageUrl">
                        </div>
                        <div class="mb-3">
                            <label for="suppliers" class="form-label">Nhà cung cấp</label>
                            <select multiple class="form-select" id="suppliers">
                                <option value="1">Minh Hạnh</option>
                                <option value="2">Điện Tr</option>
                                <option value="3">DULUX</option>
                                <option value="4">Prime</option>
                                <option value="5">Hải Âu</option>
                            </select>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button type="button" class="btn btn-primary" id="saveMaterial">Lưu</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Chi tiết vật tư -->
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
                            <img id="detailImage" class="img-fluid" src="" alt="Hình ảnh vật tư">
                        </div>
                        <div class="col-md-8">
                            <p><strong>Mã vật tư:</strong> <span id="detailCode"></span></p>
                            <p><strong>Tên vật tư:</strong> <span id="detailName"></span></p>
                            <p><strong>Danh mục:</strong> <span id="detailCategory"></span></p>
                            <p><strong>Nhãn hiệu:</strong> <span id="detailBrand"></span></p>
                            <p><strong>Đơn vị:</strong> <span id="detailUnit"></span></p>
                            <p><strong>Mô tả:</strong> <span id="detailDescription"></span></p>
                            <p><strong>Nhà cung cấp:</strong> <span id="detailSuppliers"></span></p>
                            <p><strong>Tồn kho:</strong> <span id="detailInventory"></span></p>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    <button type="button" class="btn btn-primary" id="editMaterial">Sửa</button>
                </div>
            </div>
        </div>
    </div>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- DataTables JS -->
    <script src="https://cdn.datatables.net/1.13.4/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.4/js/dataTables.bootstrap5.min.js"></script>
    <script>
        $(document).ready(function () {
            var table = $('#materialTable').DataTable({
                language: { url: '//cdn.datatables.net/plug-ins/1.13.4/i18n/vi.json' }
            });
            // Tìm kiếm
            $('#searchInput').on('keyup', function () {
                table.search(this.value).draw();
            });
            // Lọc theo danh mục, nhãn hiệu, nhà cung cấp
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
    </script>
</body>
</html>