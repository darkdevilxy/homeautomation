// Attach click event listeners to the cards
const cards = document.querySelectorAll('.card');
const overlay = document.querySelector('.overlay');
const overlayImage = document.querySelector('.overlay-image');
const overlayTitle = document.querySelector('.overlay-title');
const overlayDescription = document.querySelector('.overlay-description');
const overlayAction1 = document.querySelector('.overlay-action1');
const overlayAction2 = document.querySelector('.overlay-action2');
const overlayClose = document.querySelector('.overlay-close');

const loginButton = document.querySelector('.login-button');
const loginOverlay = document.querySelector('.login-overlay');
const loginOverlayClose = document.querySelector('.login-overlay-close');

cards.forEach((card, index) => {
    card.addEventListener('click', () => {
        console.log('Cards Clicked', card)
        // Update the overlay content based on the clicked card
        overlayImage.src = card.querySelector('.card_image').src;
        overlayTitle.textContent = card.querySelector('.card_title').textContent;
        overlayDescription.textContent = card.querySelector('.card_discription').textContent;

        // Add your custom actions for the overlay buttons here
        overlayAction1.textContent = 'Custom Action 1';
        overlayAction2.textContent = 'Custom Action 2';

        // Show the overlay
        overlay.classList.add('active');
        console.log('Card clicked:', index)
    });
});

// Close the overlay when the close button is clicked
overlayClose.addEventListener('click', () => {
    overlay.classList.remove('active');
});



loginButton.addEventListener('click', () => {
    loginOverlay.classList.add('active');
});

loginOverlayClose.addEventListener('click', () => {
    loginOverlay.classList.remove('active');
});