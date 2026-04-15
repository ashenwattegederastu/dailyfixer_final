package com.dailyfixer.util;

import com.dailyfixer.dao.StoreDAO;
import com.dailyfixer.model.Product;
import com.dailyfixer.model.Store;

import java.util.ArrayList;
import java.util.List;

public final class PurchaseRadiusFilter {

    public static final double RADIUS_KM = 10.0;

    private PurchaseRadiusFilter() {}

    public static List<Product> withinRadius(List<Product> products, double userLat, double userLng,
                                            StoreDAO storeDAO) {
        List<Product> out = new ArrayList<>();
        if (products == null || products.isEmpty()) {
            return out;
        }
        for (Product p : products) {
            Store store = resolveStore(storeDAO, p);
            if (store == null) {
                continue;
            }
            if (store.getLatitude() == 0.0 && store.getLongitude() == 0.0) {
                continue;
            }
            double km = DeliveryFeeCalculator.haversineDistance(
                    userLat, userLng, store.getLatitude(), store.getLongitude());
            if (km <= RADIUS_KM) {
                out.add(p);
            }
        }
        return out;
    }

    private static Store resolveStore(StoreDAO storeDAO, Product product) {
        Store store = null;
        if (product.getStoreId() > 0) {
            store = storeDAO.getStoreById(product.getStoreId());
        }
        if (store == null && product.getStoreUsername() != null && !product.getStoreUsername().isBlank()) {
            store = storeDAO.getStoreByUsername(product.getStoreUsername());
        }
        return store;
    }
}
