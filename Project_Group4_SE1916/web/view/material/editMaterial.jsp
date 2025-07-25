<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Edit Material - Material Management System</title>
        <!-- Tailwind CSS -->
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>
        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_add_edit.css">
        <style>
            .autocomplete-container {
                position: relative;
            }
            
            .autocomplete-dropdown {
                position: absolute;
                top: 100%;
                left: 0;
                right: 0;
                background: white;
                border: 1px solid #d1d5db;
                border-top: none;
                border-radius: 0 0 0.5rem 0.5rem;
                max-height: 200px;
                overflow-y: auto;
                z-index: 1000;
                display: none;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            }
            
            .dark .autocomplete-dropdown {
                background: #374151;
                border-color: #4b5563;
            }
            
            .autocomplete-item {
                padding: 0.75rem 1rem;
                cursor: pointer;
                transition: background-color 0.2s;
            }
            
            .autocomplete-item:hover {
                background-color: #f3f4f6;
            }
            
            .dark .autocomplete-item:hover {
                background-color: #4b5563;
            }
            
            .autocomplete-item.selected {
                background-color: #3b82f6;
                color: white;
            }
            
            .image-preview {
                max-width: 200px;
                max-height: 200px;
                margin-top: 10px;
                display: none;
                border-radius: 0.5rem;
                border: 1px solid #d1d5db;
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
            <div class="max-w-6xl mx-auto card bg-white dark:bg-gray-800 p-6">
                <div class="flex items-center gap-4 mb-6">
                    <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                        <i class="fas fa-bars text-2xl"></i>
                    </button>
                    <h2 class="text-2xl font-bold text-gray-800 dark:text-white">
                        <i class="fas fa-edit mr-2"></i>Edit Material
                    </h2>
                </div>
                <!-- Error/Success Messages -->
                <c:if test="${not empty message}">
                    <div class="mb-4 p-3 rounded ${messageType == 'success' ? 'bg-green-100 text-green-700 dark:bg-green-900/20 dark:text-green-300' : 'bg-red-100 text-red-700 dark:bg-red-900/20 dark:text-red-300'}">
                        <i class="fas ${messageType == 'success' ? 'fa-check-circle' : 'fa-exclamation-circle'} mr-2"></i>${message}
                    </div>
                </c:if>
                <form id="editMaterialForm" action="${pageContext.request.contextPath}/EditMaterialController" method="post" enctype="multipart/form-data" class="space-y-4">
                    <input type="hidden" name="id" value="${material.materialId}" />
                    <input type="hidden" name="origin" value="${origin}" />
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div class="space-y-2">
                            <label for="code" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Material Code</label>
                            <input type="text" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" id="code" name="code" value="${material.code}" required placeholder="Enter material code">
                        </div>
                        <div class="space-y-2">
                            <label for="name" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Material Name</label>
                            <input type="text" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" id="name" name="name" value="${material.name}" required placeholder="Enter material name">
                        </div>
                    </div>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div class="space-y-2">
                            <label for="category" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Sub Category</label>
                            <div class="autocomplete-container">
                                <input type="text" id="category" name="categoryName" required autocomplete="off" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" value="${material.category.name}" placeholder="Select sub category">
                                <input type="hidden" id="categoryId" name="category" value="${material.category.categoryId}">
                                <div class="autocomplete-dropdown" id="categoryDropdown"></div>
                            </div>
                        </div>
                        <div class="space-y-2">
                            <label for="unit" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Unit</label>
                            <div class="autocomplete-container">
                                <input type="text" id="unit" name="unit" required autocomplete="off" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" value="${material.unit}" placeholder="Enter unit">
                                <div class="autocomplete-dropdown" id="unitDropdown"></div>
                            </div>
                        </div>
                    </div>
                    <div class="space-y-2">
                        <label for="description" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Description</label>
                        <textarea class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" id="description" name="description" rows="3" placeholder="Enter material description">${material.description}</textarea>
                    </div>
                    <div class="space-y-2">
                        <label for="imageFile" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Material Image</label>
                        <input type="file" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" id="imageFile" name="imageFile" accept="image/*">
                        <c:if test="${not empty material.imageUrl}">
                            <img id="imagePreview" class="image-preview" src="${pageContext.request.contextPath}/${material.imageUrl}" alt="Current Material Image" style="display: block;">
                        </c:if>
                        <c:if test="${empty material.imageUrl}">
                            <img id="imagePreview" class="image-preview" src="#" alt="Preview">
                        </c:if>
                    </div>
                    <div class="flex gap-4">
                        <c:choose>
                            <c:when test="${origin == 'listMaterialOfSupplier'}">
                                <a href="${pageContext.request.contextPath}/FilterSupplierServlet?supplierId=${supplierId}&supplierName=${fn:escapeXml(supplierName)}" class="btn-secondary text-white px-4 py-2 rounded-lg flex items-center justify-center">
                                    <i class="fas fa-arrow-left mr-2"></i>Back to List
                                </a>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/ListMaterialController" class="btn-secondary text-white px-4 py-2 rounded-lg flex items-center justify-center">
                                    <i class="fas fa-arrow-left mr-2"></i>Back to List
                                </a>
                            </c:otherwise>
                        </c:choose>
                        <button type="reset" class="btn-secondary text-white px-4 py-2 rounded-lg flex items-center justify-center">
                            <i class="fas fa-undo mr-2"></i>Reset
                        </button>
                        <button type="submit" class="btn-primary text-white px-4 py-2 rounded-lg flex items-center justify-center">
                            <i class="fas fa-save mr-2"></i>Save Material
                        </button>
                    </div>
                </form>
            </div>
        </main>
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script>
            // Data from server
            const categories = [
                <c:forEach var="cat" items="${categories}" varStatus="status">
                    {id: ${cat.categoryId}, name: "${cat.name}"}<c:if test="${!status.last}">,</c:if>
                </c:forEach>
            ];
            const units = [
                <c:forEach var="unit" items="${units}" varStatus="status">
                    "${unit}"<c:if test="${!status.last}">,</c:if>
                </c:forEach>
            ];

            $(document).ready(function() {
                // AJAX form submission
                $('#editMaterialForm').on('submit', function(e) {
                    e.preventDefault();
                    const formData = new FormData(this);
                    const origin = "${origin}";
                    const supplierId = "${supplierId}";
                    const supplierName = "${fn:escapeXml(supplierName)}";

                    $.ajax({
                        url: $(this).attr('action'),
                        type: 'POST',
                        data: formData,
                        processData: false,
                        contentType: false,
                        success: function(response) {
                            Swal.fire({
                                icon: 'success',
                                title: 'Success',
                                text: 'Material updated successfully!',
                                showConfirmButton: false,
                                timer: 2000,
                                customClass: { popup: 'animated fadeInDown' }
                            }).then(() => {
                                // Redirect based on origin
                                if (origin === 'listMaterialOfSupplier') {
                                    window.location.href = "${pageContext.request.contextPath}/FilterSupplierServlet?supplierId=" + supplierId + "&supplierName=" + encodeURIComponent(supplierName);
                                } else {
                                    window.location.href = "${pageContext.request.contextPath}/ListMaterialController";
                                }
                            });
                        },
                        error: function(xhr, status, error) {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error',
                                text: 'Failed to update material. Please try again.',
                                showConfirmButton: true,
                                customClass: { popup: 'animated fadeInDown' }
                            });
                        }
                    });
                });

                // Image preview functionality
                $('#imageFile').change(function() {
                    const file = this.files[0];
                    if (file) {
                        const reader = new FileReader();
                        reader.onload = function(e) {
                            $('#imagePreview').attr('src', e.target.result).show();
                        };
                        reader.readAsDataURL(file);
                    }
                });

                // Autocomplete functionality
                function setupAutocomplete(inputId, dropdownId, data, displayField, valueField, onSelect) {
                    const input = $('#' + inputId);
                    const dropdown = $('#' + dropdownId);
                    let selectedIndex = -1;

                    function showDropdown(filteredData) {
                        dropdown.empty();
                        if (filteredData.length === 0) {
                            dropdown.hide();
                            return;
                        }

                        filteredData.forEach((item, index) => {
                            const value = typeof item === 'string' ? item : item[displayField];
                            const div = $('<div class="autocomplete-item">').text(value);
                            div.click(function() {
                                input.val(value);
                                if (onSelect) {
                                    onSelect(item);
                                }
                                dropdown.hide();
                            });
                            dropdown.append(div);
                        });
                        dropdown.show();
                        selectedIndex = -1;
                    }

                    input.on('input', function() {
                        const value = $(this).val().toLowerCase();
                        if (value.length === 0) {
                            dropdown.hide();
                            return;
                        }

                        const filteredData = data.filter(item => {
                            const itemValue = typeof item === 'string' ? item : item[displayField];
                            return itemValue.toLowerCase().includes(value);
                        });

                        showDropdown(filteredData);
                    });

                    input.on('click', function() {
                        if ($(this).val().length === 0) {
                            showDropdown(data);
                        }
                    });

                    input.on('keydown', function(e) {
                        const items = dropdown.find('.autocomplete-item');

                        if (e.key === 'ArrowDown') {
                            e.preventDefault();
                            selectedIndex = Math.min(selectedIndex + 1, items.length - 1);
                            items.removeClass('selected');
                            if (selectedIndex >= 0) {
                                $(items[selectedIndex]).addClass('selected');
                            }
                        } else if (e.key === 'ArrowUp') {
                            e.preventDefault();
                            selectedIndex = Math.max(selectedIndex - 1, -1);
                            items.removeClass('selected');
                            if (selectedIndex >= 0) {
                                $(items[selectedIndex]).addClass('selected');
                            }
                        } else if (e.key === 'Enter') {
                            e.preventDefault();
                            if (selectedIndex >= 0) {
                                $(items[selectedIndex]).click();
                            }
                        } else if (e.key === 'Escape') {
                            dropdown.hide();
                        }
                    });

                    // Hide dropdown when clicking outside
                    $(document).on('click', function(e) {
                        if (!input.is(e.target) && !dropdown.is(e.target) && dropdown.has(e.target).length === 0) {
                            dropdown.hide();
                        }
                    });
                }

                // Setup autocomplete for units
                setupAutocomplete('unit', 'unitDropdown', units, null, null, null);
                // Setup autocomplete for categories
                setupAutocomplete('category', 'categoryDropdown', categories, 'name', 'id', function(item) {
                    $('#categoryId').val(item.id);
                });

                // Reset form functionality
                $('button[type="reset"]').click(function() {
                    setTimeout(function() {
                        $('#categoryId').val('');
                        $('#imagePreview').hide();
                        $('.autocomplete-dropdown').hide();
                    }, 10);
                });
            });
        </script>
        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tablesort.js"></script>
    </body>
</html>