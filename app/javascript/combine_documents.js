document.addEventListener("DOMContentLoaded", function () {
  const form = document.getElementById("combine-form");
  const previewFrame = document.getElementById("pdf-preview");

  if (form) {
    form.addEventListener("submit", function (event) {
      event.preventDefault();
      const formData = new FormData(form);
      fetch(form.action, {
        method: "POST",
        body: formData,
        headers: { "X-Requested-With": "XMLHttpRequest" },
      })
        .then(response => response.json())
        .then(data => {
          if (data.pdf_data) {
            previewFrame.src = "data:application/pdf;base64," + data.pdf_data;
          }
        })
        .catch(error => console.error("Error:", error));
    });
  }
});
