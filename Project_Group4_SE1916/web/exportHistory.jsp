

<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <title>Lịch sử xuất kho</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        body {
            background-color: #f4f7fa;
            font-family: 'Arial', sans-serif;
            color: #333;
        }
        .container {
            max-width: 90rem;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .header h2 {
            font-size: 24px;
            font-weight: 600;
            color: #1e3a8a;
        }
        .filter-form {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        .form-control {
            padding: 8px 12px;
            border: 1px solid #d1d5db;
            border-radius: 4px;
            font-size: 14px;
        }
        .btn {
            padding: 8px 16px;
            background-color: #e5e7eb;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 500;
        }
        .btn:hover {
            background-color: #d1d5db;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: #fff;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        thead {
            background-color: #3b82f6;
            color: white;
        }
        th, td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #e5e7eb;
        }
        tbody tr:hover {
            background-color: #f3f4f6;
        }
        .action a {
            color: #3b82f6;
            text-decoration: none;
        }
        .action a:hover {
            text-decoration: underline;
        }
        .pagination {
            margin-top: 20px;
            display: flex;
            gap: 5px;
        }
        .pagination a {
            padding: 8px 12px;
            background-color: #e5e7eb;
            color: #333;
            text-decoration: none;
            border-radius: 4px;
        }
        .pagination a.active {
            background-color: #3b82f6;
            color: white;
        }
        .back-btn {
            display: block;
            margin-top: 20px;
            padding: 10px 20px;
            background-color: #3b82f6;
            color: white;
            text-align: center;
            text-decoration: none;
            border-radius: 4px;
            width: fit-content;
        }
        .back-btn:hover {
            background-color: #2563eb;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>Export History</h2>
        </div>
        <form method="get" action="exporthistory" class="filter-form">
            <input type="date" name="fromDate" value="${fromDate}" class="form-control" />
            <span>to</span>
            <input type="date" name="toDate" value="${toDate}" class="form-control" />
            <input type="text" name="exporter" value="${exporter}" placeholder="Input name of exporter" class="form-control" />
            <button type="submit" class="btn">Do</button>
        </form>
        <table>
            <thead>
                <tr>
                    <th>Code</th>
                    <th>Date</th>
                    <th>Exporter</th>
                    <th>Note</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="item" items="${historyData}">
                    <tr>
                        <td>${item.code}</td>
                        <td>${item.date}</td>
                        <td>${item.exporter}</td>
                        <td>${item.note}</td>
                        <td class="action"><a href="exporthistorydetail?exportId=${item.exportId}&keyword=${param.keyword}&sort=${param.sort}&page=1">View</a></td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
        <div class="pagination mt-4">
            <c:forEach begin="1" end="${totalPages}" var="i">
                <a href="exportHistory?page=${i}&fromDate=${param.fromDate}&toDate=${param.toDate}&importer=${param.importer}"
                   class="${i == currentPage ? 'active' : ''}">${i}</a>
            </c:forEach>
        </div>
        <a href="/" class="back-btn">Back to home</a>
    </div>
</body>
</html>

