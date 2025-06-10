<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Phiếu Nhập Kho</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f9fafb;
        }
        .table-container {
            border: 1px solid #e5e7eb;
            border-radius: 0.375rem;
            overflow: hidden;
        }
        .table-header {
            background-color: #f3f4f6;
            font-weight: 600;
        }
        .table-row {
            border-bottom: 1px solid #e5e7eb;
        }
        .table-row:last-child {
            border-bottom: none;
        }
        .input-field {
            border: 1px solid #d1d5db;
            border-radius: 0.375rem;
            padding: 0.5rem;
            width: 100%;
        }
        .btn {
            padding: 0.5rem 1rem;
            border-radius: 0.375rem;
            cursor: pointer;
        }
        .btn-primary { background-color: #3b82f6; color: white; }
        .btn-secondary { background-color: #6b7280; color: white; }
        .btn:hover { opacity: 0.9; }
        .new-supplier-input, .new-unit-input {
            display: none;
            margin-top: 0.25rem;
        }
        .show-input { display: block; }
    </style>
</head>
<body class="p-6">
    <div class="max-w-4xl mx-auto bg-white p-6 rounded-lg shadow-md">
        <h1 class="text-2xl font-bold text-center mb-6">Phiếu Nhập Kho</h1>

        <form action="${pageContext.request.contextPath}/import-data" method="post" id="importForm">
            <div class="mb-6">
                <h2 class="text-lg font-semibold mb-4">Thông tin phiếu nhập</h2>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700">Mã phiếu nhập</label>
                        <input type="text" name="import_id" class="input-field" required>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700">Ngày nhập</label>
                        <input type="date" name="import_date" class="input-field" required>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700">Người lập phiếu</label>
                        <input type="text" name="user_id" class="input-field" value="${sessionScope.username}" readonly>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700">Nhà cung cấp</label>
                        <select name="supplier_id" id="supplier-select" class="input-field" onchange="toggleSupplierInput()" required>
                            <option value="">-- Chọn nhà cung cấp --</option>
                            <c:forEach var="supplier" items="${suppliers}">
                                <option value="${supplier.supplierId}">${supplier.supplierName}</option>
                            </c:forEach>
                            <option value="new">Thêm nhà cung cấp mới</option>
                        </select>
                        <input type="text" name="new_supplier_name" id="new-supplier-input" class="new-supplier-input input-field" placeholder="Nhập tên nhà cung cấp mới">
                        <c:if test="${empty suppliers}">
                            <p class="text-red-500">Không có nhà cung cấp nào trong database!</p>
                        </c:if>
                    </div>
                    <div class="md:col-span-2">
                        <label class="block text-sm font-medium text-gray-700">Ghi chú</label>
                        <textarea name="note" class="input-field" rows="2"></textarea>
                    </div>
                </div>
            </div>

            <div class="mb-6">
                <h2 class="text-lg font-semibold mb-4">Danh sách hàng nhập</h2>
                <div class="table-container">
                    <table class="w-full">
                        <thead>
                            <tr class="table-header">
                                <th class="p-2 text-left">STT</th>
                                <th class="p-2 text-left">Mã hàng</th>
                                <th class="p-2 text-left">Tên hàng</th>
                                <th class="p-2 text-left">Đơn vị</th>
                                <th class="p-2 text-left">Số lượng</th>
                                <th class="p-2 text-left">Đơn giá</th>
                                <th class="p-2 text-left">Thành tiền</th>
                                <th class="p-2 text-left">Trạng thái</th>
                                <th class="p-2 text-left">Hành động</th>
                            </tr>
                        </thead>
                        <tbody id="material-list">
                            <!-- Không có hàng mặc định -->
                        </tbody>
                    </table>
                </div>
                <button type="button" id="add-material" class="mt-4 btn btn-primary">+ Thêm hàng</button>
            </div>

            <div class="mb-6">
                <h2 class="text-lg font-semibold mb-4">Tổng kết</h2>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700">Tổng mặt hàng</label>
                        <input type="number" id="total_items" class="input-field" value="0" readonly>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700">Tổng số lượng</label>
                        <input type="number" id="total_quantity" class="input-field" value="0" readonly>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700">Tổng tiền hàng</label>
                        <input type="number" id="total_amount" class="input-field" value="0" readonly>
                    </div>
                </div>
            </div>

            <div class="flex justify-between">
                <div>
                    <button type="submit" class="btn btn-primary mr-2">Lưu phiếu nhập</button>
                    <button type="button" class="btn btn-secondary" onclick="window.print()">In phiếu nhập</button>
                </div>
                <div>
                    <button type="button" class="btn btn-primary mr-2" onclick="resetForm()">Nhập phiếu mới</button>
                    <button type="button" class="btn btn-secondary" onclick="window.location.href=''">Quay lại danh sách</button>
                </div>
            </div>
        </form>

        <c:if test="${not empty message}">
            <div class="mt-6 p-4 bg-green-100 text-green-700 rounded-lg">${message}</div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="mt-6 p-4 bg-red-100 text-red-700 rounded-lg">${error}</div>
        </c:if>
    </div>

    <script>
        document.getElementById('add-material').addEventListener('click', function() {
            const materialList = document.getElementById('material-list');
            const rowCount = materialList.getElementsByTagName('tr').length + 1;
            const newRow = document.createElement('tr');
            newRow.className = 'table-row';
            newRow.innerHTML = `
                <td class="p-2">${rowCount}</td>
                <td class="p-2"><input type="text" name="material_id[]" class="input-field" required></td>
                <td class="p-2"><input type="text" name="material_name[]" class="input-field" required></td>
                <td class="p-2">
                    <select name="unit[]" id="unit-select-${rowCount}" class="input-field" onchange="toggleUnitInput(${rowCount})" required>
                        <option value="">-- Chọn đơn vị --</option>
                        <c:forEach var="material" items="${materials}">
                            <option value="${material.unit}">${material.unit}</option>
                        </c:forEach>
                        <option value="new">Thêm đơn vị mới</option>
                    </select>
                    <input type="text" name="new_unit[]" id="new-unit-input-${rowCount}" class="new-unit-input input-field" placeholder="Nhập đơn vị mới">
                    <c:if test="${empty materials}">
                        <p class="text-red-500">Không có đơn vị nào trong database!</p>
                    </c:if>
                </td>
                <td class="p-2"><input type="number" name="quantity[]" class="input-field" min="1" required></td>
                <td class="p-2"><input type="number" name="price_per_unit[]" class="input-field" min="0" step="1000" required></td>
                <td class="p-2"><input type="number" name="total_price[]" class="input-field" readonly></td>
                <td class="p-2">
                    <select name="material_condition[]" class="input-field" required>
                        <option value="Mới">Mới</option>
                        <option value="Hỏng hóc">Hỏng hóc</option>
                        <option value="Cũ">Cũ</option>
                    </select>
                </td>
                <td class="p-2"><button type="button" class="btn btn-secondary remove-row">Xóa</button></td>
            `;
            materialList.appendChild(newRow);
            updateTotals();
        });

        document.addEventListener('click', function(e) {
            if (e.target.classList.contains('remove-row')) {
                e.target.closest('tr').remove();
                updateRowNumbers();
                updateTotals();
            }
        });

        function updateRowNumbers() {
            const rows = document.getElementById('material-list').getElementsByTagName('tr');
            for (let i = 0; i < rows.length; i++) {
                rows[i].cells[0].textContent = i + 1;
            }
        }

        function updateTotals() {
            let totalItems = 0;
            let totalQuantity = 0;
            let totalAmount = 0;

            const rows = document.getElementById('material-list').getElementsByTagName('tr');
            for (let row of rows) {
                totalItems++;
                const quantity = parseInt(row.cells[4].getElementsByTagName('input')[0].value) || 0;
                const price = parseInt(row.cells[5].getElementsByTagName('input')[0].value) || 0;
                const totalPrice = quantity * price;
                row.cells[6].getElementsByTagName('input')[0].value = totalPrice;
                totalQuantity += quantity;
                totalAmount += totalPrice;
            }

            document.getElementById('total_items').value = totalItems;
            document.getElementById('total_quantity').value = totalQuantity;
            document.getElementById('total_amount').value = totalAmount;
        }

        function resetForm() {
            document.getElementById('importForm').reset();
            const materialList = document.getElementById('material-list');
            while (materialList.getElementsByTagName('tr').length > 0) {
                materialList.removeChild(materialList.lastChild);
            }
            updateRowNumbers();
            updateTotals();
            document.getElementById('new-supplier-input').classList.remove('show-input');
            const unitInputs = document.getElementsByClassName('new-unit-input');
            for (let input of unitInputs) {
                input.classList.remove('show-input');
            }
        }

        document.getElementById('material-list').addEventListener('input', function(e) {
            if (e.target.name.includes('quantity') || e.target.name.includes('price_per_unit')) {
                const row = e.target.closest('tr');
                const quantity = parseInt(row.cells[4].getElementsByTagName('input')[0].value) || 0;
                const price = parseInt(row.cells[5].getElementsByTagName('input')[0].value) || 0;
                row.cells[6].getElementsByTagName('input')[0].value = quantity * price;
                updateTotals();
            }
        });

        function toggleSupplierInput() {
            const select = document.getElementById('supplier-select');
            const newSupplierInput = document.getElementById('new-supplier-input');
            if (select.value === 'new') {
                newSupplierInput.classList.add('show-input');
                select.required = false;
            } else {
                newSupplierInput.classList.remove('show-input');
                select.required = true;
            }
        }

        function toggleUnitInput(rowIndex) {
            const select = document.getElementById(`unit-select-${rowIndex}`);
            const newUnitInput = document.getElementById(`new-unit-input-${rowIndex}`);
            if (select.value === 'new') {
                newUnitInput.classList.add('show-input');
                select.required = false;
            } else {
                newUnitInput.classList.remove('show-input');
                select.required = true;
            }
        }

        window.onload = function() {
            updateTotals();
            toggleSupplierInput();
            // Không gọi toggleUnitInput(1) vì không có hàng mặc định
        };
    </script>
</body>
</html>