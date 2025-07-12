<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Proposal</title>
        <!-- Tailwind CSS -->
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>
        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_add_edit.css">
    </head>
    <body class="bg-gray-50 min-h-screen font-sans antialiased">
        <%
            String role = (String) session.getAttribute("role");
            Integer userId = (Integer) session.getAttribute("userId");
            String userFullName = (String) session.getAttribute("userFullName");
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
        <main class="flex-1 p-8 transition-all duration-300 min-h-screen">
            <div class="max-w-6xl mx-auto card bg-white dark:bg-gray-800 p-6">
                <div class="flex items-center gap-4 mb-6">
                    <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                        <i class="fas fa-bars text-2xl"></i>
                    </button>
                    <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Proposal Material</h2>
                </div>

                <form action="EditProposalServlet" method="post" class="space-y-4">
                    <input type="hidden" name="proposalId" value="${proposalId}">
                    <div class="space-y-2">
                        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Proposer</label>
                        <input type="text" value="${sessionScope.userFullName}" readonly class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white"  >
                    </div>
                    <div class="space-y-2">
                        <label for="proposalType" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Type of proposal</label>
                        <select id="proposalType" name="proposalType" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                            <option value="import_from_supplier">Purchase</option>
                            <option value="import_returned">Retrieve</option>
                            <option value="export">Export</option>
                        </select>
                    </div>
                    <div class="space-y-2">
                        <label for="note" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Note</label>
                        <textarea class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" name="note" rows="3" required>${proposal.note}</textarea>
                    </div> 

                    <div class="space-y-2">
                        <label for="note" class="block text-sm font-medium text-gray-700 dark:text-gray-300">List of Proposed Materials</label>
                        <br/>
                        <div class="table-container bg-white dark:bg-gray-800">
                            <div class="overflow-x-auto">
                                <table class="w-full table-fixed text-sm" id="importDetailsTable">
                                    <thead>
                                        <tr class="bg-primary-600 text-white text-sm">
                                            <th class="p-2 text-left w-[20%]">Name of Material</th>
                                            <th class="p-2 text-left w-[7%]">Unit</th> 
                                            <th class="p-2 text-left w-[10%]">Quantity</th>
                                            <th class="p-2 text-left w-[9%]">Condition</th> 
                                            <th class="p-2 text-left w-[23%] supplier-column">Supplier</th>
                                            <th class="p-2 text-left w-[12%] price-column">Price (VNĐ)</th>
                                            <th class="p-2 text-left w-[13%] constructionSite-column">Construction Site</th>
                                            <th class="p-2 text-left w-[5%]">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody id="itemsBody">
                                        <c:forEach var="detail" items="${proposal.proposalDetails}">

                                            <tr class="border-b border-gray-200 dark:border-gray-700">
                                                <td class="pr-2">
                                                    <input list="materialList" required class="w-full px-2 py-2 border border-gray-300 dark:border-gray-600 rounded-md nameMaterialInput" name="materialName[]" autocomplete="off" placeholder="Enter material name" value="${detail.materialName}">
                                                    <datalist id="materialList">
                                                        <c:forEach var="cat" items="${material}">
                                                            <option 
                                                                value="${cat.name}" 
                                                                data-id="${cat.materialId}" 
                                                                data-parent="${cat.category.categoryId}" 
                                                                data-unit="${cat.unit}">
                                                                ${cat.name}
                                                            </option>
                                                        </c:forEach>
                                                    </datalist>
                                                    <input type="hidden" name="materialId[]" class="materialIdHidden">
                                                </td>
                                                <td class="pr-2">
                                                    <input type="text" name="unit[]" value="${detail.unit}" class="w-full px-2 py-2 border border-gray-300 dark:border-gray-600 rounded-md unitMaterial" readonly>
                                                </td>
                                                <td class="pr-2">
                                                    <input type="number" name="quantity[]" value="${detail.quantity}" class="w-full px-2 py-2 border border-gray-300 dark:border-gray-600 rounded-md" step="1" min="1" required>
                                                </td>
                                                <td class="pr-2">
                                                    <select name="materialCondition[]" class="w-full px-2 py-2 border border-gray-300 dark:border-gray-600 rounded-md conditionSelect" required>
                                                        <option value="new" ${detail.materialCondition == 'new' ? 'selected' : ''}>New</option>
                                                        <option value="used" ${detail.materialCondition == 'used' ? 'selected' : ''}>Used</option>
                                                        <option class="damaged-option" value="damaged" ${detail.materialCondition == 'damaged' ? 'selected' : ''}>Damaged</option>
                                                    </select>
                                                </td>
                                                <td class="supplier-column hidden">
                                                    <input list="supplierList" name="supplierName[]" value="${detail.supplierName}" class="w-full px-2 py-2 border border-gray-300 dark:border-gray-600 rounded-md" placeholder="Enter supplier name">
                                                    <datalist id="supplierList">
                                                        <c:forEach var="supplier" items="${suppliers}">
                                                            <option value="${supplier.supplierName}" data-id="${supplier.supplierId}">${supplier.supplierName}</option>
                                                        </c:forEach>
                                                    </datalist>
                                                    <input type="hidden" name="supplierId[]" class="supplierIdHidden">
                                                </td>
                                                <td class="price-column hidden">
                                                    <input 
                                                        type="number" 
                                                        name="pricePerUnit[]" 
                                                        value="<fmt:formatNumber value='${detail.price}' type='number' groupingUsed='false' maxFractionDigits='0' />" 
                                                        class="w-full px-2 py-2 border border-gray-300 dark:border-gray-600 rounded-md" 
                                                        step="1000" min="0" />
                                                </td>
                                                <td class="constructionSite-column hidden">
                                                    <input list="siteList" name="siteName[]" value="${detail.siteName}" class="w-full px-2 py-2 border border-gray-300 dark:border-gray-600 rounded-md" placeholder="Enter site name">
                                                    <datalist id="siteList">
                                                        <c:forEach var="site" items="${constructionSites}">
                                                            <option value="${site.siteName}" data-id="${site.siteId}">${site.siteName}</option>
                                                        </c:forEach>
                                                    </datalist>
                                                    <input type="hidden" name="siteId[]" class="siteIdHidden">
                                                </td>
                                                <td>
                                                    <button type="button" class="p-2 text-red-600 hover:text-red-800 pr-2" onclick="removeRow(this)">
                                                        <i class="fas fa-trash"></i>
                                                    </button>
                                                </td>
                                            </tr>
                                        </c:forEach>

                                    </tbody>
                                </table>

                            </div>
                            <button type="button" class="p-2 font-medium bg-green-500 hover:bg-green-600 text-white rounded-md border border-green-500 hover:border-green-600 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-opacity-50 transition-all duration-200 flex items-center" onclick="addRow()">
                                <i class="fas fa-plus me-2"></i>Add
                            </button>
                        </div>
                    </div>
                    <input type="hidden" id="itemCount" name="itemCount" value="1">

                    <div class="flex gap-4 justify-center">
                        <button type="submit" class="btn-primary text-white px-6 py-3 rounded-lg flex items-center justify-center">
                            <i class="fas fa-plus-circle mr-2"></i> Submit 
                        </button>

                        <a href="${pageContext.request.contextPath}/ProposalServlet" onclick="event.preventDefault(); document.querySelector('form').reset(); window.location.href = this.href;" class="bg-yellow-500 hover:bg-yellow-600 text-white px-6 py-3 rounded-lg inline-flex items-center">
                            <i class="fas fa-undo mr-2"></i> Reset form
                        </a>
                    </div>

                </form>

                <c:if test="${not empty error}">
                    <div class="mb-4 p-3 rounded
                         ${error == 'successful!' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}">
                        ${error}
                    </div>
                </c:if>
                <c:choose>
                    <c:when test="${role == 'warehouse'}">
                        <div class="mt-4 flex justify-center">
                            <a href="${pageContext.request.contextPath}/ListProposalServlet" class="btn-secondary text-white px-6 py-3 rounded-lg">Back to list proposal</a>
                        </div>
                    </c:when>
                    <c:when test="${role == 'employee'}">
                        <div class="mt-4 flex justify-center">
                            <a href="${pageContext.request.contextPath}/ListProposalServlet" class="btn-secondary text-white px-6 py-3 rounded-lg">Back to list proposal</a>
                        </div>
                    </c:when>
                </c:choose>
            </div>
        </main>

        <script>
            function addRow() {
                const tbody = document.getElementById('itemsBody');
                const newRow = tbody.rows[0].cloneNode(true);
                newRow.querySelectorAll('input').forEach(input => input.value = '');
                newRow.querySelectorAll('select').forEach(select => select.selectedIndex = 0);
                tbody.appendChild(newRow);
                document.getElementById('itemCount').value = tbody.rows.length;
                toggleMaterialConditionOptions(document.getElementById('proposalType').value);
            }
            toggleMaterialConditionOptions(document.getElementById('proposalType').value);

            function removeRow(btn) {
                const tbody = document.getElementById('itemsBody');
                if (tbody.rows.length > 1) {
                    btn.closest('tr').remove();
                    document.getElementById('itemCount').value = tbody.rows.length;
                }
            }
            document.addEventListener('input', function (e) {
                if (e.target.classList.contains('nameMaterialInput')) {
                    const input = e.target;
                    const value = input.value.trim();
                    const row = input.closest('tr');
                    const hiddenInput = row.querySelector('.materialIdHidden');
                    const unitInput = row.querySelector('.unitMaterial');
                    const datalist = document.getElementById('materialList');
                    const options = datalist.options;

                    let foundId = '';
                    let foundUnit = '';

                    for (let i = 0; i < options.length; i++) {
                        if (options[i].value === value) {
                            foundId = options[i].getAttribute('data-id');
                            foundUnit = options[i].getAttribute('data-unit');
                            break;
                        }
                    }

                    hiddenInput.value = foundId;
                    unitInput.value = foundUnit;
                }
                if (e.target.name === 'siteName[]') {
                    const input = e.target;
                    const value = input.value.trim();
                    const row = input.closest('tr');
                    const hiddenInput = row.querySelector('.siteIdHidden');
                    const datalist = document.getElementById('siteList');
                    const options = datalist.options;

                    let foundId = '';

                    for (let i = 0; i < options.length; i++) {
                        if (options[i].value === value) {
                            foundId = options[i].getAttribute('data-id');
                            break;
                        }
                    }

                    if (hiddenInput)
                        hiddenInput.value = foundId;
                }

                if (e.target.name === 'supplierName[]') {
                    const input = e.target;
                    const value = input.value.trim();
                    const row = input.closest('tr');
                    const hiddenInput = row.querySelector('.supplierIdHidden');
                    const datalist = document.getElementById('supplierList');

                    const options = datalist.options;
                    let foundId = '';

                    for (let i = 0; i < options.length; i++) {
                        if (options[i].value === value) {
                            foundId = options[i].getAttribute('data-id');
                            break;
                        }
                    }

                    hiddenInput.value = foundId;
                }

            });


            function toggleTableColumns(proposalType) {
                const supplierCols = document.querySelectorAll('.supplier-column');
                const priceCols = document.querySelectorAll('.price-column');
                const constructionSiteCols = document.querySelectorAll('.constructionSite-column');

                // Ẩn hết các cột trước
                [...supplierCols, ...priceCols, ...constructionSiteCols].forEach(col => col.classList.add('hidden'));

                // Hiển thị theo loại phiếu
                if (proposalType === 'import_from_supplier') {
                    supplierCols.forEach(col => col.classList.remove('hidden'));
                    priceCols.forEach(col => col.classList.remove('hidden'));
                } else if (proposalType === 'import_returned') {
                    constructionSiteCols.forEach(col => col.classList.remove('hidden')); // công trình thu hồi
                } else if (proposalType === 'export') {
                    constructionSiteCols.forEach(col => col.classList.remove('hidden')); // công trình nhận
                }
            }

// Kích hoạt khi thay đổi loại đề xuất
            document.getElementById('proposalType').addEventListener('change', function () {
                toggleTableColumns(this.value);
                toggleMaterialConditionOptions(this.value); // THÊM
            });


// Gọi một lần ban đầu nếu cần
            toggleTableColumns(document.getElementById('proposalType').value);

            function toggleMaterialConditionOptions(proposalType) {
                const allSelects = document.querySelectorAll('.conditionSelect');

                allSelects.forEach(select => {
                    const damagedOption = select.querySelector('option[value="damaged"]');
                    if (!damagedOption)
                        return;

                    if (proposalType === 'import_from_supplier' || proposalType === 'export') {
                        damagedOption.disabled = true;
                        // Nếu đang chọn "damaged" thì reset về "new"
                        if (select.value === 'damaged') {
                            select.value = 'new';
                        }
                    } else {
                        damagedOption.disabled = false;
                    }
                });
            }


        </script>
        <!--JavaScript -->
        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
    </body>
</html>