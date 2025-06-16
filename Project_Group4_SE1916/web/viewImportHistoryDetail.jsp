<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết phiếu nhập</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f9fafb;
            color: #1f2937;
        }
        .container {
            max-width: 900px;
            margin: 30px auto;
            background-color: #fff;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        h2 {
            color: #2563eb;
            margin-bottom: 20px;
        }
        .info p {
            margin: 5px 0;
        }
        form {
            margin-top: 20px;
            display: flex;
            gap: 10px;
        }
        input, select {
            padding: 6px 10px;
            font-size: 14px;
        }
        button {
            padding: 6px 12px;
            background-color: #2563eb;
            color: white;
            border: none;
            cursor: pointer;
            border-radius: 4px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        thead {
            background-color: #2563eb;
            color: white;
        }
        th, td {
            padding: 10px;
            border: 1px solid #e5e7eb;
            text-align: left;
        }
        tbody tr:hover {
            background-color: #f3f4f6;
        }
        .pagination {
            margin-top: 20px;
            text-align: center;
        }
        .pagination a {
            display: inline-block;
            margin: 0 5px;
            padding: 6px 10px;
            background: #eee;
            color: #333;
            border-radius: 4px;
            text-decoration: none;
        }
        .pagination a.active {
            background: #2563eb;
            color: white;
            font-weight: bold;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>Chi tiết phiếu nhập</h2>

    <!-- Thông tin chung -->
    <div class="info">
        <p><strong>Mã phiếu:</strong> ${receipt.voucherId}</p>
        <p><strong>Người nhập:</strong> ${receipt.importerName}</p>
        <p><strong>Nhà cung cấp:</strong> ${receipt.supplierName}</p>
        <p><strong>Ngày nhập:</strong> ${receipt.importDate}</p>
        <p><strong>Ghi chú:</strong> ${receipt.note}</p>
        <p><strong>Tổng tiền:</strong> ${receipt.total} đ</p>
    </div>

    <!-- Bộ lọc tìm kiếm + sắp xếp -->
    <form method="get" action="importhistorydetail">
        <input type="hidden" name="voucherId" value="${receipt.voucherId}" />
        <input type="text" name="keyword" value="${param.keyword}" placeholder="Tìm tên vật tư..." />
        <select name="sort">
            <option value="">Sắp xếp theo giá</option>
            <option value="asc" ${param.sort == 'asc' ? 'selected' : ''}>Tăng dần</option>
            <option value="desc" ${param.sort == 'desc' ? 'selected' : ''}>Giảm dần</option>
        </select>
        <button type="submit">Lọc</button>
    </form>

    <!-- Chi tiết vật tư -->
    <h3>Danh sách vật tư nhập</h3>
    <table>
        <thead>
            <tr>
                <th>Mã vật tư</th>
                <th>Tên vật tư</th>
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
                    <td>${detail.quantity}</td>
                    <td>${detail.unitPrice}</td>
                    <td>${detail.totalPrice}</td>
                </tr>
            </c:forEach>
        </tbody>
    </table>

    <!-- Phân trang -->
    <div class="pagination">
        <c:forEach var="i" begin="1" end="${totalPages}">
            <a href="importhistorydetail?voucherId=${receipt.voucherId}&page=${i}&keyword=${param.keyword}&sort=${param.sort}"
               class="${i == currentPage ? 'active' : ''}">${i}</a>
        </c:forEach>
    </div>
</div>
</body>
</html>
