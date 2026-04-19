(function initProductReviews() {
    "use strict";

    try {
        const DATA = window.PRODUCT_DETAILS_DATA || {};
        const contextPath = DATA.contextPath || "";
        const productId = DATA.productId;

        function escapeHtml(text) {
            if (!text) return "";
            const div = document.createElement("div");
            div.textContent = text;
            return div.innerHTML;
        }

        function updateRatingSummary(avgRating, reviewCount) {
            const avgRatingDisplay = document.getElementById("avgRatingDisplay");
            const reviewCountDisplay = document.getElementById("reviewCountDisplay");
            const avgStarsDisplay = document.getElementById("avgStarsDisplay");

            const rating = parseFloat(avgRating) || 0;
            const count = parseInt(reviewCount, 10) || 0;

            if (avgRatingDisplay) avgRatingDisplay.textContent = rating.toFixed(1);
            if (reviewCountDisplay) reviewCountDisplay.textContent = count + (count === 1 ? " review" : " reviews");

            if (avgStarsDisplay) {
                const filledStar = "\u2605";
                const emptyStar = "\u2606";
                const fullStars = Math.floor(rating);
                const hasHalfStar = (rating % 1) >= 0.5;
                let stars = "";

                for (let i = 0; i < 5; i++) {
                    if (i < fullStars || (i === fullStars && hasHalfStar)) {
                        stars += filledStar;
                    } else {
                        stars += emptyStar;
                    }
                }
                avgStarsDisplay.textContent = stars;
                avgStarsDisplay.style.color = "var(--chart-3)";
            }
        }

        function displayReviews(reviews) {
            const container = document.getElementById("reviewsContainer");
            if (!container) return;

            if (!reviews || reviews.length === 0) {
                container.innerHTML = '<p style="color: var(--muted-foreground); text-align: center; padding: 20px;">No reviews yet. Be the first to review!</p>';
                return;
            }

            let html = "";
            reviews.forEach((review) => {
                let dateStr = "Recently";
                if (review.createdAt) {
                    const date = new Date(review.createdAt);
                    if (!isNaN(date.getTime())) {
                        dateStr = date.toLocaleDateString("en-US", {
                            year: "numeric",
                            month: "long",
                            day: "numeric"
                        });
                    }
                }

                const rating = parseInt(review.rating, 10) || 0;
                const stars = "\u2605".repeat(Math.max(0, Math.min(5, rating))) + "\u2606".repeat(Math.max(0, 5 - rating));
                const username = escapeHtml(review.username || "Anonymous");
                const comment = escapeHtml(review.comment || "");
                const imagePath = review.imagePath || "";

                html += '<div style="padding: 20px; margin-bottom: 20px; background-color: var(--card); border: 1px solid var(--border); border-radius: 10px; width: 100%; box-sizing: border-box;">';
                html += '<div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 10px;">';
                html += '<div style="flex: 1;">';
                html += '<strong style="font-size: 1.1em;">' + username + '</strong>';
                html += '<div style="color: var(--chart-3); font-size: 1.2em; margin-top: 5px;">' + stars + '</div>';
                html += '</div>';
                html += '<span style="color: var(--muted-foreground); font-size: 0.9em; margin-left: 15px;">' + dateStr + '</span>';
                html += '</div>';
                html += '<p style="color: var(--foreground); line-height: 1.6; margin: 0; text-align: left;">' + comment + '</p>';
                if (imagePath) {
                    const fullUrl = contextPath + "/" + imagePath;
                    html += '<div style="margin-top: 12px;">';
                    html += '<img src="' + fullUrl + '" alt="Review photo" '
                          + 'style="width:90px; height:90px; object-fit:cover; border-radius:8px; cursor:pointer; border:1px solid var(--border);" '
                          + 'onclick="openReviewPhoto(\'' + fullUrl.replace(/'/g, "\\'") + '\')" '
                          + 'title="Click to enlarge">';
                    html += '</div>';
                }
                html += '</div>';
            });

            container.innerHTML = html;
        }

        function loadReviews() {
            fetch(contextPath + "/productReview?productId=" + productId)
                .then((res) => {
                    if (!res.ok) throw new Error("HTTP " + res.status);
                    return res.json();
                })
                .then((data) => {
                    if (data.success) {
                        updateRatingSummary(data.avgRating, data.reviewCount);
                        displayReviews(data.reviews || []);
                    } else {
                        const container = document.getElementById("reviewsContainer");
                        if (container) {
                            container.innerHTML = '<p style="color: var(--muted-foreground); text-align: center; padding: 20px;">No reviews yet.</p>';
                        }
                    }
                })
                .catch((err) => {
                    console.error("Error loading reviews:", err);
                    const container = document.getElementById("reviewsContainer");
                    if (container) {
                        container.innerHTML = '<p style="color: var(--muted-foreground); text-align: center; padding: 20px;">No reviews yet.</p>';
                    }
                });
        }

        // Load reviews on page load
        loadReviews();
    } catch (e) {
        console.error("Error initializing product reviews:", e);
    }
})();

function openReviewPhoto(url) {
    let overlay = document.getElementById("reviewPhotoLightbox");
    if (!overlay) {
        overlay = document.createElement("div");
        overlay.id = "reviewPhotoLightbox";
        overlay.style.cssText = "position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.85);display:flex;align-items:center;justify-content:center;z-index:9999;cursor:zoom-out;";
        overlay.addEventListener("click", () => { overlay.style.display = "none"; });
        document.addEventListener("keydown", (e) => { if (e.key === "Escape") overlay.style.display = "none"; });
        const img = document.createElement("img");
        img.id = "reviewPhotoLightboxImg";
        img.style.cssText = "max-width:92vw;max-height:90vh;border-radius:8px;object-fit:contain;box-shadow:0 8px 40px rgba(0,0,0,0.6);";
        img.addEventListener("click", (e) => e.stopPropagation());
        overlay.appendChild(img);
        document.body.appendChild(overlay);
    }
    document.getElementById("reviewPhotoLightboxImg").src = url;
    overlay.style.display = "flex";
}
