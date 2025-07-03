<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="editable" value="${proposal.approval != null and (empty proposal.approval.adminStatus or proposal.approval.adminStatus eq 'pending')}" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Proposal Detail</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="${pageContext.request.contextPath}/assets/js/tailwind_config.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style_list.css">
</head>
<body class="bg-gray-50 min-h-screen font-sans antialiased">
<%
    String role = (String) session.getAttribute("role");
%>
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
    <div class="max-w-4xl mx-auto">
        <div class="flex items-center gap-4 mb-6">
            <button id="toggleSidebarMobile" class="text-gray-700 hover:text-primary-600">
                <i class="fas fa-bars text-2xl"></i>
            </button>
            <h1 class="text-3xl font-bold text-gray-800">Proposal Detail – ID: ${proposal.proposalId}</h1>
        </div>

        <div class="bg-white p-6 rounded shadow mb-6">
            <h2 class="text-xl font-semibold mb-4">General Information</h2>
            <p><strong>Type:</strong> ${proposal.proposalType}</p>
            <p><strong>Sender:</strong> ${proposal.senderName}</p>
            <p><strong>Sent Date:</strong> <fmt:formatDate value="${proposal.proposalSentDate}" pattern="yyyy-MM-dd HH:mm" /></p>
            <p><strong>Note:</strong> ${proposal.note}</p>
            <p><strong>Final Status:</strong> ${proposal.finalStatus}</p>
            <c:if test="${proposal.approval != null}">
                <p><strong>Admin Status:</strong> ${proposal.approval.adminStatus}</p>
                <p><strong>Director Status:</strong> ${proposal.approval.directorStatus}</p>
                <c:if test="${proposal.approval.adminApprovalDate != null}">
                    <p><strong>Admin Approval Date:</strong> <fmt:formatDate value="${proposal.approval.adminApprovalDate}" pattern="yyyy-MM-dd HH:mm" /></p>
                </c:if>
                <c:if test="${proposal.approval.directorApprovalDate != null}">
                    <p><strong>Director Approval Date:</strong> <fmt:formatDate value="${proposal.approval.directorApprovalDate}" pattern="yyyy-MM-dd HH:mm" /></p>
                </c:if>
            </c:if>
        </div>

        <div class="bg-white p-6 rounded shadow mb-6">
            <h2 class="text-xl font-semibold mb-4">Proposal Details</h2>
            <table class="w-full text-left border border-blue-300">
                <thead>
                    <tr class="bg-blue-600 text-white">
                        <th class="p-3 border border-blue-300">Material ID</th>
                        <th class="p-3 border border-blue-300">Material Name</th>
                        <th class="p-3 border border-blue-300">Quantity</th>
                        <th class="p-3 border border-blue-300">Condition</th>
                    </tr>
                </thead>
                <tbody class="text-black">
                    <c:forEach var="detail" items="${proposal.proposalDetails}">
                        <tr class="hover:bg-blue-50">
                            <td class="p-3 border border-blue-300">${detail.materialId}</td>
                            <td class="p-3 border border-blue-300">${detail.materialName}</td>
                            <td class="p-3 border border-blue-300">${detail.quantity}</td>
                            <td class="p-3 border border-blue-300">${detail.materialCondition}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <div class="bg-white p-6 rounded shadow">
            <h2 class="text-xl font-semibold mb-4">Admin Approval</h2>
            <form method="post" action="${pageContext.request.contextPath}/AdminUpdateProposalServlet">
                <input type="hidden" name="proposalId" value="${proposal.proposalId}" />
                <input type="hidden" name="adminApproverId" value="${sessionScope.userId}" />
                <div class="mb-4">
                    <label>Status</label>
                    <select name="adminStatus" class="w-full border p-2 rounded" <c:if test="${!editable}">disabled</c:if>>
                        <option value="approved" ${proposal.approval != null && proposal.approval.adminStatus == 'approved' ? 'selected' : ''}>Approved</option>
                        <option value="rejected" ${proposal.approval != null && proposal.approval.adminStatus == 'rejected' ? 'selected' : ''}>Rejected</option>
                    </select>
                    <c:if test="${!editable}">
                        <input type="hidden" name="adminStatus" value="${proposal.approval.adminStatus}" />
                    </c:if>
                </div>
                <div class="mb-4">
                    <label>Reason</label>
                    <textarea name="adminReason" class="w-full border p-2 rounded" <c:if test="${!editable}">readonly</c:if>>${proposal.approval != null ? proposal.approval.adminReason : ''}</textarea>
                    <c:if test="${!editable}">
                        <input type="hidden" name="adminReason" value="${proposal.approval.adminReason}" />
                    </c:if>
                </div>
                <div class="mb-4">
                    <label>Note</label>
                    <textarea name="adminNote" class="w-full border p-2 rounded" <c:if test="${!editable}">readonly</c:if>>${proposal.approval != null ? proposal.approval.adminNote : ''}</textarea>
                    <c:if test="${!editable}">
                        <input type="hidden" name="adminNote" value="${proposal.approval.adminNote}" />
                    </c:if>
                </div>
                <c:if test="${editable}">
                    <button type="submit" class="bg-blue-500 text-white px-4 py-2 rounded">Save & Submit</button>
                </c:if>
                <c:if test="${!editable}">
                    <p class="text-red-600">This proposal has already been processed.</p>
                </c:if>
            </form>
        </div>

        <div class="mt-6 text-center">
            <button onclick="history.back()" class="bg-gray-500 text-white px-4 py-2 rounded">&larr; Back</button>
        </div>
    </div>
</main>

<script src="${pageContext.request.contextPath}/assets/js/idebar_darkmode.js"></script>
</body>
</html>
