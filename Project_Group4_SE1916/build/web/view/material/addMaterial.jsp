<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Add Material</title>
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
            if (role == null || (!role.equals("admin") && !role.equals("direction"))) {
                response.sendRedirect(request.getContextPath() + "/view/accessDenied.jsp");
                return;
            }
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

        <!-- Main Content -->
        <main class="flex-1 p-8 transition-all duration-300">
            <div class="max-w-6xl mx-auto card bg-white dark:bg-gray-800 p-6">
                <div class="flex items-center gap-4 mb-6">
                    <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                        <i class="fas fa-bars text-2xl"></i>
                    </button>
                    <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Add New Material</h2>
                </div>

                <!-- Error/Success Messages -->
                <c:if test="${not empty message}">
                    <div class="mb-4 p-3 rounded ${messageType == 'success' ? 'bg-green-100 text-green-700 dark:bg-green-900/20 dark:text-green-300' : 'bg-red-100 text-red-700 dark:bg-red-900/20 dark:text-red-300'}">
                        <i class="fas ${messageType == 'success' ? 'fa-check-circle' : 'fa-exclamation-circle'} mr-2"></i>${message}
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/AddMaterialController" method="post" enctype="multipart/form-data" id="addMaterialForm" class="space-y-4">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div class="space-y-2">
                            <label for="name" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Material Name</label>
                            <input type="text" id="name" name="name" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" placeholder="Enter material name">
                        </div>
                        
                        <div class="space-y-2">
                            <label for="unit" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Unit</label>
                            <div class="autocomplete-container">
                                <input type="text" id="unit" name="unit" required autocomplete="off" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" placeholder="Enter unit">
                                <div class="autocomplete-dropdown" id="unitDropdown"></div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div class="space-y-2">
                            <label for="parentCategory" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Root Category</label>
                            <div class="autocomplete-container">
                                <input type="text" id="parentCategory" name="parentCategory" required autocomplete="off" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" placeholder="Select root category">
                                <input type="hidden" id="parentCategoryId" name="parentCategoryId">
                                <div class="autocomplete-dropdown" id="parentCategoryDropdown"></div>
                            </div>
                        </div>
                        
                        <div class="space-y-2">
                            <label for="childCategory" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Sub Category</label>
                            <div class="autocomplete-container">
                                <input type="text" id="childCategory" name="childCategoryName" required autocomplete="off" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" placeholder="Select sub category">
                                <input type="hidden" id="childCategoryId" name="childCategory">
                                <div class="autocomplete-dropdown" id="childCategoryDropdown"></div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="space-y-2">
                        <label for="description" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Description</label>
                        <textarea id="description" name="description" rows="3" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" placeholder="Enter material description"></textarea>
                    </div>
                    
                    <div class="space-y-2">
                        <label for="imageFile" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Material Image</label>
                        <input type="file" id="imageFile" name="imageFile" accept="image/*" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                        <img id="imagePreview" class="image-preview" src="#" alt="Preview">
                    </div>

                    <div class="flex gap-4">
                        <button type="reset" class="btn-secondary text-white px-4 py-2 rounded-lg flex items-center justify-center">
                            <i class="fas fa-undo mr-2"></i> Reset
                        </button>
                        <button type="submit" class="btn-primary text-white px-4 py-2 rounded-lg flex items-center justify-center">
                            <i class="fas fa-save mr-2"></i> Save Material
                        </button>
                    </div>
                </form>

            </div>
            <div class="mt-6 flex justify-center gap-4 max-w-2xl mx-auto w-full">
                <div class="w-1/3">
                    <a href="${pageContext.request.contextPath}/ListMaterialController?action=list" 
                       class="btn-secondary text-white px-6 py-3 rounded-lg">
                        Back to Material List
                    </a>
                </div>
                <div class="w-1/2">
                    <div class="w-full">
                        <jsp:include page="/view/backToDashboardButton.jsp" />
                    </div>
                </div>
            </div>
        </main>

        <!--JavaScript -->
        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script>
            // Data from server
            const parentCategories = [
                <c:forEach var="cat" items="${parentCategories}" varStatus="status">
                    {id: ${cat.categoryId}, name: "${cat.name}"}<c:if test="${!status.last}">,</c:if>
                </c:forEach>
            ];
            
            const childCategories = [
                <c:forEach var="cat" items="${childCategories}" varStatus="status">
                    {id: ${cat.categoryId}, name: "${cat.name}", parentId: ${cat.parentId}}<c:if test="${!status.last}">,</c:if>
                </c:forEach>
            ];
            
            const units = [
                <c:forEach var="unit" items="${units}" varStatus="status">
                    "${unit}"<c:if test="${!status.last}">,</c:if>
                </c:forEach>
            ];

            // Success message with SweetAlert
            <c:if test="${not empty message && messageType == 'success'}">
                Swal.fire({
                    icon: 'success',
                    title: 'Success',
                    text: '${message}',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: { popup: 'animated fadeInDown' }
                }).then(() => {
                    document.getElementById('addMaterialForm').reset();
                    $('#imagePreview').hide();
                });
            </c:if>
            
            $(document).ready(function() {
                // Image preview functionality
                $('#imageFile').change(function() {
                    const file = this.files[0];
                    if (file) {
                        const reader = new FileReader();
                        reader.onload = function(e) {
                            $('#imagePreview').attr('src', e.target.result).show();
                        }
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
                
                // Setup autocomplete for parent categories
                setupAutocomplete('parentCategory', 'parentCategoryDropdown', parentCategories, 'name', 'id', function(item) {
                    $('#parentCategoryId').val(item.id);
                    // Filter child categories based on selected parent
                    const filteredChildren = childCategories.filter(child => child.parentId === item.id);
                    
                    // Clear child category selection
                    $('#childCategory').val('');
                    $('#childCategoryId').val('');
                    
                    // Update child category autocomplete
                    setupChildCategoryAutocomplete(filteredChildren);
                });
                
                // Setup autocomplete for child categories
                function setupChildCategoryAutocomplete(filteredChildren) {
                    setupAutocomplete('childCategory', 'childCategoryDropdown', filteredChildren, 'name', 'id', function(item) {
                        $('#childCategoryId').val(item.id);
                    });
                }
                
                // Initial setup for child categories (all categories)
                setupChildCategoryAutocomplete(childCategories);
                
                // Reset form functionality
                $('button[type="reset"]').click(function() {
                    setTimeout(function() {
                        $('#parentCategoryId').val('');
                        $('#childCategoryId').val('');
                        $('#imagePreview').hide();
                        $('.autocomplete-dropdown').hide();
                    }, 10);
                });
            });
        </script>

    </body>
</html>