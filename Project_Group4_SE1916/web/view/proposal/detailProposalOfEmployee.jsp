<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Detail Request</title>
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

            if (role == null || !role.equals("employee") || !proposerId.equals(userId)) {
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
            <div class="max-w-6xl mx-auto">
                <div class="flex justify-between items-center mb-6">
                    <div class="flex items-center gap-4">
                        <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                            <i class="fas fa-bars text-2xl"></i>
                        </button>
                        <h2 class="text-2xl font-bold text-gray-800 dark:text-white">Detail Request ID:${proposalId}</h2>
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
                                <span class="font-semibold">Sender note:</span> ${proposal.note}
                            </div>
                            <div>
                                <span class="font-semibold">Type of request:</span> 
                                <c:choose>
                                    <c:when test="${proposal.proposalType == 'import_from_supplier'}">
                                        <span class="underline">Purchase</span> 
                                    </c:when>
                                    <c:when test="${proposal.proposalType == 'import_returned'}">
                                        <span class="underline">Retrieve</span> 
                                    </c:when>
                                    <c:when test="${proposal.proposalType == 'export'}">
                                        <span class="underline">Export</span> 
                                    </c:when>
                                </c:choose>
                            </div>
                            <div>
                                <span class="font-semibold">Admin note:</span> ${proApp.adminNote}
                            </div>
                            <div>
                                <span class="font-semibold">Status:</span> 
                                <c:choose>
                                    <c:when test="${proposal.finalStatus == 'rejected'}">
                                        <span class="underline">Rejected</span> 
                                    </c:when>
                                    <c:when test="${proposal.finalStatus == 'pending'}">
                                        <span class="underline">Pending</span> 
                                    </c:when>
                                    <c:when test="${proposal.finalStatus == 'approved_by_admin'}">
                                        <span class="underline">Approved by admin</span> 
                                    </c:when>
                                    <c:when test="${proposal.finalStatus == 'approved_but_not_executed'}">
                                        <span class="underline">To Be Execute</span> 
                                    </c:when>
                                    <c:when test="${proposal.finalStatus == 'executed'}">
                                        <span class="underline">Executed</span> 
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-gray-500 font-semibold underline">Unknown</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div>
                                <span class="font-semibold">Direction note:</span> ${proApp.directorNote}
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
                        <div class="text-center my-4">
                            <c:if test="${proposal.proposalType == 'import_from_supplier'}">
                                <h1 class="text-xl font-bold text-gray-800 dark:text-white mb-4">Purchase from supplier: ${proposal.supplierName}(<c:choose>
                                        <c:when test="${proposal.finalStatus == 'rejected'}">
                                            <span >Rejected</span> 
                                        </c:when>
                                        <c:when test="${proposal.finalStatus == 'pending'}">
                                            <span >Pending</span> 
                                        </c:when>
                                        <c:when test="${proposal.finalStatus == 'approved_by_admin'}">
                                            <span >Approved by admin</span> 
                                        </c:when>
                                        <c:when test="${proposal.finalStatus == 'approved_but_not_executed'}">
                                            <span >To Be Execute</span> 
                                        </c:when>
                                        <c:when test="${proposal.finalStatus == 'executed'}">
                                            <span >Executed</span> 
                                        </c:when>
                                    </c:choose>)</h1>
                                </c:if>
                                <c:if test="${proposal.proposalType == 'export'}">
                                <h1 class="text-xl font-bold text-gray-800 dark:text-white mb-4">Export for construction site: ${proposal.siteName} (<c:choose>
                                        <c:when test="${proposal.finalStatus == 'rejected'}">
                                            <span>Rejected</span> 
                                        </c:when>
                                        <c:when test="${proposal.finalStatus == 'pending'}">
                                            <span>Pending</span> 
                                        </c:when>
                                        <c:when test="${proposal.finalStatus == 'approved_by_admin'}">
                                            <span >Approved by admin</span> 
                                        </c:when>
                                        <c:when test="${proposal.finalStatus == 'approved_but_not_executed'}">
                                            <span >To Be Execute</span> 
                                        </c:when>
                                        <c:when test="${proposal.finalStatus == 'executed'}">
                                            <span >Executed</span> 
                                        </c:when>
                                    </c:choose>)</h1>
                                </c:if>
                                <c:if test="${proposal.proposalType == 'import_returned'}">
                                <h1 class="text-xl font-bold text-gray-800 dark:text-white mb-4">Retrieve from construction site: ${proposal.siteName} (<c:choose>
                                        <c:when test="${proposal.finalStatus == 'rejected'}">
                                            <span >Rejected</span> 
                                        </c:when>
                                        <c:when test="${proposal.finalStatus == 'pending'}">
                                            <span >Pending</span> 
                                        </c:when>
                                        <c:when test="${proposal.finalStatus == 'approved_by_admin'}">
                                            <span >Approved by admin</span> 
                                        </c:when>
                                        <c:when test="${proposal.finalStatus == 'approved_but_not_executed'}">
                                            <span >To Be Execute</span> 
                                        </c:when>
                                        <c:when test="${proposal.finalStatus == 'executed'}">
                                            <span >Executed</span> 
                                        </c:when>

                                    </c:choose>)</h1>
                                </c:if>
                        </div>
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
                                                <th class="p-2 text-left w-[12%]">Price (VNĐ)</th>
                                                </c:if>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="detail" items="${proposal.proposalDetails}" varStatus="status">
                                            <tr class="border-b border-gray-200 dark:border-gray-700">
                                                <td class="p-2">${status.index + 1}</td> 
                                                <td class="p-2">${detail.materialName}</td>
                                                <td class="p-2">${detail.unit}</td>
                                                <td class="p-2">
                                                    <fmt:formatNumber value="${detail.quantity}" type="number" minFractionDigits="0" maxFractionDigits="2" />
                                                </td>
                                                <td class="p-2">${detail.materialCondition}</td>
                                                <c:if test="${proposal.proposalType == 'import_from_supplier'}">
                                                    <td class="p-2">
                                                        <fmt:formatNumber value="${detail.price}" type="number" minFractionDigits="0" maxFractionDigits="2" />
                                                    </td>
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
                        <a href="EditProposalServlet?proposalId=${proposal.proposalId}" class="bg-blue-500 hover:bg-blue-700 text-white px-6 py-3 rounded-lg">
                            <i class="fas fa-pen mr-2"></i>Edit
                        </a>
                    </c:when>
                </c:choose>
            </div>
            <div class="mt-6 flex justify-center gap-4 max-w-2xl mx-auto w-full">
                <div class="w-1/3">
                    <a href="${pageContext.request.contextPath}/ListProposalServlet" 
                       class="btn-secondary text-white px-6 py-3 rounded-lg">
                        Back to list request
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
    </body>
</html>