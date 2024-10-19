import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.CallableStatement;
import java.sql.SQLException;

public class connect {

    // Database credentials
    private static final String URL = "jdbc:sqlserver://localhost:1433;databaseName=YourDatabase";
    private static final String USER = "yourUsername";
    private static final String PASSWORD = "yourPassword";

    // Method to call any stored procedure with name, parameters (name, course, age)
    public static void callStoredProcedure(String procedureName, String name, String course, int age) {
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

            System.out.println("Stored procedure '" + procedureName + "' executed successfully.");

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        } finally {
            // Close the resources
            try {
                if (callableStatement != null) callableStatement.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    public static void main(String[] args) {
        // Example of how to call the method with a dynamic procedure name
        callStoredProcedure("InsertStudent", "John Doe", "Computer Science", 20);
    }
}
