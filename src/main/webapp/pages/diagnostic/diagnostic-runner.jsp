<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>

        <% String treeId=request.getParameter("id"); if (treeId==null || treeId.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/pages/diagnostic/diagnostic-browse.jsp" ); return; } %>

            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Diagnostic Tool | Daily Fixer</title>
                <link
                    href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap"
                    rel="stylesheet">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/framework.css">
                <style>
                    .runner-container {
                        max-width: 700px;
                        margin: 0 auto;
                        padding: 2rem;
                        min-height: calc(100vh - 200px);
                        display: flex;
                        flex-direction: column;
                        justify-content: center;
                    }

                    .tree-header {
                        text-align: center;
                        margin-bottom: 2rem;
                    }

                    .tree-title {
                        font-size: 1.5rem;
                        font-weight: 700;
                        color: var(--foreground);
                        margin-bottom: 0.5rem;
                    }

                    .tree-creator {
                        font-size: 0.9rem;
                        color: var(--muted-foreground);
                    }

                    /* Wizard Card */
                    .wizard-card {
                        background: var(--card);
                        border: 1px solid var(--border);
                        border-radius: var(--radius-lg);
                        padding: 2.5rem;
                        box-shadow: var(--shadow-lg);
                        animation: fadeIn 0.3s ease;
                    }

                    @keyframes fadeIn {
                        from {
                            opacity: 0;
                            transform: translateY(10px);
                        }

                        to {
                            opacity: 1;
                            transform: translateY(0);
                        }
                    }

                    .node-type-badge {
                        display: inline-block;
                        font-size: 0.75rem;
                        font-weight: 600;
                        text-transform: uppercase;
                        padding: 0.25rem 0.75rem;
                        border-radius: var(--radius-sm);
                        margin-bottom: 1rem;
                    }

                    .node-type-badge.question {
                        background: var(--muted);
                        color: var(--muted-foreground);
                    }

                    .node-type-badge.result {
                        background: oklch(0.6290 0.1902 156.4499 / 0.2);
                        color: oklch(0.6290 0.1902 156.4499);
                    }

                    .node-text {
                        font-size: 1.25rem;
                        font-weight: 500;
                        color: var(--foreground);
                        line-height: 1.6;
                        margin-bottom: 2rem;
                    }

                    /* Options */
                    .options-container {
                        display: flex;
                        flex-direction: column;
                        gap: 0.75rem;
                    }

                    .option-btn {
                        padding: 1rem 1.5rem;
                        background: var(--secondary);
                        color: var(--secondary-foreground);
                        border: 2px solid var(--border);
                        border-radius: var(--radius-md);
                        font-size: 1rem;
                        font-weight: 500;
                        cursor: pointer;
                        text-align: left;
                        transition: all 0.2s ease;
                    }

                    .option-btn:hover {
                        background: var(--primary);
                        color: var(--primary-foreground);
                        border-color: var(--primary);
                        transform: translateX(5px);
                    }

                    /* Navigation */
                    .wizard-buttons {
                        display: flex;
                        justify-content: space-between;
                        margin-top: 2rem;
                        padding-top: 1.5rem;
                        border-top: 1px solid var(--border);
                    }

                    .back-btn {
                        display: inline-flex;
                        align-items: center;
                        gap: 0.5rem;
                        padding: 0.75rem 1.5rem;
                        background: var(--secondary);
                        color: var(--secondary-foreground);
                        border: 1px solid var(--border);
                        border-radius: var(--radius-md);
                        font-size: 0.9rem;
                        font-weight: 500;
                        cursor: pointer;
                        transition: all 0.2s ease;
                        text-decoration: none;
                    }

                    .back-btn:hover {
                        background: var(--accent);
                        color: var(--accent-foreground);
                    }

                    .restart-btn {
                        padding: 0.75rem 1.5rem;
                        background: var(--muted);
                        color: var(--muted-foreground);
                        border: none;
                        border-radius: var(--radius-md);
                        font-size: 0.9rem;
                        cursor: pointer;
                        transition: all 0.2s ease;
                    }

                    .restart-btn:hover {
                        background: var(--secondary);
                        color: var(--secondary-foreground);
                    }

                    /* Result Section */
                    .result-section {
                        margin-top: 2rem;
                        padding-top: 2rem;
                        border-top: 1px solid var(--border);
                    }

                    .result-actions {
                        display: flex;
                        gap: 1rem;
                        margin-top: 1.5rem;
                    }

                    /* Rating Section */
                    .rating-section {
                        background: var(--muted);
                        border-radius: var(--radius-md);
                        padding: 1.5rem;
                        margin-top: 2rem;
                    }

                    .rating-section h4 {
                        font-size: 1rem;
                        margin-bottom: 1rem;
                        color: var(--foreground);
                    }

                    .star-rating {
                        display: flex;
                        gap: 0.5rem;
                        margin-bottom: 1rem;
                    }

                    .star-btn {
                        font-size: 2rem;
                        background: none;
                        border: none;
                        cursor: pointer;
                        color: var(--muted-foreground);
                        transition: all 0.2s ease;
                    }

                    .star-btn:hover,
                    .star-btn.active {
                        color: oklch(0.7336 0.1758 50.5517);
                        transform: scale(1.1);
                    }

                    .rating-feedback {
                        width: 100%;
                        padding: 0.75rem;
                        border: 1px solid var(--border);
                        border-radius: var(--radius-md);
                        background: var(--input);
                        color: var(--foreground);
                        font-size: 0.9rem;
                        resize: vertical;
                        min-height: 80px;
                        margin-bottom: 1rem;
                    }

                    .submit-rating-btn {
                        padding: 0.75rem 1.5rem;
                        background: var(--primary);
                        color: var(--primary-foreground);
                        border: none;
                        border-radius: var(--radius-md);
                        font-weight: 600;
                        cursor: pointer;
                        transition: all 0.2s ease;
                    }

                    .submit-rating-btn:hover {
                        transform: translateY(-2px);
                        box-shadow: var(--shadow-md);
                    }

                    .rating-thanks {
                        text-align: center;
                        color: oklch(0.6290 0.1902 156.4499);
                        font-weight: 600;
                    }

                    /* Progress */
                    .progress-bar {
                        height: 4px;
                        background: var(--muted);
                        border-radius: 2px;
                        margin-bottom: 1rem;
                        overflow: hidden;
                    }

                    .progress-fill {
                        height: 100%;
                        background: var(--primary);
                        transition: width 0.3s ease;
                    }

                    /* Loading */
                    .loading {
                        text-align: center;
                        padding: 4rem;
                        color: var(--muted-foreground);
                    }
                </style>
            </head>

            <body>
                <%@ include file="/pages/shared/header.jsp" %>

                    <div class="runner-container" style="margin-top: 30px;">
                        <div id="loadingState" class="loading">
                            Loading diagnostic guide...
                        </div>

                        <div id="runnerContent" style="display: none;">
                            <!-- Tree Header -->
                            <div class="tree-header">
                                <div class="tree-title" id="treeTitle"></div>
                                <div class="tree-creator" id="treeCreator"></div>
                            </div>

                            <!-- Progress Bar -->
                            <div class="progress-bar">
                                <div class="progress-fill" id="progressFill" style="width: 10%;"></div>
                            </div>

                            <!-- Wizard Card -->
                            <div class="wizard-card" id="wizardCard">
                                <span class="node-type-badge question" id="nodeTypeBadge">Question</span>
                                <div class="node-text" id="nodeText"></div>

                                <div class="options-container" id="optionsContainer"></div>

                                <!-- Result Rating Section (hidden for questions) -->
                                <div class="rating-section" id="ratingSectionWrapper" style="display: none;">
                                    <div id="ratingSection">
                                        <h4>Was this helpful? Rate this guide:</h4>
                                        <div class="star-rating" id="starRating">
                                            <button class="star-btn" data-rating="1">☆</button>
                                            <button class="star-btn" data-rating="2">☆</button>
                                            <button class="star-btn" data-rating="3">☆</button>
                                            <button class="star-btn" data-rating="4">☆</button>
                                            <button class="star-btn" data-rating="5">☆</button>
                                        </div>
                                        <textarea class="rating-feedback" id="ratingFeedback"
                                            placeholder="Any additional feedback? (optional)"></textarea>
                                        <button class="submit-rating-btn" onclick="submitRating()">Submit
                                            Rating</button>
                                    </div>
                                    <div id="ratingThanks" class="rating-thanks" style="display: none;">
                                        <p>✓ Thank you for your feedback!</p>
                                    </div>
                                </div>

                                <!-- Navigation -->
                                <div class="wizard-buttons">
                                    <button class="back-btn" id="backBtn" onclick="goBack()"
                                        style="visibility: hidden;">
                                        ← Back
                                    </button>
                                    <button class="restart-btn" onclick="restartTree()">
                                        ↻ Start Over
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>



                    <script>
                        const contextPath = '${pageContext.request.contextPath}';
                        const treeIdValue = '<%= treeId %>';
                        let tree = null;
                        let rootNode = null;
                        let currentNode = null;
                        let nodeHistory = [];
                        let selectedRating = 0;

                        document.addEventListener('DOMContentLoaded', function () {
                            loadTree();
                            setupStarRating();
                        });

                        function loadTree() {
                            fetch(contextPath + '/api/diagnostic/trees/' + treeIdValue + '?includeNodes=true')
                                .then(response => {
                                    if (!response.ok) throw new Error('Tree not found');
                                    return response.json();
                                })
                                .then(data => {
                                    tree = data;
                                    rootNode = data.rootNode;

                                    document.getElementById('loadingState').style.display = 'none';
                                    document.getElementById('runnerContent').style.display = 'block';

                                    document.getElementById('treeTitle').textContent = tree.title;
                                    document.getElementById('treeCreator').textContent = 'Created by ' + tree.creatorUsername;

                                    if (!rootNode) {
                                        document.getElementById('nodeText').textContent = 'This guide has no content yet.';
                                        return;
                                    }

                                    displayNode(rootNode);
                                    checkUserRating();
                                })
                                .catch(err => {
                                    console.error('Failed to load tree:', err);
                                    document.getElementById('loadingState').innerHTML = `
                        <h3>Guide not found</h3>
                        <p>This diagnostic guide may have been removed.</p>
                        <a href="${contextPath}/pages/diagnostic/diagnostic-browse.jsp" class="btn-primary" style="margin-top: 1rem;">Browse Guides</a>
                    `;
                                });
                        }

                        function displayNode(node) {
                            currentNode = node;
                            updateProgress();

                            // Update badge and text
                            const badge = document.getElementById('nodeTypeBadge');
                            badge.textContent = node.nodeType;
                            badge.className = 'node-type-badge ' + node.nodeType.toLowerCase();

                            document.getElementById('nodeText').textContent = node.nodeText;

                            // Show/hide back button
                            document.getElementById('backBtn').style.visibility = nodeHistory.length > 0 ? 'visible' : 'hidden';

                            // Handle options or result
                            const optionsContainer = document.getElementById('optionsContainer');
                            const ratingSection = document.getElementById('ratingSectionWrapper');

                            if (node.nodeType === 'RESULT') {
                                optionsContainer.innerHTML = '';
                                ratingSection.style.display = 'block';
                                updateProgress(100);
                            } else {
                                ratingSection.style.display = 'none';

                                if (node.children && node.children.length > 0) {
                                    let html = '';
                                    node.children.forEach(function (child) {
                                        html += '<button class="option-btn" onclick="selectOption(' + child.nodeId + ')">' +
                                            escapeHtml(child.optionLabel || 'Continue') +
                                            '</button>';
                                    });
                                    optionsContainer.innerHTML = html;
                                } else {
                                    optionsContainer.innerHTML = '<p style="color: var(--muted-foreground);">No options available.</p>';
                                }
                            }

                            // Animate card
                            const card = document.getElementById('wizardCard');
                            card.style.animation = 'none';
                            card.offsetHeight; // Trigger reflow
                            card.style.animation = 'fadeIn 0.3s ease';
                        }

                        function selectOption(childNodeId) {
                            const childNode = findNodeById(rootNode, childNodeId);
                            if (childNode) {
                                nodeHistory.push(currentNode);
                                displayNode(childNode);
                            }
                        }

                        function goBack() {
                            if (nodeHistory.length > 0) {
                                const previousNode = nodeHistory.pop();
                                displayNode(previousNode);
                            }
                        }

                        function restartTree() {
                            nodeHistory = [];
                            if (rootNode) {
                                displayNode(rootNode);
                            }
                        }

                        function findNodeById(node, id) {
                            if (!node) return null;
                            if (node.nodeId === id) return node;
                            if (node.children) {
                                for (const child of node.children) {
                                    const found = findNodeById(child, id);
                                    if (found) return found;
                                }
                            }
                            return null;
                        }

                        function updateProgress(forcePercent) {
                            const depth = nodeHistory.length + 1;
                            // Estimate max depth as 5 levels for progress display
                            const percent = forcePercent || Math.min(95, (depth / 5) * 100);
                            document.getElementById('progressFill').style.width = percent + '%';
                        }

                        // ==================== Rating ====================
                        function setupStarRating() {
                            document.querySelectorAll('.star-btn').forEach(btn => {
                                btn.addEventListener('click', function () {
                                    selectedRating = parseInt(this.dataset.rating);
                                    updateStars();
                                });

                                btn.addEventListener('mouseenter', function () {
                                    const rating = parseInt(this.dataset.rating);
                                    highlightStars(rating);
                                });

                                btn.addEventListener('mouseleave', function () {
                                    updateStars();
                                });
                            });
                        }

                        function highlightStars(rating) {
                            document.querySelectorAll('.star-btn').forEach((btn, index) => {
                                btn.textContent = index < rating ? '★' : '☆';
                            });
                        }

                        function updateStars() {
                            document.querySelectorAll('.star-btn').forEach((btn, index) => {
                                btn.textContent = index < selectedRating ? '★' : '☆';
                                btn.classList.toggle('active', index < selectedRating);
                            });
                        }

                        function checkUserRating() {
                            fetch(contextPath + '/api/diagnostic/ratings?tree=' + treeIdValue + '&userRating=true')
                                .then(response => response.json())
                                .then(data => {
                                    if (data.hasRated) {
                                        selectedRating = data.rating;
                                        updateStars();
                                        document.getElementById('ratingFeedback').value = data.feedback || '';
                                    }
                                })
                                .catch(err => console.error('Failed to check rating:', err));
                        }

                        function submitRating() {
                            if (selectedRating === 0) {
                                alert('Please select a rating');
                                return;
                            }

                            const feedback = document.getElementById('ratingFeedback').value.trim();

                            const formData = new FormData();
                            formData.append('treeId', treeIdValue);
                            formData.append('rating', selectedRating);
                            if (feedback) formData.append('feedback', feedback);

                            fetch(contextPath + '/api/diagnostic/ratings', {
                                method: 'POST',
                                body: new URLSearchParams(formData)
                            })
                                .then(response => response.json())
                                .then(data => {
                                    if (data.success) {
                                        document.getElementById('ratingSection').style.display = 'none';
                                        document.getElementById('ratingThanks').style.display = 'block';
                                    } else if (data.error && data.error.includes('Login')) {
                                        alert('Please log in to rate this guide');
                                        window.location.href = contextPath + '/pages/authentication/login.jsp';
                                    } else {
                                        alert('Failed to submit rating: ' + (data.error || 'Unknown error'));
                                    }
                                })
                                .catch(err => {
                                    console.error('Failed to submit rating:', err);
                                    alert('Failed to submit rating');
                                });
                        }

                        function escapeHtml(text) {
                            if (!text) return '';
                            const div = document.createElement('div');
                            div.textContent = text;
                            return div.innerHTML;
                        }
                    </script>
            </body>

            </html>