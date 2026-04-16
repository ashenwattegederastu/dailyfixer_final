<%-- ============================================================
     Floating Google Translate Widget
     Include this before </body> on any page:
         <jsp:include page="/pages/shared/translate.jsp" />
     ============================================================ --%>

<%-- CSS --%>
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/translate.css">

<%-- Floating Action Button --%>
<button class="translate-fab" id="translateFab" aria-label="Open language selector" onclick="toggleTranslatePanel()">
    <i class="ph-fill ph-globe"></i>
</button>

<%-- Popup Panel --%>
<div class="translate-panel" id="translatePanel" role="dialog" aria-label="Language selection">
    <div class="translate-panel-header">
        <span class="translate-panel-title">
            <i class="ph-fill ph-translate"></i>
            Translate Page
        </span>
        <button class="translate-panel-close" onclick="toggleTranslatePanel()" aria-label="Close">
            <i class="ph ph-x"></i>
        </button>
    </div>
    <div class="translate-panel-body">
        <p class="translate-panel-hint">Choose your language</p>
        <div id="google_translate_element"></div>
    </div>
</div>

<%-- Google Translate Scripts --%>
<script>
    function googleTranslateElementInit() {
        new google.translate.TranslateElement({
            pageLanguage: 'en',
            includedLanguages: 'en,si,ta',
            layout: google.translate.TranslateElement.InlineLayout.SIMPLE,
            autoDisplay: false
        }, 'google_translate_element');
    }

    function toggleTranslatePanel() {
        var panel = document.getElementById('translatePanel');
        var fab   = document.getElementById('translateFab');
        var isOpen = panel.classList.contains('open');

        if (isOpen) {
            panel.classList.remove('open');
            fab.classList.remove('open');
            fab.setAttribute('aria-expanded', 'false');
        } else {
            panel.classList.add('open');
            fab.classList.add('open');
            fab.setAttribute('aria-expanded', 'true');
        }
    }

    // Close panel when clicking outside
    document.addEventListener('click', function (e) {
        var panel = document.getElementById('translatePanel');
        var fab   = document.getElementById('translateFab');
        if (panel && fab && panel.classList.contains('open')) {
            if (!panel.contains(e.target) && !fab.contains(e.target)) {
                panel.classList.remove('open');
                fab.classList.remove('open');
                fab.setAttribute('aria-expanded', 'false');
            }
        }
    });
</script>
<script src="//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit"></script>
