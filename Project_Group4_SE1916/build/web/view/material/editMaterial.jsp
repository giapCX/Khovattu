edit.jsp

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Edit Material - Material Management System</title>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_list.css">
        <style>
            :root {
                --primary-color: #4361ee;
                --secondary-color: #3f37c9;
                --light-color: #f8f9fa;
                --dark-color: #212529;
                --danger-color: #dc3545;
                --success-color: #28a745;
                --border-radius: 8px;
                --box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
                --gray-100: #f8f9fa;
                --gray-200: #e9ecef;
                --gray-300: #dee2e6;
                --gray-400: #ced4da;
                --gray-600: #6c757d;
                --gray-800: #343a40;
            }

            body {
                background-color: #f5f7fb;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                margin: 0;
                min-height: 100vh;
            }

            /* Container styles */
            .container {
                width: 100%;
                max-width: 1200px;
                margin: 0 auto;
                padding: 0 15px;
            }

            /* Row and column styles */
            .row {
                display: flex;
                flex-wrap: wrap;
                margin-left: -15px;
                margin-right: -15px;
            }

            .col-lg-8 {
                flex: 0 0 66.666667%;
                max-width: 66.666667%;
                padding-left: 15px;
                padding-right: 15px;
                margin: 0 auto;
            }

            .col-md-6 {
                flex: 0 0 50%;
                max-width: 50%;
                padding-left: 15px;
                padding-right: 15px;
            }

            /* Form container */
            .form-container {
                background-color: white;
                border-radius: var(--border-radius);
                box-shadow: var(--box-shadow);
                padding: 2rem;
                margin-bottom: 2rem;
            }

            /* Form header */
            .form-header {
                color: var(--primary-color);
                border-bottom: 2px solid var(--primary-color);
                padding-bottom: 0.75rem;
                margin-bottom: 1.5rem;
                font-size: 1.5rem;
                font-weight: 600;
            }

            /* Form elements */
            .form-label {
                font-weight: 500;
                color: var(--dark-color);
                margin-bottom: 0.5rem;
                display: block;
            }

            .form-control, .form-select {
                display: block;
                width: 100%;
                padding: 0.75rem 1rem;
                font-size: 1rem;
                line-height: 1.5;
                color: var(--dark-color);
                background-color: #fff;
                border: 1px solid var(--gray-400);
                border-radius: var(--border-radius);
                transition: border-color 0.3s ease, box-shadow 0.3s ease;
            }

            .form-control:focus, .form-select:focus {
                outline: none;
                border-color: var(--primary-color);
                box-shadow: 0 0 0 0.25rem rgba(67, 97, 238, 0.25);
            }

            .form-select {
                appearance: none;
                background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3E%3Cpath fill='none' stroke='%23343a40' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M2 5l6 6 6-6'/%3E%3C/svg%3E");
                background-repeat: no-repeat;
                background-position: right 0.75rem center;
                background-size: 16px 12px;
            }

            textarea.form-control {
                resize: vertical;
                min-height: 100px;
            }

            /* Suppliers container */
            .suppliers-container {
                border: 1px solid var(--gray-300);
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
                background-color: var(--gray-200);
            }

            .form-check {
                display: flex;
                align-items: center;
                margin-bottom: 0.5rem;
            }

            .form-check-input {
                width: 1.25rem;
                height: 1.25rem;
                margin-right: 0.5rem;
                cursor: pointer;
            }

            .form-check-label {
                cursor: pointer;
            }

            /* Buttons */
            .btn {
                display: inline-flex;
                align-items: center;
                padding: 0.5rem 1.5rem;
                font-size: 1rem;
                font-weight: 500;
                text-align: center;
                text-decoration: none;
                border-radius: var(--border-radius);
                transition: all 0.3s ease;
                cursor: pointer;
            }

            .btn-primary {
                background-color: var(--primary-color);
                border: 1px solid var(--primary-color);
                color: white;
            }

            .btn-primary:hover {
                background-color: var(--secondary-color);
                border-color: var(--secondary-color);
                transform: translateY(-2px);
            }

            .btn-secondary, .btn-outline-secondary {
                background-color: transparent;
                border: 1px solid var(--gray-600);
                color: var(--gray-600);
            }

            .btn-secondary:hover, .btn-outline-secondary:hover {
                background-color: var(--gray-200);
                border-color: var(--gray-800);
                color: var(--gray-800);
            }

            /* Alert styles */
            .alert {
                position: relative;
                padding: 1rem;
                margin-bottom: 1rem;
                border: 1px solid transparent;
                border-radius: var(--border-radius);
                display: flex;
                align-items: center;
            }

            .alert-success {
                background-color: #d4edda;
                border-color: #c3e6cb;
                color: var(--success-color);
            }

            .alert-danger {
                background-color: #f8d7da;
                border-color: #f5c6cb;
                color: var(--danger-color);
            }

            .btn-close {
                background: transparent;
                border: none;
                font-size: 1rem;
                line-height: 1;
                padding: 0.25rem;
                cursor: pointer;
                position: absolute;
                right: 1rem;
                top: 1rem;
                color: inherit;
            }

            .btn-close::before {
                content: '\00d7';
                font-size: 1.25rem;
            }

            /* Error message */
            .error-message {
                color: var(--danger-color);
                font-size: 0.875rem;
                margin-top: 0.25rem;
                display: none;
            }

            /* Flex utilities */
            .d-flex {
                display: flex;
            }

            .justify-content-between {
                justify-content: space-between;
            }

            .justify-content-center {
                justify-content: center;
            }

            .items-center {
                align-items: center;
            }

            .gap-4 {
                gap: 1rem;
            }

            .mb-3 {
                margin-bottom: 1rem;
            }

            .mb-4 {
                margin-bottom: 1.5rem;
            }

            .mb-6 {
                margin-bottom: 2rem;
            }

            .me-2 {
                margin-right: 0.5rem;
            }

            /* Media queries */
            @media (max-width: 992px) {
                .col-lg-8 {
                    flex: 0 0 100%;
                    max-width: 100%;
                }
            }

            @media (max-width: 768px) {
                .form-container {
                    padding: 1.5rem;
                }

                .col-md-6 {
                    flex: 0 0 100%;
                    max-width: 100%;
                }
            }

            @media (max-width: 576px) {
                .container {
                    padding: 0 10px;
                }
            }
        </style>
    </head>
    <body class="bg-gray-50 min-h-screen font-sans antialiased">
        <%
            String role = (String) session.getAttribute("role");
        %>
        <!-- Sidebar -->
        <c:choose>
            <c:when test="${role == 'admin'}">
                <jsp:include page="/view/sidebar/sidebarAdmin.jsp" />
            </c:when>
            <c:when test="${role == 'direction'}">
                <jsp:include page="/view/sidebar/sidebarDirection.jsp" />
            </c:when>
            <c:when test="${role == 'warehouse'}">
                <jsp:include page="/view/sidebar/sidebarWarehouse.jsp" />
            </c:when>
            <c:when test="${role == 'employee'}">
                <jsp:include page="/view/sidebar/sidebarEmployee.jsp" />
            </c:when>
        </c:choose>
        <main class="flex-1 p-8 transition-all duration-300">
            <div class="container">
                <div class="row justify-content-center">
                    <div class="col-lg-8">
                        <div class="flex items-center gap-4 mb-6">
                            <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                                <i class="fas fa-bars text-2xl"></i>
                            </button>
                            <!--                            <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Edit Material</h2>-->
                        </div>
                        <div class="form-container">
                            <c:if test="${not empty message}">
                                <div class="alert alert-${messageType} fade show" role="alert">
                                    <i class="fas ${messageType == 'success' ? 'fa-check-circle' : 'fa-exclamation-circle'} me-2"></i>
                                    ${message}
                                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                </div>
                            </c:if>
                            <h2 class="form-header">
                                <i class="fas fa-edit me-2"></i>Edit Material
                            </h2>

                            <form id="editMaterialForm" action="${pageContext.request.contextPath}/EditMaterialController" method="post">
                                <input type="hidden" name="id" value="${material.materialId}" />
                                <input type="hidden" name="origin" value="${origin}" />
<!--                                <input type="hidden" name="supplierId" value="${supplierId}" />
                                <input type="hidden" name="supplierName" value="${supplierName}" />-->
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



                                <div class="d-flex justify-content-between">
                                    <div>
                                        <c:choose>
                                            <c:when test="${origin == 'listMaterialOfSupplier'}">
                                                <a href="${pageContext.request.contextPath}/FilterSupplierServlet?supplierId=${supplierId}&supplierName=${fn:escapeXml(supplierName)}" class="btn btn-secondary">
                                                    <i class="fas fa-arrow-left me-2"></i>Back to List
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="${pageContext.request.contextPath}/ListMaterialController" class="btn btn-secondary">
                                                    <i class="fas fa-arrow-left me-2"></i>Back to List
                                                </a>
                                            </c:otherwise>
                                        </c:choose>
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
        </main>
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script>
            // Bootstrap-compatible alert dismissal (without Bootstrap JS dependency)
            document.querySelectorAll('.btn-close').forEach(button => {
                button.addEventListener('click', () => {
                    const alert = button.closest('.alert');
                    if (alert) {
                        alert.style.opacity = '0';
                        setTimeout(() => alert.remove(), 300);
                    }
                });
            });

            $(document).ready(function () {
                // Auto-dismiss alerts after 5 seconds
                setTimeout(function () {
                    document.querySelectorAll('.alert').forEach(alert => {
                        alert.style.opacity = '0';
                        setTimeout(() => alert.remove(), 300);
                    });
                }, 5000);

                // Preview image when URL changes
                $('#imageUrl').on('change', function () {
                    const url = $(this).val();
                    if (url) {
                        console.log('Image URL changed:', url);
                    }
                });

//                // Validate at least one supplier is selected
//                $('#editMaterialForm').on('submit', function (e) {
//                    const checkedSuppliers = $('.supplier-checkbox:checked').length;
//                    if (checkedSuppliers === 0) {
//                        e.preventDefault();
//                        $('#supplierError').show();
//                    } else {
//                        $('#supplierError').hide();
//                    }
//                });
            });
        </script>
        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
    </body>
</html>