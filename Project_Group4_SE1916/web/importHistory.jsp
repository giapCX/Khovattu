<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <title>Lịch sử nhập vật tư</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        body {
            background-color: #f9fafb;
            color: #1f2937;
            font-family: 'Inter', sans-serif;
        }
        .max-w-6xl {
            max-width: 72rem;
            margin: 0 auto;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: #fff;
            border-radius: 0.5rem;
            overflow: hidden;
            box-shadow: 0 1px 3px rgb(0 0 0 / 0.1);
        }
        thead tr {
            background-color: #2563eb;
            color: white;
        }
        th, td {
            padding: 0.75rem 1rem;
            text-align: left;
            border-bottom: 1px solid #e5e7eb;
        }
        tbody tr:hover {
            background-color: #f3f4f6;
        }
        .p-4 {
            padding: 1rem;
        }
    </style>
</head>
<body>
    <main class="flex-1 p-8 transition-all duration-300">
        <div class="max-w-6xl mx-auto">
            <div class="flex justify-between items-center mb-6">
                <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Lịch sử nhập vật tư</h2>
            </div>
            
            <!-- Bộ lọc -->
        <form method="get" action="importhistory" class="mb-4">
            <input type="date" name="fromDate" value="${fromDate}" class="form-control" />
            <input type="date" name="toDate" value="${toDate}" class="form-control" />
            <input type="text" name="importer" value="${importer}" placeholder="Người nhập" class="form-control" />
            <button type="submit" class="btn">Do</button>
        </form>
            <br><br/>
            <div class="table-container bg-white dark:bg-gray-800">
                <div class="overflow-x-auto">
                    <table class="w-full table-auto">
                        <thead>
                            <tr>
                                <th class="p-4">Mã phiếu</th>
                                <th class="p-4">Thành tiền</th>
                                <th class="p-4">Ngày nhập</th>
                                <th class="p-4">Người nhập</th>
                                <th class="p-4">Ghi chú</th>
                                <th class="p-4">Action</th>
                                
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="item" items="${historyData}">
                                <tr class="border-b border-gray-200 dark:border-gray-700">
                                    <td class="p-4">${item.voucherId}</td>
                                    <td class="p-4">${item.total}</td>
                                    <td class="p-4">${item.importDate}</td>
                                    <td class="p-4">${item.importerName}</td>
                                    <td class="p-4">${item.note}</td>
                                    <td class="p-4">
                                        <a href="importhistorydetail" class="text-primary-600">View</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
            <!-- Phân trang -->
        <div class="pagination mt-4">
            <c:forEach begin="1" end="${totalPages}" var="i">
                <a href="importhistory?page=${i}&fromDate=${param.fromDate}&toDate=${param.toDate}&importer=${param.importer}"
                   class="${i == currentPage ? 'active' : ''}">${i}</a>
            </c:forEach>
        </div>
        </div>
    </main>
</body>
</html>
