/* Category-aware dynamic form behaviour for Add/Edit Product */

var categoryConfig = {
    "Cutting Tools": {
        guidance: "Specify blade or bit sizes and materials. Warranty details are especially important for premium cutting tools.",
        variantLabels: { color: "Color / Brand", size: "Blade / Bit Size", power: "Power (W)" }
    },
    "Painting Tools": {
        guidance: "Include brush/roller sizes and coverage area. List compatible paint types and surfaces in the description.",
        variantLabels: { color: "Color / Type", size: "Brush / Roller Size", power: "Coverage (sq.m)" }
    },
    "Tool Storage & Safety Gear": {
        guidance: "Specify dimensions and load capacity for storage. For safety gear, include protection ratings and certifications.",
        variantLabels: { color: "Color", size: "Size / Dimensions", power: "Load Capacity" }
    },
    "Electrical Tools & Accessories": {
        guidance: "Include voltage ratings, cable lengths, and safety certifications. Warranty is important for electrical products.",
        variantLabels: { color: "Color", size: "Cable / Length", power: "Voltage / Wattage" }
    },
    "Power Tools": {
        guidance: "Specify wattage, RPM, and compatible accessories. Customers expect warranty details for power tools.",
        variantLabels: { color: "Color / Brand", size: "Chuck / Bit Size", power: "Power (W / RPM)" }
    },
    "Cleaning & Maintenance": {
        guidance: "Include volume, concentration, and surface compatibility. For equipment, list coverage area and power draw.",
        variantLabels: { color: "Variant / Type", size: "Volume / Size", power: "Power (W)" }
    },
    "Vehicle Parts & Accessories": {
        guidance: "Specify compatible vehicle makes and models. Include part numbers where applicable.",
        variantLabels: { color: "Finish / Material", size: "Fitment / Size", power: "Spec / Grade" }
    },
    "Measuring & Marking Tools": {
        guidance: "Specify measurement range, precision, and calibration standards where applicable.",
        variantLabels: { color: "Color", size: "Measurement Range", power: "Precision / Class" }
    },
    "Tapes": {
        guidance: "Include tape width, length per roll, adhesive type, and surface compatibility.",
        variantLabels: { color: "Color", size: "Width \u00d7 Length", power: "Tensile Strength" }
    },
    "Fasteners & Fittings": {
        guidance: "Specify material (steel/stainless/brass), grade/class, and compatible uses (wood/metal/concrete).",
        variantLabels: { color: "Material / Finish", size: "Size / Spec", power: "Grade / Class" }
    },
    "Plumbing Tools & Supplies": {
        guidance: "Specify pipe diameter compatibility, material (PVC/copper/brass), and pressure ratings.",
        variantLabels: { color: "Material", size: "Diameter / Size", power: "Pressure Rating" }
    },
    "Adhesives & Sealants": {
        guidance: "Include curing time, bond strength, and compatible surfaces. Volume and coverage are key details for buyers.",
        variantLabels: { color: "Color / Type", size: "Volume / Pack Size", power: "Bond Strength" }
    },
    "Other": {
        guidance: "Enter a specific category name below. Provide as much detail as possible in the description.",
        variantLabels: { color: "Attribute 1", size: "Attribute 2", power: "Attribute 3" }
    }
};

function updateCategoryUI(selectedValue) {
    var config = categoryConfig[selectedValue];
    var guidanceEl = document.getElementById('categoryGuidance');
    var customWrap = document.getElementById('customCategoryWrap');
    var customInput = document.getElementById('customCategory');

    if (customWrap) {
        if (selectedValue === 'Other') {
            customWrap.style.display = 'block';
            if (customInput) customInput.required = true;
        } else {
            customWrap.style.display = 'none';
            if (customInput) customInput.required = false;
        }
    }

    if (guidanceEl) {
        if (config) {
            guidanceEl.textContent = config.guidance;
            guidanceEl.style.display = 'block';
        } else {
            guidanceEl.style.display = 'none';
        }
    }

    if (config && config.variantLabels) {
        updateAllVariantLabels(config.variantLabels);
    }
}

function updateAllVariantLabels(labels) {
    document.querySelectorAll('.variant-row').forEach(function(row) {
        applyLabelsToRow(row, labels);
    });
}

function applyLabelsToRow(row, labels) {
    var colorWrap = row.querySelector('[data-vfield="color"]');
    var sizeWrap  = row.querySelector('[data-vfield="size"]');
    var powerWrap = row.querySelector('[data-vfield="power"]');

    if (colorWrap) {
        var lbl = colorWrap.querySelector('label');
        var inp = colorWrap.querySelector('input');
        if (lbl) lbl.textContent = labels.color;
        if (inp) inp.placeholder = labels.color;
    }
    if (sizeWrap) {
        var lbl = sizeWrap.querySelector('label');
        var inp = sizeWrap.querySelector('input');
        if (lbl) lbl.textContent = labels.size;
        if (inp) inp.placeholder = labels.size;
    }
    if (powerWrap) {
        var lbl = powerWrap.querySelector('label');
        var inp = powerWrap.querySelector('input');
        if (lbl) lbl.textContent = labels.power;
        if (inp) inp.placeholder = labels.power;
    }
}

/* Called by storedash-product-variants.js when a new row is dynamically added */
function applyCategoryLabelsToRow(row) {
    var select = document.getElementById('categorySelect');
    if (!select || !select.value) return;
    var config = categoryConfig[select.value];
    if (config && config.variantLabels) {
        applyLabelsToRow(row, config.variantLabels);
    }
}

document.addEventListener('DOMContentLoaded', function() {
    var select = document.getElementById('categorySelect');
    if (select) {
        select.addEventListener('change', function() {
            updateCategoryUI(this.value);
        });
        if (select.value) {
            updateCategoryUI(select.value);
        }
    }

    /* Preview for main product image */
    var imageInput = document.getElementById('productImageInput');
    var imagePreviewWrap = document.getElementById('imagePreviewWrap');
    var imagePreview = document.getElementById('productImagePreview');
    if (imageInput && imagePreview) {
        imageInput.addEventListener('change', function() {
            var file = this.files[0];
            if (file) {
                var reader = new FileReader();
                reader.onload = function(e) {
                    imagePreview.src = e.target.result;
                    imagePreview.style.display = 'block';
                    if (imagePreviewWrap) imagePreviewWrap.style.display = 'block';
                };
                reader.readAsDataURL(file);
            }
        });
    }

    /* Delegated preview handler for variant images */
    var variantContainer = document.getElementById('variantsContainer');
    if (variantContainer) {
        variantContainer.addEventListener('change', function(e) {
            if (e.target && e.target.classList.contains('variant-image-input')) {
                var file = e.target.files[0];
                var row = e.target.closest('.variant-row');
                var preview = row ? row.querySelector('.variant-image-preview') : null;
                if (file && preview) {
                    var reader = new FileReader();
                    reader.onload = function(ev) {
                        preview.src = ev.target.result;
                        preview.style.display = 'block';
                    };
                    reader.readAsDataURL(file);
                }
            }
        });
    }
});
