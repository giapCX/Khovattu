<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit Child Category</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <a href="${pageContext.request.contextPath}/ListParentCategoryController" class="btn btn-secondary mb-3">
        <i class="fas fa-arrow-left me-2"></i>Back to Material List
    </a>

    <div class="card p-4 shadow">
        <h3 class="text-primary mb-4">
            <i class="fas fa-edit me-2"></i>Edit Child Category
        </h3>

        <c:if test="${not empty successMessage}">
            <div class="alert alert-success">${successMessage}</div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger">${errorMessage}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/EditChildCategoryController" method="post">
            <!-- Ẩn categoryId -->
            <input type="hidden" name="categoryId" value="${categoryToEdit.categoryId}" />

            <!-- Tên danh mục -->
            <div class="mb-3">
                <label class="form-label">Child Category Name</label>
                <input type="text" class="form-control" name="newCategoryName"
                       value="${categoryToEdit.name}" required />
            </div>

            <!-- Chọn danh mục cha -->
            <div class="mb-3">
                <label class="form-label">Parent Category</label>
                <select class="form-select" name="parentId" required>
                    <option value="">Select Parent Category</option>
                    <c:forEach var="parentCat" items="${parentCategories}">
                        <option value="${parentCat.categoryId}"
                                <c:if test="${parentCat.categoryId == categoryToEdit.parentId}">selected</c:if>>
                            ${parentCat.name}
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div class="d-flex justify-content-end">
                <a href="${pageContext.request.contextPath}/ListParentCategoryController" class="btn btn-secondary me-3">
                    <i class="fas fa-times me-1"></i>Cancel
                </a>
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save me-1"></i>Update Child Category
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Bootstrap + FontAwesome -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/js/all.min.js"></script>
</body>
</html>
