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

document.getElementById('channel-input').addEventListener('input', async function() {
    const query = this.value.trim();
    const suggestionsList = document.getElementById('channel-suggestions');
    
    if (query.length < 2) {
        suggestionsList.classList.add('hidden');
        return;
    }

    const response = await fetch(`/api/channels/search?q=${query}`);
    const channels = await response.json();

    suggestionsList.innerHTML = '';
    channels.forEach(channel => {
        const li = document.createElement('li');
        li.textContent = channel.name;
        li.classList.add('p-2', 'cursor-pointer', 'hover:bg-gray-100', 'dark:hover:bg-gray-600', 'text-white');
        li.addEventListener('click', () => {
            document.getElementById('channel-input').value = channel.name;
            suggestionsList.classList.add('hidden');
        });
        suggestionsList.appendChild(li);
    });

    suggestionsList.classList.remove('hidden');
});
