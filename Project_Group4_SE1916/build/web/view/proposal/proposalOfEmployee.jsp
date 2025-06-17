<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Proposal</title>
        <!-- Bootstrap 5 CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <!-- jQuery UI CSS -->
        <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
        <!-- Font Awesome for icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <!-- Custom CSS -->
        <style>
            body {
                background-color: #f5f7fa;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
            .container {
                max-width: 1200px;
                background: #fff;
                padding: 20px;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
                margin-top: 20px;
            }
            h1, h2 {
                color: #2c3e50;
            }
            .table thead {
                background-color: #34495e;
                color: #fff;
            }
            .table th, .table td {
                vertical-align: middle;
            }
            .form-control, .form-select {
                border-radius: 4px;
            }
            .btn-primary {
                background-color: #2980b9;
                border: none;
            }
            .btn-primary:hover {
                background-color: #3498db;
            }
            .btn-danger {
                background-color: #e74c3c;
            }
            .btn-danger:hover {
                background-color: #c0392b;
            }
            .btn-success {
                background-color: #27ae60;
            }
            .btn-success:hover {
                background-color: #219653;
            }
            #newSupplierFields {
                margin-top: 10px;
                padding: 10px;
                background: #f8f9fa;
                border-radius: 4px;
            }
            .error {
                color: #e74c3c;
                font-size: 0.9em;
            }
            .success {
                color: #27ae60;
                font-size: 0.9em;
            }
            .autocomplete-suggestion {
                padding: 8px;
                cursor: pointer;
            }
            .autocomplete-suggestion:hover {
                background-color: #e9ecef;
            }
        </style>
    </head>
    <body>
        <%
            String role = (String) session.getAttribute("role");
            Integer userId = (Integer) session.getAttribute("userId");
            String userFullName = (String) session.getAttribute("userFullName");
        %>
        <div class="container">
            <h1 class="mb-4"><i class="fas fa-warehouse me-2"></i>Proposal</h1>

            <form action="${pageContext.request.contextPath}/ProposalServlet" method="post" enctype="multipart/form-data">
                <!-- Information -->
                <div class="card mb-4">
                    <div class="card-header bg-primary text-white">
                        <h2 class="mb-0"><i class="fas fa-info-circle me-2"></i>Information Proposal</h2>
                    </div>
                    <div class="card-body">
                        <div class="row mb-3">
                            <div class="row mb-3">
                                <label class="col-sm-2 col-form-label">Proposer</label>
                                <div class="col-sm-10">
                                    <input class="form-control" name="note" value="${sessionScope.userFullName}" readonly>
                                </div>
                            </div>
                            <label class="col-sm-2 col-form-label">Proposal Type</label>
                            <div class="col-sm-10">
                                <select name="proposalType" class="form-select" required>
                                    <option value="export">Export</option>
                                    <option value="import">Import</option>
                                    <c:if test="${role == 'warehouse'}">
                                        <option value="repair">Repair</option>               
                                    </c:if>
                                </select>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <label class="col-sm-2 col-form-label">Note</label>
                            <div class="col-sm-10">
                                <textarea class="form-control" name="note" rows="3">${param.note}</textarea>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Danh sách hàng đề xuất -->
                <div class="card mb-4">
                    <div class="card-header bg-primary text-white">
                        <h2 class="mb-0"><i class="fas fa-list-alt me-2"></i>List of Proposed Materials </h2>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-bordered" id="importDetailsTable">
                                <thead>
                                    <tr>
                                        <th style="width: 5%">STT</th>
                                        <th style="width: 20%">Material Name</th>
                                        <th style="width: 10%">Material ID</th>
                                        <th style="width: 10%">Unit</th>
                                        <th style="width: 15%">Quantity</th>
                                        <th style="width: 10%">Material Condition </th>
                                        <th style="width: 5%">Action</th>
                                    </tr>
                                </thead>
                                <tbody id="importDetailsBody">
                                    <tr>
                                        <td>1</td>
                                        <td>
                                            <input type="text" class="form-control material-autocomplete" placeholder="Enter material name" required name="materialName[]">
                                            <input type="hidden" name="materialId[]" class="material-id">
                                        </td>
                                        <td><input type="text" name="materialCode[]" class="form-control" placeholder="Enter material code"></td> 
                                        <td><input type="text" name="unit[]" class="form-control unit" readonly></td>
                                        <td><input type="number" name="quantity[]" class="form-control" value="0.00" step="0.01" min="0.01" required></td>
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
                        </div>
                        <button type="button" class="btn btn-success mt-2" onclick="addRow()">
                            <i class="fas fa-plus me-2"></i>Add
                        </button>
                    </div>
                </div>

                <!-- Nút hành động -->
                <div class="d-flex justify-content-end gap-2">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save me-2"></i>Submit Proposal
                    </button>
                    <button type="button" class="btn btn-info" onclick="printReceipt()">
                        <i class="fas fa-print me-2"></i>Print Proposal
                    </button>
                    <button type="button" class="btn btn-warning" onclick="resetForm()">
                        <i class="fas fa-redo me-2"></i>Enter New Proposal
                    </button>
                    <c:choose>
                        <c:when test="${role == 'warehouse'}">
                            <a href="${pageContext.request.contextPath}/view/warehouse/warehouseDashboard.jsp" class="btn btn-secondary">
                                <i class="fas fa-arrow-left me-2"></i>Back to home 
                            </a>
                        </c:when>
                        <c:when test="${role == 'employee'}">
                            <a href="${pageContext.request.contextPath}/view/employee/employeeDashboard.jsp" class="btn btn-secondary">
                                <i class="fas fa-arrow-left me-2"></i>Back to home 
                            </a>                    
                        </c:when>
                    </c:choose>
                </div>

                <!-- Thông báo -->
                <c:if test="${not empty message}">
                    <p class="${messageType == 'success' ? 'success' : 'error'} mt-3">${message}</p>
                </c:if>
                <c:if test="${not empty error}">
                    <p class="error mt-3">${error}</p>
                </c:if>
            </form>
        </div>

        <!-- Bootstrap 5 JS and Popper.js -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <!-- jQuery and jQuery UI -->
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
        <!-- Custom JavaScript -->
        <script>
                       $(document).ready(function () {
    // Initialize autocomplete for material search
    function initAutocomplete(input) {
        input.autocomplete({
            source: function (request, response) {
                $.ajax({
                    url: "${pageContext.request.contextPath}/ProposalServlet",  // Sử dụng cùng URL
                    data: {
                        term: request.term  // Truyền từ khóa tìm kiếm
                    },
                    dataType: "json",
                    success: function (data) {
                        response(data.suggestions);  // Trả lại danh sách gợi ý
                    }
                });
            },
            minLength: 2,  // Tìm kiếm sau khi người dùng nhập ít nhất 2 ký tự
            select: function (event, ui) {
                event.preventDefault();
                $(this).val(ui.item.name);
                $(this).closest('tr').find('.material-id').val(ui.item.material_id);
                $(this).closest('tr').find('.unit').val(ui.item.unit);
                $(this).closest('tr').find('input[name="material_code[]"]').val(ui.item.material_code || ui.item.material_id); 
            },
            response: function (event, ui) {
                if (ui.content.length === 0) {
                    ui.content.push({
                        label: "Không tìm thấy vật tư",
                        value: ""
                    });
                }
            }
        }).data("ui-autocomplete")._renderItem = function (ul, item) {
            return $("<li>")
                .addClass("autocomplete-suggestion")
                .append("<div>" + item.label + (item.unit ? " (" + item.unit + ")" : "") + "</div>")
                .appendTo(ul);
        };
    }
                            // Apply autocomplete to existing inputs
                            $('.material-autocomplete').each(function () {
                                initAutocomplete($(this));
                            });

                            // Add new row
                            window.addRow = function () {
                                var table = document.getElementById("importDetailsBody");
                                var row = table.insertRow();
                                var stt = table.rows.length;
                                row.innerHTML = `
                        <td>${stt}</td>
                         <td>
                                            <input type="text" class="form-control material-autocomplete" placeholder="Enter material name" required>
                                            <input type="hidden" name="material_id[]" class="material-id">
                                        </td>
                                        <td><input type="text" name="material_code[]" class="form-control" placeholder="Enter material code"></td> 
                                        <td><input type="text" name="unit[]" class="form-control unit" readonly></td>
                                        <td><input type="number" name="quantity[]" class="form-control" value="0.00" step="0.01" min="0.01" required></td>
                                        <td>
                                            <select name="material_condition[]" class="form-select" required>
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
                    `;
                                initAutocomplete($(row).find('.material-autocomplete'));
                                updateRowNumbers();
                                updateTotals();
                            };

                            // Delete row
                            window.deleteRow = function (button) {
                                var row = button.parentNode.parentNode;
                                row.parentNode.removeChild(row);
                                updateRowNumbers();
                                updateTotals();
                            };

                            // Update row numbers
                            function updateRowNumbers() {
                                var rows = document.getElementById("importDetailsBody").rows;
                                for (var i = 0; i < rows.length; i++) {
                                    rows[i].cells[0].innerHTML = i + 1;
                                }
                                document.getElementById("totalItems").innerText = rows.length;
                            }

                            // Update totals
                            function updateTotals() {
                                var rows = document.getElementById("importDetailsBody").rows;
                                var totalQuantity = 0;
                                var totalAmount = 0;

                                for (var i = 0; i < rows.length; i++) {
                                    var quantity = parseFloat(rows[i].cells[4].getElementsByTagName("input")[0].value) || 0;
                                    var price = parseFloat(rows[i].cells[5].getElementsByTagName("input")[0].value) || 0;
                                    var total = quantity * price;
                                    rows[i].cells[6].innerHTML = total.toFixed(2);
                                    totalQuantity += quantity;
                                    totalAmount += total;
                                }

                                document.getElementById("totalQuantity").innerText = totalQuantity.toFixed(2);
                                document.getElementById("totalAmount").innerText = totalAmount.toFixed(2);
                                document.getElementById("totalItems").innerText = rows.length;
                            }

                            // Reset form
                            window.resetForm = function () {
                                document.querySelector('form').reset();
                                document.getElementById("newSupplierFields").style.display = 'none';
                                document.getElementById("importDetailsBody").innerHTML = `
                        <tr>
                            <td>1</td>
                                <td>
                                            <input type="text" class="form-control material-autocomplete" placeholder="Enter material name" required>
                                            <input type="hidden" name="material_id[]" class="material-id">
                                        </td>
                                        <td><input type="text" name="material_code[]" class="form-control" placeholder="Enter material code"></td> 
                                        <td><input type="text" name="unit[]" class="form-control unit" readonly></td>
                                        <td><input type="number" name="quantity[]" class="form-control" value="0.00" step="0.01" min="0.01" required></td>
                                        <td>
                                            <select name="material_condition[]" class="form-select" required>
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
                                $('.material-autocomplete').each(function () {
                                    initAutocomplete($(this));
                                });
                                updateRowNumbers();
                                updateTotals();
                            };

                            // Print receipt (placeholder)
                            window.printReceipt = function () {
                                window.print();
                            };

                            // Update totals on input change
                            document.getElementById("importDetailsBody").addEventListener("input", updateTotals);

                            // Initial update
                            updateTotals();
                        });
        </script>
    </body>
</html>