document.addEventListener("DOMContentLoaded", function () {
    const tabs = document.querySelectorAll(".tab-link");
    const contents = document.querySelectorAll(".tab-content");

    tabs.forEach(tab => {
        tab.addEventListener("click", function () {
            const target = this.getAttribute("data-tab");

            // Hide all content
            contents.forEach(content => content.classList.add("hidden"));

            // Show selected content
            document.getElementById(target).classList.remove("hidden");
        });
    });
});