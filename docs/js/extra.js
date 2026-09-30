/* Report pages: if the embedded report does not exist (e.g. the other platform's report was not
   built on this machine), replace the empty frame with a short explanation instead of a 404 page. */
(function () {
  function check(frameBox) {
    var iframe = frameBox.querySelector("iframe");
    if (!iframe || !window.fetch) { return; }
    fetch(iframe.getAttribute("src"), { method: "HEAD" }).then(function (r) {
      if (r.ok) { return; }
      var note = document.createElement("p");
      note.className = "report-missing";
      note.textContent = "This report is not part of this build of the site" +
        (frameBox.dataset.platform ? " (" + frameBox.dataset.platform + " report)" : "") +
        ". The " + (frameBox.dataset.platform || "matching platform") +
        " build script produces it; CI builds both platforms.";
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
