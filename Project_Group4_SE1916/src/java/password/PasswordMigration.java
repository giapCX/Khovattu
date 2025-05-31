import org.mindrot.jbcrypt.BCrypt;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import Dal.DBContext;

public class PasswordMigration {
    public static void main(String[] args) throws Exception {
        try (Connection conn = DBContext.getConnection()) {
            String selectSQL = "SELECT username, password_hash FROM users";
            PreparedStatement selectStmt = conn.prepareStatement(selectSQL);
            ResultSet rs = selectStmt.executeQuery();

            String updateSQL = "UPDATE users SET password_hash = ? WHERE username = ?";
            PreparedStatement updateStmt = conn.prepareStatement(updateSQL);

            while (rs.next()) {
                String username = rs.getString("username");
                String plainPassword = rs.getString("password_hash");

                if (plainPassword != null && !plainPassword.startsWith("$2a$")) {
                    String hashedPassword = BCrypt.hashpw(plainPassword, BCrypt.gensalt());
                    updateStmt.setString(1, hashedPassword);
                    updateStmt.setString(2, username);
                    updateStmt.executeUpdate();
                    System.out.println("Updated password for user: " + username);
                }
            }
        }
    }
}