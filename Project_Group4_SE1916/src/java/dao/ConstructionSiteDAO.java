/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;
import model.ConstructionSite;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 *
 * @author Admin
 */
public class ConstructionSiteDAO {

    protected Connection conn;

    public ConstructionSiteDAO(Connection conn) {
        this.conn = conn;
    }

    public ConstructionSiteDAO() {
    }

    public List<ConstructionSite> getAllConstructionSites() {
        List<ConstructionSite> sites = new ArrayList<>();
        String sql = "SELECT * FROM ConstructionSites";

        try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ConstructionSite site = new ConstructionSite();
                site.setSiteId(rs.getInt("site_id"));
                site.setSiteName(rs.getString("site_name"));
                site.setAddress(rs.getString("address"));
                site.setManagerId(rs.getInt("manager_id"));
                site.setStartDate(rs.getDate("start_date"));
                site.setEndDate(rs.getDate("end_date"));
                site.setStatus(rs.getString("status"));
                site.setNote(rs.getString("note"));

                sites.add(site);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return sites;
    }

    public int countConstructionSiteBySearchAndStatus(String search, String status) {
        int count = 0;
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM ConstructionSites WHERE 1=1");

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (site_name LIKE ? OR address LIKE ?)");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND status = ?");
        }

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int index = 1;
            if (search != null && !search.trim().isEmpty()) {
                String keyword = "%" + search.trim() + "%";
                ps.setString(index++, keyword);
                ps.setString(index++, keyword);
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(index++, status.trim());
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return count;
    }

    public List<ConstructionSite> searchConstructionSiteBySearchAndStatusWithPaging(
            String search, String status, int offset, int limit) {

        List<ConstructionSite> sites = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM ConstructionSites WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (site_name LIKE ? OR address LIKE ?)");
            String keyword = "%" + search.trim() + "%";
            params.add(keyword);
            params.add(keyword);
        }

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND status = ?");
            params.add(status.trim());
        }

        sql.append(" ORDER BY site_id DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ConstructionSite site = new ConstructionSite();
                    site.setSiteId(rs.getInt("site_id"));
                    site.setSiteName(rs.getString("site_name"));
                    site.setAddress(rs.getString("address"));
                    site.setManagerId(rs.getInt("manager_id"));
                    site.setStartDate(rs.getDate("start_date"));
                    site.setEndDate(rs.getDate("end_date"));
                    site.setStatus(rs.getString("status"));
                    site.setNote(rs.getString("note"));
                    sites.add(site);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return sites;
    }

    public boolean siteExists(int siteId) {
        String sql = "SELECT COUNT(*) FROM ConstructionSites WHERE site_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, siteId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean addConstructionSite(ConstructionSite site) {
        String sql = "INSERT INTO ConstructionSites (site_name, address, manager_id, start_date, end_date, status, note) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, site.getSiteName());
            ps.setString(2, site.getAddress());
            ps.setInt(3, site.getManagerId());
            ps.setDate(4, site.getStartDate());
            ps.setDate(5, site.getEndDate());
            ps.setString(6, site.getStatus());
            ps.setString(7, site.getNote());

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateConstructionSite(ConstructionSite site) {
        String sql = "UPDATE ConstructionSites SET site_name = ?, address = ?, manager_id = ?, start_date = ?, "
                + "end_date = ?, status = ?, note = ? WHERE site_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, site.getSiteName());
            ps.setString(2, site.getAddress());
            ps.setInt(3, site.getManagerId());
            ps.setDate(4, site.getStartDate());
            ps.setDate(5, site.getEndDate());
            ps.setString(6, site.getStatus());
            ps.setString(7, site.getNote());
            ps.setInt(8, site.getSiteId());

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public ConstructionSite getConstructionSiteById(int siteId) {
        String sql = "SELECT * FROM ConstructionSites WHERE site_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, siteId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ConstructionSite site = new ConstructionSite();
                    site.setSiteId(rs.getInt("site_id"));
                    site.setSiteName(rs.getString("site_name"));
                    site.setAddress(rs.getString("address"));
                    site.setManagerId(rs.getInt("manager_id"));
                    site.setStartDate(rs.getDate("start_date"));
                    site.setEndDate(rs.getDate("end_date"));
                    site.setStatus(rs.getString("status"));
                    site.setNote(rs.getString("note"));
                    return site;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
