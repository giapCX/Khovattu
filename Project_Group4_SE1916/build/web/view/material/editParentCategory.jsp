<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Parent Category</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f4f6f9;
            padding-top: 20px;
        }
        .container {
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            padding: 2rem;
        }
        .form-control, .form-select {
            border-radius: 8px;
            border: 1px solid #d1d5db;
            padding: 10px;
        }
        .form-control:focus, .form-select:focus {
            border-color: #60a5fa;
            box-shadow: 0 0 0 3px rgba(96, 165, 250, 0.1);
        }
        .btn {
            border-radius: 8px;
            padding: 10px 20px;
            transition: all 0.3s ease;
        }
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header-actions flex justify-between items-center mb-6">
            <h2>Edit Parent Category</h2>
            <a href="${pageContext.request.contextPath}/ListParentCategoryController" class="btn btn-secondary">Back to List</a>
        </div>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger" role="alert">${errorMessage}</div>
        </c:if>
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success" role="alert">${successMessage}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/EditParentCategoryController" method="post" id="editCategoryForm">
            <input type="hidden" name="categoryId" value="${category.categoryId}">
            <div class="mb-3">
                <label for="name" class="form-label">Category Name</label>
                <input type="text" class="form-control" id="name" name="name" required placeholder="Enter parent category name" value="${category.name}">
            </div>
            <div class="mb-3">
                <label for="status" class="form-label">Status</label>
                <select class="form-select" id="status" name="status" required>
                    <option value="active" ${category.status == 'active' ? 'selected' : ''}>Active</option>
                    <option value="inactive" ${category.status == 'inactive' ? 'selected' : ''}>Inactive</option>
                </select>
            </div>
            <button type="submit" class="btn btn-primary">Update Category</button>
            <button type="button" class="btn btn-secondary" onclick="document.getElementById('editCategoryForm').reset();">Cancel</button>
        </form>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        <c:if test="${not empty successMessage}">
            Swal.fire({
                icon: 'success',
                title: 'Success',
                text: '${successMessage}',
                showConfirmButton: false,
                timer: 2000,
                customClass: { popup: 'animated fadeInDown' }
            });
            <% session.removeAttribute("successMessage"); %>
        </c:if>
    </script>
</body>
</html>