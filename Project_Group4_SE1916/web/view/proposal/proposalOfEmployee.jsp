<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
            <div class="max-w-full mx-auto card bg-white dark:bg-gray-800 p-6">
                <div class="flex items-center gap-4 mb-6">
                    <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                        <i class="fas fa-bars text-2xl"></i>
                    </button>
                    <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Proposal Material</h2>
                </div>

                <form action="ProposalServlet" method="post" class="space-y-4">
                    <div class="space-y-2">
                        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Proposer</label>
                        <input type="text" value="${sessionScope.userFullName}" readonly class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white"  >
                    </div>

                    <div class="space-y-2">
                        <label for="proposalType" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Status</label>
                        <select id="proposalType" name="proposalType" required class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white">
                            <option value="export">Export</option>
                            <option value="import">Import</option>
                            <c:if test="${role == 'warehouse'}">
                                <option value="repair">Repair</option>               
                            </c:if>
                        </select>
                    </div>
                    <div class="space-y-2">
                        <label for="note" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Note</label>
                        <textarea class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" name="note" rows="3"></textarea>
                    </div> 

                    <div class="space-y-2">
                        <label for="note" class="block text-sm font-medium text-gray-700 dark:text-gray-300">List of Proposed Materials</label>
                        <br/>
                        <div class="table-container bg-white dark:bg-gray-800">
                            <div class="overflow-x-auto">
                                <table class="w-full table-auto" id="importDetailsTable">
                                    <thead>
                                        <tr class="bg-primary-600 text-white">
                                            <th class="p-4 text-left">Name of Material</th>
                                            <th class="p-4 text-left">Unit</th>
                                            <th class="p-4 text-left">Quantity</th>
                                            <th class="p-4 text-left">Material Condition </th>
                                            <th class="p-4 text-left">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody id="itemsBody">
                                        <tr class="border-b border-gray-200 dark:border-gray-700">
                                            <td>
                                                <input list="materialList" class="w-lg px-2 py-2 border border-gray-300 dark:border-gray-600 rounded-md nameMaterialInput" name="materialName[]" autocomplete="off">
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
                                            <td>
                                                <input type="text" name="unit[]" class="w-lg px-2 py-2 border border-gray-300 dark:border-gray-600 rounded-md unitMaterial" readonly>
                                            </td>
                                            <td><input type="number" name="quantity[]" class="w-lg px-2 py-2 border border-gray-300 dark:border-gray-600 rounded-md" value="0.00" step="0.01" min="0.01" required></td>
                                            <td>
                                                <select name="materialCondition[]" class="w-3/4 px-2 py-2 border border-gray-300 dark:border-gray-600 rounded-md" required>
                                                    <option value="new">New</option>
                                                    <option value="used">Used</option>
                                                    <option value="damaged">Damaged</option>
                                                </select>
                                            </td>
                                            <td>
                                                <button type="button" class="p-4 px-12 font-medium " onclick="removeRow(this)">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                            <button type="button" class="p-2 font-medium bg-green-500 hover:bg-green-600 text-white rounded-md border border-green-500 hover:border-green-600 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-opacity-50 transition-all duration-200 flex items-center" onclick="addRow()">
                                <i class="fas fa-plus me-2"></i>Add
                            </button>
                        </div>
                    </div>
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
            }
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
            });

        </script>
        <!--JavaScript -->
        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
    </body>
</html>