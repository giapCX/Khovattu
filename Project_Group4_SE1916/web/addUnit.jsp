<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
    <head>
            <meta charset="UTF-8">
            <title>Add Unit</title>
            <script src="https://cdn.tailwindcss.com"></script>
        <style>
            body {
                font-family: Arial, sans-serif;
                background-color: #f8f9fa;
                padding: 40px;
            }

            .add-unit-container {
                max-width: 500px;
                margin: auto;
                background-color: white;
                padding: 30px;
                border-radius: 16px;
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            }

            h1 {
                text-align: center;
                margin-bottom: 20px;
            }

            label {
                display: block;
                font-weight: bold;
                margin-bottom: 8px;
            }

            input[type="text"] {
                width: 100%;
                padding: 10px 14px;
                margin-bottom: 20px;
                border: 1px solid #ccc;
                border-radius: 12px; /* ✅ Bo tròn */
                box-sizing: border-box;
                transition: 0.3s;
            }

            input[type="text"]:focus {
                border-color: #007bff;
                outline: none;
                box-shadow: 0 0 5px rgba(0,123,255,0.3);
            }

            button {
                width: 100%;
                padding: 12px;
                background-color: #28a745;
                color: white;
                border: none;
                border-radius: 12px; /* ✅ Bo tròn */
                font-size: 16px;
                cursor: pointer;
                transition: background-color 0.3s;
            }

            button:hover {
                background-color: #218838;
            }

            .back-link {
                display: block;
                text-align: center;
                margin-top: 15px;
                text-decoration: none;
                color: #007bff;
            }

            .back-link:hover {
                text-decoration: underline;
            }
        </style>
    </head>
    <body class="bg-gray-50 min-h-screen p-8">

            <div class="max-w-md mx-auto bg-white p-6 rounded shadow">
                    <h2 class="text-2xl font-bold text-center mb-6 text-gray-800">Add New Unit</h2>

                    <c:if test="${not empty error}">
                            <p class="text-red-600 text-center mb-4">${error}</p>
                        </c:if>
                    <c:if test="${not empty success}">
                            <p class="text-green-600 text-center mb-4">${success}</p>
                        </c:if>

            <form action="addUnit" method="post">
                <label for="unitName">Unit Name:</label>
                <input type="text" id="name" name="name" placeholder="Enter unit name" required>

                <button type="submit">Add Unit</button>
            </form>

            <a href="unit" class="back-link">← Back to Unit List</a>
            </div>
    </body>
</html>
