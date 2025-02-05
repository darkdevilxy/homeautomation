// Attach click event listeners to the cards
const cards = document.querySelectorAll(".card");
const overlay = document.querySelector(".overlay");
const overlayImage = document.querySelector(".overlay-image");
const overlayTitle = document.querySelector(".overlay-title");
const overlayDescription = document.querySelector(".overlay-description");
const overlayAction1 = document.querySelector(".overlay-action1");
const overlayAction2 = document.querySelector(".overlay-action2");
const overlayClose = document.querySelector(".overlay-close");

const loginButton = document.querySelector(".login-button");
const loginOverlay = document.querySelector(".login-overlay");
const loginOverlayClose = document.querySelector(".login-overlay-close");

let isDropdoenActive = false;

cards.forEach((card, index) => {
  card.addEventListener("click", () => {
    console.log("Cards Clicked", card);
    // Update the overlay content based on the clicked card
    overlayImage.src = card.querySelector(".card_image").src;
    overlayTitle.textContent = card.querySelector(".card_title").textContent;
    overlayDescription.textContent =
      card.querySelector(".card_discription").textContent;

    // Add your custom actions for the overlay buttons here
    overlayAction1.removeEventListener("click", turnOnLight);
    overlayAction2.removeEventListener("click", turnOffLight);
    overlayAction1.removeEventListener("click", viewCamera);
    overlayAction2.removeEventListener("click", turnOffCamera);
    

    switch (overlayTitle.textContent) {
      case "Light Bulb":
        overlayAction1.textContent = "Turn On";
        overlayAction1.addEventListener("click", turnOnLight);
        overlayAction2.textContent = "Turn Off";
        overlayAction2.addEventListener("click", turnOffLight);
        break;
      case "DoorBell Camera":
        overlayAction1.textContent = "View Camera";
        overlayAction1.addEventListener("click", viewCamera);
        overlayAction2.textContent = "Turn Off";
        overlayAction2.addEventListener("click", turnOffCamera);
        break;
      default:
        overlayAction1.textContent = "Action 1";
        overlayAction2.textContent = "Action 2";
    }

    // Show the overlay
    overlay.classList.add("active");
    console.log("Card clicked:", index);
  });
});

// Close the overlay when the close button is clicked
overlayClose.addEventListener("click", () => {
  overlay.classList.remove("active");
});

loginButton.addEventListener("click", () => {
  loginOverlay.classList.add("active");
  console.log("Login button clicked");
});

loginOverlayClose.addEventListener("click", () => {
  loginOverlay.classList.remove("active");
});

function turnOnLight() {
  console.log("Turning on the light");
  // Call the API to turn on the light
}

function turnOffLight() {
  console.log("Turning off the light");
  // Call the API to turn off the light
}

function viewCamera() {
  console.log("Viewing the camera");
  // Call the API to view the camera×
  document.querySelector(".video-overlay").classList.add("active");
    document.querySelector(".video-overlay-close").addEventListener("click", () => {
        document.querySelector(".video-overlay").classList.remove("active");
    });
}

function turnOffCamera() {
  console.log("Turning off the camera");
  // Call the API to turn off the camera
}

function showLoginOptions() {
  console.log("Showing login options");
  // Show the login options
  if (isDropdoenActive) {
    document.querySelector(".dropdown").classList.remove("active");
    isDropdoenActive = false;
    return;
  }
  else {
    document.querySelector(".dropdown").classList.add("active");
    isDropdoenActive = true;
  }
}