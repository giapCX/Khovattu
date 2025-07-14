
package controller.importhistory;

import dao.ConstructionSiteDAO;
import dao.ImportDAO;
import dao.MaterialDAO;
import dao.SupplierDAO;
import model.ConstructionSite;
import model.ImportDetail;
import model.ImportReceipt;
import model.Supplier;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import com.google.gson.Gson;
import model.Material;
import java.util.logging.Logger;
import java.util.logging.Level;

public class ImportMaterialServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(ImportMaterialServlet.class.getName());
    private static final Gson GSON = new Gson();

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        LOGGER.info("Received GET request with action: " + action);
        if (action == null || action.isEmpty()) {
            try (var conn = Dal.DBContext.getConnection()) {
                ConstructionSiteDAO siteDAO = new ConstructionSiteDAO(conn);
                SupplierDAO supplierDAO = new SupplierDAO(conn);
                List<ConstructionSite> sites = siteDAO.getAllConstructionSites();
                List<Supplier> suppliers = supplierDAO.getAllSuppliers();
                request.setAttribute("sites", sites);
                request.setAttribute("suppliers", suppliers);
                LOGGER.info("Forwarding to importData.jsp with sites: " + sites.size() + ", suppliers: " + suppliers.size());
                request.getRequestDispatcher("/view/imports/importData.jsp").forward(request, response);
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Error loading import form: ", e);
                request.setAttribute("error", "Failed to load import form: " + e.getMessage());
                request.getRequestDispatcher("/view/imports/importData.jsp").forward(request, response);
            }
        } else {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();
            try (var conn = Dal.DBContext.getConnection()) {
                if ("searchMaterials".equals(action)) {
                    String term = request.getParameter("term");
                    LOGGER.info("Processing searchMaterials with term: " + term);
                    if (term == null || term.trim().isEmpty()) {
                        LOGGER.warning("Empty search term received");
                        out.print(GSON.toJson(new ArrayList<>()));
                        return;
                    }
                    MaterialDAO materialDAO = new MaterialDAO();
                    List<Material> materials = materialDAO.searchMaterials(term);
                    LOGGER.info("Found " + materials.size() + " materials for term: " + term);
                    out.print(GSON.toJson(materials));
                } else if ("materialsBySite".equals(action)) {
                    int siteId = Integer.parseInt(request.getParameter("siteId"));
                    MaterialDAO materialDAO = new MaterialDAO();
                    List<Map<String, Object>> materials = materialDAO.getMaterialsByConstructionSite(siteId, 1, 100);
                    LOGGER.info("Found " + materials.size() + " materials for siteId: " + siteId);
                    out.print(GSON.toJson(materials));
                } else if ("suppliersByMaterial".equals(action)) {
                    int materialId = Integer.parseInt(request.getParameter("materialId"));
                    SupplierDAO supplierDAO = new SupplierDAO(conn);
                    List<Supplier> suppliers = supplierDAO.getSuppliersByMaterialId(materialId);
                    LOGGER.info("Found " + (suppliers != null ? suppliers.size() : 0) + " suppliers for materialId: " + materialId);
                    if (suppliers == null) {
                        out.print(GSON.toJson(new ArrayList<>()));
                        return;
                    }
                    List<Supplier> filteredSuppliers = suppliers.stream()
                            .filter(s -> s.getMaterials() != null && !s.getMaterials().isEmpty() &&
                                         s.getMaterials().stream().anyMatch(m -> m.getMaterialId() == materialId))
                            .toList();
                    out.print(GSON.toJson(filteredSuppliers));
                } else {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print(GSON.toJson(new ErrorResponse("Invalid action: " + action)));
                }
            } catch (NumberFormatException e) {
                LOGGER.log(Level.SEVERE, "Invalid parameter format: ", e);
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print(GSON.toJson(new ErrorResponse("Invalid parameter format: " + e.getMessage())));
            } catch (Exception e) {
                LOGGER.log(Level.SEVERE, "Server error in action " + action + ": ", e);
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print(GSON.toJson(new ErrorResponse("Server error: " + e.getMessage())));
            } finally {
                out.flush();
            }
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try (var conn = Dal.DBContext.getConnection()) {
            conn.setAutoCommit(false);
            ImportDAO importDAO = new ImportDAO(conn);
            MaterialDAO materialDAO = new MaterialDAO();

            String importType = request.getParameter("importType");
            LOGGER.info("Processing POST request with importType: " + importType);
            if (importType == null || (!"import_from_supplier".equals(importType) && !"import_returned_from_site".equals(importType))) {
                throw new IllegalArgumentException("Invalid import type");
            }

            Integer userId = (Integer) request.getSession().getAttribute("userId");
            if (userId == null) {
                LOGGER.warning("User not logged in, redirecting to login");
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            Integer siteId = request.getParameter("siteId") != null && !request.getParameter("siteId").isEmpty() ?
                             Integer.parseInt(request.getParameter("siteId")) : null;
            String note = request.getParameter("note") != null ? request.getParameter("note").trim() : "";
            Integer supplierId = request.getParameter("supplierId") != null && !request.getParameter("supplierId").isEmpty() ?
                                 Integer.parseInt(request.getParameter("supplierId")) : null;
            String importDateStr = request.getParameter("importDate");
            if (importDateStr == null) {
                throw new IllegalArgumentException("Import date is required");
            }
            Date importDate = Date.valueOf(importDateStr);

            ImportReceipt receipt = new ImportReceipt();
            receipt.setImportType(importType);
            receipt.setUserId(userId);
            receipt.setSiteId("import_from_supplier".equals(importType) ? siteId : null);
            receipt.setReturnedSiteId("import_returned_from_site".equals(importType) ? siteId : null);
            receipt.setImportDate(importDate);
            receipt.setNote(note);
            receipt.setSupplierId(supplierId);

            List<ImportDetail> details = new ArrayList<>();
            String[] materialIds = request.getParameterValues("materialId");
            String[] quantities = request.getParameterValues("quantity");
            String[] prices = request.getParameterValues("pricePerUnit");
            String[] conditions = request.getParameterValues("materialCondition");
            String[] detailSupplierIds = request.getParameterValues("detailSupplierId");

            if (materialIds == null || quantities == null || prices == null || conditions == null ||
                materialIds.length != quantities.length || materialIds.length != prices.length || materialIds.length != conditions.length) {
                throw new IllegalArgumentException("Mismatch in material details");
            }

            for (int i = 0; i < materialIds.length; i++) {
                if (materialIds[i] != null && !materialIds[i].isEmpty()) {
                    ImportDetail detail = new ImportDetail();
                    detail.setMaterialId(Integer.parseInt(materialIds[i]));
                    detail.setQuantity(Double.parseDouble(quantities[i]));
                    detail.setPricePerUnit(Double.parseDouble(prices[i]));
                    detail.setMaterialCondition(conditions[i]);
                    if (detailSupplierIds != null && detailSupplierIds[i] != null && !detailSupplierIds[i].isEmpty()) {
                        detail.setSupplierId(Integer.parseInt(detailSupplierIds[i]));
                    }
                    details.add(detail);
                }
            }

            if (details.isEmpty()) {
                throw new IllegalArgumentException("No materials provided");
            }

            importDAO.saveImport(receipt, details);
            conn.commit();
            LOGGER.info("Import saved successfully for userId: " + userId);
            request.getSession().setAttribute("successMessage", "Import saved successfully!");
            response.sendRedirect(request.getContextPath() + "/importMaterial");
        } catch (IllegalArgumentException e) {
            LOGGER.log(Level.SEVERE, "Validation error: ", e);
            request.setAttribute("error", "Validation error: " + e.getMessage());
            request.getRequestDispatcher("/view/imports/importData.jsp").forward(request, response);
        } catch (Exception e) {
            try (var conn = Dal.DBContext.getConnection()) {
                conn.rollback();
            } catch (Exception rollbackEx) {
                LOGGER.log(Level.SEVERE, "Rollback failed: ", rollbackEx);
            }
            LOGGER.log(Level.SEVERE, "Error saving import: ", e);
            request.setAttribute("error", "Error saving import: " + e.getMessage());
            request.getRequestDispatcher("/view/imports/importData.jsp").forward(request, response);
        }
    }

    private static class ErrorResponse {
        String error;
        ErrorResponse(String error) { this.error = error; }
    }
}
