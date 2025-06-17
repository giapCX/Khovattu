<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head>
    <title>In phiếu nhập vật tư</title>
    <style>
        body { font-family: Arial; background-color: #fff; color: #000; }
        .container { width: 80%; margin: auto; padding: 20px; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
        th { background-color: #eee; }
        .btns { margin-top: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <h2>PHIẾU NHẬP KHO</h2>
        <p><strong>Mã phiếu:</strong> ${receipt.voucherId}</p>
        <p><strong>Ngày nhập:</strong> ${receipt.importDate}</p>
        <p><strong>Người nhập:</strong> ${receipt.importerName}</p>
        <p><strong>Nhà cung cấp:</strong> ${receipt.supplierName}</p>
        <p><strong>Ghi chú:</strong> ${receipt.note}</p>

        <table>
            <thead>
                <tr>
                    <th>STT</th>
                    <th>Mã vật tư</th>
                    <th>Tên vật tư</th>
                    <th>Đơn vị</th>
                    <th>Số lượng</th>
                    <th>Đơn giá</th>
                    <th>Thành tiền</th>
                    <th>Tình trạng</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="item" items="${details}" varStatus="loop">
                    <tr>
                        <td>${loop.index + 1}</td>
                        <td>${item.materialCode}</td>
                        <td>${item.materialName}</td>
                        <td>${item.unit}</td>
                        <td>${item.quantity}</td>
                        <td>${item.pricePerUnit}</td>
                        <td>${item.total}</td>
                        <td>${item.materialCondition}</td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>

        <p style="text-align: right; font-weight: bold;">Tổng tiền: ${receipt.total}</p>

        <div class="btns">
            <form action="exportReceiptFile" method="post" style="display:inline;">
                <input type="hidden" name="importId" value="${receipt.voucherId}" />
                <button type="submit">Xuất file</button>
            </form>

            <form action="importhistory" method="get" style="display:inline;">
                <button type="submit">Quay lại</button>
            </form>
        </div>
    </div>
</body>
</html>
