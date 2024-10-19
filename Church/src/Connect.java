import javax.swing.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.CallableStatement;
import java.sql.SQLException;

public class Connect {

    // Database credentials
    private static final String URL = "jdbc:sqlserver://localhost:63267;databaseName=childQRSystem;encrypt=true;trustServerCertificate=true;";
    private static final String USER = "tangi";
    private static final String PASSWORD = "linus";

    // Method to call any stored procedure with name, parameters (name, course, age)
    public void callStoredProcedure(String procedureName, String name, String course, int age) {
        Connection conn = null;
        CallableStatement callableStatement = null;

        try {
            // Load SQL Server JDBC driver
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

            // Establish the connection to the database
            conn = DriverManager.getConnection(URL, USER, PASSWORD);

            // Define the stored procedure call dynamically based on the procedure name
            String storedProc = "{call " + procedureName + "(?, ?, ?)}";
            callableStatement = conn.prepareCall(storedProc);

            // Set input parameters for the stored procedure
            callableStatement.setString(1, name);
            callableStatement.setString(2, course);
            callableStatement.setInt(3, age);

            // Execute the stored procedure
            callableStatement.execute();

            JOptionPane.showMessageDialog(null,"Stored procedure '" + procedureName + "' executed successfully.");

        } catch (SQLException e) {
            // Handle SQL exceptions, especially for specific SQL Server errors
            System.out.println("SQL Error: " + e.getMessage()+"Error");
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            // Handle JDBC driver not found error
            JOptionPane.showMessageDialog(null, "JDBC Driver not found: " + e.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
            e.printStackTrace();
        } finally {
            // Ensure the resources are closed properly
            try {
                if (callableStatement != null) callableStatement.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                JOptionPane.showMessageDialog(null, "Error closing resources: " + e.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
                e.printStackTrace();
            }
        }
    }
}
