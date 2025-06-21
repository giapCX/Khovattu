<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head>
    <title>Proposal Detail</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        /* Tùy chỉnh thêm một số style không có sẵn trong Tailwind */
        th, td {
            transition: background-color 0.2s ease;
        }
        tbody tr:hover {
            background-color: #f1f5f9;
        }
        select:focus, textarea:focus, button:focus {
            outline: none;
            ring: 2px solid #2563eb;
        }
    </style>
</head>
<body class="bg-gray-50 min-h-screen flex flex-col items-center p-4 md:p-8">
    <div class="w-full max-w-4xl">
        <!-- Tiêu đề -->
        <h1 class="text-3xl md:text-4xl font-bold text-gray-800 mb-8 text-center">
            Proposal Detail - ID: ${proposal.proposalId}
        </h1>

        <!-- Thông tin chung -->
        <div class="bg-white shadow-lg rounded-2xl p-6 mb-8 border border-gray-200">
            <h2 class="text-xl font-semibold text-gray-700 mb-4">General Information</h2>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <p><strong class="text-gray-600">Type:</strong> <span class="text-gray-800">${proposal.proposalType}</span></p>
                <p><strong class="text-gray-600">Sender:</strong> <span class="text-gray-800">${proposal.senderName}</span></p>
                <p><strong class="text-gray-600">Sent Date:</strong> 
                    <span class="text-gray-800">
                        <fmt:formatDate value="${proposal.proposalSentDate}" pattern="yyyy-MM-dd HH:mm" />
                    </span>
                </p>
                <p><strong class="text-gray-600">Note:</strong> <span class="text-gray-800">${proposal.note}</span></p>
                <p class="md:col-span-2"><strong class="text-gray-600">Final Status:</strong> 
                    <span class="inline-block px-3 py-1 rounded-full text-sm font-medium 
                        ${proposal.finalStatus == 'pending' ? 'bg-yellow-100 text-yellow-800' : 
                          proposal.finalStatus == 'approved_by_admin' ? 'bg-green-100 text-green-800' : 
                          'bg-red-100 text-red-800'}">
                        ${proposal.finalStatus}
                    </span>
                </p>
            </div>
        </div>

        <!-- Danh sách vật tư -->
        <h2 class="text-2xl font-semibold text-gray-800 mb-4">Proposal Details</h2>
        <div class="overflow-x-auto">
            <table class="w-full bg-white shadow-lg rounded-2xl border border-gray-200">
                <thead>
                    <tr class="bg-blue-600 text-white text-left">
                        <th class="p-4 font-semibold rounded-tl-2xl">Material ID</th>
                        <th class="p-4 font-semibold">Material Name</th>
                        <th class="p-4 font-semibold">Quantity</th>
                        <th class="p-4 font-semibold rounded-tr-2xl">Condition</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="detail" items="${proposal.proposalDetails}">
                        <tr class="border-t border-gray-200">
                            <td class="p-4 text-gray-700">${detail.materialId}</td>
                            <td class="p-4 text-gray-700">${detail.materialName}</td>
                            <td class="p-4 text-gray-700">${detail.quantity}</td>
                            <td class="p-4 text-gray-700">${detail.materialCondition}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <!-- Form phê duyệt của Admin -->
        <h2 class="text-2xl font-semibold text-gray-800 mt-8 mb-4">Admin Approval</h2>
        <form action="${pageContext.request.contextPath}/AdminUpdateProposalServlet" method="post" class="bg-white shadow-lg rounded-2xl p-6 border border-gray-200 space-y-6">
            <input type="hidden" name="proposalId" value="${proposal.proposalId}" />

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Status</label>
                <select name="finalStatus" class="w-full border border-gray-300 rounded-lg p-3 text-gray-700 focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                    <option value="pending" ${proposal.finalStatus == 'pending' ? 'selected' : ''}>Pending</option>
                    <option value="approved_by_admin" ${proposal.finalStatus == 'approved_by_admin' ? 'selected' : ''}>Approved by Admin</option>
                    <option value="rejected" ${proposal.finalStatus == 'rejected' ? 'selected' : ''}>Rejected</option>
                </select>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Admin Reason</label>
                <textarea name="adminReason" class="w-full border border-gray-300 rounded-lg p-3 text-gray-700 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 resize-vertical min-h-[100px]">${proposal.approval.adminReason}</textarea>
            </div>

            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Admin Note</label>
                <textarea name="adminNote" class="w-full border border-gray-300 rounded-lg p-3 text-gray-700 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 resize-vertical min-h-[100px]">${proposal.approval.adminNote}</textarea>
            </div>

            <div class="flex justify-end">
                <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white font-medium px-6 py-3 rounded-lg transition duration-200">
                    Save & Submit
                </button>
            </div>
        </form>
    </div>
</body>
</html>