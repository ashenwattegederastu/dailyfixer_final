<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.dailyfixer.model.User" %>

<%
  User user = (User) session.getAttribute("currentUser");
  if (user == null || !"driver".equalsIgnoreCase(user.getRole())) {
    response.sendRedirect(request.getContextPath() + "/pages/authentication/login.jsp");
    return;
  }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Driver Delivery Procedure | Daily Fixer</title>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
  <style>
    .container {
      flex: 1;
      margin-left: 240px;
      padding: 32px;
      background: linear-gradient(180deg, color-mix(in srgb, var(--muted) 55%, transparent), transparent 280px), var(--background);
      min-height: 100vh;
    }

    .page-shell {
      max-width: 1180px;
      margin: 0 auto;
    }

    .hero {
      display: grid;
      grid-template-columns: 1.6fr 0.9fr;
      gap: 24px;
      margin-bottom: 24px;
    }

    .hero-card,
    .panel,
    .step-card,
    .info-card,
    .notice-card {
      background: var(--card);
      border: 1px solid var(--border);
      border-radius: var(--radius-lg);
      box-shadow: var(--shadow-sm);
    }

    .hero-card {
      padding: 28px;
      background: linear-gradient(135deg, color-mix(in srgb, var(--primary) 18%, var(--card)) 0%, var(--card) 55%, color-mix(in srgb, var(--secondary) 65%, var(--card)) 100%);
    }

    .eyebrow {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 8px 12px;
      border-radius: 999px;
      background: color-mix(in srgb, var(--primary) 12%, var(--background));
      color: var(--primary);
      font-size: 0.82rem;
      font-weight: 700;
      letter-spacing: 0.04em;
      text-transform: uppercase;
      margin-bottom: 16px;
    }

    .hero-card h1 {
      margin: 0 0 12px;
      font-size: clamp(2rem, 4vw, 3rem);
      line-height: 1.05;
      color: var(--foreground);
    }

    .hero-card p {
      margin: 0;
      max-width: 60ch;
      color: var(--muted-foreground);
      font-size: 1rem;
      line-height: 1.7;
    }

    .hero-summary {
      padding: 24px;
      display: grid;
      gap: 14px;
    }

    .summary-item {
      padding: 14px 16px;
      border-radius: var(--radius-md);
      background: var(--muted);
    }

    .summary-item strong {
      display: block;
      color: var(--foreground);
      margin-bottom: 4px;
      font-size: 0.95rem;
    }

    .summary-item span {
      color: var(--muted-foreground);
      font-size: 0.92rem;
      line-height: 1.5;
    }

    .grid {
      display: grid;
      grid-template-columns: minmax(0, 1.65fr) minmax(280px, 0.95fr);
      gap: 24px;
      align-items: start;
    }

    .panel {
      padding: 24px;
    }

    .section-title {
      margin: 0 0 8px;
      font-size: 1.5rem;
      color: var(--foreground);
    }

    .section-subtitle {
      margin: 0 0 22px;
      color: var(--muted-foreground);
      line-height: 1.6;
    }

    .steps {
      display: grid;
      gap: 16px;
    }

    .step-card {
      padding: 20px;
      display: grid;
      grid-template-columns: auto 1fr;
      gap: 16px;
    }

    .step-number {
      width: 44px;
      height: 44px;
      border-radius: 14px;
      display: grid;
      place-items: center;
      font-weight: 800;
      color: var(--primary-foreground);
      background: linear-gradient(135deg, var(--primary), color-mix(in srgb, var(--primary) 65%, black));
      box-shadow: var(--shadow-sm);
    }

    .step-card h3 {
      margin: 0 0 8px;
      color: var(--foreground);
      font-size: 1.08rem;
    }

    .step-card p {
      margin: 0 0 12px;
      color: var(--muted-foreground);
      line-height: 1.6;
    }

    .tag-row {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
    }

    .tag {
      padding: 7px 10px;
      border-radius: 999px;
      background: var(--muted);
      color: var(--foreground);
      font-size: 0.82rem;
      font-weight: 600;
    }

    .sidebar-stack {
      display: grid;
      gap: 18px;
    }

    .info-card,
    .notice-card {
      padding: 20px;
    }

    .info-card h3,
    .notice-card h3 {
      margin: 0 0 10px;
      color: var(--foreground);
      font-size: 1.02rem;
    }

    .info-card ul,
    .notice-card ol,
    .notice-card ul {
      margin: 0;
      padding-left: 18px;
      color: var(--muted-foreground);
      line-height: 1.7;
    }

    .info-card li + li,
    .notice-card li + li {
      margin-top: 8px;
    }

    .notice-card {
      background: linear-gradient(180deg, color-mix(in srgb, #f59e0b 10%, var(--card)), var(--card));
    }

    .contact-box {
      margin-top: 14px;
      padding: 14px;
      border-radius: var(--radius-md);
      background: var(--muted);
      color: var(--foreground);
      font-weight: 600;
    }

    .mini-checklist {
      display: grid;
      gap: 12px;
    }

    .check-item {
      display: flex;
      gap: 12px;
      align-items: flex-start;
      padding: 14px;
      border-radius: var(--radius-md);
      background: var(--muted);
    }

    .check-mark {
      width: 22px;
      height: 22px;
      border-radius: 999px;
      flex-shrink: 0;
      margin-top: 2px;
      background: color-mix(in srgb, var(--primary) 20%, var(--background));
      border: 1px solid color-mix(in srgb, var(--primary) 45%, var(--border));
    }

    .check-item strong {
      display: block;
      margin-bottom: 4px;
      color: var(--foreground);
    }

    .check-item span {
      color: var(--muted-foreground);
      line-height: 1.5;
      font-size: 0.93rem;
    }

    .footer-note {
      margin-top: 22px;
      padding: 18px 20px;
      border-left: 4px solid var(--primary);
      border-radius: var(--radius-md);
      background: color-mix(in srgb, var(--primary) 10%, var(--card));
      color: var(--foreground);
      line-height: 1.6;
    }

    @media (max-width: 1100px) {
      .hero,
      .grid {
        grid-template-columns: 1fr;
      }
    }

    @media (max-width: 768px) {
      .container {
        margin-left: 0;
        padding: 100px 16px 24px;
      }

      .hero-card,
      .panel,
      .info-card,
      .notice-card,
      .step-card {
        padding: 18px;
      }

      .step-card {
        grid-template-columns: 1fr;
      }
    }
  </style>
</head>
<body>

<%@ include file="/pages/dashboards/driverdash/sidebar.jsp" %>

<main class="container">
  <div class="page-shell">
    <section class="hero">
      <div class="hero-card">
        <div class="eyebrow">Driver Guide</div>
        <h1>Delivery Procedure</h1>
        <p>
          This page gives drivers a simple operating flow from accepting a delivery to handing the order to the buyer.
          The text is intentionally lightweight for now so you can replace each section with your final procedure later.
        </p>
      </div>

      <div class="hero-summary">
        <div class="summary-item">
          <strong>Start Point</strong>
          <span>Accept the delivery only if you can complete it safely and within the expected time.</span>
        </div>
        <div class="summary-item">
          <strong>Main Goal</strong>
          <span>Keep the store, buyer, and platform updated while moving the order through each delivery stage.</span>
        </div>
        <div class="summary-item">
          <strong>If Something Goes Wrong</strong>
          <span>Document the issue, attempt contact, wait the required time, and escalate before leaving the location.</span>
        </div>
      </div>
    </section>

    <section class="grid">
      <div class="panel">
        <h2 class="section-title">Step-by-Step Flow</h2>
        <p class="section-subtitle">
          Use these steps as the base procedure for every delivery. You can later edit the wording, timing, and policy details.
        </p>

        <div class="steps">
          <article class="step-card">
            <div class="step-number">1</div>
            <div>
              <h3>Accept the request</h3>
              <p>Review the order details, pickup point, drop-off point, and item notes before confirming. Only accept if your vehicle, route, and current workload allow you to complete it properly.</p>
              <div class="tag-row">
                <span class="tag">Check route</span>
                <span class="tag">Confirm capacity</span>
                <span class="tag">Review notes</span>
              </div>
            </div>
          </article>

          <article class="step-card">
            <div class="step-number">2</div>
            <div>
              <h3>Travel to the pickup location</h3>
              <p>Head to the store or sender as soon as possible. If there is an unusual delay, update the relevant party through the platform or agreed communication channel.</p>
              <div class="tag-row">
                <span class="tag">Leave promptly</span>
                <span class="tag">Report delays</span>
              </div>
            </div>
          </article>

          <article class="step-card">
            <div class="step-number">3</div>
            <div>
              <h3>Verify the package at pickup</h3>
              <p>Match the order ID, package count, and any visible condition details before leaving. If something looks wrong, ask the pickup location to correct it before you continue.</p>
              <div class="tag-row">
                <span class="tag">Check order ID</span>
                <span class="tag">Inspect packaging</span>
                <span class="tag">Raise issues early</span>
              </div>
            </div>
          </article>

          <article class="step-card">
            <div class="step-number">4</div>
            <div>
              <h3>Mark the order in transit</h3>
              <p>Once pickup is complete, update the delivery status so the buyer can see progress. Keep location and ETA communication as accurate as possible.</p>
              <div class="tag-row">
                <span class="tag">Update status</span>
                <span class="tag">Share ETA</span>
              </div>
            </div>
          </article>

          <article class="step-card">
            <div class="step-number">5</div>
            <div>
              <h3>Arrive and attempt delivery</h3>
              <p>Confirm the drop-off address, contact the buyer if needed, and hand over the package only to the correct recipient or according to the approved drop-off instruction.</p>
              <div class="tag-row">
                <span class="tag">Confirm destination</span>
                <span class="tag">Contact buyer</span>
                <span class="tag">Verify handoff</span>
              </div>
            </div>
          </article>

          <article class="step-card">
            <div class="step-number">6</div>
            <div>
              <h3>Complete the delivery record</h3>
              <p>Mark the order delivered only after the handoff is complete. Add a note if there was a delay, special instruction, or issue during the trip.</p>
              <div class="tag-row">
                <span class="tag">Mark delivered</span>
                <span class="tag">Add final notes</span>
              </div>
            </div>
          </article>
        </div>

        <div class="footer-note">
          Keep all communication professional and use platform-approved status updates whenever possible. If the real business rule uses specific wait times, proof requirements, or escalation contacts, replace the placeholder guidance on this page with those exact rules.
        </div>
      </div>

      <div class="sidebar-stack">
        <aside class="notice-card">
          <h3>If the buyer is unreachable</h3>
          <ol>
            <li>Daily Fixer uses a one-attempt delivery policy.</li>
            <li>If the buyer answers, they may authorize handover to a nearby neighbor or family member using the delivery PIN.</li>
            <li>If the buyer does not answer, use the doorstep proof completion flow only when the order allows it.</li>
            <li>Upload two clear proof photos: package close-up and package with door/house context.</li>
            <li>Do not mark delivered until both photos are uploaded successfully.</li>
            <li>If a buyer raises an issue later, support handles the dispute via email using the saved proof.</li>
          </ol>
          <div class="contact-box">
            Required proof: two photos are mandatory for buyer-unreachable doorstep completion.
          </div>
        </aside>

        <aside class="info-card">
          <h3>Quick checklist before pickup</h3>
          <div class="mini-checklist">
            <div class="check-item">
              <div class="check-mark"></div>
              <div>
                <strong>Vehicle ready</strong>
                <span>Fuel, storage space, and documents are in order.</span>
              </div>
            </div>
            <div class="check-item">
              <div class="check-mark"></div>
              <div>
                <strong>Phone charged</strong>
                <span>Navigation, calls, and status updates can be completed without interruption.</span>
              </div>
            </div>
            <div class="check-item">
              <div class="check-mark"></div>
              <div>
                <strong>Order understood</strong>
                <span>You reviewed delivery notes, special instructions, and destination details.</span>
              </div>
            </div>
          </div>
        </aside>

        <aside class="info-card">
          <h3>Delivery conduct reminders</h3>
          <ul>
            <li>Handle packages carefully and keep them secure during transport.</li>
            <li>Communicate early if traffic, weather, or store delays affect the ETA.</li>
            <li>Do not confirm completion until the buyer receives the order properly.</li>
            <li>Document unusual events so the next follow-up is clear.</li>
          </ul>
        </aside>
      </div>
    </section>
  </div>
</main>

</body>
</html>
