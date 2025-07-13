<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Unauthorized access</title>
        <script src="https://cdn.tailwindcss.com"></script>
    </head>
    <body class="bg-gray-100 flex items-center justify-center h-screen">
        <div class="bg-white p-10 rounded shadow-md text-center">
            <h1 class="text-2xl font-bold text-red-600 mb-4">You are not allowed to access this page.</h1>
            <p class="mb-6 text-gray-700">Please log in with an account that has appropriate access permissions.</p>
            <a href="${pageContext.request.contextPath}/login.jsp"
               class="inline-block px-6 py-3 bg-blue-600 text-white rounded hover:bg-blue-700 transition">
                Back to login.
            </a>
        </div>
    </body>
</html>
