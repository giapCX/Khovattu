/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package controller;


import dao.MaterialDAO;
import dao.SupplierDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.ImportReceipt;
import model.ImportDetail;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;


@MultipartConfig
public class ImportDataController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        request.getRequestDispatcher("importData.jsp").forward(request, response);
    }

    @Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    HttpSession session = request.getSession(false);
    if (session == null || session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int userId = (int) session.getAttribute("userId");
    SupplierDAO supplierDao = new SupplierDAO();
    MaterialDAO materialDao = new MaterialDAO();
    List<ImportReceipt> receipts = new ArrayList<>();
    List<ImportDetail> details = new ArrayList<>();

    // Xử lý file CSV
    var csvFile = request.getPart("csvFile");
    if (csvFile != null && csvFile.getSize() > 0) {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(csvFile.getInputStream()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] data = line.split(",");
                if (data.length == 9) {
                    ImportReceipt receipt = new ImportReceipt();
                    receipt.setImportId(Integer.parseInt(data[0].trim()));
                    receipt.setSupplierId(Integer.parseInt(data[1].trim()));
                    receipt.setUserId(userId);
                    receipt.setImportDate(java.sql.Date.valueOf(data[3].trim()));
                    receipt.setNote(data[4].trim());

                    ImportDetail detail = new ImportDetail();
                    detail.setImportId(Integer.parseInt(data[0].trim()));
                    detail.setMaterialId(Integer.parseInt(data[5].trim()));
                    detail.setQuantity(Double.parseDouble(data[6].trim()));
                    detail.setPricePerUnit(Double.parseDouble(data[7].trim()));
                    detail.setMaterialCondition(data[8].trim());

                    receipts.add(receipt);
                    details.add(detail);
                }
            }
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi khi xử lý file CSV: " + e.getMessage());
            request.getRequestDispatcher("importData.jsp").forward(request, response);
            return;
        }
    }

    // Xử lý dữ liệu thủ công
    String manualData = request.getParameter("manualData");
    if (manualData != null && !manualData.isEmpty()) {
        String[] lines = manualData.split("\n");
        for (String line : lines) {
            String[] data = line.split(",");
            if (data.length == 9) {
                ImportReceipt receipt = new ImportReceipt();
                receipt.setImportId(Integer.parseInt(data[0].trim()));
                receipt.setSupplierId(Integer.parseInt(data[1].trim()));
                receipt.setUserId(userId);
                receipt.setImportDate(java.sql.Date.valueOf(data[3].trim()));
                receipt.setNote(data[4].trim());

                ImportDetail detail = new ImportDetail();
                detail.setImportId(Integer.parseInt(data[0].trim()));
                detail.setMaterialId(Integer.parseInt(data[5].trim()));
                detail.setQuantity(Double.parseDouble(data[6].trim()));
                detail.setPricePerUnit(Double.parseDouble(data[7].trim()));
                detail.setMaterialCondition(data[8].trim());

                receipts.add(receipt);
                details.add(detail);
            }
        }
    }

    // Lưu dữ liệu
    try {
        for (ImportReceipt receipt : receipts) {
            supplierDao.saveImportReceipt(receipt, details.stream().filter(d -> d.getImportId() == receipt.getImportId()).toList());
        }
        materialDao.updateInventoryFromImport(details); // Cập nhật tồn kho
        request.setAttribute("message", "Dữ liệu đã nhập kho thành công!");
    } catch (SQLException e) {
        request.setAttribute("error", "Lỗi khi lưu dữ liệu: " + e.getMessage());
    }

    request.getRequestDispatcher("importData.jsp").forward(request, response);
}
}

