<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Edit Material - Material Management System</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
        <style>
            :root {
                --primary-color: #4361ee;
                --secondary-color: #3f37c9;
                --light-color: #f8f9fa;
                --dark-color: #212529;
                --border-radius: 8px;
                --box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
            }

            body {
                background-color: #f5f7fb;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                padding-top: 2rem;
            }

            .form-container {
                background-color: white;
                border-radius: var(--border-radius);
                box-shadow: var(--box-shadow);
                padding: 2rem;
                margin-bottom: 2rem;
            }

            .form-header {
                color: var(--primary-color);
                border-bottom: 2px solid var(--primary-color);
                padding-bottom: 0.75rem;
                margin-bottom: 1.5rem;
            }

            .form-label {
                font-weight: 500;
                color: var(--dark-color);
                margin-bottom: 0.5rem;
            }

            .form-control, .form-select {
                border-radius: var(--border-radius);
                border: 1px solid #ced4da;
                padding: 0.75rem 1rem;
                transition: all 0.3s ease;
            }

            .form-control:focus, .form-select:focus {
                border-color: var(--primary-color);
                box-shadow: 0 0 0 0.25rem rgba(67, 97, 238, 0.25);
            }

            .suppliers-container {
                border: 1px solid #dee2e6;
                border-radius: var(--border-radius);
                padding: 1rem;
                max-height: 200px;
                overflow-y: auto;
                background-color: var(--light-color);
            }

            .supplier-item {
                margin-bottom: 0.5rem;
                padding: 0.5rem;
                border-radius: 4px;
                transition: background-color 0.2s;
            }

            .supplier-item:hover {
                background-color: #e9ecef;
            }

            .btn-primary {
                background-color: var(--primary-color);
                border-color: var(--primary-color);
                padding: 0.5rem 1.5rem;
                border-radius: var(--border-radius);
                font-weight: 500;
                transition: all 0.3s;
            }

            .btn-primary:hover {
                background-color: var(--secondary-color);
                border-color: var(--secondary-color);
                transform: translateY(-2px);
            }

            .btn-secondary {
                border-radius: var(--border-radius);
                padding: 0.5rem 1.5rem;
                font-weight: 500;
            }

            .alert {
                border-radius: var(--border-radius);
            }

            @media (max-width: 768px) {
                .form-container {
                    padding: 1.5rem;
                }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <div class="form-container">
                        <c:if test="${not empty message}">
                            <div class="alert alert-${messageType} alert-dismissible fade show" role="alert">
                                <i class="fas ${messageType == 'success' ? 'fa-check-circle' : 'fa-exclamation-circle'} me-2"></i>
                                ${message}
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        </c:if>

                        <h2 class="form-header">
                            <i class="fas fa-edit me-2"></i>Edit Material
                        </h2>

                        <form action="${pageContext.request.contextPath}/EditMaterialController" method="post">
                            <input type="hidden" name="id" value="${material.materialId}" />
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="code" class="form-label">Material Code</label>
                                    <input type="text" class="form-control" id="code" name="code" value="${material.code}" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="name" class="form-label">Material Name</label>
                                    <input type="text" class="form-control" id="name" name="name" value="${material.name}" required>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="category" class="form-label">Child Category</label>
                                    <select class="form-select" id="category" name="category" required>
                                        <option value="">Select Category</option>
                                        <c:forEach var="cat" items="${categories}">
                                            <option value="${cat.categoryId}" ${cat.categoryId == material.category.categoryId ? 'selected' : ''}>${cat.name}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="unit" class="form-label">Unit</label>
                                    <input type="text" class="form-control" id="unit" name="unit" value="${material.unit}" required>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label for="description" class="form-label">Description</label>
                                <textarea class="form-control" id="description" name="description" rows="3">${material.description}</textarea>
                            </div>

                            <div class="mb-3">
                                <label for="imageUrl" class="form-label">Image URL</label>
                                <input type="url" class="form-control" id="imageUrl" name="imageUrl" value="${material.imageUrl}" placeholder="https://example.com/image.jpg">
                            </div>

                            <div class="mb-4">
                                <label class="form-label">Suppliers</label>
                                <div class="suppliers-container">
                                    <div class="row">
                                        <c:forEach var="sup" items="${suppliers}">
                                            <div class="col-md-6">
                                                <div class="supplier-item">
                                                    <div class="form-check">
                                                        <input class="form-check-input" type="checkbox" 
                                                               id="supplier_${sup.supplierId}" name="suppliers" 
                                                               value="${sup.supplierId}"
                                                               <c:forEach var="matSup" items="${material.suppliers}">
                                                                   <c:if test="${matSup.supplierId == sup.supplierId}">checked</c:if>
                                                               </c:forEach>
                                                               >
                                                        <label class="form-check-label" for="supplier_${sup.supplierId}">
                                                            <i class="fas fa-truck me-2"></i>${sup.supplierName}
                                                        </label>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </div>
                            </div>

                            <div class="d-flex justify-content-between">
                                <div>
                                    <a onclick ="history.back()" class="btn btn-secondary">
                                        <i class="fas fa-arrow-left me-2"></i>Back to List
                                    </a>
                                </div>
                                <div>
                                    <button type="reset" class="btn btn-outline-secondary me-2">
                                        <i class="fas fa-undo me-2"></i>Reset
                                    </button>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-save me-2"></i>Save Material
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/js/all.min.js"></script>
        <script>
            $(document).ready(function () {
                // Auto-dismiss alerts after 5 seconds
                setTimeout(function () {
                    $('.alert').alert('close');
                }, 5000);

                // Preview image when URL changes
                $('#imageUrl').on('change', function () {
                    const url = $(this).val();
                    if (url) {
                        // You could add image preview functionality here
                        console.log('Image URL changed:', url);
                    }
                });
            });
        </script>
    </body>
</html>