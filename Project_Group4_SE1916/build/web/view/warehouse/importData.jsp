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
            <h2 class="text-center mb-4">Add Import Voucher</h2>
            <div id="successAlert" class="alert alert-success" role="alert"></div>
            <div id="errorAlert" class="alert alert-danger" role="alert"></div>
            <form id="importForm" method="post" action="${pageContext.request.contextPath}/ImportMaterialServlet">
                <div class="mb-3">
                    <label for="voucherId" class="form-label">Import Voucher Code</label>
                    <input type="text" class="form-control" id="voucherId" name="voucher_id" required>
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
                    <textarea class="form-control" id="note" name="note" rows="3"></textarea>
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
                                    <select class="form-select supplier-select" name="supplierId[]" required disabled>
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
                    <button type="button" id="printReceiptBtn" class="btn btn-secondary" onclick="printReceipt()">Print Receipt</button>
                </div>
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">Summary</h5>
                        <p>Total Materials: <span id="totalItems">1</span></p>
                        <p>Total Quantity: <span id="totalQuantity">0.00</span></p>
                        <p>Total Amount: <span id="totalAmount">0.00</span> VND</p>
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
                                    const filtered = materialData.filter(mat => mat.name.toLowerCase().includes(term));
                                    response(filtered.map(mat => ({
                                            label: mat.name,
                                            value: mat.materialId,
                                            code: mat.code,
                                            unit: mat.unit,
                                            suppliers: mat.suppliers || []
                                        })));
                                },
                                select: function (event, ui) {
                                    const row = $(this).closest("tr");
                                    row.find(".material-name-select").val(ui.item.label);
                                    row.find(".material-id-hidden").val(ui.item.value);
                                    row.find(".material-code-select").val(ui.item.code);
                                    row.find(".unit-display").val(ui.item.unit);
                                    const supplierSelect = row.find(".supplier-select");
                                    supplierSelect.html('<option value="">-- Select Supplier --</option>');
                                    if (ui.item.suppliers.length > 0) {
                                        ui.item.suppliers.forEach(supplier => {
                                            supplierSelect.append(new Option(supplier.supplierName, supplier.supplierId));
                                        });
                                        supplierSelect.prop('disabled', false);
                                        supplierSelect.val(ui.item.suppliers[0].supplierId);
                                    } else {
                                        supplierSelect.html('<option value="">-- No Supplier --</option>');
                                        supplierSelect.prop('disabled', true);
                                    }
                                    updateTotalPrice(row[0]);
                                    return false;
                                },
                                minLength: 1
                            });
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
                        <select class="form-select supplier-select" name="supplierId[]" required disabled>
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
                            const voucherId = document.getElementById('voucherId').value;
                            console.log('Raw Voucher ID:', voucherId); // Debug raw value
                            const trimmedVoucherId = voucherId.trim();
                            console.log('Trimmed Voucher ID:', trimmedVoucherId); // Debug trimmed value
                            const voucherError = document.getElementById('voucherError');
                            voucherError.textContent = '';

                            if (!trimmedVoucherId) {
                                voucherError.textContent = 'The import voucher code must not be empty.';
                                return false;
                            }
                            const importDate = document.getElementById('importDate').value.trim();
                            const importer = document.getElementById('importer').value.trim();
                            const materialIds = document.getElementsByClassName('material-id-hidden');
                            const quantities = document.getElementsByName('quantity[]');
                            const unitPrices = document.getElementsByName('price_per_unit[]');
                            const conditions = document.getElementsByName('materialCondition[]');
                            const supplierIds = document.getElementsByName('supplierId[]');
                            const rows = document.querySelectorAll('#materialTableBody tr');

                            rows.forEach(row => row.classList.remove('error-row'));

                            if (!importDate) {
                                alert('The import date must not be empty.');
                                return false;
                            }
                            if (!importer || importer === 'Not Identified') {
                                alert('The importer must not be empty or not identified.');
                                return false;
                            }
                            if (materialIds.length === 0) {
                                alert('At least one material is required.');
                                return false;
                            }

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
                            }
                            return true;
                        }

                        function checkVoucherId(voucherId) {
                            return fetch('${pageContext.request.contextPath}/ImportMaterialServlet/check_voucher_id', {
                                method: 'POST',
                                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                                body: new URLSearchParams({voucher_id: voucherId})
                            })
                                    .then(res => res.json())
                                    .then(data => {
                                        if (data.error) {
                                            console.error('Voucher ID check error:', data.error);
                                            throw new Error(data.error);
                                        }
                                        return data.exists;
                                    })
                                    .catch(error => {
                                        console.error('Error checking voucher ID:', error);
                                        return false;
                                    });
                        }

                        document.addEventListener("DOMContentLoaded", () => {
                            const tableBody = document.getElementById('materialTableBody');
                            const addButton = document.getElementById('addMaterialBtn');
                            const saveButton = document.getElementById('saveImportBtn');
                            const voucherIdInput = document.getElementById('voucherId');


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

                            voucherIdInput.addEventListener('blur', () => {
                                const voucherId = voucherIdInput.value.trim();
                                if (voucherId) {
                                    checkVoucherId(voucherId).then(exists => {
                                        const voucherError = document.getElementById('voucherError');
                                        if (exists) {
                                            voucherError.textContent = 'The import voucher code already exists. Please use a different code.';
                                            saveButton.disabled = true;
                                        } else {
                                            voucherError.textContent = '';
                                            saveButton.disabled = false;
                                        }
                                    }).catch(error => {
                                        const voucherError = document.getElementById('voucherError');
                                        voucherError.textContent = 'Error checking voucher code: ' + error.message;
                                        saveButton.disabled = true;
                                    });
                                }
                            });

                            saveButton.addEventListener('click', (e) => {
                                e.preventDefault();
                                if (!validateForm())
                                    return;

                                const voucherId = document.getElementById('voucherId').value.trim();
                                console.log('Submitting Voucher ID:', voucherId);
                                checkVoucherId(voucherId).then(exists => {
                                    if (exists) {
                                        document.getElementById('voucherError').textContent = 'The import voucher code already exists. Please use a different code.';
                                        return;
                                    }

                                    const formData = new FormData(document.getElementById('importForm'));
                                    // Explicitly add voucher_id to ensure it’s included
                                    formData.append('voucher_id', voucherId);
                                    for (let pair of formData.entries()) {
                                        console.log(pair[0] + ': ' + pair[1]);
                                    }
                                    fetch('${pageContext.request.contextPath}/ImportMaterialServlet', {
                                        method: 'POST',
                                        body: formData
                                    })
                                            .then(response => {
                                                if (!response.ok)
                                                    throw new Error(`Server error: ${response.status}`);
                                                return response.json();
                                            })
                                            .then(data => {
                                                const successAlert = document.getElementById('successAlert');
                                                const errorAlert = document.getElementById('errorAlert');
                                                if (data.status === 'success') {
                                                    successAlert.textContent = `${data.message} (Import Voucher ID: ${data.importId})`;
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
                                <td><input type="text" class="form-control material-code-select" readonly></td>
                                <td><select class="form-select supplier-select" name="supplierId[]" required disabled><option value="">-- Select Supplier --</option></select></td>
                                <td><input type="number" class="form-control quantity" name="quantity[]" min="0.01" step="0.01" required></td>
                                <td><input type="text" class="form-control unit-display" readonly></td>
                                <td><input type="number" class="form-control unit-price" name="price_per_unit[]" min="0.01" step="0.01" required></td>
                                <td class="total-price">0.00</td>
                                <td><select class="form-select" name="materialCondition[]" required><option value="">Select Condition</option><option value="new">New</option><option value="used">Used</option><option value="damaged">Damaged</option></select></td>
                                <td><button type="button" class="btn btn-danger btn-sm remove-row" disabled>Delete</button></td>
                            </tr>
                        `;
                                                    attachMaterialAutocomplete(document.querySelector('.material-name-select'));
                                                    updateSerialNumbers();
                                                    updateRemoveButtons();
                                                    updateTotals();
                                                    document.getElementById('voucherError').textContent = '';
                                                } else {
                                                    errorAlert.textContent = data.message;
                                                    errorAlert.style.display = 'block';
                                                    if (data.errorRow !== undefined) {
                                                        document.querySelectorAll('#materialTableBody tr')[data.errorRow].classList.add('error-row');
                                                    }
                                                    setTimeout(() => errorAlert.style.display = 'none', 5000);
                                                }
                                            })
                                            .catch(error => {
                                                const errorAlert = document.getElementById('errorAlert');
                                                errorAlert.textContent = 'An unexpected error occurred: ' + error.message;
                                                errorAlert.style.display = 'block';
                                                setTimeout(() => errorAlert.style.display = 'none', 5000);
                                            });
                                });
                            });

                            function printReceipt() {
                                window.print();
                            }
                        });
        </script>

    </body>
</html>