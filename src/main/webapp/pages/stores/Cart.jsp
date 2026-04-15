<%@ page import="java.util.Map" %>
<%@ page import="com.dailyfixer.model.CartItem" %>
<%@ page import="com.dailyfixer.model.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Check if user is logged in
    User currentUser = (User) session.getAttribute("currentUser");
    boolean isLoggedIn = (currentUser != null);
    double purchaseLimit = 10000.0;
%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Daily Fixer - Cart</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/cart.css" />
</head>

<body>

    <jsp:include page="/pages/shared/header.jsp"/>

    <div class="cart-container">
        <h2>Your Cart</h2>

        <% @SuppressWarnings("unchecked") Map<String, CartItem> cart = (Map<String, CartItem>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) { %>
            <p class="empty-cart-msg">Your cart is empty.</p>
            <p class="subtotal">Subtotal: Rs 0</p>
        <% } else { %>
            <div class="cart-items">
                <% for (CartItem ci : cart.values()) { %>
                    <div class="cart-item" data-id="<%=ci.getProductId()%>"
                        data-unit-price="<%=ci.getPrice()%>"
                        data-cart-key="<%=ci.getVariantId() != null ? "V-" + ci.getVariantId() : "P-" + ci.getProductId()%>">
                        <% String ciImg = ci.getImagePath(); %>
                        <img src="<%=ciImg != null && !ciImg.isEmpty() ? request.getContextPath() + "/" + ciImg : request.getContextPath() + "/assets/images/tools.png"%>" alt="<%=ci.getName()%>">
                        <div class="item-details">
                            <p class="item-name"><%=ci.getName()%></p>
                            <% if (ci.getVariantId() != null) { %>
                                <p style="font-size: 0.85rem; color: var(--muted-foreground); margin-bottom: 4px;">
                                    <% if (ci.getVariantColor() != null && !ci.getVariantColor().isEmpty()) { %>
                                        Color: <%=ci.getVariantColor()%>
                                    <% } %>
                                    <% if (ci.getVariantSize() != null && !ci.getVariantSize().isEmpty()) { %>
                                        <% if (ci.getVariantColor() != null && !ci.getVariantColor().isEmpty()) { %> | <% } %>
                                        Size: <%=ci.getVariantSize()%>
                                    <% } %>
                                    <% if (ci.getVariantPower() != null && !ci.getVariantPower().isEmpty()) { %>
                                        <% if ((ci.getVariantColor() != null && !ci.getVariantColor().isEmpty()) ||
                                               (ci.getVariantSize() != null && !ci.getVariantSize().isEmpty())) { %> | <% } %>
                                        Power: <%=ci.getVariantPower()%>
                                    <% } %>
                                </p>
                            <% } %>
                            <p class="item-qty">
                                Quantity:
                                <span class="quantity-controls"
                                    data-product-id="<%=ci.getProductId()%>"
                                    data-variant-id="<%=ci.getVariantId() != null ? ci.getVariantId() : ""%>"
                                    data-cart-key="<%=ci.getVariantId() != null ? "V-" + ci.getVariantId() : "P-" + ci.getProductId()%>">
                                    <button type="button" class="qty-btn qty-decrease">-</button>
                                    <span class="qty-value"><%=ci.getQuantity()%></span>
                                    <button type="button" class="qty-btn qty-increase">+</button>
                                </span>
                            </p>
                            <p class="item-price">
                                <% if (ci.getDiscountAmount() > 0.01 && ci.getOriginalPrice() > ci.getPrice()) { %>
                                    <span style="text-decoration: line-through; color: var(--muted-foreground); margin-right: 10px;">
                                        Rs <%= String.format("%.2f", ci.getOriginalPrice()) %>
                                    </span>
                                    <span style="color: var(--chart-1); font-weight: 600;">
                                        Rs <%= String.format("%.2f", ci.getPrice()) %>
                                    </span>
                                    <% if (ci.getDiscountName() != null && !ci.getDiscountName().trim().isEmpty()) { %>
                                        <span style="background: var(--destructive); color: var(--destructive-foreground); padding: 2px 8px; border-radius: 8px; font-size: 0.8em; margin-left: 8px;">
                                            <%= ci.getDiscountName() %>
                                        </span>
                                    <% } %>
                                <% } else { %>
                                    Price: Rs <%= String.format("%.2f", ci.getPrice()) %>
                                <% } %>
                            </p>
                        </div>
                        <button class="remove-item"
                            data-product-id="<%=ci.getProductId()%>"
                            data-variant-id="<%=ci.getVariantId() != null ? ci.getVariantId() : ""%>"
                            data-cart-key="<%=ci.getVariantId() != null ? "V-" + ci.getVariantId() : "P-" + ci.getProductId()%>">Remove</button>
                    </div>
                <% } %>
            </div>

            <%
            double subtotal = 0;
            double totalDiscount = 0;
            boolean itemPriceLimitExceeded = false;
            for (CartItem ci : cart.values()) {
                subtotal += ci.getQuantity() * ci.getOriginalPrice();
                if (ci.getDiscountAmount() > 0) {
                    totalDiscount += ci.getTotalDiscount();
                }
                if ((ci.getPrice() * ci.getQuantity()) > purchaseLimit) {
                    itemPriceLimitExceeded = true;
                }
            }
            double finalTotal = subtotal - totalDiscount;
            boolean orderPriceLimitExceeded = finalTotal > purchaseLimit;
            %>
            <div class="cart-summary">
                <div class="summary-row subtotal-row">
                    <span class="summary-label">Subtotal</span>
                    <span class="summary-value" id="subtotal">Rs <%= String.format("%.2f", subtotal) %></span>
                </div>
                <% if (totalDiscount > 0) { %>
                    <div class="summary-row discount-row">
                        <span class="summary-label">Discount</span>
                        <span class="summary-value discount-value" id="totalDiscount">-Rs <%= String.format("%.2f", totalDiscount) %></span>
                    </div>
                <% } %>
                <div class="summary-row total-row">
                    <span class="summary-label">Total</span>
                    <span class="summary-value total-value" id="finalTotal">Rs <%= String.format("%.2f", finalTotal) %></span>
                </div>
            </div>

            <div id="priceLimitNotice" style="<%= (itemPriceLimitExceeded || orderPriceLimitExceeded) ? "display:block;" : "display:none;" %> background-color: #fff3cd; color: #856404; padding: 12px; border-radius: 8px; margin: 16px 0; border: 1px solid #ffeeba;">
                <%= itemPriceLimitExceeded
                        ? "One or more items exceed the Rs 10,000 purchase limit."
                        : "Your item subtotal exceeds the Rs 10,000 purchase limit." %>
            </div>

            <form id="checkoutForm">
                <button type="button" id="checkoutBtn" class="checkout-btn" <%= (itemPriceLimitExceeded || orderPriceLimitExceeded) ? "disabled title=\"Orders above Rs 10,000 are view only\"" : "" %>>Proceed to Checkout</button>
            </form>

        <% } %>
    </div>

    <script>
        function updateSubtotal() {
            const items = document.querySelectorAll(".cart-item");
            let subtotal = 0;
            let totalDiscount = 0;
            let payableTotal = 0;
            let anyItemOverLimit = false;

            items.forEach(item => {
                const qtyText = item.querySelector(".qty-value").innerText;
                const qty = parseInt(qtyText);
                const priceElement = item.querySelector(".item-price");
                const unitPrice = parseFloat(item.dataset.unitPrice || "0");

                // Get original price and discounted price
                let originalPrice = 0;
                let discountedPrice = 0;
                const priceText = priceElement.innerText;

                // Check if there's a discount (line-through price exists)
                const originalPriceMatch = priceText.match(/Rs\s+([\d.]+)/);
                if (originalPriceMatch) {
                    originalPrice = parseFloat(originalPriceMatch[1]);
                }

                // Get the discounted price (usually the second price)
                const prices = priceText.match(/Rs\s+([\d.]+)/g);
                if (prices && prices.length > 1) {
                    discountedPrice = parseFloat(prices[1].replace("Rs ", ""));
                    totalDiscount += (originalPrice - discountedPrice) * qty;
                    subtotal += originalPrice * qty;
                } else if (originalPriceMatch) {
                    // No discount, single price
                    discountedPrice = originalPrice;
                    subtotal += originalPrice * qty;
                } else {
                    // Fallback: try to parse single price
                    const singlePrice = parseFloat(priceText.replace(/[^\d.]/g, ''));
                    if (!isNaN(singlePrice)) {
                        originalPrice = singlePrice;
                        discountedPrice = singlePrice;
                        subtotal += originalPrice * qty;
                    }
                }

                const payableLineTotal = unitPrice * qty;
                payableTotal += payableLineTotal;
                if (payableLineTotal > <%= purchaseLimit %>) {
                    anyItemOverLimit = true;
                }
            });

            const subtotalElement = document.getElementById("subtotal");
            const discountElement = document.getElementById("totalDiscount");
            const discountRow = discountElement ? discountElement.closest(".summary-row") : null;
            const finalTotalElement = document.getElementById("finalTotal");
            const finalTotal = subtotal - totalDiscount;

            if (subtotalElement) {
                subtotalElement.innerText = "Rs " + subtotal.toFixed(2);
            }

            if (discountElement && discountRow) {
                if (totalDiscount > 0) {
                    discountElement.innerText = "-Rs " + totalDiscount.toFixed(2);
                    discountRow.style.display = "flex";
                } else {
                    discountRow.style.display = "none";
                }
            }

            if (finalTotalElement) {
                finalTotalElement.innerText = "Rs " + finalTotal.toFixed(2);
            }

            const checkoutBtn = document.getElementById("checkoutBtn");
            const priceLimitNotice = document.getElementById("priceLimitNotice");
            const orderOverLimit = payableTotal > <%= purchaseLimit %>;

            if (checkoutBtn) {
                checkoutBtn.disabled = anyItemOverLimit || orderOverLimit;
            }

            if (priceLimitNotice) {
                if (anyItemOverLimit) {
                    priceLimitNotice.textContent = "One or more items exceed the Rs 10,000 purchase limit.";
                    priceLimitNotice.style.display = "block";
                } else if (orderOverLimit) {
                    priceLimitNotice.textContent = "Your item subtotal exceeds the Rs 10,000 purchase limit.";
                    priceLimitNotice.style.display = "block";
                } else {
                    priceLimitNotice.style.display = "none";
                    priceLimitNotice.textContent = "";
                }
            }
        }

        function sendQuantityUpdate(productId, variantId, cartKey, newQty, onSuccess) {
            let body = "productId=" + encodeURIComponent(productId) + "&quantity=" + encodeURIComponent(newQty);
            if (variantId && variantId !== "") {
                body += "&variantId=" + encodeURIComponent(variantId);
            }
            body += "&cartKey=" + encodeURIComponent(cartKey);

            fetch('<%=request.getContextPath()%>/updateCartQuantity', {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: body
            })
                .then(res => res.json())
                .then(data => {
                    if (data.error) {
                        alert(data.error);
                        return;
                    }
                    if (typeof onSuccess === "function") {
                        onSuccess(data);
                    }
                })
                .catch(() => alert("Server error"));
        }

        document.querySelectorAll(".cart-item").forEach(item => {
            const quantityControls = item.querySelector(".quantity-controls");
            if (!quantityControls) return;

            const productId = quantityControls.getAttribute("data-product-id");
            const variantId = quantityControls.getAttribute("data-variant-id") || "";
            const cartKey = quantityControls.getAttribute("data-cart-key");
            const decBtn = item.querySelector(".qty-decrease");
            const incBtn = item.querySelector(".qty-increase");
            const qtyValueEl = item.querySelector(".qty-value");

            if (!decBtn || !incBtn || !qtyValueEl) return;

            decBtn.addEventListener("click", () => {
                let currentQty = parseInt(qtyValueEl.innerText);
                if (currentQty <= 1) return; // keep at least 1
                const newQty = currentQty - 1;
                sendQuantityUpdate(productId, variantId, cartKey, newQty, (data) => {
                    qtyValueEl.innerText = newQty;
                    const cartCountEl = document.querySelector(".cart-count");
                    if (cartCountEl && typeof data.cartCount === "number") {
                        cartCountEl.innerText = data.cartCount;
                    }
                    updateSubtotal();
                });
            });

            incBtn.addEventListener("click", () => {
                let currentQty = parseInt(qtyValueEl.innerText);
                const newQty = currentQty + 1;
                sendQuantityUpdate(productId, variantId, cartKey, newQty, (data) => {
                    const finalQty = typeof data.quantity === "number" ? data.quantity : newQty;
                    qtyValueEl.innerText = finalQty;
                    const cartCountEl = document.querySelector(".cart-count");
                    if (cartCountEl && typeof data.cartCount === "number") {
                        cartCountEl.innerText = data.cartCount;
                    }
                    updateSubtotal();
                });
            });
        });

        document.querySelectorAll(".remove-item").forEach(btn => {
            btn.addEventListener("click", () => {
                const productId = btn.dataset.productId;
                const variantId = btn.dataset.variantId || "";
                const cartKey = btn.dataset.cartKey;

                let body = "productId=" + encodeURIComponent(productId);
                if (variantId && variantId !== "") {
                    body += "&variantId=" + encodeURIComponent(variantId);
                }
                body += "&cartKey=" + encodeURIComponent(cartKey);

                fetch('<%=request.getContextPath()%>/removeFromCart', {
                    method: "POST",
                    headers: { "Content-Type": "application/x-www-form-urlencoded" },
                    body: body
                })
                    .then(async res => {
                        if (!res.ok) {
                            throw new Error("HTTP " + res.status);
                        }
                        const text = await res.text();
                        try {
                            return JSON.parse(text);
                        } catch (e) {
                            throw new Error("Invalid JSON: " + text.substring(0, 50));
                        }
                    })
                    .then(data => {
                        if (data.error) {
                            alert(data.error);
                            return;
                        }
                        // Remove item from DOM
                        const itemDiv = btn.closest(".cart-item");
                        itemDiv.remove();

                        // Update nav cart count
                        const cartCountEl = document.querySelector(".cart-count");
                        if (cartCountEl) cartCountEl.innerText = data.cartCount;

                        // Update subtotal
                        updateSubtotal();

                        // Show "cart empty" if no items
                        if (document.querySelectorAll(".cart-item").length === 0) {
                            document.querySelector(".cart-items")?.remove();
                            document.querySelector(".cart-summary")?.remove();
                            document.getElementById("checkoutForm")?.remove();

                            const cartContainer = document.querySelector(".cart-container");

                            const emptyMsg = document.createElement("p");
                            emptyMsg.className = "empty-cart-msg";
                            emptyMsg.innerText = "Your cart is empty.";
                            cartContainer.appendChild(emptyMsg);

                            const subtotalP = document.createElement("p");
                            subtotalP.className = "subtotal";
                            subtotalP.innerText = "Subtotal: Rs 0";
                            cartContainer.appendChild(subtotalP);
                        }
                    })
                    .catch(err => alert("Server error details: " + err.message));
            });
        });

        document.getElementById("checkoutBtn").addEventListener("click", () => {
            <% if (!isLoggedIn) { %>
                alert("Please login before purchasing products");
                const currentPath = window.location.pathname + window.location.search;
                window.location.href = "<%=request.getContextPath()%>/pages/authentication/login.jsp?redirect=" + encodeURIComponent(currentPath);
                return;
            <% } %>
            window.location.href = "checkout.jsp?fromCart=1";
        });

        updateSubtotal();
    </script>

</body>

</html>
