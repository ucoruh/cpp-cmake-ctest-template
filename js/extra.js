/* Report pages: if the embedded report does not exist (e.g. the other platform's report was not
   built on this machine), replace the empty frame with a short explanation instead of a 404 page.
   The text follows the page language (English at the root, Turkish under /tr/). */
(function () {
  var TEXT = {
    en: function (p) {
      return "This report is not part of this build of the site" + (p ? " (" + p + " report)" : "") +
        ". The " + (p || "matching platform") + " build script produces it; CI builds both platforms.";
    },
    tr: function (p) {
      return "Bu rapor sitenin bu derlemesinde yok" + (p ? " (" + p + " raporu)" : "") +
        ". " + (p || "İlgili platformun") + " derleme betiği onu üretir; CI iki platformu da derler.";
    }
  };
  function check(frameBox) {
    var iframe = frameBox.querySelector("iframe");
    if (!iframe || !window.fetch) { return; }
    fetch(iframe.getAttribute("src"), { method: "HEAD" }).then(function (r) {
      if (r.ok) { return; }
      var lang = (document.documentElement.lang || "en").slice(0, 2);
      var note = document.createElement("p");
      note.className = "report-missing";
      note.textContent = (TEXT[lang] || TEXT.en)(frameBox.dataset.platform || "");
      iframe.style.display = "none";
      frameBox.appendChild(note);
    }).catch(function () { /* file:// or offline: leave the frame alone */ });
  }
  function run() {
    document.querySelectorAll(".report-frame").forEach(check);
  }
  if (typeof document$ !== "undefined") { document$.subscribe(run); }   /* Material instant navigation */
  else if (document.readyState !== "loading") { run(); }
  else { document.addEventListener("DOMContentLoaded", run); }
})();
