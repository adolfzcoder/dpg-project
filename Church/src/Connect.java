import javax.swing.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.CallableStatement;
import java.sql.SQLException;

public class Connect {

    // Method to call any stored procedure with name, parameters (name, course, age)
    public void callStoredProcedure(String procedureName,String firstName, String lastName, String DOB, String emergency_contact_number,String emergency_contact_first_name, String emergency_contact_last_name, int classID,String parent_id_number) {
        final String URL = "jdbc:sqlserver://localhost:63267;databaseName=childQRSystem;encrypt=true;trustServerCertificate=true;";
        final String USER = "tangi";
        final String PASSWORD = "linus";
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
            callableStatement.setString(1,firstName);
            callableStatement.setString(2,lastName);
            callableStatement.setString(3, DOB);
            callableStatement.setString(4, emergency_contact_number);
            callableStatement.setString(5, emergency_contact_first_name);
            callableStatement.setString(6, emergency_contact_last_name);
            callableStatement.setInt(7, classID);
            callableStatement.setString(8,parent_id_number);


            // Execute the stored procedure
            callableStatement.execute();

            JOptionPane.showMessageDialog(null,firstName+"'s details saved");

        } catch (SQLException e) {
            // Handle SQL exceptions, especially for specific SQL Server errors
            System.out.println("SQL Error: " + e.getMessage()+"Error");
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            // Handle JDBC driver not found error
            JOptionPane.showMessageDialog(null, "system error\ncall it department", "Error", JOptionPane.ERROR_MESSAGE);
            e.printStackTrace();
        } finally {
            // Ensure the resources are closed properly
            try {
                if (callableStatement != null) callableStatement.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                JOptionPane.showMessageDialog(null, "system error\ncall it department","Error", JOptionPane.ERROR_MESSAGE);
                e.printStackTrace();
            }
        }
    }
}
