<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Import Materials</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            min-height: 100vh;
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
            width: 60px;
        }
        .btn-primary {
            background: linear-gradient(45deg, #6e8efb, #a777e3);
            border: none;
            border-radius: 8px;
            padding: 10px 20px;
            font-weight: 600;
        }
        .btn-danger, .btn-secondary, .btn-success, .btn-info {
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
        <h1 class="text-center mb-4">Import Materials</h1>

        <!-- Display error message if present -->
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                ${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <!-- Display success message with importId if present -->
        <c:if test="${not empty message}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                ${message} <c:if test="${not empty importId}">(Import ID: ${importId})</c:if>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/ImportWarehouseServlet" method="post" class="needs-validation" novalidate>
            <div class="mb-3">
                <label for="userFN" class="form-label">Importer</label>
                <input type="text" name="userFN" class="form-control" value="${sessionScope.userFullName != null ? sessionScope.userFullName : 'Not Identified'}" readonly>
                <input type="hidden" name="user_id" value="${sessionScope.userId != null ? sessionScope.userId : ''}">
                <c:if test="${empty sessionScope.userFullName}">
                    <p class="error mt-2">Not logged in or user information is missing. Please log in again.</p>
                </c:if>
            </div>

            <div class="mb-3">
                <label for="voucherId" class="form-label">Voucher ID</label>
                <input type="text" class="form-control" id="voucherId" name="voucher_id" required>
                <div class="invalid-feedback">Please enter the voucher ID.</div>
            </div>

            <div class="mb-3">
                <label for="importDate" class="form-label">Import Date</label>
                <input type="date" class="form-control" id="importDate" name="import_date" required value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                <div class="invalid-feedback">Please select the import date.</div>
            </div>

            <div class="mb-3">
                <label for="note" class="form-label">Note</label>
                <textarea class="form-control" id="note" name="note" rows="3"></textarea>
            </div>

            <div class="mb-3">
                <label class="form-label">Material List</label>
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>No.</th>
                            <th>Parent Category</th>
                            <th>Child Category</th>
                            <th>Material Name</th>
                            <th>Material Code</th>
                            <th>Supplier</th>
                            <th>Quantity</th>
                            <th>Unit</th>
                            <th>Unit Price</th>
                            <th>Total Price</th>
                            <th>Condition</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="materialTableBody">
                        <tr>
                            <td class="serial-number">1</td>
                            <td>
                                <select class="form-select parent-category-select" name="parentCategoryId[]" required>
                                    <option value="">Select parent category</option>
                                </select>
                            </td>
                            <td>
                                <select class="form-select category-select" name="childCategoryId[]" required disabled>
                                    <option value="">Select child category</option>
                                </select>
                            </td>
                            <td>
                                <select class="form-select material-name-select" name="materialId[]" required disabled>
                                    <option value="">-- Select material name --</option>
                                </select>
                            </td>
                            <td>
                                <input type="text" class="form-control material-code-select" name="materialCode[]" readonly>
                            </td>
                            <td>
                                <select class="form-select supplier-select" name="supplierId[]" required disabled>
                                    <option value="">-- Select supplier --</option>
                                </select>
                            </td>
                            <td><input type="number" class="form-control quantity" name="quantity[]" min="0.01" step="0.01" required></td>
                            <td><input type="text" class="form-control unit-display" name="unit[]" readonly></td>
                            <td><input type="number" class="form-control unit-price" name="price_per_unit[]" min="0.01" step="0.01" required></td>
                            <td class="total-price">0.00</td>
                            <td>
                                <select class="form-select" name="materialCondition[]" required>
                                    <option value="">Select condition</option>
                                    <option value="new">New</option>
                                    <option value="used">Used</option>
                                    <option value="damaged">Damaged</option>
                                </select>
                            </td>
                            <td><button type="button" class="btn btn-danger btn-sm remove-row" disabled>Delete</button></td>
                        </tr>
                    </tbody>
                </table>
                <button type="button" class="btn btn-secondary" id="addMaterialBtn">Add Material</button>
            </div>

            <div class="text-end mb-3">
                <button type="button" class="btn btn-success" onclick="printReceipt()">Print Receipt</button>
            </div>

            <div class="row">
                <div class="col-sm-6">
                    <p>Total Rows: <span id="totalItems">1</span></p>
                    <p>Total Quantity: <span id="totalQuantity">0.00</span></p>
                </div>
                <div class="col-sm-6 text-end">
                    <p>Total Amount: <span id="totalAmount">0.00</span> VND</p>
                </div>
            </div>

            <button type="submit" class="btn btn-primary">Save Import Receipt</button>
            <button type="reset" class="btn btn-info">Reset</button>
            <a href="${pageContext.request.contextPath}/view/warehouse/warehouseDashboard.jsp" class="btn btn-secondary">Back to Dashboard</a>
        </form>
    </div>

    <script>
        let materialData = [];

        // Function to attach event listeners to parent category select
        function attachParentCategoryListener(parentCategorySelect) {
            parentCategorySelect.addEventListener("change", function () {
                const selectedParentCategoryId = this.value;
                const row = this.closest("tr");
                const categorySelect = row.querySelector(".category-select");
                const nameSelect = row.querySelector(".material-name-select");
                const codeInput = row.querySelector(".material-code-select");
                const supplierSelect = row.querySelector(".supplier-select");
                const unitInput = row.querySelector(".unit-display");
                const unitPriceInput = row.querySelector(".unit-price");
                const totalPriceCell = row.querySelector(".total-price");

                // Reset
                categorySelect.innerHTML = '<option value="">Select child category</option>';
                nameSelect.innerHTML = '<option value="">-- Select material name --</option>';
                codeInput.value = '';
                supplierSelect.innerHTML = '<option value="">-- Select supplier --</option>';
                unitInput.value = '';
                unitPriceInput.value = '0.00';
                totalPriceCell.textContent = '0.00';
                categorySelect.disabled = !selectedParentCategoryId;
                nameSelect.disabled = true;
                codeInput.disabled = true;
                supplierSelect.disabled = true;
                unitPriceInput.disabled = true;

                if (!selectedParentCategoryId) return;

                // Filter subcategories based on parentCategoryId
                const childCategories = materialData
                    .filter(mat => mat.category && mat.category.parentId == selectedParentCategoryId)
                    .map(mat => ({ categoryId: mat.category.categoryId, name: mat.category.name }))
                    .reduce((unique, item) => {
                        if (!unique.some(cat => cat.categoryId === item.categoryId)) unique.push(item);
                        return unique;
                    }, []);

                childCategories.forEach(cat => {
                    categorySelect.add(new Option(cat.name, cat.categoryId));
                });

                // Attach event for categorySelect
                categorySelect.onchange = function () {
                    const selectedCategoryId = this.value;
                    nameSelect.innerHTML = '<option value="">-- Select material name --</option>';
                    codeInput.value = '';
                    supplierSelect.innerHTML = '<option value="">-- Select supplier --</option>';
                    unitInput.value = '';
                    unitPriceInput.value = '0.00';
                    totalPriceCell.textContent = '0.00';
                    nameSelect.disabled = !selectedCategoryId;
                    codeInput.disabled = !selectedCategoryId;
                    supplierSelect.disabled = !selectedCategoryId;
                    unitPriceInput.disabled = !selectedCategoryId;

                    if (!selectedCategoryId) return;

                    const filteredMaterials = materialData.filter(mat => mat.category && mat.category.categoryId == selectedCategoryId);

                    if (filteredMaterials.length > 0) {
                        filteredMaterials.forEach(mat => {
                            nameSelect.add(new Option(mat.name, mat.materialId));
                            if (mat.supplier) {
                                supplierSelect.add(new Option(mat.supplier.supplierName, mat.supplier.supplierId));
                            }
                        });

                        const updateDetails = () => {
                            const selectedMaterial = filteredMaterials.find(m => m.materialId == nameSelect.value);
                            if (selectedMaterial) {
                                codeInput.value = selectedMaterial.code;
                                unitInput.value = selectedMaterial.unit;
                                unitPriceInput.value = selectedMaterial.pricePerUnit || '0.00';
                                updateTotalPrice(row);
                            }
                        };

                        nameSelect.onchange = updateDetails;
                        supplierSelect.onchange = updateDetails;
                    }
                };
            });
        }

        // Update serial numbers for No. column
        function updateSerialNumbers() {
            const rows = document.querySelectorAll('#materialTableBody tr');
            rows.forEach((row, index) => {
                const serialCell = row.querySelector('.serial-number');
                if (serialCell) serialCell.textContent = index + 1;
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
                return;
            }
            const row = document.createElement('tr');
            row.innerHTML = `
                <td class="serial-number"></td>
                <td>
                    <select class="form-select parent-category-select" name="parentCategoryId[]" required>
                        <option value="">Select parent category</option>
                    </select>
                </td>
                <td>
                    <select class="form-select category-select" name="childCategoryId[]" required disabled>
                        <option value="">Select child category</option>
                    </select>
                </td>
                <td>
                    <select class="form-select material-name-select" name="materialId[]" required disabled>
                        <option value="">-- Select material name --</option>
                    </select>
                </td>
                <td>
                    <input type="text" class="form-control material-code-select" name="materialCode[]" readonly>
                </td>
                <td>
                    <select class="form-select supplier-select" name="supplierId[]" required disabled>
                        <option value="">-- Select supplier --</option>
                    </select>
                </td>
                <td><input type="number" class="form-control quantity" name="quantity[]" min="0.01" step="0.01" required></td>
                <td><input type="text" class="form-control unit-display" name="unit[]" readonly></td>
                <td><input type="number" class="form-control unit-price" name="price_per_unit[]" min="0.01" step="0.01" required></td>
                <td class="total-price">0.00</td>
                <td>
                    <select class="form-select" name="materialCondition[]" required>
                        <option value="">Select condition</option>
                        <option value="new">New</option>
                        <option value="used">Used</option>
                        <option value="damaged">Damaged</option>
                    </select>
                </td>
                <td><button type="button" class="btn btn-danger btn-sm remove-row">Delete</button></td>
            `;
            tableBody.appendChild(row);
            attachParentCategoryListener(row.querySelector('.parent-category-select'));
            updateSerialNumbers();
            updateRemoveButtons();
            updateTotals();
        }

        // Remove material row
        function removeRow(button) {
            const rows = document.querySelectorAll('#materialTableBody tr');
            if (rows.length <= 1) return;
            const row = button.closest('tr');
            if (!row) return;
            row.remove();
            updateSerialNumbers();
            updateRemoveButtons();
            updateTotals();
        }

        // Update total price for a row
        function updateTotalPrice(row) {
            const quantityInput = row.querySelector('.quantity');
            const unitPriceInput = row.querySelector('.unit-price');
            const totalPriceCell = row.querySelector('.total-price');
            const quantity = parseFloat(quantityInput.value) || 0;
            const unitPrice = parseFloat(unitPriceInput.value) || 0;
            totalPriceCell.textContent = (quantity * unitPrice).toFixed(2);
            updateTotals();
        }

        // Update totals for all rows
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
            const voucherId = document.getElementById('voucherId').value.trim();
            const importDate = document.getElementById('importDate').value.trim();
            const materialIds = document.getElementsByName('materialId[]');
            const quantities = document.getElementsByName('quantity[]');
            const unitPrices = document.getElementsByName('price_per_unit[]');
            const units = document.getElementsByName('unit[]');
            const conditions = document.getElementsByName('materialCondition[]');
            const rows = document.querySelectorAll('#materialTableBody tr');

            // Clear previous error highlights
            rows.forEach(row => row.classList.remove('error-row'));

            if (!voucherId) {
                alert('Voucher ID cannot be empty.');
                return false;
            }
            if (!importDate) {
                alert('Import date cannot be empty.');
                return false;
            }

            if (materialIds.length === 0) {
                alert('At least one material is required.');
                return false;
            }

            for (let i = 0; i < materialIds.length; i++) {
                if (!materialIds[i].value.trim()) {
                    alert(`Material name cannot be empty at row ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (!quantities[i].value || quantities[i].value <= 0) {
                    alert(`Quantity must be greater than 0 at row ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (!unitPrices[i].value || unitPrices[i].value <= 0) {
                    alert(`Unit price must be greater than 0 at row ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (!units[i].value) {
                    alert(`Unit cannot be empty at row ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
                if (!conditions[i].value) {
                    alert(`Condition cannot be empty at row ${i + 1}`);
                    rows[i].classList.add('error-row');
                    return false;
                }
            }
            return true;
        }

        // Load materials and initialize listeners
        document.addEventListener("DOMContentLoaded", () => {
            const tableBody = document.getElementById('materialTableBody');
            const addButton = document.getElementById('addMaterialBtn');

            if (!tableBody || !addButton) {
                console.error('Required elements not found.');
                return;
            }

            // Fetch materials
            fetch('${pageContext.request.contextPath}/ImportWarehouseServlet', {
                method: 'GET',
                headers: {
                    'Accept': 'application/json'
                }
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error(`Server error: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                materialData = data;
                console.log('Material data loaded:', materialData);

                // Populate parent categories dynamically
                const parentSelects = document.querySelectorAll('.parent-category-select');
                const uniqueParentCategories = [...new Set(materialData.map(mat => mat.category.parentId))];
                uniqueParentCategories.forEach(parentId => {
                    const parentCat = materialData.find(mat => mat.category.parentId === parentId).category;
                    parentSelects.forEach(select => {
                        select.add(new Option(parentCat.name, parentCat.parentId));
                    });
                });

                document.querySelectorAll(".parent-category-select").forEach(attachParentCategoryListener);
            })
            .catch(error => {
                console.error('Error fetching materials:', error);
                alert(`Failed to load material data. Error: ${error.message}`);
            });

            // Add row event
            addButton.addEventListener('click', addMaterialRow);

            // Remove row event
            tableBody.addEventListener('click', (event) => {
                if (event.target.classList.contains('remove-row')) {
                    removeRow(event.target);
                }
            });

            // Initialize serial numbers and remove button states
            updateSerialNumbers();
            updateRemoveButtons();

            // Add event listener for quantity and unit price changes
            tableBody.addEventListener('input', function(e) {
                if (e.target.classList.contains('quantity') || e.target.classList.contains('unit-price')) {
                    updateTotalPrice(e.target.closest('tr'));
                }
            });

            // Highlight error row on page load
            <c:if test="${not empty errorRow}">
                const rows = document.querySelectorAll('#materialTableBody tr');
                if (rows[${errorRow}]) {
                    rows[${errorRow}].classList.add('error-row');
                }
            </c:if>
        });

        // Print receipt function
        function printReceipt() {
            window.print();
        }
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>