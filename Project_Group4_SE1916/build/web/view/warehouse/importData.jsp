<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nhập kho</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .error { color: red; }
    </style>
</head>
<body>
    <div class="container mt-4">
        <!-- Debug Session -->
        <div style="display:none;">
            <h3>Debug Session</h3>
            <p>userId: ${sessionScope.userId}</p>
            <p>userFullName: ${sessionScope.userFullName}</p>
            <p>username: ${sessionScope.username}</p>
            <p>role: ${sessionScope.role}</p>
        </div>

        <h2 class="mb-4">Thông tin phiếu nhập</h2>
        <form id="importForm" action="${pageContext.request.contextPath}/save_import" method="post">
            <div class="row mb-3">
                <label class="col-sm-2 col-form-label">Mã phiếu nhập *</label>
                <div class="col-sm-4">
                    <input type="text" class="form-control" id="voucher_id" name="voucher_id" required>
                    <p id="voucherError" class="error"></p>
                </div>
                <label class="col-sm-2 col-form-label">Ngày nhập *</label>
                <div class="col-sm-4">
                    <input type="date" class="form-control" name="import_date" required value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                </div>
            </div>

            <div class="row mb-3">
                <label class="col-sm-2 col-form-label">Người lập phiếu</label>
                <div class="col-sm-4">
                    <input type="text" class="form-control" value="${sessionScope.userFullName != null ? sessionScope.userFullName : 'Chưa xác định'}" readonly>
                    <input type="hidden" name="user_id" value="${sessionScope.userId != null ? sessionScope.userId : ''}">
                    <c:if test="${empty sessionScope.userFullName}">
                        <p class="error mt-2">Chưa đăng nhập hoặc thông tin người dùng không có. Vui lòng đăng nhập lại.</p>
                    </c:if>
                </div>
                <label class="col-sm-2 col-form-label">Nhà cung cấp *</label>
                <div class="col-sm-4">
                    <input type="text" class="form-control" name="supplier_name" required placeholder="Nhập tên nhà cung cấp">
                    <input type="text" class="form-control mt-2" name="supplier_phone" placeholder="Số điện thoại">
                    <input type="text" class="form-control mt-2" name="supplier_address" placeholder="Địa chỉ">
                    <input type="email" class="form-control mt-2" name="supplier_email" placeholder="Email">
                </div>
            </div>

            <div class="row mb-3">
                <label class="col-sm-2 col-form-label">Ghi chú</label>
                <div class="col-sm-10">
                    <textarea class="form-control" name="note" rows="3" placeholder="Nhập ghi chú"></textarea>
                </div>
            </div>

            <h3 class="mb-4">Danh sách hàng nhập</h3>
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th>STT</th>
                        <th>Tên hàng</th>
                        <th>Mã hàng</th>
                        <th>Đơn vị</th>
                        <th>Số lượng</th>
                        <th>Đơn giá</th>
                        <th>Thành tiền</th>
                        <th>Trạng thái hàng</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody id="importDetailsBody">
                    <tr>
                        <td>1</td>
                        <td><input type="text" class="form-control" name="material_name[]" required placeholder="Nhập tên hàng"></td>
                        <td><input type="text" class="form-control" name="material_code[]" required placeholder="Nhập mã hàng"></td>
                        <td><input type="text" class="form-control" name="unit[]" required placeholder="Nhập đơn vị"></td>
                        <td><input type="number" name="quantity[]" class="form-control quantity" value="0.00" step="0.01" min="0.01" required></td>
                        <td><input type="number" name="price_per_unit[]" class="form-control price" value="0.00" step="0.01" min="0.01" required></td>
                        <td class="total">0.00</td>
                        <td>
                            <select name="material_condition[]" class="form-select" required>
                                <option value="new">Mới</option>
                                <option value="used">Cũ</option>
                                <option value="damaged">Hỏng hóc</option>
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
                <button type="button" class="btn btn-primary" onclick="addRow()">Thêm dòng</button>
                <button type="button" class="btn btn-secondary" onclick="resetForm()">Reset</button>
                <button type="button" class="btn btn-success" onclick="printReceipt()">In phiếu</button>
                <button type="button" class="btn btn-warning" onclick="goBack()">Quay lại</button>
            </div>
            <div class="row">
                <div class="col-sm-6">
                    <p>Tổng số dòng: <span id="totalItems">1</span></p>
                    <p>Tổng số lượng: <span id="totalQuantity">0.00</span></p>
                </div>
                <div class="col-sm-6 text-end">
                    <p>Tổng tiền: <span id="totalAmount">0.00</span> VNĐ</p>
                </div>
            </div>
            <div class="text-end mt-3">
                <button type="submit" class="btn btn-primary">Lưu phiếu nhập</button>
            </div>
        </form>
        <c:if test="${param.success == 'true'}">
            <div class="alert alert-success mt-3" role="alert">
                Lưu phiếu nhập thành công!
                <a href="${pageContext.request.contextPath}/download_csv?voucher_id=${param.voucher_id}" class="btn btn-info btn-sm ms-2">Tải CSV</a>
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
                            if (response.exists) {
                                $('#voucherError').text('Mã phiếu nhập đã tồn tại.');
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
                var row = table.insertRow();
                var stt = table.rows.length + 1;
                row.innerHTML = `
                    <td>${stt}</td>
                    <td><input type="text" class="form-control" name="material_name[]" required placeholder="Nhập tên hàng"></td>
                    <td><input type="text" class="form-control" name="material_code[]" required placeholder="Nhập mã hàng"></td>
                    <td><input type="text" class="form-control" name="unit[]" required placeholder="Nhập đơn vị"></td>
                    <td><input type="number" name="quantity[]" class="form-control quantity" value="0.00" step="0.01" min="0.01" required></td>
                    <td><input type="number" name="price_per_unit[]" class="form-control price" value="0.00" step="0.01" min="0.01" required></td>
                    <td class="total">0.00</td>
                    <td>
                        <select name="material_condition[]" class="form-select" required>
                            <option value="new">Mới</option>
                            <option value="used">Cũ</option>
                            <option value="damaged">Hỏng hóc</option>
                        </select>
                    </td>
                    <td>
                        <button type="button" class="btn btn-danger btn-sm" onclick="deleteRow(this)">
                            <i class="fas fa-trash"></i>
                        </button>
                    </td>
                `;
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
                    var quantity = parseFloat(rows[i].cells[4].getElementsByTagName("input")[0].value) || 0;
                    var price = parseFloat(rows[i].cells[5].getElementsByTagName("input")[0].value) || 0;
                    var total = quantity * price;
                    rows[i].cells[6].innerHTML = total.toFixed(2);
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
                        <td><input type="text" class="form-control" name="material_name[]" required placeholder="Nhập tên hàng"></td>
                        <td><input type="text" class="form-control" name="material_code[]" required placeholder="Nhập mã hàng"></td>
                        <td><input type="text" class="form-control" name="unit[]" required placeholder="Nhập đơn vị"></td>
                        <td><input type="number" name="quantity[]" class="form-control quantity" value="0.00" step="0.01" min="0.01" required></td>
                        <td><input type="number" name="price_per_unit[]" class="form-control price" value="0.00" step="0.01" min="0.01" required></td>
                        <td class="total">0.00</td>
                        <td>
                            <select name="material_condition[]" class="form-select" required>
                                <option value="new">Mới</option>
                                <option value="used">Cũ</option>
                                <option value="damaged">Hỏng hóc</option>
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

            document.getElementById("importDetailsBody").addEventListener("input", updateTotals);

            $('#importForm').on('submit', function(e) {
                if ($('#voucher_id').hasClass('is-invalid')) {
                    e.preventDefault();
                    alert('Vui lòng sửa mã phiếu nhập bị trùng.');
                }
            });

            updateTotals();
        });
    </script>
</body>
</html>