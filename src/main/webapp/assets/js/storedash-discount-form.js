function updateDiscountValueLabel() {
    var discountType = document.getElementById('discountType').value;
    var label = document.getElementById('discountValueLabel');

    if (discountType === 'PERCENTAGE') {
        label.textContent = '%';
        document.getElementById('discountValue').setAttribute('max', '100');
    } else if (discountType === 'FIXED') {
        label.textContent = 'Rs';
        document.getElementById('discountValue').removeAttribute('max');
    } else {
        label.textContent = '-';
    }
}

document.addEventListener('DOMContentLoaded', function() {
    updateDiscountValueLabel();

    var form = document.querySelector('form');
    if (form) {
        form.addEventListener('submit', function(e) {
            var productCheckboxes = document.querySelectorAll('input[name="productIds"]:checked');
            if (productCheckboxes.length === 0) {
                e.preventDefault();
                alert('Please select at least one product to apply the discount.');
                return false;
            }

            var discountType = document.getElementById('discountType').value;
            var discountValue = parseFloat(document.getElementById('discountValue').value);

            if (discountType === 'PERCENTAGE' && (discountValue <= 0 || discountValue > 100)) {
                e.preventDefault();
                alert('Percentage discount must be between 1 and 100.');
                return false;
            }

            if (discountType === 'FIXED' && discountValue <= 0) {
                e.preventDefault();
                alert('Fixed discount amount must be greater than 0.');
                return false;
            }

            return true;
        });
    }
});
