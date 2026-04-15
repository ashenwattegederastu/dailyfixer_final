package com.dailyfixer.util;

import com.dailyfixer.model.CartItem;

import java.math.BigDecimal;
import java.math.RoundingMode;

public final class PurchaseLimitUtil {

    public static final BigDecimal PURCHASE_LIMIT = new BigDecimal("10000.00");

    private PurchaseLimitUtil() {
    }

    public static BigDecimal lineTotal(double unitPrice, int quantity) {
        return BigDecimal.valueOf(unitPrice)
                .setScale(2, RoundingMode.HALF_UP)
                .multiply(BigDecimal.valueOf(quantity))
                .setScale(2, RoundingMode.HALF_UP);
    }

    public static boolean isLineTotalOverLimit(double unitPrice, int quantity) {
        return lineTotal(unitPrice, quantity).compareTo(PURCHASE_LIMIT) > 0;
    }

    public static boolean isLineTotalOverLimit(CartItem item) {
        if (item == null) {
            return false;
        }
        return isLineTotalOverLimit(item.getPrice(), item.getQuantity());
    }

    public static BigDecimal cartSubtotal(Iterable<CartItem> items) {
        BigDecimal subtotal = BigDecimal.ZERO;
        if (items == null) {
            return subtotal;
        }

        for (CartItem item : items) {
            if (item == null) {
                continue;
            }
            subtotal = subtotal.add(lineTotal(item.getPrice(), item.getQuantity()));
        }
        return subtotal.setScale(2, RoundingMode.HALF_UP);
    }

    public static boolean isOrderTotalOverLimit(Iterable<CartItem> items) {
        return cartSubtotal(items).compareTo(PURCHASE_LIMIT) > 0;
    }

    public static double purchaseLimitValue() {
        return PURCHASE_LIMIT.doubleValue();
    }
}