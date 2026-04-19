<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <!DOCTYPE html>
        <html>

        <head>
            <title>Sign Up - Daily Fixer</title>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
            <style>
                body {
                    display: flex;
                    flex-direction: column;
                    min-height: 100vh;
                }

                .main-content {
                    margin-left: 0;
                    margin-top: 0;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    flex-direction: column;
                    padding: 40px 20px;
                    background: transparent !important;
                }

                .role-cards {
                    display: flex;
                    gap: 30px;
                    flex-wrap: wrap;
                    justify-content: center;
                    margin-top: 40px;
                    width: 100%;
                    max-width: 1200px;
                }

                .role-card {
                    background: var(--card);
                    border: 1px solid var(--border);
                    border-radius: 0;
                    padding: 40px 30px;
                    text-align: center;
                    cursor: pointer;
                    transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
                    width: 210px;
                    box-shadow: var(--shadow-md);
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    text-decoration: none;
                }

                .role-card:hover {
                    transform: translateY(-10px);
                    box-shadow: var(--shadow-xl);
                    background: var(--accent);
                    border-color: var(--border);
                }

                .role-card h3 {
                    margin-top: 24px;
                    font-size: 1.2rem;
                    font-weight: 600;
                    color: var(--foreground);
                }

                .role-card .role-icon {
                    width: 110px;
                    height: 110px;
                    border-radius: 0;
                    background: var(--background);
                    box-shadow: var(--shadow-sm);
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    transition: all 0.3s ease;
                }

                .role-card:hover .role-icon {
                    background: var(--card);
                    transform: scale(1.05);
                    box-shadow: var(--shadow-md);
                }

                .role-card .role-icon img {
                    width: 50px;
                    height: 50px;
                    transition: transform 0.3s ease;
                }

                .role-card:hover .role-icon img {
                    transform: scale(1.1);
                }

                .page-title {
                    font-size: 3.5rem;
                    font-weight: 800;
                    margin-bottom: 5px;
                    text-align: center;
                    color: var(--foreground);
                    letter-spacing: -0.02em;
                }

                .page-subtitle {
                    color: var(--muted-foreground);
                    text-align: center;
                    font-size: 1.2rem;
                }

                .bottom-actions {
                    margin-top: 60px;
                    display: flex;
                    gap: 20px;
                    justify-content: center;
                }

                .action-link {
                    color: var(--foreground);
                    text-decoration: none;
                    padding: 14px 28px;
                    border-radius: 0;
                    background: var(--card);
                    border: 1px solid var(--border);
                    transition: all 0.3s ease;
                    font-weight: 500;
                    box-shadow: var(--shadow-sm);
                }

                .action-link:hover {
                    background: var(--accent);
                    color: var(--accent-foreground);
                    border-color: var(--border);
                    transform: translateY(-2px);
                    box-shadow: var(--shadow-md);
                }

                .action-link strong {
                    color: var(--primary);
                    font-weight: 700;
                }
            </style>
        </head>

        <body>


            <div class="main-content">
                <h1 class="page-title">Join DailyFixer</h1>
                <p class="page-subtitle">Choose your role to get started</p>

                <div class="role-cards">
                    <a href="registerUser.jsp" class="role-card">
                        <div class="role-icon">
                            <img src="${pageContext.request.contextPath}/assets/images/icons/user2_signup.svg"
                                alt="User" />
                        </div>
                        <h3>User</h3>
                    </a>
                    <a href="registerTechnician.jsp" class="role-card">
                        <div class="role-icon">
                            <img src="${pageContext.request.contextPath}/assets/images/icons/tech2_signup.svg"
                                alt="Technician" />
                        </div>
                        <h3>Technician</h3>
                    </a>
                    <a href="registerVolunteer.jsp" class="role-card">
                        <div class="role-icon">
                            <img src="${pageContext.request.contextPath}/assets/images/icons/writer_signup.svg"
                                alt="Volunteer" />
                        </div>
                        <h3>Volunteer</h3>
                    </a>
                    <a href="registerDriver.jsp" class="role-card">
                        <div class="role-icon">
                            <img src="${pageContext.request.contextPath}/assets/images/icons/driver_signup.svg"
                                alt="Driver" />
                        </div>
                        <h3>Driver</h3>
                    </a>
                    <a href="registerStore.jsp" class="role-card">
                        <div class="role-icon">
                            <img src="${pageContext.request.contextPath}/assets/images/icons/entrepreneur.png"
                                alt="Store Owner" />
                        </div>
                        <h3>Store Owner</h3>
                    </a>
                </div>

                <div class="bottom-actions">
                    <a href="${pageContext.request.contextPath}/pages/authentication/login.jsp" class="action-link">
                        Already have an account? <strong>Log In</strong>
                    </a>
                    <a href="${pageContext.request.contextPath}/index.jsp" class="action-link">
                        Go Back Home
                    </a>
                </div>
            </div>

        </body>

        </html>