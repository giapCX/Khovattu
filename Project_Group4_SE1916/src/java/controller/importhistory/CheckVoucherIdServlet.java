package controller.importhistory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import com.google.gson.Gson;
import dao.ImportDAO;
import java.sql.SQLException;


public class CheckVoucherIdServlet extends HttpServlet {
    private static class VoucherCheckResponse {
        boolean exists;
        String error;

        VoucherCheckResponse(boolean exists) {
            this.exists = exists;
            this.error = null;
        }

        VoucherCheckResponse(String error) {
            this.exists = false;
            this.error = error;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();

        String voucherId = request.getParameter("voucher_id");
        if (voucherId == null || voucherId.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write(gson.toJson(new VoucherCheckResponse("Mã phiếu nhập không được để trống")));
            out.flush();
            return;
        }

        try {
            ImportDAO dao = new ImportDAO();
            boolean exists = dao.voucherIdExists(voucherId);
            out.write(gson.toJson(new VoucherCheckResponse(exists)));
            out.flush();
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.write(gson.toJson(new VoucherCheckResponse("Lỗi cơ sở dữ liệu: " + e.getMessage())));
            out.flush();
            e.printStackTrace();
        }
    }
}