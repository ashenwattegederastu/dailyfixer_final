package com.dailyfixer.config;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * Configuration loader for PayHere and database settings.
 * Reads from config.properties file in classpath.
 */
public class PayHereConfig {

    private static Properties properties = new Properties();
    private static boolean loaded = false;

    // Load properties from config file
    static {
        loadProperties();
    }

    /**
     * Load configuration from properties file
     */
    private static void loadProperties() {
        try (InputStream input = PayHereConfig.class.getClassLoader()
                .getResourceAsStream("config.properties")) {
            if (input != null) {
                properties.load(input);
                loaded = true;
            } else {
                System.err.println("WARNING: config.properties not found in classpath");
            }
        } catch (IOException e) {
            System.err.println("ERROR loading config.properties: " + e.getMessage());
        }
    }

    // ==================== PayHere Settings ====================

    /**
     * Get PayHere Merchant ID
     */
    public static String getMerchantId() {
        return properties.getProperty("payhere.merchant_id", "");
    }

    /**
     * Get PayHere Merchant Secret (Base64 encoded)
     */
    public static String getMerchantSecret() {
        return properties.getProperty("payhere.merchant_secret", "");
    }

    /**
     * Get PayHere Sandbox/Production URL
     */
    public static String getPayHereUrl() {
        return properties.getProperty("payhere.sandbox_url",
                "https://sandbox.payhere.lk/pay/checkout");
    }

    // ==================== Application URLs ====================

    /**
     * Get base URL of the application
     */
    public static String getBaseUrl() {
        return properties.getProperty("app.base_url", "http://localhost:8080/dailyfixer");
    }

    /**
     * Get return URL (success page)
     */
    public static String getReturnUrl() {
        return properties.getProperty("app.return_url",
                "http://localhost:8080/dailyfixer/success.html");
    }

    /**
     * Get cancel URL (cancel/failure page)
     */
    public static String getCancelUrl() {
        return properties.getProperty("app.cancel_url",
                "http://localhost:8080/dailyfixer/cancel.html");
    }

    /**
     * Get notify URL (server callback endpoint)
     */
    public static String getNotifyUrl() {
        return properties.getProperty("app.notify_url",
                "http://localhost:8080/dailyfixer/notify");
    }

    // ==================== Database Settings ====================

    /**
     * Get database connection URL
     */
    public static String getDbUrl() {
        return properties.getProperty("db.url",
                "jdbc:mysql://localhost:3306/dailyfixer_payments");
    }

    /**
     * Get database username
     */
    public static String getDbUsername() {
        return properties.getProperty("db.username", "root");
    }

    /**
     * Get database password
     */
    public static String getDbPassword() {
        return properties.getProperty("db.password", "");
    }

    /**
     * Check if properties were loaded successfully
     */
    public static boolean isLoaded() {
        return loaded;
    }
}
