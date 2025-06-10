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
            .form-control {
                border-radius: 8px;
                border: 1px solid #ddd;
                transition: border-color 0.3s ease, box-shadow 0.3s ease;
            }
            .form-control:focus {
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
            .btn-primary {
                background: linear-gradient(45deg, #6e8efb, #a777e3);
                border: none;
                border-radius: 8px;
                padding: 10px 20px;
                font-weight: 600;
            }
            .btn-danger {
                border-radius: 8px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1 class="text-center mb-4">Xuất Kho Vật Tư</h1>

            <form action="${pageContext.request.contextPath}/saveExport" method="post" class="needs-validation" novalidate>
                <div class="mb-3">
                    <label for="adminId" class="form-label">Mã Nhân Viên</label>
                    <input type="text" class="form-control" id="adminId" name="adminId"
                           value="<%= session.getAttribute("adminId") != null ? session.getAttribute("adminId") : ""%>" readonly>
                </div>

                <div class="mb-3">
                    <label for="purpose" class="form-label">Lý Do Xuất</label>
                    <textarea class="form-control" id="purpose" name="purpose" rows="3" required></textarea>
                    <div class="invalid-feedback">Vui lòng nhập lý do xuất.</div>
                </div>

                <div class="mb-3">
                    <label class="form-label">Danh Sách Vật Tư</label>
                    <table class="table table-striped">
                        <thead>
                            <tr>
                                <th>Tên Vật Tư</th>
                                <th>Mã Vật Tư</th>
                                <th>Số Lượng</th>
                                <th>Loại Vật Tư</th>
                                <th>Đơn Vị</th>
                                <th>Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody id="materialTableBody">
                            <tr>
                                <td><input type="text" class="form-control" name="materialName[]" required></td>
                                <td><input type="text" class="form-control" name="materialCode[]" required></td>
                                <td><input type="number" class="form-control" name="quantity[]" min="1" required></td>
                                <td>
                                    <select class="form-control" name="categoryId[]" required>
                                        <option value="">Chọn loại vật tư</option>
                                        <%
                                            MaterialCategoryDAO cateDAO = new MaterialCategoryDAO();
                                            List<MaterialCategory> categories = cateDAO.getAllCategories();
                                            for (MaterialCategory cat : categories) {
                                        %>
                                        <option value="<%= cat.getCategoryId()%>"><%= cat.getName()%></option>
                                        <%
                                            }
                                        %>
                                    </select>
                                </td>
                                <td>
                                    <select class="form-control" name="unit[]" required>
                                        <option value="">Chọn đơn vị</option>
                                        <option value="bao">Bao</option>
                                        <option value="hộp">Hộp</option>
                                        <option value="lít">Lít</option>
                                        <option value="viên">Viên</option>
                                        <option value="mét">Mét</option>
                                    </select>
                                </td>
                                <td><button type="button" class="btn btn-danger btn-sm" onclick="removeRow(this)">Xóa</button></td>
                            </tr>
                        </tbody>
                    </table>
                    <button type="button" class="btn btn-secondary" onclick="addMaterialRow()">Thêm Vật Tư</button>
                </div>

                <div class="mb-3">
                    <label for="priority" class="form-label">Mức Độ Ưu Tiên</label>
                    <select class="form-control" id="priority" name="priority" required>
                        <option value="low">Thấp</option>
                        <option value="medium">Trung bình</option>
                        <option value="high">Cao</option>
                    </select>
                </div>

                <div class="mb-3">
                    <label for="requiredDate" class="form-label">Ngày Cần Xuất</label>
                    <input type="date" class="form-control" id="requiredDate" name="requiredDate" required>
                </div>

                <div class="mb-3">
                    <label for="additionalNote" class="form-label">Ghi Chú Bổ Sung</label>
                    <textarea class="form-control" id="additionalNote" name="additionalNote" rows="3"></textarea>
                </div>

                <button type="submit" class="btn btn-primary">Lưu Phiếu Xuất</button>
            </form>
        </div>

        <script>
                        function addMaterialRow() {
                        const row = document.createElement('tr');
                                row.innerHTML = `
                                <td><input type="text" class="form-control" name="materialName[]" required></td>
                <td><input type="text" class="form-control" name="materialCode[]" required></td>
                <td><input type="number" class="form-control" name="quantity[]" min="1" required></td>
                <td>
                <select class="form-control" name="categoryId[]" required>
                <option value="">Chọn loại vật tư</option>
            <!-- Danh sách loại vật tư cần được render lại bằng JS hoặc từ dữ liệu server -->
            </select>
                </td>
                <td>
                <select class="form-control" name="unit[]" required>
                <option value="">Chọn đơn vị</option>
                            <option value="bao">Bao</option>
                            <option value="hộp">Hộp</option>
                            <option value="lít">Lít</option>
                            <option value="viên">Viên</option>
                            <option value="mét">Mét</option>
                        </select>
                    </td>
                    <td><button type="button" class="btn btn-danger btn-sm" onclick="removeRow(this)">Xóa</button></td>
                `;
                document.getElementById('materialTableBody').appendChild(row);
            }

            function removeRow(button) {
                button.closest('tr').remove();
            }
        </script>
    </body>
</html>

