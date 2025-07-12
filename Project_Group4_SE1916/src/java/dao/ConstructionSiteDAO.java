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

/**
 *
 * @author Admin
 */
public class ConstructionSiteDAO {

    protected Connection conn;

    public ConstructionSiteDAO(Connection conn) {
        this.conn = conn;
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

    public int countConstructionSiteByNameAddressStatus(String name, String address, String status) {
        int count = 0;
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM ConstructionSites  WHERE 1=1");

        if (name != null && !name.trim().isEmpty()) {
            sql.append(" AND site_name LIKE ?");
        }
        if (address != null && !address.trim().isEmpty()) {
            sql.append(" AND address LIKE ?");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND status = ?");
        }

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int index = 1;
            if (name != null && !name.trim().isEmpty()) {
                ps.setString(index++, "%" + name.trim() + "%");
            }
            if (address != null && !address.trim().isEmpty()) {
                ps.setString(index++, "%" + address.trim() + "%");
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

    public List<ConstructionSite> searchConstructionSiteByNameAddressStatusWithPaging(String name, String address, String status, int offset, int limit) {
        List<ConstructionSite> sites = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM ConstructionSites  WHERE 1=1");

        if (name != null && !name.trim().isEmpty()) {
            sql.append(" AND site_name LIKE ?");
        }
        if (address != null && !address.trim().isEmpty()) {
            sql.append(" AND address LIKE ?");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND status = ?");
        }

        sql.append(" ORDER BY site_id DESC LIMIT ? OFFSET ?");

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int index = 1;
            if (name != null && !name.trim().isEmpty()) {
                ps.setString(index++, "%" + name.trim() + "%");
            }
            if (address != null && !address.trim().isEmpty()) {
                ps.setString(index++, "%" + address.trim() + "%");
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(index++, status.trim());
            }

            ps.setInt(index++, limit);
            ps.setInt(index, offset);

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

}
