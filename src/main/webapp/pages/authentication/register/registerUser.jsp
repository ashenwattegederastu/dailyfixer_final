<%@ page contentType="text/html; charset=UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <!DOCTYPE html>
        <html>

        <head>
            <title>Register - DailyFixer</title>
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

                .register-container {
                    width: 100%;
                    max-width: 600px;
                }

                .form-container {
                    margin: 0 auto;
                }

                .page-header {
                    text-align: center;
                    margin-bottom: 30px;
                }

                .page-header h2 {
                    font-size: 2rem;
                    color: var(--primary);
                    margin-bottom: 10px;
                }

                .error-text {
                    color: var(--destructive);
                    font-size: 0.85rem;
                    margin-top: 5px;
                    font-weight: 500;
                }

                .server-error {
                    background-color: var(--destructive);
                    /* Using destructive color */
                    color: white;
                    /* Force white text on red background */
                    padding: 15px;
                    border-radius: var(--radius-md);
                    margin-bottom: 20px;
                    font-weight: 500;
                }

                .login-link {
                    text-align: center;
                    margin-top: 20px;
                    color: var(--muted-foreground);
                }

                .login-link a {
                    color: var(--primary);
                    font-weight: 600;
                    text-decoration: none;
                }

                .login-link a:hover {
                    text-decoration: underline;
                }

                .form-cols {
                    display: grid;
                    grid-template-columns: 1fr 1fr;
                    gap: 20px;
                }

                @media (max-width: 600px) {
                    .form-cols {
                        grid-template-columns: 1fr;
                        gap: 0;
                    }
                }
            </style>
        </head>

        <body>

            <div class="register-container">
                <div class="form-container">
                    <div class="page-header">
                        <h2>Create Account</h2>
                        <p style="color: var(--muted-foreground)">Join DailyFixer as a User</p>
                    </div>

                    <% String serverError=(String) request.getAttribute("errorMsg"); %>
                        <% if (serverError !=null) { %>
                            <div class="server-error">
                                <%= serverError %>
                            </div>
                            <% } %>

                                <form id="registerForm" method="post" action="${pageContext.request.contextPath}/registerUser">
                                    <div class="form-cols">
                                        <div class="form-group">
                                            <label for="firstName">First Name</label>
                                            <input type="text" name="firstName" id="firstName" placeholder="First Name">
                                            <div id="firstNameError" class="error-text"></div>
                                        </div>

                                        <div class="form-group">
                                            <label for="lastName">Last Name</label>
                                            <input type="text" name="lastName" id="lastName" placeholder="Last Name">
                                            <div id="lastNameError" class="error-text"></div>
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <label for="username">Username</label>
                                        <input type="text" name="username" id="username"
                                            placeholder="Choose a username">
                                        <div id="usernameError" class="error-text"></div>
                                    </div>

                                    <div class="form-group">
                                        <label for="email">Email Address</label>
                                        <input type="email" name="email" id="email" placeholder="name@example.com">
                                        <!-- input[type=email] acts like text in framework css generally, or we use class -->
                                        <div id="emailError" class="error-text"></div>
                                    </div>

                                    <div class="form-cols">
                                        <div class="form-group">
                                            <label for="password">Password</label>
                                            <input type="password" name="password" id="password"
                                                placeholder="Create a password">
                                            <div id="passwordError" class="error-text"></div>
                                        </div>

                                        <div class="form-group">
                                            <label for="confirmPassword">Confirm Password</label>
                                            <input type="password" name="confirmPassword" id="confirmPassword"
                                                placeholder="Confirm password">
                                            <div id="confirmPasswordError" class="error-text"></div>
                                        </div>
                                    </div>

                                    <div class="form-cols">
                                        <div class="form-group">
                                            <label for="phone">Phone Number</label>
                                            <input type="text" name="phone" id="phone" placeholder="10-digit number">
                                            <div id="phoneError" class="error-text"></div>
                                        </div>

                                        <div class="form-group">
                                            <label for="city">City</label>
                                            <select name="city" id="city" class="filter-select" style="width: 100%">
                                                <option value="">-- Select City --</option>
                                                <option>Colombo</option>
                                                <option>Kandy</option>
                                                <option>Galle</option>
                                                <option>Jaffna</option>
                                                <option>Negombo</option>
                                                <option>Matara</option>
                                                <option>Trincomalee</option>
                                                <option>Anuradhapura</option>
                                                <option>Kurunegala</option>
                                                <option>Ratnapura</option>
                                                <option>Badulla</option>
                                                <option>Hambantota</option>
                                                <option>Puttalam</option>
                                                <option>Polonnaruwa</option>
                                                <option>Nuwara Eliya</option>
                                                <option>Vavuniya</option>
                                                <option>Mannar</option>
                                                <option>Mullaitivu</option>
                                                <option>Kalutara</option>
                                                <option>Batticaloa</option>
                                                <option>Ampara</option>
                                                <option>Monaragala</option>
                                                <option>Kegalle</option>
                                                <option>Matalawa</option>
                                            </select>
                                            <div id="cityError" class="error-text"></div>
                                        </div>
                                    </div>

                                    <button type="submit" class="btn-primary"
                                        style="width: 100%; margin-top: 20px;">Register</button>
                                </form>

                                <p class="login-link">Already have an account? <a href="${pageContext.request.contextPath}/pages/authentication/login.jsp">Login here</a></p>
                </div>
            </div>

            <script>
                const form = document.getElementById('registerForm');
                form.addEventListener('submit', e => {
                    document.querySelectorAll('.error-text').forEach(el => el.textContent = '');
                    let hasError = false;
                    const f = id => document.getElementById(id).value.trim();

                    if (!f('firstName')) { document.getElementById('firstNameError').textContent = 'First name required'; hasError = true; }
                    if (!f('lastName')) { document.getElementById('lastNameError').textContent = 'Last name required'; hasError = true; }
                    if (!f('username')) { document.getElementById('usernameError').textContent = 'Username required'; hasError = true; }
                    if (!f('email')) { document.getElementById('emailError').textContent = 'Email required'; hasError = true; }
                    if (f('password').length < 6) { document.getElementById('passwordError').textContent = 'Min 6 chars'; hasError = true; }
                    if (f('password') !== f('confirmPassword')) { document.getElementById('confirmPasswordError').textContent = 'Passwords do not match'; hasError = true; }
                    if (!f('city')) { document.getElementById('cityError').textContent = 'City required'; hasError = true; }

                    // Phone number validation: exactly 10 digits
                    const phoneVal = f('phone').replace(/\D/g, ''); // remove non-digit characters
                    if (!phoneVal) {
                        document.getElementById('phoneError').textContent = 'Phone number required';
                        hasError = true;
                    } else if (phoneVal.length !== 10) {
                        document.getElementById('phoneError').textContent = 'Phone must be exactly 10 digits';
                        hasError = true;
                    }

                    // Email validation: required + valid format
                    const emailVal = f('email');
                    if (!emailVal) {
                        document.getElementById('emailError').textContent = 'Email required';
                        hasError = true;
                    } else {
                        // Simple regex for basic email format check
                        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                        if (!emailRegex.test(emailVal)) {
                            document.getElementById('emailError').textContent = 'Invalid email format';
                            hasError = true;
                        }
                    }

                    if (hasError) e.preventDefault();
                });
            </script>
            <script src="${pageContext.request.contextPath}/assets/js/password-toggle.js"></script>
        </body>

        </html>