package com.dailyfixer.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

public final class MarketplaceLocationSession {

    public static final String ATTR_LAT = "userLat";
    public static final String ATTR_LNG = "userLng";

    private MarketplaceLocationSession() {}

    public static void syncFromRequest(HttpServletRequest request) {
        HttpSession session = request.getSession();
        String clearLocation = request.getParameter("clearLocation");
        Double lat = tryParseDouble(request.getParameter("lat"));
        Double lng = tryParseDouble(request.getParameter("lng"));
        if ("true".equalsIgnoreCase(clearLocation)) {
            session.removeAttribute(ATTR_LAT);
            session.removeAttribute(ATTR_LNG);
        } else if (lat != null && lng != null) {
            session.setAttribute(ATTR_LAT, lat);
            session.setAttribute(ATTR_LNG, lng);
        }
    }

    public static Double getLat(HttpSession session) {
        return readDouble(session.getAttribute(ATTR_LAT));
    }

    public static Double getLng(HttpSession session) {
        return readDouble(session.getAttribute(ATTR_LNG));
    }

    private static Double readDouble(Object value) {
        if (value instanceof Number) {
            return ((Number) value).doubleValue();
        }
        if (value instanceof String) {
            try {
                return Double.parseDouble((String) value);
            } catch (NumberFormatException ignored) {
                return null;
            }
        }
        return null;
    }

    private static Double tryParseDouble(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return Double.parseDouble(value);
        } catch (NumberFormatException ex) {
            return null;
        }
    }
}
