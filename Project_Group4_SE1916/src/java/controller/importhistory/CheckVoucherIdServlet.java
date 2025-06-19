package controller.importhistory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import Dal.DBContext;


public class CheckVoucherIdServlet extends HttpServlet {
    private static final String CHECK_VOUCHER_SQL = "SELECT COUNT(*) FROM ImportReceipts WHERE voucher_id = ?";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String voucherId = request.getParameter("voucher_id");
        boolean exists = false;

        try (Connection conn = DBContext.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(CHECK_VOUCHER_SQL)) {
            pstmt.setString(1, voucherId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                exists = rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        response.setContentType("application/json");
        response.getWriter().write("{\"exists\": " + exists + "}");
    }
}