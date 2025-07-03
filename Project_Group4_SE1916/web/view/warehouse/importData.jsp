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
            #printReceiptPreview {
                display: none;
                margin-top: 20px;
            }
        </style>
    </head>
    <body>
        <div class="container mt-5">
            <h2 class="text-center mb-4">Add Import Voucher</h2>
            <div id="successAlert" class="alert alert-success" role="alert"></div>
            <div id="errorAlert" class="alert alert-danger" role="alert"></div>
            <form id="importForm" method="post" action="${pageContext.request.contextPath}/ImportMaterialServlet">
                <div class="mb-3">
                    <label for="voucherId" class="form-label">Import Voucher Code</label>
                    <input type="text" class="form-control" id="voucherId" name="voucher_id" required pattern="[A-Za-z0-9-_]+">
                    <div id="voucherError" class="error mt-2"></div>
                </div>
                <div class="mb-3">
                    <label for="importer" class="form-label">Importer</label>
                    <input type="text" class="form-control" id="importer" name="importer" value="${sessionScope.userFullName != null ? sessionScope.userFullName : 'Not Identified'}" readonly>
                    <c:if test="${empty sessionScope.userFullName}">
                        <p class="error mt-2">Not logged in or user information missing. Please log in again.</p>
                    </c:if>
                </div>
                <div class="mb-3">
                    <label for="importDate" class="form-label">Import Date</label>
                    <input type="date" class="form-control" id="importDate" name="import_date" required>
                </div>
                <div class="mb-3">
                    <label for="note" class="form-label">Note</label>
                    <textarea class="form-control" id="note" name="note" rows="3" maxlength="1000"></textarea>
                </div>
                <div class="table-responsive">
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Material Name</th>
                                <th>Material Code</th>
                                <th>Supplier</th>
                                <th>Quantity</th>
                                <th>Unit</th>
                                <th>Unit Price (VND)</th>
                                <th>Total Price (VND)</th>
                                <th>Condition</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody id="materialTableBody">
                            <tr>
                                <td class="serial-number">1</td>
                                <td>
                                    <input type="text" class="form-control material-name-select" required>
                                    <input type="hidden" class="material-id-hidden" name="materialId[]">
                                </td>
                                <td><input type="text" class="form-control material-code-select" readonly></td>
                                <td>
                                    <select class="form-select supplier-select" name="supplierId[]" required>
                                        <option value="">-- Select Supplier --</option>
                                    </select>
                                </td>
                                <td><input type="number" class="form-control quantity" name="quantity[]" min="0.01" step="0.01" required></td>
                                <td><input type="text" class="form-control unit-display" readonly></td>
                                <td><input type="number" class="form-control unit-price" name="price_per_unit[]" min="0.01" step="0.01" required></td>
                                <td class="total-price">0.00</td>
                                <td>
                                    <select class="form-select" name="materialCondition[]" required>
                                        <option value="">Select Condition</option>
                                        <option value="new">New</option>
                                        <option value="used">Used</option>
                                        <option value="damaged">Damaged</option>
                                    </select>
                                </td>
                                <td><button type="button" class="btn btn-danger btn-sm remove-row" disabled>Delete</button></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="mb-3">
                    <button type="button" id="addMaterialBtn" class="btn btn-primary">Add Material</button>
                    <button type="button" id="saveImportBtn" class="btn btn-success">Save Import</button>
                    <button type="button" id="printReceiptBtn" class="btn btn-secondary" onclick="showPrintPreview()">Print Receipt</button>
                    <button type="button" id="backBtn" class="btn btn-info" onclick="goBack()">Back</button>
                </div>
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">Summary</h5>
                        <p>Total Materials: <span id="totalItems">1</span></p>
                        <p>Total Quantity: <span id="totalQuantity">0.00</span></p>
                        <p>Total Amount: <span id="totalAmount">0.00</span> VND</p>
                    </div>
                </div>
                <div id="printReceiptPreview" class="card">
                    <div class="card-body">
                        <h5 class="card-title">Receipt Preview</h5>
                        <table id="receiptTable" class="table table-bordered">
                            <thead>
                                <tr>
                                    <th>Material Name</th>
                                    <th>Quantity</th>
                                    <th>Unit Price</th>
                                    <th>Total Price</th>
                                </tr>
                            </thead>
                            <tbody id="receiptTableBody"></tbody>
                            <tfoot>
                                <tr>
                                    <td colspan="3"><strong>Total Amount:</strong></td>
                                    <td id="receiptTotalAmount">0.00</td>
                                </tr>
                            </tfoot>
                        </table>
                        <button type="button" class="btn btn-primary" onclick="printReceipt()">Print</button>
                        <button type="button" class="btn btn-secondary" onclick="hidePrintPreview()">Cancel</button>
                    </div>
                </div>
            </form>
        </div>

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                            let materialData = [];

                            function attachMaterialAutocomplete(materialInput) {
                                $(materialInput).autocomplete({
                                    source: function (request, response) {
                                        const term = request.term.toLowerCase();
                                        fetch('${pageContext.request.contextPath}/ImportMaterialServlet', {
                                            method: 'GET',
                                            headers: {'Accept': 'application/json'}
                                        })
                                                .then(res => res.json())
                                                .then(data => {
                                                    materialData = data; // Lưu dữ liệu để sử dụng sau
                                                    const filtered = materialData.filter(mat => mat.name.toLowerCase().includes(term));
                                                    response(filtered.map(mat => ({
                                                            label: mat.name,
                                                            value: mat.materialId,
                                                            code: mat.code,
                                                            unit: mat.unit,
                                                            suppliers: mat.suppliers || []
                                                        })));
                                                })
                                                .catch(error => {
                                                    console.error('Error loading materials:', error);
                                                    alert(`Unable to load material data: ${error.message}`);
                                                });
                                    },
                                    select: function (event, ui) {
                                        const row = $(this).closest("tr");
                                        row.find(".material-name-select").val(ui.item.label);
                                        row.find(".material-id-hidden").val(ui.item.value);
                                        row.find(".material-code-select").val(ui.item.code);
                                        row.find(".unit-display").val(ui.item.unit);

                                        const supplierSelect = row.find(".supplier-select");
                                        supplierSelect.empty().append('<option value="">-- Select Supplier --</option>');
                                        if (ui.item.suppliers && ui.item.suppliers.length > 0) {
                                            ui.item.suppliers.forEach(supplier => {
                                                supplierSelect.append(new Option(supplier.supplierName, supplier.supplierId));
                                            });
                                            supplierSelect.prop('disabled', false);
                                        } else {
                                            supplierSelect.html('<option value="">No Suppliers Available</option>');
                                            supplierSelect.prop('disabled', true);
                                            alert('No suppliers are associated with material "' + ui.item.label + '". Please contact the administrator.');
                                        }

                                        updateTotalPrice(row[0]);
                                        validateSuppliers();
                                        return false;
                                    },
                                    minLength: 1
                                });
                            }

                            function validateSuppliers() {
                                const supplierSelects = document.querySelectorAll('.supplier-select');
                                let firstSupplierId = null;
                                let isValid = true;

                                supplierSelects.forEach((select, index) => {
                                    if (select.value && !firstSupplierId) {
                                        firstSupplierId = select.value;
                                    } else if (select.value && select.value !== firstSupplierId) {
                                        isValid = false;
                                        alert(`All materials must be supplied by the same supplier. Please select supplier ${firstSupplierId} for row ${index + 1}.`);
                                        select.classList.add('is-invalid');
                                    } else {
                                        select.classList.remove('is-invalid');
                                    }
                                });
                                document.getElementById('saveImportBtn').disabled = !isValid || supplierSelects.length === 0 || [...supplierSelects].every(select => !select.value);
                            }

                            function updateSerialNumbers() {
                                const rows = document.querySelectorAll('#materialTableBody tr');
                                rows.forEach((row, index) => {
                                    row.querySelector('.serial-number').textContent = index + 1;
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
                                const row = document.createElement('tr');
                                row.innerHTML = `
                    <td class="serial-number"></td>
                    <td>
                        <input type="text" class="form-control material-name-select" required>
                        <input type="hidden" class="material-id-hidden" name="materialId[]">
                    </td>
                    <td><input type="text" class="form-control material-code-select" readonly></td>
                    <td>
                        <select class="form-select supplier-select" name="supplierId[]" required>
                            <option value="">-- Select Supplier --</option>
                        </select>
                    </td>
                    <td><input type="number" class="form-control quantity" name="quantity[]" min="0.01" step="0.01" required></td>
                    <td><input type="text" class="form-control unit-display" readonly></td>
                    <td><input type="number" class="form-control unit-price" name="price_per_unit[]" min="0.01" step="0.01" required></td>
                    <td class="total-price">0.00</td>
                    <td>
                        <select class="form-select" name="materialCondition[]" required>
                            <option value="">Select Condition</option>
                            <option value="new">New</option>
                            <option value="used">Used</option>
                            <option value="damaged">Damaged</option>
                        </select>
                    </td>
                    <td><button type="button" class="btn btn-danger btn-sm remove-row">Delete</button></td>
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
                                button.closest('tr').remove();
                                updateSerialNumbers();
                                updateRemoveButtons();
                                updateTotals();
                                validateSuppliers();
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
                                    const quantity = parseFloat(row.querySelector('.quantity').value) || 0;
                                    const unitPrice = parseFloat(row.querySelector('.unit-price').value) || 0;
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
                                const voucherError = document.getElementById('voucherError');
                                const importDate = document.getElementById('importDate').value.trim();
                                const importer = document.getElementById('importer').value.trim();
                                const note = document.getElementById('note').value.trim();
                                const materialIds = document.getElementsByClassName('material-id-hidden');
                                const quantities = document.getElementsByName('quantity[]');
                                const unitPrices = document.getElementsByName('price_per_unit[]');
                                const conditions = document.getElementsByName('materialCondition[]');
                                const supplierIds = document.getElementsByName('supplierId[]');
                                const rows = document.querySelectorAll('#materialTableBody tr');

                                voucherError.textContent = '';
                                rows.forEach(row => row.classList.remove('error-row'));

                                if (!voucherId) {
                                    voucherError.textContent = 'The import voucher code must not be empty.';
                                    return false;
                                }
                                if (!/^[A-Za-z0-9-_]+$/.test(voucherId)) {
                                    voucherError.textContent = 'Voucher ID can only contain alphanumeric characters, hyphens, or underscores.';
                                    return false;
                                }
                                if (voucherId.length > 50) {
                                    voucherError.textContent = 'Voucher ID cannot exceed 50 characters.';
                                    return false;
                                }
                                if (!importDate) {
                                    alert('The import date must not be empty.');
                                    return false;
                                }
                                if (!importer || importer === 'Not Identified') {
                                    alert('The importer must not be empty or not identified.');
                                    return false;
                                }
                                if (note && note.length > 1000) {
                                    alert('Note cannot exceed 1000 characters.');
                                    return false;
                                }
                                if (note && !/^[A-Za-z0-9\s,.()-]+$/.test(note)) {
                                    alert('Note can only contain alphanumeric characters, spaces, commas, periods, parentheses, or hyphens.');
                                    return false;
                                }
                                if (materialIds.length === 0) {
                                    alert('At least one material is required.');
                                    return false;
                                }

                                let firstSupplierId = supplierIds[0].value;
                                for (let i = 0; i < materialIds.length; i++) {
                                    if (!materialIds[i].value.trim()) {
                                        alert(`Material ID must not be empty at row ${i + 1}`);
                                        rows[i].classList.add('error-row');
                                        return false;
                                    }
                                    if (!quantities[i].value || parseFloat(quantities[i].value) <= 0) {
                                        alert(`Quantity must be greater than 0 at row ${i + 1}`);
                                        rows[i].classList.add('error-row');
                                        return false;
                                    }
                                    if (!unitPrices[i].value || parseFloat(unitPrices[i].value) <= 0) {
                                        alert(`Unit price must be greater than 0 at row ${i + 1}`);
                                        rows[i].classList.add('error-row');
                                        return false;
                                    }
                                    if (!conditions[i].value) {
                                        alert(`Condition must not be empty at row ${i + 1}`);
                                        rows[i].classList.add('error-row');
                                        return false;
                                    }
                                    if (!supplierIds[i].value) {
                                        alert(`Supplier must not be empty at row ${i + 1}`);
                                        rows[i].classList.add('error-row');
                                        return false;
                                    }
                                    if (supplierIds[i].value !== firstSupplierId) {
                                        alert(`All materials must be supplied by the same supplier at row ${i + 1}`);
                                        rows[i].classList.add('error-row');
                                        return false;
                                    }
                                }
                                return true;
                            }

                            function showPrintPreview() {
                                const rows = document.querySelectorAll('#materialTableBody tr');
                                const receiptTableBody = document.getElementById('receiptTableBody');
                                const receiptTotalAmount = document.getElementById('receiptTotalAmount');
                                let totalAmount = 0;

                                receiptTableBody.innerHTML = '';
                                rows.forEach(row => {
                                    const materialName = row.querySelector('.material-name-select').value;
                                    const quantity = parseFloat(row.querySelector('.quantity').value) || 0;
                                    const unitPrice = parseFloat(row.querySelector('.unit-price').value) || 0;
                                    const total = quantity * unitPrice;

                                    if (materialName && quantity > 0 && unitPrice > 0) {
                                        const newRow = document.createElement('tr');
                                        newRow.innerHTML = `
                            <td>${materialName}</td>
                            <td>${quantity.toFixed(2)}</td>
                            <td>${unitPrice.toFixed(2)}</td>
                            <td>${total.toFixed(2)}</td>
                        `;
                                        receiptTableBody.appendChild(newRow);
                                        totalAmount += total;
                                    }
                                });
                                receiptTotalAmount.textContent = totalAmount.toFixed(2);
                                document.getElementById('printReceiptPreview').style.display = 'block';
                            }

                            function printReceipt() {
                                const printContents = document.getElementById('printReceiptPreview').innerHTML;
                                const originalContents = document.body.innerHTML;
                                document.body.innerHTML = printContents;
                                window.print();
                                document.body.innerHTML = originalContents;
                                hidePrintPreview();
                                window.location.reload();
                            }

                            function hidePrintPreview() {
                                document.getElementById('printReceiptPreview').style.display = 'none';
                            }

                            function goBack() {
                                window.history.back();
                            }

                            document.addEventListener("DOMContentLoaded", () => {
                                const tableBody = document.getElementById('materialTableBody');
                                const addButton = document.getElementById('addMaterialBtn');
                                const saveButton = document.getElementById('saveImportBtn');
                                const voucherIdInput = document.getElementById('voucherId');

                                // Load materials
                                fetch('${pageContext.request.contextPath}/ImportMaterialServlet', {
                                    method: 'GET',
                                    headers: {'Accept': 'application/json'}
                                })
                                        .then(response => {
                                            if (!response.ok)
                                                throw new Error(`Server error: ${response.status}`);
                                            return response.json();
                                        })
                                        .then(data => {
                                            materialData = data;
                                            document.querySelectorAll(".material-name-select").forEach(attachMaterialAutocomplete);
                                        })
                                        .catch(error => {
                                            console.error('Error loading materials:', error);
                                            alert(`Unable to load material data: ${error.message}`);
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
                                tableBody.addEventListener('change', (e) => {
                                    if (e.target.classList.contains('supplier-select')) {
                                        validateSuppliers();
                                    }
                                });

                                voucherIdInput.addEventListener('blur', () => {
                                    const voucherId = voucherIdInput.value.trim();
                                    const voucherError = document.getElementById('voucherError');
                                    voucherError.textContent = '';
                                    if (!voucherId) {
                                        voucherError.textContent = 'The import voucher code must not be empty.';
                                        saveButton.disabled = true;
                                        return;
                                    }
                                    if (!/^[A-Za-z0-9-_]+$/.test(voucherId)) {
                                        voucherError.textContent = 'Voucher ID can only contain alphanumeric characters, hyphens, or underscores.';
                                        saveButton.disabled = true;
                                        return;
                                    }
                                    if (voucherId.length > 50) {
                                        voucherError.textContent = 'Voucher ID cannot exceed 50 characters.';
                                        saveButton.disabled = true;
                                        return;
                                    }
                                    fetch('${pageContext.request.contextPath}/check_voucher_id', {
                                        method: 'POST',
                                        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                                        body: 'voucher_id=' + encodeURIComponent(voucherId) + '&type=import'
                                    })
                                            .then(response => response.json())
                                            .then(data => {
                                                if (data.error) {
                                                    voucherError.textContent = data.error;
                                                    saveButton.disabled = true;
                                                } else if (data.exists) {
                                                    voucherError.textContent = 'The import voucher code already exists. Please use a different code.';
                                                    saveButton.disabled = true;
                                                } else {
                                                    voucherError.textContent = '';
                                                    saveButton.disabled = false;
                                                }
                                            })
                                            .catch(error => {
                                                voucherError.textContent = 'Error checking voucher ID: ' + error.message;
                                                saveButton.disabled = true;
                                            });
                                });

                                saveButton.addEventListener('click', (e) => {
                                    e.preventDefault();
                                    if (!validateForm())
                                        return;

                                    const formData = new FormData(document.getElementById('importForm'));
                                    fetch('${pageContext.request.contextPath}/ImportMaterialServlet', {
                                        method: 'POST',
                                        body: formData
                                    })
                                            .then(response => {
                                                if (!response.ok) {
                                                    return response.text().then(text => {
                                                        throw new Error(`Server error: ${response.status} - ${text}`);
                                                    });
                                                }
                                                return response.json();
                                            })
                                            .then(data => {
                                                const successAlert = document.getElementById('successAlert');
                                                const errorAlert = document.getElementById('errorAlert');
                                                if (data.status === 'success') {
                                                    successAlert.textContent = data.message;
                                                    successAlert.style.display = 'block';
                                                    setTimeout(() => successAlert.style.display = 'none', 5000);
                                                    document.getElementById('importForm').reset();
                                                    const tableBody = document.getElementById('materialTableBody');
                                                    tableBody.innerHTML = `
                                <tr>
                                    <td class="serial-number">1</td>
                                    <td>
                                        <input type="text" class="form-control material-name-select" required>
                                        <input type="hidden" class="material-id-hidden" name="materialId[]">
                                    </td>
                                    <td><input type="text" class="form-control material-code-select" readonly></td>
                                    <td>
                                        <select class="form-select supplier-select" name="supplierId[]" required>
                                            <option value="">-- Select Supplier --</option>
                                        </select>
                                    </td>
                                    <td><input type="number" class="form-control quantity" name="quantity[]" min="0.01" step="0.01" required></td>
                                    <td><input type="text" class="form-control unit-display" readonly></td>
                                    <td><input type="number" class="form-control unit-price" name="price_per_unit[]" min="0.01" step="0.01" required></td>
                                    <td class="total-price">0.00</td>
                                    <td>
                                        <select class="form-select" name="materialCondition[]" required>
                                            <option value="">Select Condition</option>
                                            <option value="new">New</option>
                                            <option value="used">Used</option>
                                            <option value="damaged">Damaged</option>
                                        </select>
                                    </td>
                                    <td><button type="button" class="btn btn-danger btn-sm remove-row" disabled>Delete</button></td>
                                </tr>
                            `;
                                                    updateSerialNumbers();
                                                    updateRemoveButtons();
                                                    updateTotals();
                                                    document.querySelectorAll(".material-name-select").forEach(attachMaterialAutocomplete);
                                                } else {
                                                    errorAlert.textContent = data.message;
                                                    if (data.errorRow != null) {
                                                        const rows = document.querySelectorAll('#materialTableBody tr');
                                                        rows[data.errorRow].classList.add('error-row');
                                                    }
                                                    errorAlert.style.display = 'block';
                                                    setTimeout(() => errorAlert.style.display = 'none', 5000);
                                                }
                                            })
                                            .catch(error => {
                                                const errorAlert = document.getElementById('errorAlert');
                                                errorAlert.textContent = `Error saving import voucher: ${error.message}`;
                                                errorAlert.style.display = 'block';
                                                setTimeout(() => errorAlert.style.display = 'none', 5000);
                                            });
                                });
                            });
        </script>
    </body>
</html>