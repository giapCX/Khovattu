/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.unit;

import Dal.DBContext;
import dao.UnitDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.Connection;
import model.Unit;

/**
 *
 * @author quanh
 */
public class EditUnitServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet EditUnitServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet EditUnitServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int unitId = Integer.parseInt(request.getParameter("unitId"));
        try (Connection conn = DBContext.getConnection()) {
            UnitDAO dao = new UnitDAO(conn);
            Unit unit = dao.getUnitById(unitId);
            request.setAttribute("unit", unit);
            request.getRequestDispatcher("editUnit.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500);
        }
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        int unitId = Integer.parseInt(request.getParameter("unitId"));
        String name = request.getParameter("unitName");
        String status = request.getParameter("status");

        try (Connection conn = DBContext.getConnection()) {
            UnitDAO dao = new UnitDAO(conn);
            Unit unit = new Unit();
            unit.setUnitId(unitId);
            unit.setName(name);
            unit.setStatus(status);
            boolean isUsed = dao.checkIfUnitIsUsed(unitId);

            if (status.equals("inactive") && isUsed) {
                request.setAttribute("error", "Cannot deactivate this unit because it is in use by materials.");
                request.getRequestDispatcher("editUnit.jsp").forward(request, response);
                return;
            }
            boolean success = dao.updateUnit(unit);
            if (success) {
                response.sendRedirect("unit?success=updated");
            } else {
                request.setAttribute("error", "Failed to update unit.");
                request.setAttribute("unit", unit);
                request.getRequestDispatcher("editUnit.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500);
        }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
