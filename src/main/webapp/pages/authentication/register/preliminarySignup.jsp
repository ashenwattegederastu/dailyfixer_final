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
                    background-color: var(--card);
                    color: var(--card-foreground);
                    border: 1px solid var(--border);
                    border-radius: var(--radius-lg);
                    padding: 30px;
                    text-align: center;
                    cursor: pointer;
                    transition: all 0.3s ease;
                    width: 200px;
                    box-shadow: var(--shadow-md);
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    text-decoration: none;
                }

                .role-card:hover {
                    transform: translateY(-5px);
                    box-shadow: var(--shadow-xl);
                    border-color: var(--primary);
                }

                .role-card h3 {
                    margin-top: 20px;
                    font-size: 1.2rem;
                    font-weight: 600;
                }

                .role-card .role-icon {
                    width: 100px;
                    height: 100px;
                    border-radius: 50%;
                    background-color: var(--secondary);
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    transition: background-color 0.3s ease;
                }

                .role-card:hover .role-icon {
                    background-color: var(--primary);
                }

                .role-card .role-icon img {
                    width: 50px;
                    height: 50px;
                    filter: grayscale(100%);
                    transition: filter 0.3s ease;
                }

                .role-card:hover .role-icon img {
                    filter: brightness(0) invert(1);
                }

                .page-title {
                    font-size: 2.5rem;
                    font-weight: 700;
                    margin-bottom: 10px;
                    text-align: center;
                    color: var(--foreground);
                }

                .page-subtitle {
                    color: var(--muted-foreground);
                    text-align: center;
                    font-size: 1.1rem;
                }

                .bottom-actions {
                    margin-top: 60px;
                    display: flex;
                    gap: 20px;
                    justify-content: center;
                }

                .action-link {
                    color: var(--muted-foreground);
                    text-decoration: none;
                    padding: 10px 20px;
                    border-radius: var(--radius-md);
                    background: var(--muted);
                    transition: all 0.2s ease;
                    font-weight: 500;
                }

                .action-link:hover {
                    background: var(--primary);
                    color: var(--primary-foreground);
                }

                .action-link strong {
                    color: var(--foreground);
                }

                .action-link:hover strong {
                    color: var(--primary-foreground);
                }
            </style>
        </head>

        <body>

            <div class="main-content">
                <h1 class="page-title">Join Daily Fixer</h1>
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