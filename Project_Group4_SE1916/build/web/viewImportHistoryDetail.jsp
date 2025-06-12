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
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        table thead {
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
</div>
</body>
</html>
