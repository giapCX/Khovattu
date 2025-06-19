<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Warehouse Import</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .error { color: red; }
        .autocomplete-suggestion { padding: 8px; cursor: pointer; }
        .autocomplete-suggestion:hover { background-color: #e9ecef; }
        .hidden { display: none; }
    </style>
</head>
<body>
    <div class="container mt-4">
        <h2 class="mb-4">Import Receipt Information</h2>
        <form id="importForm" action="${pageContext.request.contextPath}/ImportWarehouseServlet" method="post">
            <div class="row mb-3">
                <label class="col-sm-2 col-form-label">Voucher ID *</label>
                <div class="col-sm-4">
                    <input type="text" class="form-control" id="voucher_id" name="voucher_id" required>
                    <p id="voucherError" class="error"></p>
                </div>
                <label class="col-sm-2 col-form-label">Import Date *</label>
                <div class="col-sm-4">
                    <input type="date" class="form-control" name="import_date" required value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                </div>
            </div>

            <div class="row mb-3">
                <label class="col-sm-2 col-form-label">Importer</label>
                <div class="col-sm-4">
                    <input type="text" class="form-control" value="${sessionScope.userFullName != null ? sessionScope.userFullName : 'Not specified'}" readonly>
                    <input type="hidden" name="user_id" value="${sessionScope.userId != null ? sessionScope.userId : ''}">
                    <c:if test="${empty sessionScope.userFullName}">
                        <p class="error mt-2">Not logged in or user information missing. Please log in again.</p>
                    </c:if>
                </div>
                <label class="col-sm-2 col-form-label">Supplier *</label>
                <div class="col-sm-4">
                    <select id="supplier" name="supplier_id" class="form-select" required onchange="toggleNewSupplier(this)">
                        <option value="">-- Select Supplier --</option>
                        <c:forEach items="${suppliers}" var="supplier">
                            <option value="${supplier.supplierId}">${supplier.supplierName}</option>
                        </c:forEach>
                        <option value="new">Add New Supplier</option>
                    </select>
                    <div id="newSupplierFields" class="hidden mt-2">
                        <input type="text" name="new_supplier_name" placeholder="Supplier Name" class="form-control mb-2">
                        <input type="text" name="new_supplier_phone" placeholder="Phone Number" class="form-control mb-2">
                        <input type="text" name="new_supplier_address" placeholder="Address" class="form-control mb-2">
                        <input type="email" name="new_supplier_email" placeholder="Email" class="form-control mb-2">
                    </div>
                </div>
            </div>

            <div class="row mb-3">
                <label class="col-sm-2 col-form-label">Note</label>
                <div class="col-sm-10">
                    <textarea class="form-control" name="note" rows="3" placeholder="Enter note"></textarea>
                </div>
            </div>

            <h3 class="mb-4">List of Imported Items</h3>
            <table class="table table-bordered" id="importDetailsTable">
                <thead>
                    <tr>
                        <th style="width: 5%">No.</th>
                        <th style="width: 15%">Parent Category</th>
                        <th style="width: 15%">Child Category</th>
                        <th style="width: 15%">Material Name</th>
                        <th style="width: 10%">Unit</th>
                        <th style="width: 10%">Quantity</th>
                        <th style="width: 10%">Unit Price</th>
                        <th style="width: 10%">Total Price</th>
                        <th style="width: 10%">Material Condition</th>
                        <th style="width: 5%">Action</th>
                    </tr>
                </thead>
                <tbody id="importDetailsBody">
                    <tr>
                        <td>1</td>
                        <td>
                            <select class="parentCategory form-select" name="parentCategoryId[]">
                                <option value="">Select Parent Category</option>
                                <c:forEach var="cat" items="${parentCategories}">
                                    <option value="${cat.categoryId}">${cat.name}</option>
                                </c:forEach>
                            </select>
                        </td>
                        <td>
                            <select class="childCategory form-select" name="childCategoryId[]">
                                <option value="">Select Child Category</option>
                                <c:forEach var="cat" items="${childCategories}">
                                    <option value="${cat.categoryId}" data-parent="${cat.parentId}">${cat.name}</option>
                                </c:forEach>
                            </select>
                        </td>
                        <td>
                            <select class="nameMaterial form-select" name="materialId[]">
                                <option value="">Select Material</option>
                                <c:forEach var="mat" items="${material}">
                                    <option value="${mat.materialId}" data-parent="${mat.category.categoryId}" data-unit="${mat.unit}">${mat.name}</option>
                                </c:forEach>
                            </select>
                        </td>
                        <td>
                            <input type="text" class="form-control unitMaterial" name="unit[]" readonly>
                        </td>
                        <td><input type="number" name="quantity[]" class="form-control quantity" value="0.00" step="0.01" min="0.01" required></td>
                        <td><input type="number" name="price_per_unit[]" class="form-control price" value="0.00" step="0.01" min="0.01" required></td>
                        <td class="total">0.00</td>
                        <td>
                            <select name="materialCondition[]" class="form-select" required>
                                <option value="new">New</option>
                                <option value="used">Used</option>
                                <option value="damaged">Damaged</option>
                            </select>
                        </td>
                        <td>
                            <button type="button" class="btn btn-danger btn-sm" onclick="deleteRow(this)">
                                <i class="fas fa-trash"></i>
                            </button>
                        </td>
                    </tr>
                </tbody>
            </table>
            <div class="text-end mb-3">
                <button type="button" class="btn btn-primary" onclick="addRow()">Add Row</button>
                <button type="button" class="btn btn-secondary" onclick="resetForm()">Reset</button>
                <button type="button" class="btn btn-success" onclick="printReceipt()">Print Receipt</button>
                <button type="button" class="btn btn-warning" onclick="goBack()">Back</button>
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
            <div class="text-end mt-3">
                <button type="submit" class="btn btn-primary">Save Import Receipt</button>
            </div>
        </form>
        <c:if test="${param.success == 'true'}">
            <div class="alert alert-success mt-3" role="alert">
                Import receipt saved successfully!
                <a href="${pageContext.request.contextPath}/download_csv?voucher_id=${param.voucher_id}" class="btn btn-info btn-sm ms-2">Download CSV</a>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger mt-3" role="alert">${error}</div>
        </c:if>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        $(document).ready(function() {
            $('#voucher_id').on('blur', function() {
                var voucherId = $(this).val();
                if (voucherId) {
                    $.ajax({
                        url: '${pageContext.request.contextPath}/check_voucher_id',
                        type: 'POST',
                        data: { voucher_id: voucherId },
                        success: function(response) {
                            var data = JSON.parse(response);
                            if (data.exists) {
                                $('#voucherError').text('Voucher ID already exists.');
                                $('#voucher_id').addClass('is-invalid');
                            } else {
                                $('#voucherError').text('');
                                $('#voucher_id').removeClass('is-invalid');
                            }
                        }
                    });
                }
            });

            window.addRow = function() {
                var table = document.getElementById("importDetailsBody");
                var row = table.rows[0].cloneNode(true);
                row.querySelectorAll('input[type="number"]').forEach(input => input.value = '0.00');
                row.querySelectorAll('select').forEach(select => select.selectedIndex = 0);
                row.querySelector('.unitMaterial').value = '';
                table.appendChild(row);
                updateRowNumbers();
                updateTotals();
            };

            window.deleteRow = function(button) {
                var row = button.parentNode.parentNode;
                row.parentNode.removeChild(row);
                updateRowNumbers();
                updateTotals();
            };

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
                    var quantity = parseFloat(rows[i].cells[5].getElementsByTagName("input")[0].value) || 0;
                    var price = parseFloat(rows[i].cells[6].getElementsByTagName("input")[0].value) || 0;
                    var total = quantity * price;
                    rows[i].cells[7].innerHTML = total.toFixed(2);
                    totalQuantity += quantity;
                    totalAmount += total;
                }

                document.getElementById("totalQuantity").innerText = totalQuantity.toFixed(2);
                document.getElementById("totalAmount").innerText = totalAmount.toFixed(2);
            }

            window.resetForm = function() {
                document.getElementById("importForm").reset();
                document.getElementById("importDetailsBody").innerHTML = `
                    <tr>
                        <td>1</td>
                        <td>
                            <select class="parentCategory form-select" name="parentCategoryId[]">
                                <option value="">Select Parent Category</option>
                                <c:forEach var="cat" items="${parentCategories}">
                                    <option value="${cat.categoryId}">${cat.name}</option>
                                </c:forEach>
                            </select>
                        </td>
                        <td>
                            <select class="childCategory form-select" name="childCategoryId[]">
                                <option value="">Select Child Category</option>
                                <c:forEach var="cat" items="${childCategories}">
                                    <option value="${cat.categoryId}" data-parent="${cat.parentId}">${cat.name}</option>
                                </c:forEach>
                            </select>
                        </td>
                        <td>
                            <select class="nameMaterial form-select" name="materialId[]">
                                <option value="">Select Material</option>
                                <c:forEach var="mat" items="${material}">
                                    <option value="${mat.materialId}" data-parent="${mat.category.categoryId}" data-unit="${mat.unit}">${mat.name}</option>
                                </c:forEach>
                            </select>
                        </td>
                        <td>
                            <input type="text" class="form-control unitMaterial" name="unit[]" readonly>
                        </td>
                        <td><input type="number" name="quantity[]" class="form-control quantity" value="0.00" step="0.01" min="0.01" required></td>
                        <td><input type="number" name="price_per_unit[]" class="form-control price" value="0.00" step="0.01" min="0.01" required></td>
                        <td class="total">0.00</td>
                        <td>
                            <select name="materialCondition[]" class="form-select" required>
                                <option value="new">New</option>
                                <option value="used">Used</option>
                                <option value="damaged">Damaged</option>
                            </select>
                        </td>
                        <td>
                            <button type="button" class="btn btn-danger btn-sm" onclick="deleteRow(this)">
                                <i class="fas fa-trash"></i>
                            </button>
                        </td>
                    </tr>
                `;
                updateRowNumbers();
                updateTotals();
            };

            window.printReceipt = function() {
                window.print();
            };

            window.goBack = function() {
                window.history.back();
            };

            window.toggleNewSupplier = function(select) {
                var newSupplierFields = document.getElementById('newSupplierFields');
                newSupplierFields.classList.toggle('hidden', select.value !== 'new');
            };

            document.addEventListener('change', function(e) {
                if (e.target.classList.contains('parentCategory')) {
                    const parentId = e.target.value;
                    const row = e.target.closest('tr');
                    const childSelect = row.querySelector('.childCategory');
                    const materialSelect = row.querySelector('.nameMaterial');
                    const unitInput = row.querySelector('.unitMaterial');

                    childSelect.querySelectorAll('option').forEach(option => {
                        const optionParentId = option.getAttribute('data-parent');
                        option.style.display = (!parentId || optionParentId === parentId) ? '' : 'none';
                    });
                    childSelect.value = '';
                    materialSelect.value = '';
                    unitInput.value = '';

                    filterMaterialByCategory(materialSelect, parentId);
                }
                if (e.target.classList.contains('childCategory')) {
                    const childId = e.target.value;
                    const row = e.target.closest('tr');
                    const materialSelect = row.querySelector('.nameMaterial');
                    const unitInput = row.querySelector('.unitMaterial');

                    materialSelect.value = '';
                    unitInput.value = '';
                    filterMaterialByCategory(materialSelect, childId);
                }
                if (e.target.classList.contains('nameMaterial')) {
                    const materialId = e.target.value;
                    const row = e.target.closest('tr');
                    const unitInput = row.querySelector('.unitMaterial');

                    const selectedOption = e.target.selectedOptions[0];
                    unitInput.value = selectedOption ? selectedOption.getAttribute('data-unit') : '';
                }
            });

            function filterMaterialByCategory(materialSelect, categoryId) {
                materialSelect.querySelectorAll('option').forEach(option => {
                    const optionCatId = option.getAttribute('data-parent');
                    option.style.display = (!categoryId || optionCatId === categoryId) ? '' : 'none';
                });
                materialSelect.value = '';
            }

            document.getElementById("importDetailsBody").addEventListener("input", updateTotals);

            $('#importForm').on('submit', function(e) {
                if ($('#voucher_id').hasClass('is-invalid')) {
                    e.preventDefault();
                    alert('Please correct the duplicate voucher ID.');
                }
            });

            updateTotals();
        });
    </script>
</body>
</html>