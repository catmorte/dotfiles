import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import org.json.JSONObject;

public class index {

  public static void main(String[] args) {
    if (args.length < 4) {
      System.out.println("Usage: java index <JDBC_URL> <USERNAME> <PASSWORD> <SQL_QUERY>");
      return;
    }

    String jdbcUrl = args[0];
    String username = args[1];
    String password = args[2];
    String sqlQuery = args[3];

    try (Connection conn = DriverManager.getConnection(jdbcUrl, username, password);
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(sqlQuery)) {

      // Assuming you want to print JSON output for each row
      while (rs.next()) {
        JSONObject json = new JSONObject();
        int columnCount = rs.getMetaData().getColumnCount();
        for (int i = 1; i <= columnCount; i++) {
          String columnName = rs.getMetaData().getColumnName(i);
          Object columnValue = rs.getObject(i);
          json.put(columnName, columnValue);
        }
        System.out.println(json.toString());
      }

    } catch (Exception e) {
      e.printStackTrace();
    }
  }
}
