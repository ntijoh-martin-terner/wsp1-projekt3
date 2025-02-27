function copyToClipboard(postId) {
    const linkInput = document.getElementById(`share-link-${postId}`);
    navigator.clipboard.writeText(linkInput.value).then(() => {
        // Close modal after copying
        document.querySelector(`[data-modal-hide="popup-modal-${postId}"]`).click();
    });
}

function openFullscreenModal(imageUrl, postId) {
    console.log(imageUrl, postId)
    document.getElementById('fullscreen-image').src = imageUrl;
}