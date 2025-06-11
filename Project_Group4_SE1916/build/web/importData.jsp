<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Phiếu Nhập Kho</title>
    <!-- Thêm CSS và JS nếu cần -->
</head>
<body>
    <h1>Phiếu Nhập Kho</h1>

    <div>
        <h2>Thông tin phiếu nhập</h2>
        <form action="import_data" method="post">
            <table>
                <tr>
                    <td>Mã phiếu nhập *</td>
                    <td><input type="text" name="voucher_id" value="${today}" required placeholder="Vui lòng nhập mã phiếu nhập."></td>
                </tr>
                <tr>
                    <td>Ngày nhập *</td>
                    <td><input type="date" name="import_date" value="${today}" required placeholder="Vui lòng chọn ngày nhập."></td>
                </tr>
                <tr>
                    <td>Người lập phiếu</td>
                    <td>${sessionScope.userFullName}</td>
                </tr>
                <tr>
                    <td>Nhà cung cấp *</td>
                    <td>
                        <select name="supplier_id" class="form-control" required onchange="toggleNewSupplier(this)">
                            <option value="">-- Chọn nhà cung cấp --</option>
                            <c:forEach var="supplier" items="${suppliers}">
                                <option value="${supplier.supplierId}">${supplier.supplierName}</option>
                            </c:forEach>
                            <option value="new">Thêm nhà cung cấp mới</option>
                        </c:forEach>
                        </select>
                        <div id="newSupplierFields" style="display:none;">
                            <input type="text" name="new_supplier_name" placeholder="Tên nhà cung cấp" required>
                            <input type="text" name="new_supplier_phone" placeholder="Số điện thoại">
                            <input type="text" name="new_supplier_address" placeholder="Địa chỉ">
                            <input type="email" name="new_supplier_email" placeholder="Email">
                            <button type="button" onclick="addSupplier()">Thêm</button>
                        </div>
                        <c:if test="${empty suppliers}">
                            <p style="color: red;">Không tìm thấy nhà cung cấp. Vui lòng thêm nhà cung cấp mới.</p>
                        </c:if>
                        <p style="color: red;">Vui lòng chọn hoặc thêm nhà cung cấp.</p>
                    </td>
                </tr>
                <tr>
                    <td>Ghi chú</td>
                    <td><textarea name="note">${param.note}</textarea></td>
                </tr>
            </table>
        </div>

        <div>
            <h2>Danh sách hàng nhập</h2>
            <table id="importDetailsTable">
                <thead>
                    <tr>
                        <th>STT</th>
                        <th>Tên hàng</th>
                        <th>Đơn vị</th>
                        <th>Số lượng</th>
                        <th>Đơn giá</th>
                        <th>Thành tiền</th>
                        <th>Trạng thái</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody id="importDetailsBody">
                    <tr>
                        <td>1</td>
                        <td>
                            <select name="material_id[]" class="form-control" required>
                                <option value="">-- Chọn tên hàng --</option>
                                <c:forEach var="material" items="${materials}">
                                    <option value="${material.materialId}">${material.name}</option>
                                </c:forEach>
                            </select>
                        </td>
                        <td>
                            <select name="unit[]" class="form-control" required>
                                <option value="">-- Chọn đơn vị --</option>
                                <c:forEach var="unit" items="${units}">
                                    <option value="${unit}">${unit}</option>
                                </c:forEach>
                            </select>
                        </td>
                        <td><input type="number" name="quantity[]" value="0.00" step="0.01" required></td>
                        <td><input type="number" name="price_per_unit[]" value="0.00" step="0.01" required></td>
                        <td>0.00</td>
                        <td>
                            <select name="material_condition[]" class="form-control" required>
                                <option value="new">Mới</option>
                                <option value="used">Cũ</option>
                                <option value="damaged">Hỏng hóc</option>
                            </select>
                        </td>
                        <td><button type="button" onclick="deleteRow(this)">Xóa</button></td>
                    </tr>
                </tbody>
            </table>
            <button type="button" onclick="addRow()">+ Thêm hàng</button>
        </div>

        <div>
            <h2>Tổng kết</h2>
            <table>
                <tr><td>Tổng mặt hàng: <span id="totalItems">1</span></td></tr>
                <tr><td>Tổng số lượng: <span id="totalQuantity">0.00</span></td></tr>
                <tr><td>Tổng tiền hàng: <span id="totalAmount">0.00</span></td></tr>
            </table>
        </div>

        <div>
            <h2>Nhập từ file CSV</h2>
            <input type="file" name="csvFile" accept=".csv">
            <button type="button">Tải mẫu CSV</button>
        </div>

        <div>
            <button type="submit">Lưu phiếu nhập</button>
            <button type="button">In phiếu nhập</button>
            <button type="button">Nhập phiếu mới</button>
            <button type="button">Quay lại danh sách</button>
        </div>

        <p style="color: green;">${message}</p>
        <p style="color: red;">${error}</p>
    </form>

    <script>
        function toggleNewSupplier(select) {
            var newSupplierFields = document.getElementById('newSupplierFields');
            if (select.value === 'new') {
                newSupplierFields.style.display = 'block';
            } else {
                newSupplierFields.style.display = 'none';
            }
        }

        function addRow() {
            var table = document.getElementById("importDetailsBody");
            var row = table.insertRow();
            var stt = table.rows.length;
            row.innerHTML = `
                <td>${stt}</td>
                <td><select name="material_id[]" class="form-control" required><option value="">-- Chọn tên hàng --</option><c:forEach var="material" items="${materials}"><option value="${material.materialId}">${material.name}</option></c:forEach></select></td>
                <td><select name="unit[]" class="form-control" required><option value="">-- Chọn đơn vị --</option><c:forEach var="unit" items="${units}"><option value="${unit}">${unit}</option></c:forEach></select></td>
                <td><input type="number" name="quantity[]" value="0.00" step="0.01" required></td>
                <td><input type="number" name="price_per_unit[]" value="0.00" step="0.01" required></td>
                <td>0.00</td>
                <td><select name="material_condition[]" class="form-control" required><option value="new">Mới</option><option value="used">Cũ</option><option value="damaged">Hỏng hóc</option></select></td>
                <td><button type="button" onclick="deleteRow(this)">Xóa</button></td>
            `;
            updateTotals();
        }

        function deleteRow(button) {
            var row = button.parentNode.parentNode;
            row.parentNode.removeChild(row);
            updateRowNumbers();
            updateTotals();
        }

        function updateRowNumbers() {
            var rows = document.getElementById("importDetailsBody").rows;
            for (var i = 0; i < rows.length; i++) {
                rows[i].cells[0].innerHTML = i + 1;
            }
            document.getElementById("totalItems").innerText = rows.length;
        }

        function updateTotals() {
            var rows = document.getElementById("importDetailsBody").rows;
            var totalQuantity = 0;
            var totalAmount = 0;

            for (var i = 0; i < rows.length; i++) {
                var quantity = parseFloat(rows[i].cells[3].getElementsByTagName("input")[0].value) || 0;
                var price = parseFloat(rows[i].cells[4].getElementsByTagName("input")[0].value) || 0;
                var total = quantity * price;
                rows[i].cells[5].innerHTML = total.toFixed(2);
                totalQuantity += quantity;
                totalAmount += total;
            }

            document.getElementById("totalQuantity").innerText = totalQuantity.toFixed(2);
            document.getElementById("totalAmount").innerText = totalAmount.toFixed(2);
            document.getElementById("totalItems").innerText = rows.length;
        }

        // Gọi updateTotals khi trang load và khi thay đổi giá trị
        window.onload = updateTotals;
        document.getElementById("importDetailsBody").addEventListener("input", updateTotals);
    </script>
</body>
</html>