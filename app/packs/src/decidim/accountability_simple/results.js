(() => {
  const openShareModalButton = document.getElementById("openShareModal");

  if (openShareModalButton) {
    openShareModalButton.addEventListener("click", () => {
      window.Decidim.currentDialogs["socialShare"].open();
    })
  } else {
    console.error("openShareModalButton not found")
  }
})();
