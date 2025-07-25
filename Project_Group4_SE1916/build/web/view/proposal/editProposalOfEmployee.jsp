<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Edit Request</title>
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

            Integer proposerId = (Integer) request.getAttribute("proposerId");

            if (role == null || !role.equals("employee") || proposerId == null || !proposerId.equals(userId)) {
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
        <main class="flex-1 p-8 transition-all duration-300 min-h-screen">
            <div class="max-w-6xl mx-auto card bg-white dark:bg-gray-800 p-6">
                <div class="flex items-center gap-4 mb-6">
                    <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                        <i class="fas fa-bars text-2xl"></i>
                    </button>
                    <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Edit Request</h2>
                </div>

                <form action="EditProposalServlet" method="post" class="space-y-4">
                    <input type="hidden" name="proposalId" value="${proposalId}">
                    <div class="space-y-2">
                        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Sender name</label>
                        <input type="text" value="${sessionScope.userFullName}" readonly class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white"  >
                    </div>
                    <div class="space-y-2">
                        <label for="proposalType" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Type of request</label>
                        <select id="proposalType" name="proposalType" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                            <option value="import_from_supplier"
                                    <c:if test="${proposal.proposalType == 'import_from_supplier'}">selected</c:if>>Purchase
                                    </option>
                                    <option value="import_returned"
                                    <c:if test="${proposal.proposalType == 'import_returned'}">selected</c:if>>Retrieve
                                    </option>
                                    <option value="export"
                                    <c:if test="${proposal.proposalType == 'export'}">selected</c:if>>Export
                                    </option>
                            </select>
                        </div>

                        <div class="space-y-2 supplier-column hidden">
                            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Supplier:</label>
                            <input list="supplierList" id="supplierName" name="supplierName" value="${proposal.supplierName != null ? proposal.supplierName : ''}" class="w-full px-4 py-2 border rounded-lg dark:bg-gray-700 dark:text-white" placeholder="Enter supplier name">
                        <datalist id="supplierList">
                            <c:forEach var="supplier" items="${suppliers}">
                                <option value="${supplier.supplierName}" data-id="${supplier.supplierId}">${supplier.supplierName}</option>
                            </c:forEach>
                        </datalist>
                        <input type="hidden" name="supplierId" id="supplierIdHidden" value="${proposal.supplierId}">
                    </div>
                    <div class="space-y-2 constructionSite-column hidden">
                        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Construction Site:</label>
                        <input list="siteList" id="siteName" name="siteName" value="${proposal.siteName != null ? proposal.siteName : ''}" class="w-full px-4 py-2 border rounded-lg dark:bg-gray-700 dark:text-white" placeholder="Enter site name">
                        <datalist id="siteList">
                            <c:forEach var="site" items="${constructionSites}">
                                <option value="${site.siteName}" data-id="${site.siteId}">${site.siteName}</option>
                            </c:forEach>
                        </datalist>
                        <input type="hidden" name="siteId" id="siteIdHidden" value="${proposal.siteId}">
                    </div>

                    <div class="space-y-2">
                        <label for="note" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Note</label>
                        <textarea class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" name="note" rows="3" required>${proposal.note}</textarea>
                    </div> 

                    <div class="space-y-2">
                        <label for="note" class="block text-sm font-medium text-gray-700 dark:text-gray-300">List of Materials</label>
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
                                            <th class="p-2 text-left w-[12%] price-column hidden">Price(VNĐ)</th>
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
                                                                data-unit="${cat.unit}">
                                                                ${cat.name}
                                                            </option>
                                                        </c:forEach>
                                                    </datalist>
                                                    <input type="hidden" name="materialId[]" class="materialIdHidden" value="${detail.materialId}">
                                                </td>
                                                <td class="pr-2">
                                                    <input type="text" name="unit[]" value="${detail.unit}" class="w-full px-2 py-2 border border-gray-300 dark:border-gray-600 rounded-md unitMaterial" readonly>
                                                </td>
                                                <td class="pr-2">
                                                    <input type="number" name="quantity[]" value="<fmt:formatNumber value='${detail.quantity}' type='number' groupingUsed='false' maxFractionDigits='0' />" class="w-full px-2 py-2 border border-gray-300 dark:border-gray-600 rounded-md" step="1" min="1" required>
                                                </td>
                                                <td class="pr-2">
                                                    <select name="materialCondition[]" class="w-full px-2 py-2 border border-gray-300 dark:border-gray-600 rounded-md conditionSelect" required>
                                                        <option value="new" ${detail.materialCondition == 'new' ? 'selected' : ''}>New</option>
                                                        <option value="used" ${detail.materialCondition == 'used' ? 'selected' : ''}>Used</option>
                                                        <option class="damaged-option" value="damaged" ${detail.materialCondition == 'damaged' ? 'selected' : ''}>Damaged</option>
                                                    </select>
                                                </td>
                                                <td class="price-column hidden">
                                                    <input 
                                                        type="number" 
                                                        name="pricePerUnit[]" 
                                                        value="<fmt:formatNumber value='${detail.price}' type='number' groupingUsed='false' maxFractionDigits='0' />" 
                                                        class="w-full px-2 py-2 border border-gray-300 dark:border-gray-600 rounded-md" 
                                                        step="1000" min="1000" />
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

            </div>
            <div class="mt-6 flex justify-center gap-4 max-w-2xl mx-auto w-full">
                <div class="w-1/3">
                    <a href="${pageContext.request.contextPath}/ListProposalServlet" 
                       class="btn-secondary text-white px-6 py-3 rounded-lg">
                        Back to list proposal
                    </a>
                </div>
                <div class="w-1/2">
                    <div class="w-full">
                        <jsp:include page="/view/backToDashboardButton.jsp" />
                    </div>
                </div>
            </div>
        </main>
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const proposalTypeSelect = document.getElementById('proposalType');
                const supplierSection = document.querySelector('.supplier-column');
                const siteSection = document.querySelector('.constructionSite-column');
                const priceColumns = document.querySelectorAll('.price-column');

                const supplierInput = document.getElementById('supplierName');
                const siteInput = document.getElementById('siteName');
                const supplierHidden = document.getElementById('supplierIdHidden');
                const siteHidden = document.getElementById('siteIdHidden');

                function updateVisibility() {
                    const type = proposalTypeSelect.value;

                    const isImport = type === 'import_from_supplier';
                    const isImportReturned = type === 'import_returned';
                    const isExport = type === 'export';

                    // Supplier field
                    supplierSection.classList.toggle('hidden', !isImport);
                    supplierInput.required = isImport;

                    // Site field
                    siteSection.classList.toggle('hidden', !isImportReturned && !isExport);
                    siteInput.required = isImportReturned || isExport;

                    // Price column
                    priceColumns.forEach(col => {
                        col.classList.toggle('hidden', !isImport);
                        const input = col.querySelector('input');
                        if (input) {
                            input.required = isImport;
                            if (!isImport)
                                input.value = ''; // reset if hidden
                        }
                    });
                }

                // Initial visibility
                updateVisibility();
                proposalTypeSelect.addEventListener('change', updateVisibility);

                // Set hidden supplierId
                supplierInput.addEventListener('input', () => {
                    const value = supplierInput.value.trim();
                    const options = document.querySelectorAll('#supplierList option');
                    let matched = [...options].find(opt => opt.value === value);
                    supplierHidden.value = matched ? matched.dataset.id : '';
                });

                // Set hidden siteId
                siteInput.addEventListener('input', () => {
                    const value = siteInput.value.trim();
                    const options = document.querySelectorAll('#siteList option');
                    let matched = [...options].find(opt => opt.value === value);
                    siteHidden.value = matched ? matched.dataset.id : '';
                });

                // Handle materialId + unit when selecting material
                document.getElementById('itemsBody').addEventListener('input', function (e) {
                    if (e.target.matches('input[name="materialName[]"]')) {
                        const row = e.target.closest('tr');
                        const value = e.target.value.trim();
                        const options = document.querySelectorAll('#materialList option');
                        const matched = [...options].find(opt => opt.value === value);

                        const materialIdInput = row.querySelector('.materialIdHidden');
                        const unitInput = row.querySelector('.unitMaterial');

                        if (matched) {
                            materialIdInput.value = matched.dataset.id || '';
                            unitInput.value = matched.dataset.unit || '';
                        } else {
                            materialIdInput.value = '';
                            unitInput.value = '';
                        }
                    }
                });
            });

            function addRow() {
                const tableBody = document.getElementById('itemsBody');
                const firstRow = tableBody.querySelector('tr');
                const newRow = firstRow.cloneNode(true);

                // Reset all input/select fields in the new row
                newRow.querySelectorAll('input, select').forEach(input => {
                    switch (input.name) {
                        case 'unit[]':
                        case 'materialId[]':
                        case 'materialName[]':
                        case 'quantity[]':
                        case 'pricePerUnit[]':
                            input.value = '';
                            break;
                        case 'materialCondition[]':
                            input.value = 'new';
                            break;
                    }
                });

                tableBody.appendChild(newRow);

                // Cập nhật số lượng dòng
                document.getElementById('itemCount').value = tableBody.querySelectorAll('tr').length;
            }

            function removeRow(button) {
                const tableBody = document.getElementById('itemsBody');
                if (tableBody.rows.length > 1) {
                    button.closest('tr').remove();
                }
                document.getElementById('itemCount').value = tableBody.querySelectorAll('tr').length;
            }
        </script>


        <!--JavaScript -->
        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
    </body>
</html>