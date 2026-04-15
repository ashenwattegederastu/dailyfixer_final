(function () {
    "use strict";

    const DATA = window.PRODUCT_DETAILS_DATA || {};
    const contextPath = DATA.contextPath || "";
    const hasVariants = !!DATA.hasVariants;
    const baseStock = Number(DATA.baseStock || 0);
    const basePrice = Number(DATA.basePrice || 0);
    const baseDisplayPrice = Number(DATA.baseDisplayPrice || 0);
    const variants = Array.isArray(DATA.variants) ? DATA.variants : [];
    const baseDiscount = DATA.baseDiscount || null;
    const isLoggedIn = !!DATA.isLoggedIn;
    const canPurchase = !!DATA.canPurchase;
    const currentCartTotal = Number(DATA.currentCartTotal || 0);
    const priceLimit = Number(DATA.priceLimit || 10000);

    const btn = document.getElementById("addBtn");
    const buyNowBtn = document.getElementById("buyNowBtn");
    const qty = document.getElementById("qty");
    const minusBtn = document.getElementById("minusBtn");
    const plusBtn = document.getElementById("plusBtn");
    const priceValueEl = document.getElementById("priceValue");
    const stockStatusEl = document.getElementById("stockStatus");
    const selectedVariantIdEl = document.getElementById("selectedVariantId");
    const selectedColorEl = document.getElementById("selectedColor");
    const selectedSizeEl = document.getElementById("selectedSize");
    const selectedPowerEl = document.getElementById("selectedPower");
    const priceDetailsEl = document.getElementById("priceDetails");
    const originalPriceEl = document.getElementById("originalPrice");
    const discountBadgeEl = document.getElementById("discountBadge");
    const priceLimitBannerEl = document.getElementById("priceLimitBanner");
    const priceLimitMessageEl = document.getElementById("priceLimitMessage");
    const mainImgEl = document.getElementById("mainProductImage");
    const defaultImgSrc = mainImgEl ? mainImgEl.src : "";

    let currentStock = baseStock;
    let currentPrice = baseDisplayPrice;
    let currentOriginalPrice = basePrice;

    function getQuantityValue() {
        const parsed = qty ? parseInt(qty.value, 10) : 1;
        return Number.isFinite(parsed) && parsed > 0 ? parsed : 1;
    }

    function applyPriceLimitState() {
        const quantityValue = getQuantityValue();
        const lineTotal = currentPrice * quantityValue;
        const addToCartTotal = currentCartTotal + lineTotal;
        const selectionValid = currentStock > 0 && (!hasVariants || !!(selectedVariantIdEl && selectedVariantIdEl.value));
        const itemLimitExceeded = lineTotal > priceLimit;
        const orderLimitExceeded = addToCartTotal > priceLimit;

        if (priceLimitBannerEl && priceLimitMessageEl) {
            if (itemLimitExceeded) {
                priceLimitMessageEl.textContent = "This item exceeds the Rs 10,000 purchase limit.";
                priceLimitBannerEl.style.display = "flex";
            } else if (orderLimitExceeded) {
                priceLimitMessageEl.textContent = "Adding this item would exceed the Rs 10,000 order limit.";
                priceLimitBannerEl.style.display = "flex";
            } else {
                priceLimitBannerEl.style.display = "none";
                priceLimitMessageEl.textContent = "";
            }
        }

        if (btn) {
            btn.disabled = !selectionValid || !canPurchase || itemLimitExceeded || orderLimitExceeded;
        }
        if (buyNowBtn) {
            buyNowBtn.disabled = !selectionValid || !canPurchase || itemLimitExceeded;
        }

        if (qty) {
            const priceLimitedMax = currentPrice > 0 ? Math.floor(priceLimit / currentPrice) : currentStock;
            const maxAllowed = Math.max(0, Math.min(currentStock, priceLimitedMax));
            if (maxAllowed > 0) {
                qty.max = maxAllowed;
                if (getQuantityValue() > maxAllowed) {
                    qty.value = maxAllowed;
                }
            }
            if (minusBtn) {
                minusBtn.disabled = qty.disabled || currentStock <= 0 || getQuantityValue() <= 1;
            }
            if (plusBtn) {
                plusBtn.disabled = qty.disabled || currentStock <= 0 || maxAllowed <= 0 || getQuantityValue() >= maxAllowed;
            }
        }
    }

    function getSelectedValues() {
        return {
            color: selectedColorEl ? selectedColorEl.value : "",
            size: selectedSizeEl ? selectedSizeEl.value : "",
            power: selectedPowerEl ? selectedPowerEl.value : ""
        };
    }

    function findMatchingVariant() {
        if (!hasVariants) return null;

        const selected = getSelectedValues();
        const selectedColor = selected.color;
        const selectedSize = selected.size;
        const selectedPower = selected.power;

        for (const variant of variants) {
            const colorMatch = !selectedColor || variant.color === selectedColor || variant.color === "";
            const sizeMatch = !selectedSize || variant.size === selectedSize || variant.size === "";
            const powerMatch = !selectedPower || variant.power === selectedPower || variant.power === "";

            if (colorMatch && sizeMatch && powerMatch) {
                if ((!selectedColor || variant.color === selectedColor) &&
                    (!selectedSize || variant.size === selectedSize) &&
                    (!selectedPower || variant.power === selectedPower)) {
                    return variant;
                }
            }
        }
        return null;
    }

    function applyDiscountBadge(discount) {
        if (!priceDetailsEl || !originalPriceEl || !discountBadgeEl) {
            return;
        }

        if (discount && discount.isValid) {
            priceDetailsEl.style.display = "flex";
            originalPriceEl.textContent = "Rs " + currentOriginalPrice.toFixed(2);
            if (discount.type === "PERCENTAGE") {
                discountBadgeEl.textContent = discount.value + "% OFF";
            } else {
                discountBadgeEl.textContent = "Rs " + discount.value + " OFF";
            }
        } else {
            priceDetailsEl.style.display = "none";
        }
    }

    function updateVariantSelection() {
        if (!hasVariants) {
            currentStock = baseStock;
            currentPrice = baseDisplayPrice;
            currentOriginalPrice = basePrice;
            applyDiscountBadge(baseDiscount);
            if (priceValueEl) priceValueEl.textContent = currentPrice.toFixed(2);
            applyPriceLimitState();
            return;
        }

        const variant = findMatchingVariant();

        if (variant) {
            currentOriginalPrice = Number(variant.price || 0);
            currentStock = Number(variant.quantity || 0);

            if (variant.discount && variant.discount.isValid) {
                currentPrice = Number(variant.displayPrice || currentOriginalPrice);
                applyDiscountBadge(variant.discount);
            } else {
                currentPrice = currentOriginalPrice;
                applyDiscountBadge(null);
            }

            if (priceValueEl) priceValueEl.textContent = currentPrice.toFixed(2);
            if (selectedVariantIdEl) selectedVariantIdEl.value = variant.id;

            if (mainImgEl) {
                var imgUrl = variant.imagePath && variant.imagePath !== ""
                    ? contextPath + "/" + variant.imagePath
                    : defaultImgSrc;
                setMainImage(imgUrl);
                syncGalleryToImage(imgUrl);
            }

            if (currentStock > 0) {
                if (stockStatusEl) {
                    stockStatusEl.textContent = "In Stock: " + currentStock;
                    stockStatusEl.style.color = "green";
                }
                if (btn) btn.disabled = !canPurchase;
                if (buyNowBtn) buyNowBtn.disabled = !canPurchase;
                if (minusBtn) minusBtn.disabled = false;
                if (plusBtn) plusBtn.disabled = false;
                if (qty) {
                    qty.disabled = false;
                    qty.max = currentStock;
                    if (parseInt(qty.value, 10) > currentStock) {
                        qty.value = currentStock;
                    }
                }
                applyPriceLimitState();
            } else {
                if (stockStatusEl) {
                    stockStatusEl.textContent = "Out of Stock";
                    stockStatusEl.style.color = "red";
                }
                if (btn) btn.disabled = true;
                if (buyNowBtn) buyNowBtn.disabled = true;
                if (minusBtn) minusBtn.disabled = true;
                if (plusBtn) plusBtn.disabled = true;
                if (qty) qty.disabled = true;
                applyPriceLimitState();
            }
        } else {
            const selected = getSelectedValues();
            const hasColor = selected.color;
            const hasSize = selected.size;
            const hasPower = selected.power;

            if (hasColor || hasSize || hasPower) {
                if (stockStatusEl) {
                    stockStatusEl.textContent = "Please select a valid combination";
                    stockStatusEl.style.color = "orange";
                }
                if (btn) btn.disabled = true;
                if (buyNowBtn) buyNowBtn.disabled = true;
                if (selectedVariantIdEl) selectedVariantIdEl.value = "";
                applyPriceLimitState();
            } else {
                currentOriginalPrice = basePrice;
                currentPrice = baseDisplayPrice;
                currentStock = baseStock;

                applyDiscountBadge(baseDiscount);

                if (priceValueEl) priceValueEl.textContent = currentPrice.toFixed(2);
                if (stockStatusEl) {
                    stockStatusEl.textContent = baseStock > 0 ? "In Stock: " + baseStock : "Out of Stock";
                    stockStatusEl.style.color = baseStock > 0 ? "green" : "red";
                }
                if (btn) btn.disabled = baseStock <= 0 || !canPurchase;
                if (buyNowBtn) buyNowBtn.disabled = baseStock <= 0 || !canPurchase;
                if (selectedVariantIdEl) selectedVariantIdEl.value = "";
                applyPriceLimitState();
            }
        }
    }

    function handleVariantButtonClick(clickedButton, optionType) {
        const value = clickedButton.getAttribute("data-value");
        const hiddenInput = document.getElementById("selected" + optionType.charAt(0).toUpperCase() + optionType.slice(1));

        const wasAlreadyActive = clickedButton.classList.contains("active");

        let selector = "";
        if (optionType === "color") {
            selector = "button.color-btn";
        } else if (optionType === "size") {
            selector = "button.size-btn";
        } else if (optionType === "power") {
            selector = "button.power-btn";
        }

        const allButtons = document.querySelectorAll(selector);

        allButtons.forEach((b) => {
            b.classList.remove("active");
            const minWidth = b.style.minWidth;
            const position = b.style.position;
            b.style.cssText = "";
            if (minWidth) b.style.minWidth = minWidth;
            if (position) b.style.position = position;
        });

        if (!wasAlreadyActive) {
            clickedButton.classList.add("active");
            if (hiddenInput) hiddenInput.value = value;
        } else {
            if (hiddenInput) hiddenInput.value = "";
        }

        updateVariantSelection();
    }

    function attachVariantButtonListeners() {
        const colorButtons = document.querySelectorAll("button.color-btn");
        const sizeButtons = document.querySelectorAll("button.size-btn");
        const powerButtons = document.querySelectorAll("button.power-btn");

        colorButtons.forEach((button) => {
            button.onclick = null;
            button.addEventListener("click", function (e) {
                e.preventDefault();
                e.stopPropagation();
                handleVariantButtonClick(this, "color");
            });
        });

        sizeButtons.forEach((button) => {
            button.onclick = null;
            button.addEventListener("click", function (e) {
                e.preventDefault();
                e.stopPropagation();
                handleVariantButtonClick(this, "size");
            });
        });

        powerButtons.forEach((button) => {
            button.onclick = null;
            button.addEventListener("click", function (e) {
                e.preventDefault();
                e.stopPropagation();
                handleVariantButtonClick(this, "power");
            });
        });
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", function () {
            setTimeout(attachVariantButtonListeners, 100);
        });
    } else {
        setTimeout(attachVariantButtonListeners, 100);
    }

    if (minusBtn && plusBtn && qty) {
        minusBtn.onclick = () => {
            const v = parseInt(qty.value, 10);
            if (v > 1) {
                qty.value = v - 1;
                applyPriceLimitState();
            }
        };

        plusBtn.onclick = () => {
            const v = parseInt(qty.value, 10);
            const maxStock = hasVariants ? currentStock : baseStock;
            if (v < maxStock) {
                qty.value = v + 1;
                applyPriceLimitState();
            }
        };

        qty.addEventListener("input", applyPriceLimitState);
    }

    function redirectToLogin() {
        const currentPath = window.location.pathname + window.location.search;
        const loginBase = (DATA.loginUrl && DATA.loginUrl.split("?")[0]) || (contextPath + "/pages/authentication/login.jsp");
        window.location.href = loginBase + "?redirect=" + encodeURIComponent(currentPath);
    }

    if (btn) {
        btn.addEventListener("click", () => {
            if (!isLoggedIn) {
                alert("Please login before purchasing products");
                redirectToLogin();
                return;
            }

            const variantId = selectedVariantIdEl ? selectedVariantIdEl.value : "";
            if (hasVariants && !variantId) {
                alert("Please select color, size, and power options");
                return;
            }

            if (currentStock <= 0) {
                alert("Product is out of stock");
                return;
            }

            const quantity = parseInt(qty.value, 10);
            if (!quantity || quantity < 1) {
                alert("Invalid quantity");
                return;
            }

            if (quantity > currentStock) {
                alert("Requested quantity exceeds available stock");
                return;
            }

            if ((currentPrice * quantity) > priceLimit) {
                alert("This item exceeds the Rs 10,000 purchase limit");
                return;
            }

            if ((currentCartTotal + (currentPrice * quantity)) > priceLimit) {
                alert("This order exceeds the Rs 10,000 purchase limit");
                return;
            }

            const params = new URLSearchParams();
            params.append("productId", btn.dataset.productId);
            params.append("quantity", quantity);
            if (variantId) {
                params.append("variantId", variantId);
            }

            fetch(contextPath + "/addToCart", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: params.toString()
            })
                .then((res) => res.json())
                .then((data) => {
                    if (data.error) {
                        alert(data.error);
                        return;
                    }

                    const cartCount = document.querySelector(".cart-count");
                    if (cartCount) cartCount.innerText = data.cartCount;

                    alert("Product added to cart");
                })
                .catch(() => alert("Server error"));
        });
    }

    if (buyNowBtn) {
        buyNowBtn.addEventListener("click", () => {
            if (!isLoggedIn) {
                alert("Please login before purchasing products");
                redirectToLogin();
                return;
            }

            const productId = buyNowBtn.getAttribute("data-product-id");
            const quantity = qty ? parseInt(qty.value, 10) : 1;
            const variantId = selectedVariantIdEl ? selectedVariantIdEl.value : "";

            if (hasVariants && !variantId) {
                alert("Please select color, size, and power options");
                return;
            }

            if (!productId) {
                alert("Product ID missing!");
                return;
            }

            if (!quantity || quantity < 1) {
                alert("Invalid quantity!");
                return;
            }

            if (quantity > currentStock) {
                alert("Requested quantity exceeds available stock");
                return;
            }

            if ((currentPrice * quantity) > priceLimit) {
                alert("This item exceeds the Rs 10,000 purchase limit");
                return;
            }

            const checkoutUrl = new URL(contextPath + "/pages/stores/checkout.jsp", window.location.origin);
            checkoutUrl.searchParams.set("productId", productId);
            checkoutUrl.searchParams.set("quantity", String(quantity));
            if (variantId) {
                checkoutUrl.searchParams.set("variantId", variantId);
            }
            window.location.href = checkoutUrl.toString();
        });
    }

    function autoSelectFirstVariant() {
        if (!hasVariants || variants.length === 0) return;

        const firstVariant = variants[0];

        if (firstVariant.color && firstVariant.color !== "") {
            const colorBtn = document.querySelector('.color-btn[data-value="' + firstVariant.color + '"]');
            if (colorBtn && selectedColorEl) {
                colorBtn.classList.add("active");
                selectedColorEl.value = firstVariant.color;
            }
        }

        if (firstVariant.size && firstVariant.size !== "") {
            const sizeBtn = document.querySelector('.size-btn[data-value="' + firstVariant.size + '"]');
            if (sizeBtn && selectedSizeEl) {
                sizeBtn.classList.add("active");
                selectedSizeEl.value = firstVariant.size;
            }
        }

        if (firstVariant.power && firstVariant.power !== "") {
            const powerBtn = document.querySelector('.power-btn[data-value="' + firstVariant.power + '"]');
            if (powerBtn && selectedPowerEl) {
                powerBtn.classList.add("active");
                selectedPowerEl.value = firstVariant.power;
            }
        }

        updateVariantSelection();
    }

    if (hasVariants) {
        autoSelectFirstVariant();
    } else {
        updateVariantSelection();
    }

    function setMainImage(url) {
        if (!mainImgEl || !url) return;
        mainImgEl.style.transition = "opacity 0.15s ease";
        mainImgEl.style.opacity = "0";
        setTimeout(function () {
            mainImgEl.src = url;
            mainImgEl.style.opacity = "1";
        }, 150);
    }

    function syncGalleryToImage(url) {
        document.querySelectorAll(".thumbnail-item").forEach(function (t) {
            if (t.dataset.src === url) {
                t.classList.add("active");
            } else {
                t.classList.remove("active");
            }
        });
    }

    function initGallery() {
        var thumbs = document.querySelectorAll(".thumbnail-item");
        thumbs.forEach(function (thumb) {
            thumb.addEventListener("click", function () {
                setMainImage(this.dataset.src);
                thumbs.forEach(function (t) { t.classList.remove("active"); });
                this.classList.add("active");
            });
        });
        if (thumbs.length > 0 && !document.querySelector(".thumbnail-item.active")) {
            thumbs[0].classList.add("active");
        }
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", initGallery);
    } else {
        initGallery();
    }
})();
