<%-- 
    Document   : exportMaterial
    Created on : Jun 9, 2025, 7:27:11 PM
    Author     : ASUS
--%>
<%@ page import="java.util.List" %>
<%@ page import="model.MaterialCategory" %>
<%@ page import="dao.MaterialCategoryDAO" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xuất Kho Vật Tư</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            min-height: 100vh;
            background: linear-gradient(135deg, #6e8efb, #a777e3);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            color: #333;
        }
        .container {
            max-width: 900px;
            margin-top: 40px;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            padding: 30px;
            backdrop-filter: blur(5px);
        }
        h1 {
            color: #2c3e50;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .form-label {
            font-weight: 500;
            color: #34495e;
        }
        .form-control, .form-select {
            border-radius: 8px;
            border: 1px solid #ddd;
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }
        .form-control:focus, .form-select:focus {
            border-color: #6e8efb;
            box-shadow: 0 0 5px rgba(110, 142, 251, 0.5);
        }
        .table {
            background: #fff;
            border-radius: 10px;
            overflow: hidden;
        }
        .table th {
            background: #6e8efb;
            color: #fff;
            font-weight: 600;
        }
        .table th:first-child {
            width: 60px; /* Fixed width for STT column */
        }
        .btn-primary {
            background: linear-gradient(45deg, #6e8efb, #a777e3);
            border: none;
            border-radius: 8px;
            padding: 10px 20px;
            font-weight: 600;
        }
        .btn-danger, .btn-secondary {
            border-radius: 8px;
        }
        .alert {
            margin-top: 20px;
        }
        .error-row {
            background-color: #ffe6e6;
        }
        .btn-disabled {
            opacity: 0.65;
            cursor: not-allowed;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="text-center mb-4">Xuất Kho Vật Tư</h1>

        <!-- Display error message if present -->
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <!-- Display success message with exportId if present -->
        <c:if test="${not empty message}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                ${message} <c:if test="${not empty exportId}">(Mã xuất: ${exportId})</c:if>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/exportMaterial" method="post" class="needs-validation" novalidate>
            <div class="mb-3">
                <label for="wareId" class="form-label">Mã Nhân Viên</label>
                <input type="text" class="form-control" id="wareId" name="wareId"
                       value="${user.code}" readonly>
                <div class="invalid-feedback">Mã nhân viên không hợp lệ.</div>
            </div>

            <div class="mb-3">
                <label for="exportId" class="form-label">Mã Xuất Kho</label>
                <input type="text" class="form-control" id="exportId" name="exportId" required>
                <div class="invalid-feedback">Vui lòng nhập mã xuất.</div>
            </div>

            <div class="mb-3">
                <label for="voucherId" class="form-label">Mã Phiếu</label>
                <input type="text" class="form-control" id="voucherId" name="voucherId" required>
                <div class="invalid-feedback">Vui lòng nhập mã phiếu.</div>
            </div>    

            <div class="mb-3">
                <label for="purpose" class="form-label">Lý Do Xuất Kho</label>
                <textarea class="form-control" id="purpose" name="purpose" rows="3" required></textarea>
                <div class="invalid-feedback">Vui lòng nhập lý do xuất kho.</div>
            </div>

            <div class="mb-3">
                <label class="form-label">Danh Sách Vật Tư</label>
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>STT</th>
                            <th>Tên Vật Tư</th>
                            <th>Mã Vật Tư</th>
                            <th>Số Lượng</th>
                            <th>Loại Vật Tư</th>
                            <th>Đơn Vị</th>
                            <th>Điều Kiện</th>
                            <th>Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody id="materialTableBody">
                        <tr>
                            <td class="serial-number">1</td>
                            <td><input type="text" class="form-control" name="materialName[]" required></td>
                            <td><input type="text" class="form-control" name="materialCode[]" required></td>
                            <td><input type="number" class="form-control" name="quantity[]" min="1" required></td>
                            <td>
                                <select class="form-select" name="categoryId[]" required>
                                    <option value="">Chọn loại vật tư</option>
                                    <%
                                        MaterialCategoryDAO cateDAO = new MaterialCategoryDAO();
                                        List<MaterialCategory> categories = cateDAO.getAllCategories();
                                        if (categories == null || categories.isEmpty()) {
                                            out.println("<!-- Warning: No categories found -->");
                                        }
                                        for (MaterialCategory cat : categories) {
                                    %>
                                    <option value="<%= cat.getCategoryId()%>"><%= cat.getName()%></option>
                                    <%
                                        }
                                    %>
                                </select>
                            </td>
                            <td>
                                <select class="form-select" name="unit[]" required>
                                    <option value="">Chọn đơn vị</option>
                                    <option value="bao">Bao</option>
                                    <option value="hộp">Hộp</option>
                                    <option value="lít">Lít</option>
                                    <option value="viên">Viên</option>
                                    <option value="mét">Mét</option>
                                </select>
                            </td>
                            <td>
                                <select class="form-select" name="condition[]" required>
                                    <option value="">Chọn điều kiện</option>
                                    <option value="new">Mới</option>
                                    <option value="used">Đã sử dụng</option>
                                    <option value="damaged">Hỏng</option>
                                </select>
                            </td>
                            <td><button type="button" class="btn btn-danger btn-sm remove-row" disabled>Xóa</button></td>
                        </tr>
                    </tbody>
                </table>
                <button type="button" class="btn btn-secondary" id="addMaterialBtn">Thêm Vật Tư</button>
            </div>

            <div class="mb-3">
                <label for="requiredDate" class="form-label">Ngày Cần Xuất</label>
                <input type="date" class="form-control" id="requiredDate" name="requiredDate" required>
                <div class="invalid-feedback">Vui lòng chọn ngày cần xuất.</div>
            </div>

            <div class="mb-3">
                <label for="additionalNote" class="form-label">Ghi Chú</label>
                <textarea class="form-control" id="additionalNote" name="additionalNote" rows="3"></textarea>
            </div>

            <button type="submit" class="btn btn-primary">Lưu Phiếu Xuất</button>
            <a href="${pageContext.request.contextPath}/view/warehouse/warehouseDashboard.jsp" class="btn btn-secondary">Quay Về Trang Chủ</a>
        </form>
    </div>

    <script>
        // Bootstrap form validation
        (function () {
            'use strict';
            const forms = document.querySelectorAll('.needs-validation');
            Array.from(forms).forEach(form => {
                form.addEventListener('submit', event => {
                    if (!form.checkValidity() || !validateForm()) {
                        event.preventDefault();
                        event.stopPropagation();
                    }
                    form.classList.add('was-validated');
                }, false);
            });
        })();

        // Client-side form validation
        function validateForm() {
            const purpose = document.getElementById('purpose').value.trim();
            const exportId = document.getElementById('exportId').value.trim();
            const voucherId = document.getElementById('voucherId').value.trim();
            const materialNames = document.getElementsByName('materialName[]');
            const materialCodes = document.getElementsByName('materialCode[]');
            const quantities = document.getElementsByName('quantity[]');
            const categories = document.getElementsByName('categoryId[]');
            const units = document.getElementsByName('unit[]');
            const conditions = document.getElementsByName('condition[]');
            const rows = document.querySelectorAll('#materialTableBody tr');

            // Clear previous error highlights
            rows.forEach(row => row.classList.remove('error-row'));

            // Validate purpose, exportId, and voucherId
            if (!exportId) {
                alert('Mã xuất không được để trống.');
                return false;
            }
            if (!voucherId) {
                alert('Mã phiếu không được để trống.');
                return false;
            }
            if (!purpose) {
                alert('Lý do xuất kho không được để trống.');
                return false;
            }

            // Validate material rows
            if (materialNames.length === 0) {
                alert('Phải có ít nhất một vật tư.');
                return false;
            }

            for (let i = 0; i < materialNames.length; i++) {
                if (!materialNames[i].value.trim()) {
                    alert(`Tên vật tư không được để trống tại dòng ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (!materialCodes[i].value.trim()) {
                    alert(`Mã vật tư không được để trống tại dòng ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (!quantities[i].value || quantities[i].value <= 0) {
                    alert(`Số lượng phải lớn hơn 0 tại dòng ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (!categories[i].value) {
                    alert(`Loại vật tư không được để trống tại dòng ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (!units[i].value) {
                    alert(`Đơn vị không được để trống tại dòng ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (!conditions[i].value) {
                    alert(`Điều kiện không được để trống tại dòng ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
            }
            return true;
        }

        // Update serial numbers for STT column
        function updateSerialNumbers() {
            const rows = document.querySelectorAll('#materialTableBody tr');
            rows.forEach((row, index) => {
                const serialCell = row.querySelector('.serial-number');
                if (serialCell) {
                    serialCell.textContent = index + 1;
                }
            });
        }

        // Update remove button states
        function updateRemoveButtons() {
            const rows = document.querySelectorAll('#materialTableBody tr');
            const removeButtons = document.querySelectorAll('.remove-row');
            const isSingleRow = rows.length === 1;
            removeButtons.forEach(button => {
                button.disabled = isSingleRow;
                button.classList.toggle('btn-disabled', isSingleRow);
            });
        }

        // Add new material row
        function addMaterialRow() {
            const tableBody = document.getElementById('materialTableBody');
            if (!tableBody) {
                console.error('Table body with ID "materialTableBody" not found.');
                alert('Không thể thêm vật tư: Lỗi hệ thống.');
                return;
            }
            const row = document.createElement('tr');
            row.innerHTML = `
                <td class="serial-number"></td>
                <td><input type="text" class="form-control" name="materialName[]" required></td>
                <td><input type="text" class="form-control" name="materialCode[]" required></td>
                <td><input type="number" class="form-control" name="quantity[]" min="1" required></td>
                <td>
                    <select class="form-select" name="categoryId[]" required>
                        <option value="">Chọn loại vật tư</option>
                        <%
                            for (MaterialCategory cat : categories) {
                        %>
                        <option value="<%= cat.getCategoryId()%>"><%= cat.getName()%></option>
                        <%
                            }
                        %>
                    </select>
                </td>
                <td>
                    <select class="form-select" name="unit[]" required>
                        <option value="">Chọn đơn vị</option>
                        <option value="bao">Bao</option>
                        <option value="hộp">Hộp</option>
                        <option value="lít">Lít</option>
                        <option value="viên">Viên</option>
                        <option value="mét">Mét</option>
                    </select>
                </td>
                <td>
                    <select class="form-select" name="condition[]" required>
                        <option value="">Chọn điều kiện</option>
                        <option value="new">Mới</option>
                        <option value="used">Đã sử dụng</option>
                        <option value="damaged">Hỏng</option>
                    </select>
                </td>
                <td><button type="button" class="btn btn-danger btn-sm remove-row">Xóa</button></td>
            `;
            tableBody.appendChild(row);
            updateSerialNumbers();
            updateRemoveButtons();
            showAlert('success', 'Đã thêm dòng vật tư mới.');
        }

        // Remove material row
        function removeRow(button) {
            const rows = document.querySelectorAll('#materialTableBody tr');
            if (rows.length <= 1) {
                showAlert('warning', 'Không thể xóa: Phải có ít nhất một dòng vật tư.');
                return;
            }
            const row = button.closest('tr');
            if (!row) {
                console.error('Parent row not found for the button.');
                alert('Không thể xóa dòng: Lỗi hệ thống.');
                return;
            }
            row.remove();
            updateSerialNumbers();
            updateRemoveButtons();
            showAlert('success', 'Đã xóa dòng vật tư.');
        }

        // Show alert for user feedback
        

        // Event delegation for add and remove buttons
        document.addEventListener('DOMContentLoaded', () => {
            const tableBody = document.getElementById('materialTableBody');
            const addButton = document.getElementById('addMaterialBtn');

            if (!tableBody || !addButton) {
                console.error('Required elements not found: materialTableBody or addMaterialBtn');
                return;
            }

            // Add row event
            addButton.addEventListener('click', addMaterialRow);

            // Remove row event (delegated)
            tableBody.addEventListener('click', (event) => {
                if (event.target.classList.contains('remove-row')) {
                    removeRow(event.target);
                }
            });

            // Initialize serial numbers and remove button states
            updateSerialNumbers();
            updateRemoveButtons();

            // Highlight error row on page load
            <c:if test="${not empty errorRow}">
                const rows = document.querySelectorAll('#materialTableBody tr');
                if (rows[${errorRow}]) {
                    rows[${errorRow}].classList.add('error-row');
                } else {
                    console.warn('Error row index ${errorRow} is out of bounds.');
                }
            </c:if>
        });
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>