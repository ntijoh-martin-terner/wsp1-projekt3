
import { Modal } from '/js/flowbite_module.js';

document.addEventListener("htmx:afterSwap", () => {
  document.querySelectorAll("[data-modal-toggle]").forEach((btn) => {
    const modalId = btn.getAttribute("data-modal-toggle");
    const modalEl = document.getElementById(modalId);

    if (modalEl) {
      const modal = new Modal(modalEl);
      btn.addEventListener("click", () => modal.show()); // Manually bind click event
    }
  });
});