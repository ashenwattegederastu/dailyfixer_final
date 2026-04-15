<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Driver Policies | Daily Fixer</title>
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
            <h1>Driver Policies & Terms of Service</h1>
            <p>By registering as a driver on Daily Fixer, you agree to abide by the following policies and guidelines.</p>

            <ul class="policy-list">
                <li>Daily Fixer currently uses a <strong>one-attempt delivery policy</strong>. Re-delivery scheduling is out of scope.</li>
                <li>If the buyer is unavailable but answers the call, the package may be handed to a nearby neighbor or family member only after PIN verification.</li>
                <li>If the buyer is unreachable, doorstep-drop completion is allowed only for orders where buyer consent exists.</li>
                <li>For doorstep-drop completion, the driver must upload <strong>two proof photos</strong>: package close-up and package with door/house context.</li>
                <li>Drivers must not mark an order delivered unless either PIN handover or required photo proof has been completed.</li>
                <li>All delivery disputes are handled by support through the official website email channel.</li>
            </ul>

            <div class="placeholder-notice">
                <p style="font-size: 1.1rem; font-weight: 600; margin-bottom: 8px;">Policy Scope</p>
                <p style="margin-bottom: 0;">Advanced call logging, in-app calling, GPS tracking, and automated logistics rerouting are currently out of scope for this release.</p>
            </div>

            <a href="${pageContext.request.contextPath}/pages/authentication/register/registerDriver.jsp" class="back-link">← Back to Registration</a>
        </div>
    </div>
</body>
</html>
