package Dal;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBContext {

    private static final String URL = "jdbc:mysql://127.0.0.1:3306/quan_ly_vat_tu?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String USERNAME = "root";
    private static final String PASSWORD = "123456";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("Không tìm thấy JDBC Driver: " + e.getMessage());
        }
    }

   public static Connection getConnection() {
        Connection conn = null;
        try {
            // Nạp driver (nếu dùng JDBC thuần)
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Mở kết nối

            conn = DriverManager.getConnection(URL, USERNAME, PASSWORD);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return conn;
    }

    // Để kiểm tra
    public static void main(String[] args) {
        try (Connection conn = getConnection()) {
            System.out.println("Kết nối thành công tới MySQL!");
        } catch (SQLException e) {
            System.err.println("Lỗi kết nối: " + e.getMessage());
        }
    }
}