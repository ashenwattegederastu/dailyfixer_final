//package com.dailyfixer.util;
//
//import java.sql.Connection;
//import java.sql.DriverManager;
//import java.sql.SQLException;
//
//public class DBConnection {
//    private static final String URL = "jdbc:mysql://localhost:3306/dailyfixer?useSSL=false&serverTimezone=UTC";
//    private static final String USER = "root"; // change if needed
//    private static final String PASS = "admin";
//
//    public static Connection getConnection() throws SQLException, ClassNotFoundException {
//        Class.forName("com.mysql.cj.jdbc.Driver");
//        return DriverManager.getConnection(URL, USER, PASS);
//    }
//}

package com.dailyfixer.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL = "jdbc:mysql://localhost:3306/dailyfixer_demo"
            + "?useSSL=false"
            + "&serverTimezone=Asia/Colombo"
            + "&allowPublicKeyRetrieval=true";

    private static final String USER = "root";
    private static final String PASS = "admin";

    public static Connection getConnection()
            throws SQLException, ClassNotFoundException {

        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(URL, USER, PASS);
    }
}
