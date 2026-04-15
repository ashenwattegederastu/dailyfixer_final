<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <title>Application Submitted - Daily Fixer</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
        <style>
            body {
                display: flex;
                align-items: center;
                justify-content: center;
                min-height: 100vh;
                background-color: var(--background);
                padding: 40px 20px;
            }

            .success-container {
                max-width: 520px;
                width: 100%;
                text-align: center;
            }

            .success-icon {
                width: 80px;
                height: 80px;
                background: oklch(0.6290 0.1902 156.4499);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 24px;
                font-size: 2.5rem;
                box-shadow: var(--shadow-lg);
                animation: bounceIn 0.6s ease;
            }

            @keyframes bounceIn {
                0% {
                    transform: scale(0);
                }

                60% {
                    transform: scale(1.1);
                }

                100% {
                    transform: scale(1);
                }
            }

            .success-container h2 {
                font-size: 1.6rem;
                font-weight: 700;
                color: var(--foreground);
                margin-bottom: 12px;
            }

            .success-container>p {
                color: var(--muted-foreground);
                font-size: 0.95rem;
                line-height: 1.6;
                margin-bottom: 8px;
            }

            .info-box {
                background: var(--muted);
                border: 1px solid var(--border);
                border-radius: var(--radius-md);
                padding: 16px;
                margin: 24px 0;
                text-align: left;
            }

            .info-box h4 {
                font-size: 0.9rem;
                color: var(--foreground);
                margin-bottom: 8px;
                font-weight: 700;
            }

            .info-box ul {
                list-style: none;
                padding: 0;
            }

            .info-box ul li {
                font-size: 0.85rem;
                color: var(--muted-foreground);
                padding: 4px 0;
            }

            .info-box ul li::before {
                content: "✓ ";
                font-weight: bold;
                color: oklch(0.6290 0.1902 156.4499);
            }
        </style>
    </head>

    <body>

        <div class="success-container">
            <div class="form-container">
                <div class="success-icon">✓</div>
                <h2>Application Submitted!</h2>
                <p>Thank you for applying to become a DailyFixer Volunteer Guide Writer.</p>
                <p>Your application is now under review by our admin team.</p>

                <div class="info-box">
                    <h4>What happens next?</h4>
                    <ul>
                        <li>Our admin team will review your application</li>
                        <li>We'll check your qualifications and sample guide</li>
                        <li>You'll be notified once a decision is made</li>
                        <li>If approved, you can log in and start writing guides</li>
                    </ul>
                </div>

                <a href="${pageContext.request.contextPath}/pages/authentication/login.jsp" class="btn-primary"
                    style="width:100%;text-align:center;">Go to Login</a>
            </div>
        </div>

    </body>

    </html>