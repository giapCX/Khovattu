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
        <main class="flex-1 p-8 transition-all duration-300">
            <div class="max-w-6xl mx-auto">
                <div class="flex justify-between items-center mb-6">
                    <div class="flex items-center gap-4">
                        <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                            <i class="fas fa-bars text-2xl"></i>
                        </button>
                        <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Detail Proposal Material ID:${proposalId}</h2>
                    </div>

                </div>

                <div class="w-full flex justify-center">
                    <div class="w-full max-w-6xl bg-white dark:bg-gray-800 shadow-md rounded-lg p-6 mb-6">
                        <h3 class="text-xl font-bold text-gray-800 dark:text-white mb-4">Proposal Information</h3>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-3 text-gray-700 dark:text-gray-300 text-sm">
                            <div>
                                <span class="font-semibold">Proposer name:</span> ${proposal.senderName}
                            </div>
                            <div>
                                <span class="font-semibold">My note:</span> ${proposal.note}
                            </div>
                            <div>
                                <span class="font-semibold">Type of proposal:</span> 
                                <c:choose>
                                    <c:when test="${proposal.proposalType == 'import_from_supplier'}">
                                        <span class="underline font-semibold text-red-600">Purchase</span> 
                                    </c:when>
                                    <c:when test="${proposal.proposalType == 'import_returned'}">
                                        <span class="underline font-semibold text-yellow-600">Retrieve</span> 
                                    </c:when>
                                    <c:when test="${proposal.proposalType == 'export'}">
                                        <span class="underline font-semibold text-blue-600">Export</span> 
                                    </c:when>
                                </c:choose>
                            </div>
                            <div>
                                <span class="font-semibold">Note of admin:</span> ${proApp.adminNote}
                            </div>
                            <div>
                                <span class="font-semibold">Status:</span> 
                                <c:choose>
                                    <c:when test="${proposal.finalStatus == 'rejected'}">
                                        <span class="text-red-600 font-semibold underline">Rejected</span> 
                                    </c:when>
                                    <c:when test="${proposal.finalStatus == 'pending'}">
                                        <span class="text-yellow-600 font-semibold underline">Pending</span> 
                                    </c:when>
                                    <c:when test="${proposal.finalStatus == 'approved_by_admin'}">
                                        <span class="text-blue-600 font-semibold underline">Approved by admin</span> 
                                    </c:when>
                                    <c:when test="${proposal.finalStatus == 'approved_but_not_executed'}">
                                        <span class="text-green-600 font-semibold underline">To Be Execute</span> 
                                    </c:when>
                                    <c:when test="${proposal.finalStatus == 'executed'}">
                                        <span class="text-green-800 font-semibold underline">Executed</span> 
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-gray-500 font-semibold underline">Unknown</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div>
                                <span class="font-semibold">Note of direction:</span> ${proApp.directorNote}
                            </div>
                            <div>
                                <span class="font-semibold">Executor proposal:</span> ${proposal.executorName}
                            </div>
                            <div>
                                <span class="font-semibold">Time execute:</span> ${proposal.executeDate}
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
                                                <td class="p-2">${detail.materialName}</td>
                                                <td class="p-2">${detail.unit}</td>
                                                <td class="p-2">${detail.quantity}</td>
                                                <td class="p-2">${detail.materialCondition}</td>
                                                <c:if test="${proposal.proposalType == 'import_from_supplier'}">
                                                    <td class="p-2">${detail.supplierName}</td>
                                                    <td class="p-2">
                                                        <fmt:formatNumber value="${detail.price}" type="number" minFractionDigits="0" maxFractionDigits="2" />
                                                    </td>

                                                </c:if>

                                                <c:if test="${proposal.proposalType == 'export' || proposal.proposalType == 'import_returned'}">
                                                    <td class="p-2">${detail.siteName}</td>
                                                </c:if>
                                            </tr>
                                        </c:forEach>

                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
                <c:choose>
                    <c:when test="${proposal.finalStatus == 'rejected'}">
                        <a href="EditProposalServlet?proposalId=${proposal.proposalId}" class="btn-secondary text-white px-6 py-3 rounded-lg">
                            Edit
                        </a>
                    </c:when>
                    <c:otherwise>
                        <span class="btn-secondary text-white px-6 py-3 rounded-lg">Cannot edit</span>
                    </c:otherwise>
                </c:choose>
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
        <!--JavaScript -->
        <script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
    </body>
</html>