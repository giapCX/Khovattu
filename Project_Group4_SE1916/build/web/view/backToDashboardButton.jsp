<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="role" value="${sessionScope.role}" />

<c:choose>
    <c:when test="${role == 'admin'}">
        <a href="${pageContext.request.contextPath}/AdminDashboard" class="btn-secondary text-white px-6 py-3 rounded-lg">
            Back to admin dashboard
        </a>
    </c:when>
    <c:when test="${role == 'direction'}">
        <a href="${pageContext.request.contextPath}/DirectionDashboard" class="btn-secondary text-white px-6 py-3 rounded-lg">
            Back to direction dashboard
        </a>
    </c:when>
    <c:when test="${role == 'warehouse'}">
        <a href="${pageContext.request.contextPath}/WarehouseDashboard" class="btn-secondary text-white px-6 py-3 rounded-lg">
            Back to warehouse dashboard
        </a>
    </c:when>
    <c:when test="${role == 'employee'}">
        <a href="${pageContext.request.contextPath}/EmployeeDashboard" class="btn-secondary text-white px-6 py-3 rounded-lg">
            Back to employee dashboard
        </a>
    </c:when>
    <c:otherwise>
        <div class="mt-4 text-red-600">
            You do not have permission to access this page.
            <a href="${pageContext.request.contextPath}/login.jsp" class="text-blue-600 underline ml-2">Login here</a>.
        </div>
    </c:otherwise>
</c:choose>
