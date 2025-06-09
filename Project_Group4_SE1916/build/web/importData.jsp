<%-- 
    Document   : importReceipt
    Created on : 9 June 2025, 6:30:26 pm
    Author     : Giap
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
        body { font-family: 'Inter', sans-serif; background-color: #f8fafc; }
        .card { transition: all 0.3s ease; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); border-radius: 1rem; border: 1px solid #e5e7eb; }
        .card:hover { transform: translateY(-5px); box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1); }
        .btn-primary { background: linear-gradient(to right, #3b82f6, #6366f1); transition: all 0.3s ease; }
        .btn-primary:hover { transform: scale(1.05); box-shadow: 0 10px 15px -3px rgba(59,130,246,0.3); }
    </style>
</head>
<body class="bg-gray-50 min-h-screen font-sans antialiased">
    <c:if test="${empty sessionScope.username}">
        <c:redirect url="login.jsp"/>
    </c:if>

    <main class="flex-1 p-6 md:p-8">
        <div class="max-w-4xl mx-auto card bg-white p-6 md:p-8">
            <h2 class="text-2xl font-bold text-gray-800 mb-6">Nhập Dữ Liệu Đã Nhập Kho</h2>

            <form id="importForm" action="${pageContext.request.contextPath}/import-data" method="post" enctype="multipart/form-data" class="space-y-6">
                <div class="space-y-2">
                    <label class="block text-sm font-medium text-gray-700">Tải lên file CSV</label>
                    <input type="file" id="csvFile" name="csvFile" accept=".csv" class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500">
                    <p class="text-xs text-gray-500">Định dạng CSV: import_id, supplier_id, user_id, import_date, note, material_id, quantity, price_per_unit, material_condition</p>
                </div>

                <div class="space-y-2">
                    <label class="block text-sm font-medium text-gray-700">Hoặc nhập thủ công</label>
                    <textarea id="manualData" name="manualData" placeholder="Dán dữ liệu CSV ở đây..." class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" rows="5"></textarea>
                </div>

                <button type="submit" class="btn-primary text-white px-6 py-3 rounded-lg w-full">Lưu Dữ Liệu</button>
            </form>

            <c:if test="${not empty message}">
                <div class="mt-4 p-4 bg-green-100 text-green-700 rounded-lg">${message}</div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="mt-4 p-4 bg-red-100 text-red-700 rounded-lg">${error}</div>
            </c:if>
        </div>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
    <script>
        document.getElementById('importForm').addEventListener('submit', (event) => {
            const csvFile = document.getElementById('csvFile').files[0];
            const manualData = document.getElementById('manualData').value.trim();
            if (!csvFile && !manualData) {
                event.preventDefault();
                Toastify({
                    text: "Vui lòng tải lên file CSV hoặc nhập dữ liệu thủ công!",
                    duration: 3000,
                    gravity: "top",
                    position: "center",
                    backgroundColor: "#ef4444"
                }).showToast();
            }
        });
    </script>
</body>
</html>
