package controller.importhistory;

import Dal.DBContext;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class CheckVoucherIdServlet extends HttpServlet {

    private static final Gson GSON = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String receiptId = request.getParameter("receipt_id");
        String type = request.getParameter("type");
        try (PrintWriter out = response.getWriter()) {
            if (receiptId == null || receiptId.trim().isEmpty()) {
                out.print(GSON.toJson(new ResponseMessage("error", "Receipt ID must not be empty.", false)));
                out.flush();
                return;
            }
            if (receiptId.length() > 50) {
                out.print(GSON.toJson(new ResponseMessage("error", "Receipt ID cannot exceed 50 characters.", false)));
                out.flush();
                return;
            }
            if (!receiptId.matches("^[A-Za-z0-9-_]+$")) {
                out.print(GSON.toJson(new ResponseMessage("error", "Receipt ID can only contain alphanumeric characters, hyphens, or underscores.", false)));
                out.flush();
                return;
            }

            try (Connection conn = DBContext.getConnection()) {
                boolean exists = false;
                String sql;

                if ("import".equalsIgnoreCase(type)) {
                    sql = "SELECT 1 FROM ImportReceipts WHERE LOWER(receipt_id) = LOWER(?)";
                } else if ("export".equalsIgnoreCase(type)) {
                    sql = "SELECT 1 FROM ExportReceipts WHERE LOWER(receipt_id) = LOWER(?)";
                } else {
                    sql = "SELECT 1 FROM ImportReceipts WHERE LOWER(receipt_id) = LOWER(?) UNION SELECT 1 FROM ExportReceipts WHERE LOWER(receipt_id) = LOWER(?)";
                }

                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, receiptId);
                    if (!"import".equalsIgnoreCase(type) && !"export".equalsIgnoreCase(type)) {
                        ps.setString(2, receiptId);
                    }
                    try (ResultSet rs = ps.executeQuery()) {
                        exists = rs.next();
                    }
                }

                if (exists) {
                    out.print(GSON.toJson(new ResponseMessage("error", "The receipt ID already exists. Please use a different code.", true)));
                } else {
                    out.print(GSON.toJson(new ResponseMessage("success", "The receipt ID is available.", false)));
                }
                out.flush();
            } catch (SQLException e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print(GSON.toJson(new ResponseMessage("error", "Database error: " + e.getMessage(), false)));
                out.flush();
            }
        }
    }

    private static class ResponseMessage {

        String status;
        String message;
        boolean exists;

        ResponseMessage(String status, String message, boolean exists) {
            this.status = status;
            this.message = message;
            this.exists = exists;
        }
    }
}
