<%--
    Document   : importData
    Created on : 9 June 2025, 6:30:26 pm
    Author     : Giap
    Updated on : 10 June 2025
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nhập Dữ Liệu Đã Nhập Kho</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">
    <style>
        body { font-family: 'Inter', sans-serif; background: linear-gradient(to bottom, #f0f4f8, #d9e2ec); }
        .card { 
            transition: all 0.3s ease; 
            box-shadow: 0 8px 24px rgba(0,0,0,0.1); 
            border-radius: 1.5rem; 
            border: none; 
            background: white;
        }
        .card:hover { transform: translateY(-5px); box-shadow: 0 12px 32px rgba(0,0,0,0.15); }
        .btn-primary { 
            background: linear-gradient(135deg, #3b82f6, #7e22ce); 
            transition: all 0.3s ease; 
            font-weight: 600;
        }
        .btn-primary:hover { 
            transform: scale(1.05); 
            box-shadow: 0 12px 24px rgba(59,130,246,0.3); 
        }
        .input-field { 
            transition: all 0.2s ease; 
            border: 1px solid #d1d5db; 
            border-radius: 0.75rem; 
            padding: 0.75rem; 
        }
        .input-field:focus { 
            border-color: #3b82f6; 
            box-shadow: 0 0 0 3px rgba(59,130,246,0.1); 
        }
        .section-title {
            color: #1f2937;
            font-size: 1.5rem;
            font-weight: 700;
            border-bottom: 2px solid #e5e7eb;
            padding-bottom: 0.5rem;
            margin-bottom: 1.5rem;
        }
    </style>
</head>
<body class="bg-gray-100 min-h-screen font-sans antialiased">
    <c:if test="${empty sessionScope.username}">
        <c:redirect url="login.jsp"/>
    </c:if>

    <main class="flex-1 p-6 md:p-10">
        <div class="max-w-5xl mx-auto card bg-white p-8 md:p-10">
            <h2 class="text-3xl font-bold text-gray-800 mb-8 text-center">Nhập Dữ Liệu Phiếu Nhập Kho</h2>

            <form id="importForm" action="${pageContext.request.contextPath}/import_data" method="post" enctype="multipart/form-data" class="space-y-8">
                <!-- Thông tin chung -->
                <div>
                    <h3 class="section-title">Thông Tin Chung</h3>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">Mã Phiếu Nhập</label>
                            <input type="text" name="import_id" class="input-field w-full" placeholder="VD: PN20250610" required>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">Ngày Nhập Kho</label>
                            <input type="date" name="import_date" class="input-field w-full" required>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">Nhà Cung Cấp</label>
                            <select name="supplier_id" class="input-field w-full" required>
                                <option value="">Chọn nhà cung cấp</option>
                                <c:forEach var="supplier" items="${suppliers}">
                                    <option value="${supplier.id}">${supplier.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">Người Nhập</label>
                            <input type="text" name="user_id" class="input-field w-full" value="${sessionScope.username}" readonly>
                        </div>
                    </div>
                    <div class="mt-4">
                        <label class="block text-sm font-medium text-gray-700 mb-2">Ghi Chú</label>
                        <textarea name="note" class="input-field w-full" rows="3" placeholder="Ghi chú về phiếu nhập kho..."></textarea>
                    </div>
                </div>

                <!-- Chi tiết nguyên vật liệu -->
                <div>
                    <h3 class="section-title">Chi Tiết Nguyên Vật Liệu</h3>
                    <div id="material-list" class="space-y-4">
                        <div class="material-entry grid grid-cols-1 md:grid-cols-4 gap-4">
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Nguyên Vật Liệu</label>
                                <select name="material_id[]" class="input-field w-full" required>
                                    <option value="">Chọn nguyên vật liệu</option>
                                    <c:forEach var="material" items="${materials}">
                                        <option value="${material.id}">${material.name}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Số Lượng</label>
                                <input type="number" name="quantity[]" class="input-field w-full" min="1" required>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Đơn Giá (VND)</label>
                                <input type="number" name="price_per_unit[]" class="input-field w-full" min="0" step="1000" required>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Tình Trạng</label>
                                <select name="material_condition[]" class="input-field w-full" required>
                                    <option value="Tốt">Tốt</option>
                                    <option value="Trung bình">Trung bình</option>
                                    <option value="Kém">Kém</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <button type="button" id="add-material" class="mt-4 btn-primary text-white px-4 py-2 rounded-lg">
                        <i class="fas fa-plus mr-2"></i>Thêm Nguyên Vật Liệu
                    </button>
                </div>

                <!-- Tải file CSV -->
                <div>
                    <h3 class="section-title">Tải Lên File CSV</h3>
                    <div class="space-y-2">
                        <label class="block text-sm font-medium text-gray-700">Chọn file CSV</label>
                        <input type="file" id="csvFile" name="csvFile" accept=".csv" class="input-field w-full">
                        <p class="text-xs text-gray-500">Định dạng CSV: import_id, supplier_id, user_id, import_date, note, material_id, quantity, price_per_unit, material_condition</p>
                    </div>
                    <div class="mt-4">
                        <label class="block text-sm font-medium text-gray-700">Hoặc nhập thủ công</label>
                        <textarea id="manualData" name="manualData" placeholder="Dán dữ liệu CSV ở đây..." class="input-field w-full mt-2" rows="5"></textarea>
                    </div>
                </div>

                <div class="flex space-x-4">
                    <button type="submit" class="btn-primary text-white px-6 py-3 rounded-lg flex-1">
                        <i class="fas fa-save mr-2"></i>Lưu Phiếu Nhập
                    </button>
                    <button type="reset" class="bg-gray-200 text-gray-700 px-6 py-3 rounded-lg flex-1 hover:bg-gray-300">
                        <i class="fas fa-undo mr-2"></i>Đặt Lại
                    </button>
                </div>
            </form>

            <c:if test="${not empty message}">
                <div class="mt-6 p-4 bg-green-100 text-green-700 rounded-lg">${message}</div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="mt-6 p-4 bg-red-100 text-red-700 rounded-lg">${error}</div>
            </c:if>
        </div>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
    <script>
        // Validate form
        document.getElementById('importForm').addEventListener('submit', (event) => {
            const csvFile = document.getElementById('csvFile').files[0];
            const manualData = document.getElementById('manualData').value.trim();
            const materialEntries = document.querySelectorAll('.material-entry');
            if (!csvFile && !manualData && materialEntries.length === 0) {
                event.preventDefault();
                Toastify({
                    text: "Vui lòng nhập ít nhất một nguyên vật liệu, tải lên file CSV hoặc nhập dữ liệu thủ công!",
                    duration: 3000,
                    gravity: "top",
                    position: "center",
                    backgroundColor: "#ef4444"
                }).showToast();
            }
        });

        // Add new material entry
        document.getElementById('add-material').addEventListener('click', () => {
            const materialList = document.getElementById('material-list');
            const newEntry = document.createElement('div');
            newEntry.className = 'material-entry grid grid-cols-1 md:grid-cols-4 gap-4';
            newEntry.innerHTML = `
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Nguyên Vật Liệu</label>
                    <select name="material_id[]" class="input-field w-full" required>
                        <option value="">Chọn nguyên vật liệu</option>
                        <c:forEach var="material" items="${materials}">
                            <option value="${material.id}">${material.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Số Lượng</label>
                    <input type="number" name="quantity[]" class="input-field w-full" min="1" required>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Đơn Giá (VND)</label>
                    <input type="number" name="price_per_unit[]" class="input-field w-full" min="0" step="1000" required>
                </div>
                <div class="flex items-end">
                    <select name="material_condition[]" class="input-field w-full" required>
                        <option value="Tốt">Tốt</option>
                        <option value="Trung bình">Trung bình</option>
                        <option value="Kém">Kém</option>
                    </select>
                    <button type="button" class="ml-2 text-red-600 hover:text-red-800" onclick="this.parentElement.parentElement.remove()">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            `;
            materialList.appendChild(newEntry);
        });
    </script>
</body>
</html>