<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Import Warehouse Data</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css" rel="stylesheet">
        <style>
            .error-row {
                background-color: #ffcccc;
            }
            .btn-disabled {
                opacity: 0.5;
                cursor: not-allowed;
            }
            #successAlert, #errorAlert {
                display: none;
                position: fixed;
                top: 10px;
                left: 50%;
                transform: translateX(-50%);
                z-index: 1000;
            }
            .ui-autocomplete {
                z-index: 10000;
            }
            .error {
                color: #dc3545;
                font-size: 0.875em;
            }
        </style>
    </head>
    <body>
        <div class="container mt-5">
            <h2 class="text-center mb-4">Thêm Phiếu Nhập Kho</h2>
            <div id="successAlert" class="alert alert-success" role="alert"></div>
            <div id="errorAlert" class="alert alert-danger" role="alert"></div>
            <form id="importForm" method="post">
                <div class="mb-3">
                    <label for="voucherId" class="form-label">Mã phiếu nhập</label>
                    <input type="text" class="form-control" id="voucherId" name="voucher_id" required>
                </div>
                <div class="mb-3">
                    <label for="importer" class="form-label">Người nhập kho</label>
                    <input type="text" class="form-control" id="importer" name="importer" value="${sessionScope.userFullName != null ? sessionScope.userFullName : 'Not Identified'}" readonly>
                    <c:if test="${empty sessionScope.userFullName}">
                        <p class="error mt-2">Chưa đăng nhập hoặc thông tin người dùng bị thiếu. Vui lòng đăng nhập lại.</p>
                    </c:if>
                </div>
                <div class="mb-3">
                    <label for="importDate" class="form-label">Ngày nhập kho</label>
                    <input type="date" class="form-control" id="importDate" name="import_date" required>
                </div>
                <div class="mb-3">
                    <label for="note" class="form-label">Ghi chú</label>
                    <textarea class="form-control" id="note" name="note" rows="3"></textarea>
                </div>
                <div class="table-responsive">
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Tên vật liệu</th>
                                <th>Mã vật liệu</th>
                                <th>Nhà cung cấp</th>
                                <th>Số lượng</th>
                                <th>Đơn vị</th>
                                <th>Đơn giá (VND)</th>
                                <th>Tổng giá (VND)</th>
                                <th>Tình trạng</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody id="materialTableBody">
                            <tr>
                                <td class="serial-number">1</td>
                                <td>
                                    <input type="text" class="form-control material-name-select" required>
                                    <input type="hidden" class="material-id-hidden" name="materialId[]">
                                </td>
                                <td><input type="text" class="form-control material-code-select" name="materialCode[]" readonly></td>
                                <td>
                                    <select class="form-select supplier-select" name="supplierId[]" required disabled>
                                        <option value="">-- Chọn nhà cung cấp --</option>
                                    </select>
                                </td>
                                <td><input type="number" class="form-control quantity" name="quantity[]" min="0.01" step="0.01" required></td>
                                <td><input type="text" class="form-control unit-display" name="unit[]" readonly></td>
                                <td><input type="number" class="form-control unit-price" name="price_per_unit[]" min="0.01" step="0.01" required></td>
                                <td class="total-price">0.00</td>
                                <td>
                                    <select class="form-select" name="materialCondition[]" required>
                                        <option value="">Chọn tình trạng</option>
                                        <option value="new">Mới</option>
                                        <option value="used">Đã sử dụng</option>
                                        <option value="damaged">Hư hỏng</option>
                                    </select>
                                </td>
                                <td><button type="button" class="btn btn-danger btn-sm remove-row" disabled>Xóa</button></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="mb-3">
                    <button type="button" id="addMaterialBtn" class="btn btn-primary">Thêm vật liệu</button>
                    <button type="button" id="saveImportBtn" class="btn btn-success">Lưu phiếu nhập</button>
                    <button type="button" id="printReceiptBtn" class="btn btn-secondary" onclick="printReceipt()">In phiếu</button>
                </div>
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">Tổng kết</h5>
                        <p>Tổng số vật liệu: <span id="totalItems">1</span></p>
                        <p>Tổng số lượng: <span id="totalQuantity">0.00</span></p>
                        <p>Tổng tiền: <span id="totalAmount">0.00</span> VND</p>
                    </div>
                </div>
            </form>
        </div>

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
        <script>
                        let materialData = [];

                        function attachMaterialAutocomplete(materialInput) {
                            $(materialInput).autocomplete({
                                source: materialData.map(mat => ({
                                        label: mat.name,
                                        value: mat.materialId,
                                        code: mat.code,
                                        unit: mat.unit,
                                        suppliers: mat.suppliers || []
                                    })),
                                select: function (event, ui) {
                                    const row = $(this).closest("tr");
                                    row.find(".material-name-select").val(ui.item.label);
                                    row.find(".material-id-hidden").val(ui.item.value);
                                    row.find(".material-code-select").val(ui.item.code);
                                    row.find(".unit-display").val(ui.item.unit);
                                    const supplierSelect = row.find(".supplier-select");
                                    supplierSelect.html('<option value="">-- Chọn nhà cung cấp --</option>');
                                    if (ui.item.suppliers.length > 0) {
                                        ui.item.suppliers.forEach(supplier => {
                                            supplierSelect.append(new Option(supplier.supplierName, supplier.supplierId));
                                        });
                                        supplierSelect.prop('disabled', false);
                                        supplierSelect.val(ui.item.suppliers[0].supplierId);
                                    } else {
                                        supplierSelect.html('<option value="">-- Không có nhà cung cấp --</option>');
                                        supplierSelect.prop('disabled', true);
                                    }
                                    console.log('Supplier select updated:', supplierSelect.val());
                                    updateTotalPrice(row[0]);
                                    return false;
                                },
                                minLength: 1
                            });
                        }

                        function updateSerialNumbers() {
                            const rows = document.querySelectorAll('#materialTableBody tr');
                            rows.forEach((row, index) => {
                                const serialCell = row.querySelector('.serial-number');
                                if (serialCell)
                                    serialCell.textContent = index + 1;
                            });
                        }

                        function updateRemoveButtons() {
                            const rows = document.querySelectorAll('#materialTableBody tr');
                            const removeButtons = document.querySelectorAll('.remove-row');
                            const isSingleRow = rows.length === 1;
                            removeButtons.forEach(button => {
                                button.disabled = isSingleRow;
                                button.classList.toggle('btn-disabled', isSingleRow);
                            });
                        }

                        function addMaterialRow() {
                            const tableBody = document.getElementById('materialTableBody');
                            if (!tableBody) {
                                console.error('Table body with ID "materialTableBody" not found.');
                                return;
                            }
                            const row = document.createElement('tr');
                            row.innerHTML = `
                    <td class="serial-number"></td>
                    <td>
                        <input type="text" class="form-control material-name-select" required>
                        <input type="hidden" class="material-id-hidden" name="materialId[]">
                    </td>
                    <td><input type="text" class="form-control material-code-select" name="materialCode[]" readonly></td>
                    <td>
                        <select class="form-select supplier-select" name="supplierId[]" required disabled>
                            <option value="">-- Chọn nhà cung cấp --</option>
                        </select>
                    </td>
                    <td><input type="number" class="form-control quantity" name="quantity[]" min="0.01" step="0.01" required></td>
                    <td><input type="text" class="form-control unit-display" name="unit[]" readonly></td>
                    <td><input type="number" class="form-control unit-price" name="price_per_unit[]" min="0.01" step="0.01" required></td>
                    <td class="total-price">0.00</td>
                    <td>
                        <select class="form-select" name="materialCondition[]" required>
                            <option value="">Chọn tình trạng</option>
                            <option value="new">Mới</option>
                            <option value="used">Đã sử dụng</option>
                            <option value="damaged">Hư hỏng</option>
                        </select>
                    </td>
                    <td><button type="button" class="btn btn-danger btn-sm remove-row">Xóa</button></td>
                `;
                            tableBody.appendChild(row);
                            attachMaterialAutocomplete(row.querySelector('.material-name-select'));
                            updateSerialNumbers();
                            updateRemoveButtons();
                            updateTotals();
                        }

                        function removeRow(button) {
                            const rows = document.querySelectorAll('#materialTableBody tr');
                            if (rows.length <= 1)
                                return;
                            const row = button.closest('tr');
                            if (!row)
                                return;
                            row.remove();
                            updateSerialNumbers();
                            updateRemoveButtons();
                            updateTotals();
                        }

                        function updateTotalPrice(row) {
                            const quantityInput = row.querySelector('.quantity');
                            const unitPriceInput = row.querySelector('.unit-price');
                            const totalPriceCell = row.querySelector('.total-price');
                            const quantity = parseFloat(quantityInput.value) || 0;
                            const unitPrice = parseFloat(unitPriceInput.value) || 0;
                            totalPriceCell.textContent = (quantity * unitPrice).toFixed(2);
                            updateTotals();
                        }

                        function updateTotals() {
                            let totalQuantity = 0;
                            let totalAmount = 0;
                            const rows = document.querySelectorAll('#materialTableBody tr');
                            rows.forEach(row => {
                                const quantityInput = row.querySelector('.quantity');
                                const unitPriceInput = row.querySelector('.unit-price');
                                const quantity = parseFloat(quantityInput.value) || 0;
                                const unitPrice = parseFloat(unitPriceInput.value) || 0;
                                const total = quantity * unitPrice;
                                row.querySelector('.total-price').textContent = total.toFixed(2);
                                totalQuantity += quantity;
                                totalAmount += total;
                            });
                            document.getElementById('totalItems').textContent = rows.length;
                            document.getElementById('totalQuantity').textContent = totalQuantity.toFixed(2);
                            document.getElementById('totalAmount').textContent = totalAmount.toFixed(2);
                        }

                        function validateForm() {
                            const voucherId = document.getElementById('voucherId').value.trim();
                            const importDate = document.getElementById('importDate').value.trim();
                            const importer = document.getElementById('importer').value.trim();
                            const materialIds = document.getElementsByClassName('material-id-hidden');
                            const quantities = document.getElementsByName('quantity[]');
                            const unitPrices = document.getElementsByName('price_per_unit[]');
                            const units = document.getElementsByName('unit[]');
                            const conditions = document.getElementsByName('materialCondition[]');
                            const supplierIds = document.getElementsByName('supplierId[]');
                            const rows = document.querySelectorAll('#materialTableBody tr');

                            console.log('Validating form...');
                            console.log('Voucher ID:', voucherId);
                            console.log('Import Date:', importDate);
                            console.log('Importer:', importer);
                            console.log('Material IDs:', Array.from(materialIds).map(el => el.value));
                            console.log('Quantities:', Array.from(quantities).map(el => el.value));
                            console.log('Unit Prices:', Array.from(unitPrices).map(el => el.value));
                            console.log('Units:', Array.from(units).map(el => el.value));
                            console.log('Conditions:', Array.from(conditions).map(el => el.value));
                            console.log('Supplier IDs:', Array.from(supplierIds).map(el => el.value));

                            rows.forEach(row => row.classList.remove('error-row'));

                            if (!voucherId) {
                                console.error('Validation failed: Voucher ID is empty.');
                                alert('Mã phiếu nhập không được để trống.');
                                return false;
                            }
                            if (!importDate) {
                                console.error('Validation failed: Import date is empty.');
                                alert('Ngày nhập kho không được để trống.');
                                return false;
                            }
                            if (!importer || importer === 'Not Identified') {
                                console.error('Validation failed: Importer is empty or not identified.');
                                alert('Người nhập kho không được để trống hoặc không xác định.');
                                return false;
                            }
                            if (materialIds.length === 0) {
                                console.error('Validation failed: No materials specified.');
                                alert('Cần ít nhất một vật liệu.');
                                return false;
                            }

                            for (let i = 0; i < materialIds.length; i++) {
                                if (!materialIds[i].value.trim()) {
                                    console.error(`Validation failed: Material ID is empty at row ${i + 1}`);
                                    alert(`Mã vật liệu không được để trống tại dòng ${i + 1}`);
                                    rows[i].classList.add('error-row');
                                    return false;
                                }
                                if (!quantities[i].value || parseFloat(quantities[i].value) <= 0) {
                                    console.error(`Validation failed: Invalid quantity at row ${i + 1}`);
                                    alert(`Số lượng phải lớn hơn 0 tại dòng ${i + 1}`);
                                    rows[i].classList.add('error-row');
                                    return false;
                                }
                                if (!unitPrices[i].value || parseFloat(unitPrices[i].value) <= 0) {
                                    console.error(`Validation failed: Invalid unit price at row ${i + 1}`);
                                    alert(`Đơn giá phải lớn hơn 0 tại dòng ${i + 1}`);
                                    rows[i].classList.add('error-row');
                                    return false;
                                }
                                if (!units[i].value) {
                                    console.error(`Validation failed: Unit is empty at row ${i + 1}`);
                                    alert(`Đơn vị không được để trống tại dòng ${i + 1}`);
                                    rows[i].classList.add('error-row');
                                    return false;
                                }
                                if (!conditions[i].value) {
                                    console.error(`Validation failed: Condition is empty at row ${i + 1}`);
                                    alert(`Tình trạng không được để trống tại dòng ${i + 1}`);
                                    rows[i].classList.add('error-row');
                                    return false;
                                }
                                if (!supplierIds[i].value) {
                                    console.error(`Validation failed: Supplier ID is empty at row ${i + 1}`);
                                    alert(`Nhà cung cấp không được để trống tại dòng ${i + 1}`);
                                    rows[i].classList.add('error-row');
                                    return false;
                                }
                            }
                            return true;
                        }

                        function checkVoucherId(voucherId) {
                            return fetch(`${pageContext.request.contextPath}/check_voucher_id`, {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/x-www-form-urlencoded'
                                },
                                body: new URLSearchParams({voucher_id: voucherId})
                            })
                                    .then(res => res.json())
                                    .then(data => data.exists)
                                    .catch(error => {
                                        console.error('Error checking voucher ID:', error);
                                        return false; // assume not exists if error
                                    });
                        }


                        document.addEventListener("DOMContentLoaded", () => {
                            const tableBody = document.getElementById('materialTableBody');
                            const addButton = document.getElementById('addMaterialBtn');
                            const saveButton = document.getElementById('saveImportBtn');

                            if (!tableBody || !addButton || !saveButton) {
                                console.error('Required elements not found:', {tableBody, addButton, saveButton});
                                return;
                            }

                            console.log('Fetching material data...');
                            fetch('${pageContext.request.contextPath}/ImportWarehouseServlet', {
                                method: 'GET',
                                headers: {'Accept': 'application/json'}
                            })
                                    .then(response => {
                                        console.log('Material fetch response status:', response.status);
                                        if (!response.ok)
                                            throw new Error(`Server error: ${response.status}`);
                                        return response.json();
                                    })
                                    .then(data => {
                                        materialData = data;
                                        console.log('Material data loaded:', JSON.stringify(materialData, null, 2));
                                        document.querySelectorAll(".material-name-select").forEach(attachMaterialAutocomplete);
                                    })
                                    .catch(error => {
                                        console.error('Error fetching materials:', error);
                                        alert(`Không thể tải dữ liệu vật liệu. Lỗi: ${error.message}`);
                                    });

                            addButton.addEventListener('click', addMaterialRow);
                            tableBody.addEventListener('click', (event) => {
                                if (event.target.classList.contains('remove-row'))
                                    removeRow(event.target);
                            });
                            tableBody.addEventListener('input', (e) => {
                                if (e.target.classList.contains('quantity') || e.target.classList.contains('unit-price')) {
                                    updateTotalPrice(e.target.closest('tr'));
                                }
                            });

                            updateSerialNumbers();
                            updateRemoveButtons();

                            saveButton.addEventListener('click', function (e) {
                                e.preventDefault();
                                console.log('Save button clicked');
                                const voucherId = document.getElementById('voucherId').value.trim();
                                const importDate = document.getElementById('importDate').value.trim();
                                const importer = document.getElementById('importer').value.trim();

                                if (!voucherId) {
                                    console.error('Voucher ID is empty.');
                                    alert('Mã phiếu nhập không được để trống.');
                                    return;
                                }
                                if (!importDate) {
                                    console.error('Import date is empty.');
                                    alert('Ngày nhập kho không được để trống.');
                                    return;
                                }
                                if (!importer || importer === 'Not Identified') {
                                    console.error('Importer is empty or not identified.');
                                    alert('Người nhập kho không được để trống hoặc không xác định.');
                                    return;
                                }

                                checkVoucherId(voucherId).then(exists => {
                                    if (exists) {
                                        console.error('Voucher ID already exists:', voucherId);
                                        alert('Mã phiếu nhập đã tồn tại. Vui lòng sử dụng mã khác.');
                                        return;
                                    }

                                    if (!validateForm()) {
                                        console.log('Validation failed');
                                        return;
                                    }

                                    console.log('Validation passed, sending form data...');
                                    const formData = new FormData(document.getElementById('importForm'));
                                    console.log('Form data:');
                                    for (let pair of formData.entries()) {
                                        console.log(`${pair[0]}: ${pair[1]}`);
                                                        }
                                                        fetch('${pageContext.request.contextPath}/ImportWarehouseServlet', {
                                                            method: 'POST',
                                                            body: formData
                                                        })
                                                                .then(response => {
                                                                    console.log('Response status:', response.status);
                                                                    if (!response.ok)
                                                                        throw new Error(`Server error: ${response.status}`);
                                                                    return response.json();
                                                                })
                                                                .then(data => {
                                                                    console.log('Response data:', data);
                                                                    if (data.status === 'success') {
                                                                        const successAlert = document.getElementById('successAlert');
                                                                        successAlert.textContent = `${data.message} (Mã phiếu nhập: ${data.importId})`;
                                                                        successAlert.style.display = 'block';
                                                                        setTimeout(() => successAlert.style.display = 'none', 5000);
                                                                        document.getElementById('importForm').reset();
                                                                        document.getElementById('materialTableBody').innerHTML = `
                                    <tr>
                                        <td class="serial-number">1</td>
                                        <td>
                                            <input type="text" class="form-control material-name-select" required>
                                            <input type="hidden" class="material-id-hidden" name="materialId[]">
                                        </td>
                                        <td><input type="text" class="form-control material-code-select" name="materialCode[]" readonly></td>
                                        <td><select class="form-select supplier-select" name="supplierId[]" required disabled><option value="">-- Chọn nhà cung cấp --</option></select></td>
                                        <td><input type="number" class="form-control quantity" name="quantity[]" min="0.01" step="0.01" required></td>
                                        <td><input type="text" class="form-control unit-display" name="unit[]" readonly></td>
                                        <td><input type="number" class="form-control unit-price" name="price_per_unit[]" min="0.01" step="0.01" required></td>
                                        <td class="total-price">0.00</td>
                                        <td><select class="form-select" name="materialCondition[]" required><option value="">Chọn tình trạng</option><option value="new">Mới</option><option value="used">Đã sử dụng</option><option value="damaged">Hư hỏng</option></select></td>
                                        <td><button type="button" class="btn btn-danger btn-sm remove-row" disabled>Xóa</button></td>
                                    </tr>
                                `;
                                                                        attachMaterialAutocomplete(document.querySelector('.material-name-select'));
                                                                        updateSerialNumbers();
                                                                        updateRemoveButtons();
                                                                        updateTotals();
                                                                    } else {
                                                                        console.error('Server error response:', data);
                                                                        const errorAlert = document.getElementById('errorAlert');
                                                                        errorAlert.textContent = data.message;
                                                                        errorAlert.style.display = 'block';
                                                                        if (data.errorRow !== undefined) {
                                                                            document.querySelectorAll('#materialTableBody tr')[data.errorRow].classList.add('error-row');
                                                                        }
                                                                        setTimeout(() => errorAlert.style.display = 'none', 5000);
                                                                    }
                                                                })
                                                                .catch(error => {
                                                                    console.error('Error submitting form:', error);
                                                                    const errorAlert = document.getElementById('errorAlert');
                                                                    errorAlert.textContent = 'Đã xảy ra lỗi bất ngờ: ' + error.message;
                                                                    errorAlert.style.display = 'block';
                                                                    setTimeout(() => errorAlert.style.display = 'none', 5000);
                                                                });
                                                    });
                                                });
                                            });

                                            function printReceipt() {
                                                window.print();
                                            }
        </script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>