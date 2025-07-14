<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Import</title>
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

            if (role == null || !role.equals("warehouse")) {
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
        <script>
            const activeUsers = [
            <c:forEach var="u" items="${activeUsers}" varStatus="loop">
            {
            id: ${u.userId},
                    fullName: "${fn:escapeXml(u.fullName)}",
                    phone: "${fn:escapeXml(u.phone)}"
            }<c:if test="${!loop.last}">,</c:if>
            </c:forEach>
            ];
        </script>

        <!-- Main Content -->
        <main class="flex-1 p-8 transition-all duration-300">
            <div class="max-w-6xl mx-auto">
                <form action="ImportServlet" method="post" class="space-y-4">
                    <input type="hidden" name="proposalId" value="${proposalId}" />
                    <input type="hidden" name="proposalType" value="${proposal.proposalType}" />
                    <div class="flex justify-between items-center mb-6">
                        <div class="flex items-center gap-4">
                            <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                                <i class="fas fa-bars text-2xl"></i>
                            </button>
                            <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Import Material Of Request ID:${proposalId}</h2>
                        </div>
                    </div>

                    <div class="w-full flex justify-center">
                        <div class="w-full max-w-6xl bg-white dark:bg-gray-800 shadow-md rounded-lg p-6 mb-6">
                            <h3 class="text-xl font-bold text-gray-800 dark:text-white mb-4">Request Information</h3>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-3 text-gray-700 dark:text-gray-300 text-sm">
                                <div>
                                    <span class="font-semibold">Sender name:</span> ${proposal.senderName}
                                </div>
                                <div>
                                    <span class="font-semibold">Executor name:</span> ${userFullName}
                                </div>
                                <div>
                                    <span class="font-semibold">Sender note:</span> ${proposal.note}
                                </div>                       
                                <div>
                                    <span class="font-semibold">Admin note:</span> ${proApp.adminNote}
                                </div>    
                                <div>
                                    <span class="font-semibold">Direction note:</span> ${proApp.directorNote}
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="w-full flex justify-center">
                        <div class="w-full max-w-6xl bg-white dark:bg-gray-800 shadow-md rounded-lg p-6 mb-6">
                            <h3 class="text-xl font-bold text-gray-800 dark:text-white mb-4">List material</h3>

                            <!-- Table -->
                            <div class="table-container bg-white dark:bg-gray-800">
                                <div class="overflow-x-auto">
                                    <table class="w-full table-fixed text-sm" id="proposalDetailTable">
                                        <thead>
                                            <tr class="bg-primary-600 text-white text-sm">
                                                <th class="p-2 text-left w-[5%]">STT</th>
                                                <th class="p-2 text-left w-[20%]">Name of Material</th>
                                                <th class="p-2 text-left w-[7%]">Unit</th> 
                                                <th class="p-2 text-left w-[10%]">Quantity</th>
                                                <th class="p-2 text-left w-[9%]">Condition</th>

                                                <c:if test="${proposal.proposalType == 'import_from_supplier'}">
                                                    <th class="p-2 text-left w-[23%]">Supplier</th>
                                                    <th class="p-2 text-left w-[12%]">Price (VNĐ)</th>
                                                    </c:if>

                                                <c:if test="${proposal.proposalType == 'export' || proposal.proposalType == 'import_returned'}">
                                                    <th class="p-2 text-left w-[13%]">Construction Site</th>
                                                    </c:if>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="detail" items="${proposal.proposalDetails}" varStatus="status">
                                                <tr class="border-b border-gray-200 dark:border-gray-700">
                                                    <td class="p-2">${status.index + 1}</td> 
                                                    <td class="p-2">
                                                        ${detail.materialName}
                                                        <input type="hidden" name="materialId[]" value="${detail.materialId}" />
                                                    </td>
                                                    <td class="p-2">
                                                        ${detail.unit}
                                                        <input type="hidden" name="unit[]" value="${detail.unit}" />
                                                    </td>

                                                    <td class="p-2">
                                                        <fmt:formatNumber value="${detail.quantity}" type="number" minFractionDigits="0" maxFractionDigits="2" />
                                                        <input type="hidden" name="quantity[]" value="${detail.quantity}" />
                                                    </td>
                                                    <td class="p-2">
                                                        ${detail.materialCondition}
                                                        <input type="hidden" name="materialCondition[]" value="${detail.materialCondition}" />
                                                    </td>
                                                    <c:if test="${proposal.proposalType == 'import_from_supplier'}">
                                                        <td class="p-2">
                                                            ${detail.supplierName}
                                                            <input type="hidden" name="supplierIds[]" value="${detail.supplierId}" />
                                                        </td>
                                                        <td class="p-2">
                                                            <fmt:formatNumber value="${detail.price}" type="number" minFractionDigits="0" maxFractionDigits="2" />
                                                            <input type="hidden" name="pricePerUnit[]" value="${detail.price}" />
                                                            
                                                        </td>
                                                    </c:if>
                                                    <c:if test="${proposal.proposalType == 'export' || proposal.proposalType == 'import_returned'}">
                                                        <td class="p-2">
                                                            ${detail.siteName}
                                                        <input type="hidden" name="siteId[]" class="siteIdHidden" value="${detail.siteId}">
                                                        </td>
                                                    </c:if>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div class="space-y-2">
                                <label class="font-semibold">Note</label> 
                                <textarea class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 dark:bg-gray-700 dark:text-white" name="note" rows="3" required></textarea>
                            </div> 
                            <c:if test="${proposal.proposalType == 'import_returned'}">
                                <div class="mt-4">
                                    <label class="font-semibold">Delivery person ID</label> 
                                    <input id="responsibleId" name="responsibleId"
                                           class="w-full px-2 py-2 border border-gray-300 dark:border-gray-600 rounded-md"
                                           placeholder="Enter delivery ID">

                                    <div id="userInfoDisplay" class="mt-2 p-3 rounded bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-white hidden">
                                        <p><strong>Full Name:</strong> <span id="userFullName"></span></p>
                                        <p><strong>Phone:</strong> <span id="userPhone"></span></p>
                                    </div>
                                </div>
                            </c:if>
                        </div>
                    </div>
                    <button type="submit" class="btn-primary text-white px-6 py-3 rounded-lg flex items-center justify-center">
                        <i class="fas fa-plus-circle mr-2"></i> Submit 
                    </button>
                </form>
            </div>
            <div class="mt-6 flex justify-center gap-4 max-w-2xl mx-auto w-full">
                <div class="w-1/3">
                    <a href="${pageContext.request.contextPath}/ExecuteProposalServlet" 
                       class="btn-secondary text-white px-6 py-3 rounded-lg">
                        Back to request execute
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
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                const responsibleInput = document.getElementById("responsibleId");
                const displayBox = document.getElementById("userInfoDisplay");
                const fullNameSpan = document.getElementById("userFullName");
                const phoneSpan = document.getElementById("userPhone");

                responsibleInput.addEventListener("input", function () {
                    const trimmed = this.value.trim();
                    const inputId = parseInt(trimmed);

                    if (!isNaN(inputId)) {
                        const user = activeUsers.find(u => u.id === inputId);

                        if (user) {
                            fullNameSpan.textContent = user.fullName;
                            phoneSpan.textContent = user.phone;
                            displayBox.classList.remove("hidden");
                        } else {
                            displayBox.classList.add("hidden");
                        }
                    } else {
                        displayBox.classList.add("hidden");
                    }
                });

            });
        </script>

        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
    </body>
</html>