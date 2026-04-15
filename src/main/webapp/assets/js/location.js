let userLat = null;
let userLng = null;
let autocomplete = null;

function initUserLocation() {
    const input = document.getElementById('location-input');
    if (!input) return;

    // Google Places Autocomplete
    autocomplete = new google.maps.places.Autocomplete(input);
    autocomplete.addListener('place_changed', () => {
        const place = autocomplete.getPlace();
        if (place.geometry) {
            userLat = place.geometry.location.lat();
            userLng = place.geometry.location.lng();
            console.log("Selected coordinates:", userLat, userLng);
        } else {
            alert("Please select a valid location from the suggestions.");
        }
    });

    const setBtn = document.getElementById('btn-set-location');
    const filterCard = document.querySelector('.filter-card');
    if (!setBtn || !filterCard) return;

    const baseUrl = filterCard.getAttribute('data-page-url');
    const category = filterCard.getAttribute('data-category');

    // Set Location
    setBtn.addEventListener('click', () => {
        if (userLat && userLng) {
            window.location.href = `${baseUrl}?lat=${userLat}&lng=${userLng}&category=${category}`;
        } else {
            alert("Please select a location first.");
        }
    });

    // Current Location Button (if needed in future pages)
    const currentBtn = document.getElementById('btn-current-location');
    if (currentBtn && navigator.geolocation) {
        currentBtn.addEventListener('click', () => {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    userLat = position.coords.latitude;
                    userLng = position.coords.longitude;
                    input.value = "Current Location";
                    console.log("Current location:", userLat, userLng);
                },
                () => alert("Could not get your location.")
            );
        });
    }
}

window.addEventListener('load', initUserLocation);
