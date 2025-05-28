package controller;

import Dal.DBContext;
import dao.UserDAO;
import jakarta.servlet.RequestDispatcher;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class LoginController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try (Connection conn = DBContext.getConnection()) {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            UserDAO userDAO = new UserDAO(conn);
            List<User> users = userDAO.getUsersWithLoginInfo();
            String roleName = userDAO.getRoleNameByUsername(username);
            User foundAccount = null;
            for (User acc : users) {
                if (acc.getUsername().equals(username) && acc.getPassword().equals(password)) {
                    foundAccount = acc;
                    break;
                }
            }
            if (foundAccount != null) {

                HttpSession session = request.getSession();
                session.setAttribute("username", foundAccount.getUsername());
                session.setAttribute("password", foundAccount.getPassword());
                session.setAttribute("role", roleName);
                session.setMaxInactiveInterval(30 * 60);

                String roleName1 = userDAO.getUserRoleName(username);
                session.setAttribute("role", roleName1);
                
                switch (roleName) {
                    case "admin":
                        response.sendRedirect("view/admin/adminDashboard.jsp");
                        break;
                    case "direction":
                        response.sendRedirect("view/direction/directionDashboard.jsp");
                        break;
                    case "warehouse":
                        response.sendRedirect("view/warehouse/warehouseDashboard.jsp");
                        break;
                    case "employee":
                        response.sendRedirect("view/employee/employeeDashboard.jsp");
                        break;
                    default:
                        response.sendRedirect("login.jsp");
                        break;
                }
            } else {
                request.setAttribute("error", "Either user name or password is wrong.");
                RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
                rd.forward(request, response);
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }

    }

    @Override
    public String getServletInfo() {
        return "Servlet handling login process";
    }
}
