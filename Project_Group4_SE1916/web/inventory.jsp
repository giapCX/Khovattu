<%-- 
    Document   : inventory.jsp
    Created on : Jul 14, 2025, 9:57:42 PM
    Author     : ASUS
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Inventory" %>

<%
    List<Inventory> inventoryList = (List<Inventory>) request.getAttribute("inventoryList");
%>

<!DOCTYPE html>
<html>
    <head>
        <title>Quản lý tồn kho</title>
    </head>
    <body>
        <h1>Danh sách tồn kho</h1>
        <table border="1">
            <tr>
                <th>Material ID</th>
                <th>Condition</th>
                <th>Quantity in Stock</th>
                <th>Last Updated</th>
            </tr>
            <%
                for (Inventory inv : inventoryList) {
            %>
            <tr>
                <td><%= inv.getMaterialId()%></td>
                <td><%= inv.getMaterialCondition()%></td>
                <td><%= inv.getQuantityInStock()%></td>
                <td><%= inv.getLastUpdated()%></td>
            </tr>
            <%
                }
            %>
        </table>
    </body>
</html>

