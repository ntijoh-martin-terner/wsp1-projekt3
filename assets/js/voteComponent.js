document.addEventListener("DOMContentLoaded", () => {
  // Function to handle upvote and downvote clicks
  async function handleVote(event) {
    event.preventDefault(); // Prevent form submission reload

    const button = event.currentTarget;
    const parent = button.closest("[data-id]");
    const voteCountElement = parent.querySelector(".vote-count");
    const upvoteButton = parent.querySelector(".upvote-button");
    const downvoteButton = parent.querySelector(".downvote-button");

    const currentVotes = parseInt(voteCountElement.textContent, 10);
    const isUpvote = button.classList.contains("upvote-button");
    const isDownvote = button.classList.contains("downvote-button");
    const isUpvoted = upvoteButton.classList.contains("active");
    const isDownvoted = downvoteButton.classList.contains("active");

    let newVotes = currentVotes;

    // Optimistically update UI
    if (isUpvote) {
      if (isUpvoted) {
        // Remove upvote
        newVotes -= 1;
        upvoteButton.classList.remove("active");
      } else {
        // Add upvote, remove downvote if needed
        newVotes += isDownvoted ? 2 : 1;
        upvoteButton.classList.add("active");
        downvoteButton.classList.remove("active");
      }
    } else if (isDownvote) {
      if (isDownvoted) {
        // Remove downvote
        newVotes += 1;
        downvoteButton.classList.remove("active");
      } else {
        // Add downvote, remove upvote if needed
        newVotes -= isUpvoted ? 2 : 1;
        downvoteButton.classList.add("active");
        upvoteButton.classList.remove("active");
      }
    }

    // Update frontend UI
    voteCountElement.textContent = newVotes;

    // Send request to backend
    const url = button.closest("form").action;
    try {
      await fetch(url, { method: "POST" });
    } catch (error) {
      console.error("Error sending vote request:", error);
    }
  }

  // Attach event listeners to vote buttons
  document.querySelectorAll(".vote-button").forEach((button) => {
    button.addEventListener("click", handleVote);
  });
});
