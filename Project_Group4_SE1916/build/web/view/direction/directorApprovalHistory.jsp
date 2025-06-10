<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Lịch Sử Yêu Cầu Vật Liệu Xây Dựng</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
</head>
<body class="bg-gradient-to-br from-sky-100 via-cyan-100 to-blue-100 font-sans min-h-screen">
  <div class="container mx-auto p-6">
    <!-- Tiêu đề -->
    <h1 class="text-4xl font-extrabold text-center mb-8 bg-clip-text text-transparent bg-gradient-to-r from-sky-600 to-blue-600 animate-pulse">
      Lịch Sử Yêu Cầu Vật Liệu Xây Dựng
    </h1>

    <!-- Thanh tìm kiếm và bộ lọc -->
    <form action="${pageContext.request.contextPath}/proposals" method="get">
      <div class="flex flex-col md:flex-row justify-between mb-6 gap-4">
        <div class="flex w-full md:w-1/3 gap-2">
          <div class="relative flex-1">
            <input type="text" id="searchInput" name="search" value="${param.search}" placeholder="Tìm kiếm Mã đề xuất hoặc Người gửi..." 
                   class="p-3 pl-10 border-2 border-sky-300 rounded-xl w-full focus:outline-none focus:border-blue-500 transition-all duration-300 shadow-sm hover:shadow-md">
            <i class="fas fa-search absolute left-3 top-1/2 transform -translate-y-1/2 text-sky-400"></i>
          </div>
          <button type="submit" id="searchButton" class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md">
            <i class="fas fa-search mr-2"></i>Tìm
          </button>
        </div>
        <div class="flex flex-col md:flex-row gap-4 w-full md:w-2/3">
          <div class="relative w-full md:w-1/2">
            <input type="date" id="startDate" name="startDate" value="${param.startDate}" 
                   class="p-3 pl-10 border-2 border-sky-300 rounded-xl w-full focus:outline-none focus:border-blue-500 transition-all duration-300 shadow-sm hover:shadow-md">
            <i class="fas fa-calendar-alt absolute left-3 top-1/2 transform -translate-y-1/2 text-sky-400"></i>
          </div>
          <div class="relative w-full md:w-1/2">
            <input type="date" id="endDate" name="endDate" value="${param.endDate}" 
                   class="p-3 pl-10 border-2 border-sky-300 rounded-xl w-full focus:outline-none focus:border-blue-500 transition-all duration-300 shadow-sm hover:shadow-md">
            <i class="fas fa-calendar-alt absolute left-3 top-1/2 transform -translate-y-1/2 text-sky-400"></i>
          </div>
        </div>
        <select id="statusFilter" name="status" class="p-3 border-2 border-sky-300 rounded-xl w-full md:w-1/4 focus:outline-none focus:border-blue-500 transition-all duration-300 shadow-sm hover:shadow-md bg-white">
          <option value="">Tất cả trạng thái</option>
          <option value="pending" ${param.status == 'pending' ? 'selected' : ''}>Đang chờ</option>
          <option value="approved" ${param.status == 'approved' ? 'selected' : ''}>Đã phê duyệt</option>
          <option value="approved_by_admin" ${param.status == 'approved_by_admin' ? 'selected' : ''}>Đã phê duyệt (Admin)</option>
          <option value="rejected" ${param.status == 'rejected' ? 'selected' : ''}>Từ chối</option>
        </select>
      </div>

      <!-- Bộ chọn số lượng danh mục mỗi trang -->
      <div class="flex justify-end mb-4">
        <select id="itemsPerPage" name="itemsPerPage" class="p-3 border-2 border-sky-300 rounded-xl w-full md:w-1/5 focus:outline-none focus:border-blue-500 transition-all duration-300 shadow-sm hover:shadow-md bg-white">
          <option value="10" ${param.itemsPerPage == '10' ? 'selected' : ''}>10 danh mục/trang</option>
          <option value="20" ${param.itemsPerPage == '20' ? 'selected' : ''}>20 danh mục/trang</option>
          <option value="30" ${param.itemsPerPage == '30' ? 'selected' : ''}>30 danh mục/trang</option>
        </select>
      </div>
    </form>

    <!-- Bảng danh sách đề xuất -->
    <div class="overflow-x-auto rounded-2xl shadow-xl">
      <table class="min-w-full bg-white">
        <thead class="bg-gradient-to-r from-sky-600 to-blue-600 text-white">
          <tr>
            <th class="py-4 px-6 text-left rounded-tl-2xl"><i class="fas fa-list-ol mr-2"></i>STT</th>
            <th class="py-4 px-6 text-left"><i class="fas fa-id-badge mr-2"></i>Mã Đề Xuất</th>
            <th class="py-4 px-6 text-left"><i class="fas fa-box mr-2"></i>Loại Đề Xuất</th>
            <th class="py-4 px-6 text-left"><i class="fas fa-user mr-2"></i>Người Gửi</th>
            <th class="py-4 px-6 text-left"><i class="fas fa-calendar-alt mr-2"></i>Ngày Gửi</th>
            <th class="py-4 px-6 text-left"><i class="fas fa-user-check mr-2"></i>Người Duyệt Cuối</th>
            <th class="py-4 px-6 text-left"><i class="fas fa-calendar-check mr-2"></i>Ngày Duyệt</th>
            <th class="py-4 px-6 text-left"><i class="fas fa-info-circle mr-2"></i>Trạng Thái Duyệt</th>
            <th class="py-4 px-6 text-left rounded-tr-2xl"><i class="fas fa-eye mr-2"></i>Xem Chi Tiết</th>
          </tr>
        </thead>
        <tbody id="requestTableBody" class="divide-y divide-gray-200">
          <c:forEach var="request" items="${requests}" varStatus="loop">
            <tr class="hover:bg-gradient-to-r hover:from-sky-50 hover:to-cyan-50 transition-all duration-300">
              <td class="py-4 px-6 font-medium">${(param.page == null ? 1 : param.page - 1) * (param.itemsPerPage == null ? 10 : param.itemsPerPage) + loop.count}</td>
              <td class="py-4 px-6">${request.id}</td>
              <td class="py-4 px-6">${request.type}</td>
              <td class="py-4 px-6">${request.sender}</td>
              <td class="py-4 px-6"><fmt:formatDate value="${request.sendDate}" pattern="yyyy-MM-dd"/></td>
              <td class="py-4 px-6">${request.finalApprover == null ? 'Chưa có' : request.finalApprover}</td>
              <td class="py-4 px-6">${request.approvalDate == null ? 'Chưa duyệt' : request.approvalDate}</td>
              <td class="py-4 px-6">
                <span class="px-3 py-1 rounded-full font-semibold <c:choose>
                  <c:when test="${request.status == 'pending'}">bg-yellow-300 text-yellow-900 animate-bounce</c:when>
                  <c:when test="${request.status == 'approved' || request.status == 'approved_by_admin'}">bg-green-300 text-green-900</c:when>
                  <c:otherwise>bg-red-300 text-red-900</c:otherwise>
                </c:choose>">
                  <c:choose>
                    <c:when test="${request.status == 'pending'}">Đang chờ</c:when>
                    <c:when test="${request.status == 'approved'}">Đã phê duyệt</c:when>
                    <c:when test="${request.status == 'approved_by_admin'}">Đã phê duyệt (Admin)</c:when>
                    <c:otherwise>Từ chối</c:otherwise>
                  </c:choose>
                </span>
              </td>
              <td class="py-4 px-6">
                <a href="${pageContext.request.contextPath}/proposal-detail?id=${request.id}" 
                   class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md">
                  <i class="fas fa-eye mr-2"></i>Xem
                </a>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>

    <!-- Phân trang -->
    <div class="flex justify-center mt-6 gap-2">
      <c:set var="currentPage" value="${param.page == null ? 1 : param.page}"/>
      <c:set var="totalPages" value="${totalPages}"/>
      <a href="${pageContext.request.contextPath}/proposals?page=${currentPage - 1}&search=${param.search}&status=${param.status}&startDate=${param.startDate}&endDate=${param.endDate}&itemsPerPage=${param.itemsPerPage}" 
         class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md ${currentPage == 1 ? 'opacity-50 pointer-events-none' : ''}">
        <i class="fas fa-chevron-left mr-2"></i>Trang trước
      </a>
      <div class="flex gap-2">
        <c:forEach begin="1" end="${totalPages}" var="i">
          <a href="${pageContext.request.contextPath}/proposals?page=${i}&search=${param.search}&status=${param.status}&startDate=${param.startDate}&endDate=${param.endDate}&itemsPerPage=${param.itemsPerPage}" 
             class="px-4 py-2 rounded-lg shadow-md transition-all duration-300 ${i == currentPage ? 'bg-blue-600 text-white' : 'bg-sky-200 text-sky-800 hover:bg-sky-300'}">${i}</a>
        </c:forEach>
      </div>
      <a href="${pageContext.request.contextPath}/proposals?page=${currentPage + 1}&search=${param.search}&status=${param.status}&startDate=${param.startDate}&endDate=${param.endDate}&itemsPerPage=${param.itemsPerPage}" 
         class="px-4 py-2 bg-gradient-to-r from-sky-500 to-blue-500 text-white rounded-lg hover:from-sky-600 hover:to-blue-600 transition-all duration-300 shadow-md ${currentPage == totalPages ? 'opacity-50 pointer-events-none' : ''}">
        Trang sau<i class="fas fa-chevron-right ml-2"></i>
      </a>
    </div>
  </div>
</body>
</html> 