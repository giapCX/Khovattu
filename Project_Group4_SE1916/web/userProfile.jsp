<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Profile</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            color: #333;
        }
        .container {
            max-width: 750px;
            margin: 40px auto;
            padding: 25px;
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
        }
        .profile-header {
            text-align: center;
            margin-bottom: 25px;
        }
        .profile-pic {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            object-fit: cover;
            border: 4px solid #007bff;
            margin-bottom: 15px;
            transition: transform 0.3s ease;
        }
        .profile-pic:hover {
            transform: scale(1.05);
        }
        .info-group {
            margin-bottom: 20px;
        }
        .info-group label {
            font-weight: 600;
            color: #495057;
            margin-right: 15px;
            min-width: 120px;
            display: inline-block;
        }
        .info-value {
            color: #212529;
            font-size: 1.1em;
        }
        .form-group {
            margin-bottom: 20px;
            display: none;
        }
        .form-group label {
            font-weight: 600;
            color: #495057;
        }
        .form-control {
            border-radius: 6px;
            border: 1px solid #ced4da;
        }
        .form-control:focus {
            border-color: #007bff;
            box-shadow: 0 0 5px rgba(0, 123, 255, 0.3);
        }
        .form-control[readonly] {
            background-color: #e9ecef;
            cursor: not-allowed;
        }
        .btn-primary {
            background-color: #007bff;
            border: none;
            padding: 10px 20px;
            border-radius: 6px;
            transition: background-color 0.3s ease;
        }
        .btn-primary:hover {
            background-color: #0056b3;
        }
        .btn-secondary {
            background-color: #6c757d;
            border: none;
            padding: 10px 20px;
            border-radius: 6px;
            transition: background-color 0.3s ease;
        }
        .btn-secondary:hover {
            background-color: #5a6268;
        }
        .edit-mode .info-group {
            display: none;
        }
        .edit-mode .form-group {
            display: block;
        }
        .edit-mode .btn-edit, .edit-mode .btn-return {
            display: none;
        }
        .edit-mode .btn-update, .edit-mode .btn-cancel {
            display: inline-block;
        }
        .btn-edit, .btn-return {
            margin-right: 10px;
        }
        .btn-update, .btn-cancel {
            display: none;
            margin-right: 10px;
        }
    </style>
</head>
<body>
    <div class="container ${param.edit == 'true' ? 'edit-mode' : ''}">
        <div class="profile-header">
            <h2>User Profile</h2>
            <c:if test="${not empty user.image}">
                <img src="${pageContext.request.contextPath}/${user.image}" alt="Profile Picture" class="profile-pic">
            </c:if>
            <c:if test="${empty user.image}">
                <img src="${pageContext.request.contextPath}/images/default-profile.png" alt="Default Profile Picture" class="profile-pic">
            </c:if>
        </div>

        <!-- Read-only View -->
        <div class="info-section">
            <div class="info-group">
                <label>Username:</label>
                <span class="info-value">${user.username}</span>
            </div>
            <div class="info-group">
                <label>Full Name:</label>
                <span class="info-value">${user.fullName}</span>
            </div>
            <div class="info-group">
                <label>Email:</label>
                <span class="info-value">${user.email}</span>
            </div>
            <div class="info-group">
                <label>Phone Number:</label>
                <span class="info-value">${user.phone}</span>
            </div>
            <div class="info-group">
                <label>Address:</label>
                <span class="info-value">${user.address}</span>
            </div>
            <div class="info-group">
                <label>Date of Birth:</label>
                <span class="info-value">${user.dateOfBirth}</span>
            </div>
            <div class="info-group">
                <label>Status:</label>
                <span class="info-value">${user.status}</span>
            </div>
            <div class="info-group">
                <label>Role:</label>
                <span class="info-value">${role}</span>
            </div>
            <div class="info-group">
                <label>Profile Picture:</label>
                <span class="info-value">${not empty user.image ? user.image : 'Default'}</span>
            </div>
            <div class="button-group mt-3">
                <a href="${pageContext.request.contextPath}/userprofile?edit=true" class="btn btn-primary btn-edit">Edit</a>
   
            </div>
        </div>

        <!-- Editable Form -->
        <form action="${pageContext.request.contextPath}/userprofile" method="post" enctype="multipart/form-data" class="form-section">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" class="form-control" id="username" name="username" value="${user.username}" readonly>
            </div>
            <div class="form-group">
                <label for="fullName">Full Name</label>
                <input type="text" class="form-control" id="fullName" name="fullName" value="${user.fullName}">
            </div>
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" class="form-control" id="email" name="email" value="${user.email}">
            </div>
            <div class="form-group">
                <label for="phone">Phone Number</label>
                <input type="text" class="form-control" id="phone" name="phone" value="${user.phone}">
            </div>
            <div class="form-group">
                <label for="address">Address</label>
                <input type="text" class="form-control" id="address" name="address" value="${user.address}">
            </div>
            <div class="form-group">
                <label for="dateOfBirth">Date of Birth</label>
                <input type="date" class="form-control" id="dateOfBirth" name="dateOfBirth" value="${user.dateOfBirth}">
            </div>
            <div class="form-group">
                <label for="status">Status</label>
                <input type="text" class="form-control" id="status" name="status" value="${user.status}" readonly>
            </div>
            <div class="form-group">
                <label for="role">Role</label>
                <input type="text" class="form-control" id="role" value="${role}" readonly>
            </div>
            <div class="form-group">
                <label for="profilePic">Profile Picture</label>
                <input type="file" class="form-control" id="profilePic" name="profilePic" accept="image/*">
            </div>
            <div class="button-group mt-3">
                <button type="submit" class="btn btn-primary btn-update">Update Profile</button>
                <a href="${pageContext.request.contextPath}/userprofile" class="btn btn-secondary btn-cancel">Cancel</a>
            </div>
        </form>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
    <script>
        <c:if test="${not empty message}">
            Toastify({
                text: "${message}",
                duration: 3000,
                gravity: "top",
                position: "right",
                backgroundColor: "#28a745"
            }).showToast();
        </c:if>
        <c:if test="${not empty error}">
            Toastify({
                text: "${error}",
                duration: 3000,
                gravity: "top",
                position: "right",
                backgroundColor: "#dc3545"
            }).showToast();
        </c:if>
    </script>
</body>
</html>