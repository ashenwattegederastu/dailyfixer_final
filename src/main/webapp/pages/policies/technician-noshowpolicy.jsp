<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Technician No-Show Policy | Daily Fixer</title>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
    <style>
        .policy-container {
            max-width: 800px;
            margin: 60px auto;
            padding: 40px 30px;
        }

        .policy-card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 40px;
            box-shadow: var(--shadow-sm);
        }

        .policy-card h1 {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--foreground);
            margin-bottom: 8px;
        }

        .policy-card h2 {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--foreground);
            margin: 28px 0 10px;
        }

        .policy-card p {
            color: var(--muted-foreground);
            font-size: 0.95rem;
            line-height: 1.7;
            margin-bottom: 16px;
        }

        .policy-list {
            margin: 0;
            padding-left: 20px;
            color: var(--foreground);
        }

        .policy-list li {
            margin-bottom: 10px;
            line-height: 1.6;
        }

        .penalty-table {
            width: 100%;
            border-collapse: collapse;
            margin: 16px 0 24px;
            font-size: 0.92rem;
        }

        .penalty-table th {
            text-align: left;
            padding: 10px 14px;
            background: var(--muted);
            color: var(--foreground);
            font-weight: 600;
            border: 1px solid var(--border);
        }

        .penalty-table td {
            padding: 10px 14px;
            border: 1px solid var(--border);
            color: var(--muted-foreground);
            vertical-align: top;
        }

        .penalty-table tr:nth-child(even) td {
            background: var(--muted);
        }

        .badge {
            display: inline-block;
            font-size: 0.78rem;
            font-weight: 600;
            padding: 2px 10px;
            border-radius: 20px;
        }

        .badge-warn  { background: #fef9c3; color: #854d0e; }
        .badge-supp  { background: #fed7aa; color: #9a3412; }
        .badge-susp  { background: #fee2e2; color: #991b1b; }

        .placeholder-notice {
            background: var(--muted);
            border: 1px dashed var(--border);
            border-radius: 12px;
            padding: 30px;
            text-align: center;
            margin-top: 24px;
            color: var(--muted-foreground);
        }

        .back-link {
            display: inline-block;
            margin-top: 24px;
            color: var(--primary);
            text-decoration: none;
            font-weight: 600;
            font-size: 0.9rem;
        }

        .back-link:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="policy-container">
        <div class="policy-card">
            <h1>Technician No-Show Policy</h1>
            <p>Daily Fixer enforces a progressive penalty system to protect clients and maintain standards across our technician network. This page explains how no-shows are detected, how penalties escalate, and how to resolve a penalty if one is issued against your account.</p>

            <h2>What Counts as a No-Show?</h2>
            <p>A booking is automatically marked as a <strong>no-show</strong> when <strong>30 minutes</strong> have elapsed past its scheduled start time and the technician has not moved the booking to <em>In Progress</em>. Emergency circumstances (accidents, road closures, hospitalisation) are considered valid grounds for appeal — see the <em>Appeals</em> section below.</p>

            <h2>Rolling 90-Day Window</h2>
            <p>Penalties are based on the number of no-shows recorded within the <strong>last 90 calendar days</strong>. A no-show that falls outside that window no longer counts toward your rolling total. Penalties issued for earlier violations are lifted automatically when their expiry date passes.</p>

            <h2>Penalty Tiers</h2>
            <table class="penalty-table">
                <thead>
                    <tr>
                        <th>No-Shows (90 days)</th>
                        <th>Penalty Level</th>
                        <th>Consequence</th>
                        <th>Duration</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>1</td>
                        <td><span class="badge badge-warn">Level 1 — Warning</span></td>
                        <td>A formal warning notification is sent. No service restrictions at this stage.</td>
                        <td>Record held for 90 days</td>
                    </tr>
                    <tr>
                        <td>2</td>
                        <td><span class="badge badge-supp">Level 2 — Suppressed</span></td>
                        <td>Your service listing is hidden from clients. Existing accepted bookings remain unaffected.</td>
                        <td>7 days; lifts automatically</td>
                    </tr>
                    <tr>
                        <td>3 or more</td>
                        <td><span class="badge badge-susp">Level 3 — Suspended</span></td>
                        <td>Your account is suspended. You cannot accept new bookings. A support review is required before reinstatement.</td>
                        <td>Indefinite; admin lift required</td>
                    </tr>
                </tbody>
            </table>

            <h2>How Penalties Are Applied</h2>
            <ul class="policy-list">
                <li>Penalties are applied automatically by the Daily Fixer system — no manual review is required for Level 1 or Level 2.</li>
                <li>Level 3 suspensions are flagged for admin review before reinstatement is processed.</li>
                <li>Only one penalty per no-show is recorded; if you are already at a higher level, a lower-level penalty is not added on top.</li>
                <li>A penalty notification is sent to your account at the time of issue.</li>
            </ul>

            <h2>Appeals</h2>
            <p>If you believe a no-show was recorded in error, or if you had a genuine emergency, you may submit an appeal to our support team. Appeals must include the relevant booking number and, where possible, supporting documentation (e.g., medical certificate, traffic incident report). Approved appeals result in the penalty being lifted manually by an admin.</p>

            <div class="placeholder-notice">
                <p style="font-size: 1.05rem; font-weight: 600; margin-bottom: 8px;">Contact Support to Appeal</p>
                <p style="margin-bottom: 0;">Reach out via the official Daily Fixer contact channel with your booking ID and the reason for appeal. Appeals are reviewed within 3 business days.</p>
            </div>

            <a href="${pageContext.request.contextPath}/pages/dashboards/technicianDashboard.jsp" class="back-link">&#8592; Back to Dashboard</a>
        </div>
    </div>
</body>
</html>
