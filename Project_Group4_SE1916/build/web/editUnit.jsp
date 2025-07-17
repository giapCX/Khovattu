<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
    <head>
            <meta charset="UTF-8">
            <title>Edit Unit</title>
            <script src="https://cdn.tailwindcss.com"></script>
            <style>
                 body {
                font-family: Arial, sans-serif;
                background-color: #f8f9fa;
                padding: 40px;
            }

            .edit-unit-container {
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
                margin-bottom: 0px;
            }

            input[type="text"] {
                width: 100%;
                padding: 10px 14px;
                margin-bottom: 5px;
                border: 1px solid #ccc;
                border-radius: 12px;
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
            select {
                width: 100%;
                padding: 10px 14px;
                margin-bottom: 20px;
                border: 1px solid #ccc;
                border-radius: 12px;
                box-sizing: border-box;
                transition: 0.3s;
                appearance: none; 
                background-color: white;
                background-image: url("data:image/svg+xml;utf8,<svg fill='gray' height='20' viewBox='0 0 24 24' width='20' xmlns='http://www.w3.org/2000/svg'><path d='M7 10l5 5 5-5z'/></svg>");
                background-repeat: no-repeat;
                background-position: right 14px center;
                background-size: 18px 18px;
            }

            select:focus {
                border-color: #007bff;
                outline: none;
                box-shadow: 0 0 5px rgba(0,123,255,0.3);
            }
        </style>
    </head>
    <body class="bg-gray-50 min-h-screen p-8">

            <div class="edit-unit-container">
                    <h2 class="text-2xl font-bold text-center mb-6 text-gray-800">Edit Unit</h2>

                    <c:if test="${not empty error}">
                            <p class="text-red-600 text-center mb-4">${error}</p>
                        </c:if>
                    <c:if test="${not empty success}">
                            <p class="text-green-600 text-center mb-4">${success}</p>
                        </c:if>

                        <form method="post" action="editUnit">
                                <input type="hidden" name="unitId" value="${unit.unitId}" />

                            <label for="name">Unit Name:</label>
                            <input type="text" id="name" name="name" placeholder="Enter unit name" required value="${unit.name}" />
                            <label for="status">Status:</label>
                            <select id="status" name="status">
                                    <option value="active" ${unit.status == 'active' ? 'selected' : ''}>Active</option>
                                    <option value="inactive" ${unit.status == 'inactive' ? 'selected' : ''}>Inactive</option>
                             </select>

                            <button type="submit">Update Unit</button>
                        </form>

                    <a href="unit" class="back-link">← Back to Unit List</a>
                </div>

    </body>
</html>
