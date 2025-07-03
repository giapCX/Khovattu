package model;

public class User {
    private int userId;
    private String code;
    private String username;
    private String password;
    private String fullName;
    private String address;
    private String email;
    private String phone;
    private String Image; // Đổi từ imageUrl thành Image
    private String dateOfBirth;
    private String status;
    private Role role;

    public User() {
    }

    public User(int userId, String code, String username, String password, String fullName, String address, String email, String phone, String Image, String dateOfBirth, String status, Role role) {
        this.userId = userId;
        this.code = code;
        this.username = username;
        this.password = password;
        this.fullName = fullName;
        this.address = address;
        this.email = email;
        this.phone = phone;
        this.Image = Image; // Đổi từ imageUrl thành Image
        this.dateOfBirth = dateOfBirth;
        this.status = status;
        this.role = role;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getImage() { // Đổi từ getImageUrl thành getImage
        return Image;
    }

    public void setImage(String Image) { // Đổi từ setImageUrl thành setImage
        this.Image = Image;
    }

    public String getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(String dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }
}