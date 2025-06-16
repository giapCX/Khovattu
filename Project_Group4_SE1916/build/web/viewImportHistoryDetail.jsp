<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết phiếu nhập</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light text-dark">
    <div class="container my-5">
        <!-- Tiêu đề -->
        <div class="mb-4 border-bottom pb-2">
            <h2 class="text-primary fw-bold">Chi tiết phiếu nhập</h2>
        </div>

        <!-- Thông tin chung -->
        <div class="row mb-3">
            <div class="col-md-6">
                <strong>Mã phiếu:</strong> ${receipt.voucherId}
            </div>
            <div class="col-md-6">
                <strong>Ngày nhập:</strong> ${receipt.importDate}
            </div>
            <div class="col-md-6">
                <strong>Người nhập:</strong> ${receipt.importerName}
            </div>
            <div class="col-md-6">
                <strong>Tổng tiền:</strong> ${receipt.total} đ
            </div>
            <div class="col-12">
                <strong>Ghi chú:</strong> ${receipt.note}
            </div>
        </div>

        <!-- Bộ lọc -->
        <form method="get" action="importhistorydetail" class="row g-2 mb-4">
            <input type="hidden" name="voucherId" value="${receipt.voucherId}" />
            <div class="col-md-5">
                <input type="text" name="keyword" value="${param.keyword}" class="form-control" placeholder="Tìm tên vật tư..." />
            </div>
            <div class="col-md-4">
                <select name="sort" class="form-select">
                    <option value="">Sắp xếp theo giá</option>
                    <option value="asc" ${param.sort == 'asc' ? 'selected' : ''}>Tăng dần</option>
                    <option value="desc" ${param.sort == 'desc' ? 'selected' : ''}>Giảm dần</option>
                </select>
            </div>
            <div class="col-md-3">
                <button type="submit" class="btn btn-primary w-100">Lọc</button>
            </div>
        </form>

        <!-- Bảng chi tiết vật tư -->
        <h5 class="fw-bold mb-3">Danh sách vật tư nhập</h5>
        <div class="table-responsive">
            <table class="table table-bordered table-hover align-middle">
                <thead class="table-primary">
                    <tr>
                        <th>Mã vật tư</th>
                        <th>Tên vật tư</th>
                        <th>Nhà cung cấp</th>
                        <th>Số lượng</th>
                        <th>Đơn giá</th>
                        <th>Thành tiền</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="detail" items="${details}">
                        <tr>
                            <td>${detail.materialId}</td>
                            <td>${detail.materialName}</td>
                            <td>${detail.supplierName}</td>
                            <td>${detail.quantity}</td>
                            <td>${detail.unitPrice}</td>
                            <td>${detail.totalPrice}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <!-- Phân trang -->
        <nav class="mt-4">
            <ul class="pagination justify-content-center">
                <c:forEach var="i" begin="1" end="${totalPages}">
                    <li class="page-item ${i == currentPage ? 'active' : ''}">
                        <a class="page-link" href="importhistorydetail?voucherId=${receipt.voucherId}&page=${i}&keyword=${param.keyword}&sort=${param.sort}">
                            ${i}
                        </a>
                    </li>
                </c:forEach>
            </ul>
        </nav>
    </div>
</body>
</html>
