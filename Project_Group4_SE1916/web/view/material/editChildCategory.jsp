<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Select and Edit Child Category</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <style>
        :root {
            --primary-color: #4361ee;
            --secondary-color: #3f37c9;
            --light-color: #f8f9fa;
            --dark-color: #212529;
            --success-color: #2a9d8f;
            --error-color: #e76f51;
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
            display: flex;
            align-items: center;
        }
        
        .form-header i {
            margin-right: 10px;
        }
        
        .form-label {
            font-weight: 500;
            color: var(--dark-color);
            margin-bottom: 0.5rem;
        }
        
        .form-control, .form-select, .select2-container--default .select2-selection--single {
            border-radius: var(--border-radius);
            border: 1px solid #ced4da;
            padding: 0.75rem 1rem;
            transition: all 0.3s ease;
        }
        
        .form-control:focus, .form-select:focus, .select2-container--default .select2-selection--single:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 0.25rem rgba(67, 97, 238, 0.25);
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
            padding: 1rem 1.5rem;
        }
        
        .alert-success {
            background-color: rgba(42, 157, 143, 0.1);
            border-color: var(--success-color);
            color: var(--success-color);
        }
        
        .alert-danger {
            background-color: rgba(231, 111, 81, 0.1);
            border-color: var(--error-color);
            color: var(--error-color);
        }
        
        .back-btn {
            margin-bottom: 1.5rem;
            transition: all 0.3s;
        }
        
        .back-btn:hover {
            transform: translateX(-3px);
        }
        
        .select2-container--default .select2-selection--single {
            height: calc(2.75rem + 2px);
            display: flex;
            align-items: center;
        }
        
        .select2-container--default .select2-selection--single .select2-selection__arrow {
            height: calc(2.75rem + 2px);
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
                <a href="${pageContext.request.contextPath}/ListMaterialController" class="btn btn-secondary back-btn">
                    <i class="fas fa-arrow-left me-2"></i>Back to Material List
                </a>
                
                <div class="form-container">
                    <h2 class="form-header">
                        <i class="fas fa-edit"></i>Select and Edit Child Category
                    </h2>
                    
                    <!-- Hiển thị thông báo -->
                    <c:if test="${not empty successMessage}">
                        <div class="alert alert-success alert-dismissible fade show">
                            <i class="fas fa-check-circle me-2"></i>${successMessage}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>
                    <c:if test="${not empty errorMessage}">
                        <div class="alert alert-danger alert-dismissible fade show">
                            <i class="fas fa-exclamation-circle me-2"></i>${errorMessage}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <!-- Form chọn và chỉnh sửa danh mục con -->
                    <form action="${pageContext.request.contextPath}/EditChildCategoryController" method="post" id="editForm">
                        <div class="mb-4">
                            <label for="categoryId" class="form-label">Select Child Category</label>
                            <select class="form-select select2" id="categoryId" name="categoryId" required>
                                <option value="">Select Child Category</option>
                                <c:forEach var="childCat" items="${childCategories}">
                                    <option value="${childCat.categoryId}" 
                                            data-name="${childCat.name}" 
                                            data-parent-id="${childCat.parentId}">
                                        ${childCat.name}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        
                        <div class="mb-4">
                            <label for="newCategoryName" class="form-label">New Child Category Name</label>
                            <input type="text" class="form-control" id="newCategoryName" name="newCategoryName" required
                                   placeholder="Enter new child category name">
                        </div>
                        
                        <div class="mb-4">
                            <label for="parentCategory" class="form-label">Parent Category</label>
                            <select class="form-select" id="parentCategory" name="parentId" required>
                                <option value="">Select Parent Category</option>
                                <c:forEach var="parentCat" items="${parentCategories}">
                                    <option value="${parentCat.categoryId}">${parentCat.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        
                        <div class="d-flex justify-content-end mt-4">
                            <button type="reset" class="btn btn-secondary me-3">
                                <i class="fas fa-times me-2"></i>Cancel
                            </button>
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save me-2"></i>Update Child Category
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/js/all.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
    <script>
        $(document).ready(function() {
            // Add animation to form when page loads
            $('.form-container').hide().fadeIn(400);
            
            // Khởi tạo Select2 cho dropdown child category
            $('#categoryId').select2({
                placeholder: "Select Child Category",
                allowClear: true,
                width: '100%'
            });
            
            // Cập nhật chi tiết danh mục khi chọn child category
            $('#categoryId').on('change', function() {
                const selectedOption = $(this).find('option:selected');
                const name = selectedOption.data('name');
                const parentId = selectedOption.data('parent-id');
                
                $('#newCategoryName').val(name || '');
                $('#parentCategory').val(parentId || '');
            });
            
            // Reset form hoàn toàn khi nhấn Cancel
            $('button[type="reset"]').click(function() {
                $('#editForm')[0].reset();
                $('#categoryId').val('').trigger('change'); // Reset Select2
                $('.alert').alert('close');
            });
        });
    </script>
</body>
</html>