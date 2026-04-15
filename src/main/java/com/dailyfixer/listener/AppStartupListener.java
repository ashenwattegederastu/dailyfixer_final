package com.dailyfixer.listener;

import com.dailyfixer.job.BookingNoShowJob;
import com.dailyfixer.job.ClientPenaltyEscalationJob;
import com.dailyfixer.job.DeliveryTimeoutJob;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Bootstraps background jobs when the web application starts.
 * Registered automatically via @WebListener — no web.xml entry needed.
 * Jobs started here:
 *  - DeliveryTimeoutJob:  runs every 2 minutes, enforces delivery time-limit rules.
 *  - BookingNoShowJob:    runs every 10 minutes, marks no-shows and auto-rejects stale requests.
 */
@WebListener
public class AppStartupListener implements ServletContextListener {

    /** How often the delivery timeout check runs (minutes). */
    private static final int DELIVERY_CHECK_INTERVAL_MINUTES = 2;

    /** How often the booking no-show / auto-reject check runs (minutes). */
    private static final int BOOKING_CHECK_INTERVAL_MINUTES = 2;

    /** How often the client penalty escalation check runs (minutes). */
    private static final int PENALTY_ESCALATION_INTERVAL_MINUTES = 30;

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newScheduledThreadPool(3, r -> {
            Thread t = new Thread(r, "dailyfixer-job");
            t.setDaemon(true); // Don't prevent JVM shutdown
            return t;
        });

        // Initial delay of 2 minutes lets the app fully start up before the first run
        scheduler.scheduleAtFixedRate(
                new DeliveryTimeoutJob(),
                2,
                DELIVERY_CHECK_INTERVAL_MINUTES,
                TimeUnit.MINUTES
        );
        System.out.println("[AppStartupListener] DeliveryTimeoutJob scheduled — runs every "
                + DELIVERY_CHECK_INTERVAL_MINUTES + " minutes.");

        scheduler.scheduleAtFixedRate(
                new BookingNoShowJob(),
                5,
                BOOKING_CHECK_INTERVAL_MINUTES,
                TimeUnit.MINUTES
        );
        System.out.println("[AppStartupListener] BookingNoShowJob scheduled — runs every "
                + BOOKING_CHECK_INTERVAL_MINUTES + " minutes.");

        scheduler.scheduleAtFixedRate(
                new ClientPenaltyEscalationJob(),
                10,
                PENALTY_ESCALATION_INTERVAL_MINUTES,
                TimeUnit.MINUTES
        );
        System.out.println("[AppStartupListener] ClientPenaltyEscalationJob scheduled — runs every "
                + PENALTY_ESCALATION_INTERVAL_MINUTES + " minutes.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdownNow();
            System.out.println("[AppStartupListener] Scheduler shut down.");
        }
    }
}
