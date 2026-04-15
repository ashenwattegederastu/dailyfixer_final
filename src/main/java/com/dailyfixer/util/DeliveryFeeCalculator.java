package com.dailyfixer.util;

import com.dailyfixer.model.DeliveryRate;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

/**
 * Stateless utility for delivery fee calculations.
 *
 * Customer-facing price is vehicle-independent: a weighted average across all
 * active vehicle types is computed so the buyer sees one fair price regardless
 * of which vehicle type ultimately handles the delivery.
 */
public class DeliveryFeeCalculator {

    private static final int EARTH_RADIUS_KM = 6371;

    /**
     * Haversine great-circle distance between two lat/lng points.
     *
     * @return distance in kilometres
     */
    public static double haversineDistance(double lat1, double lng1,
                                           double lat2, double lng2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                  * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return EARTH_RADIUS_KM * c;
    }

    /**
     * Compute the weighted-average cost per km across all active vehicle types.
     * Uses each rate's distribution_weight (percentage) as the weight.
     *
     * @param rates active DeliveryRate entries
     * @return weighted rate per km, or Rs 85.00 as a safe default
     */
    public static BigDecimal calculateWeightedRate(List<DeliveryRate> rates) {
        if (rates == null || rates.isEmpty()) {
            return new BigDecimal("85.00"); // safe default
        }
        BigDecimal totalWeight = BigDecimal.ZERO;
        BigDecimal weightedRate = BigDecimal.ZERO;
        for (DeliveryRate r : rates) {
            BigDecimal w = r.getDistributionWeight();
            weightedRate = weightedRate.add(r.getCostPerKm().multiply(w));
            totalWeight = totalWeight.add(w);
        }
        if (totalWeight.compareTo(BigDecimal.ZERO) == 0) {
            return new BigDecimal("85.00");
        }
        return weightedRate.divide(totalWeight, 2, RoundingMode.HALF_UP);
    }

    /**
     * Compute the weighted-average base fee across all active vehicle types.
     *
     * @param rates active DeliveryRate entries
     * @return weighted base fee, or Rs 100.00 as a safe default
     */
    public static BigDecimal calculateWeightedBaseFee(List<DeliveryRate> rates) {
        if (rates == null || rates.isEmpty()) {
            return new BigDecimal("100.00");
        }
        BigDecimal totalWeight = BigDecimal.ZERO;
        BigDecimal weightedBase = BigDecimal.ZERO;
        for (DeliveryRate r : rates) {
            BigDecimal w = r.getDistributionWeight();
            weightedBase = weightedBase.add(r.getBaseFee().multiply(w));
            totalWeight = totalWeight.add(w);
        }
        if (totalWeight.compareTo(BigDecimal.ZERO) == 0) {
            return new BigDecimal("100.00");
        }
        return weightedBase.divide(totalWeight, 2, RoundingMode.HALF_UP);
    }

    /**
     * Calculate the customer-facing delivery fee for a single store leg.
     *
     * Formula: baseFee + (distanceKm × ratePerKm), rounded to 2 dp.
     *
     * @param distanceKm distance from store to customer in km
     * @param baseFee    weighted base fee
     * @param ratePerKm  weighted cost per km
     * @return delivery fee in LKR
     */
    public static BigDecimal calculateDeliveryFee(double distanceKm,
                                                   BigDecimal baseFee,
                                                   BigDecimal ratePerKm) {
        BigDecimal distance = BigDecimal.valueOf(distanceKm)
                                        .setScale(4, RoundingMode.HALF_UP);
        return baseFee.add(ratePerKm.multiply(distance))
                      .setScale(2, RoundingMode.HALF_UP);
    }
}
