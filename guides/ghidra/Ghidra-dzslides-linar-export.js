(function() {
    // 1. Capture original location info for linking/naming
    var originalBaseURL = window.location.href.split('#')[0];
    var path = window.location.pathname;
    var originalFilename = path.split("/").pop() || "slides.html";
    var newFilename = originalFilename.replace('.html', '') + '_linear_view.html';

    // 2. Select all slides
    var slides = document.querySelectorAll('section');
    
    // 3. Create the new container
    var newContainer = document.createElement('div');
    newContainer.style.maxWidth = '900px';
    newContainer.style.margin = '0 auto';
    newContainer.style.padding = '20px';
    newContainer.style.fontFamily = 'sans-serif';
    
    // 4. Loop through slides
    slides.forEach(function(slide, index) {
        var slideClone = slide.cloneNode(true);
        var slideNumber = index + 1;
        
        // --- STYLE OVERRIDES (DARK MODE) ---
        // We force black background and white text to match the original feel
        slideClone.style.cssText = `
            display: block !important;
            position: relative !important;
            opacity: 1 !important;
            visibility: visible !important;
            transform: none !important;
            left: auto !important;
            top: auto !important;
            width: 100% !important;
            height: auto !important;
            margin-bottom: 50px !important;
            border: 1px solid #444 !important; /* Dark border */
            box-shadow: 0 4px 10px rgba(0,0,0,0.5) !important;
            padding: 20px !important;
            background-color: black !important; /* Black background */
            color: white !important; /* White text */
            overflow: visible !important;
            box-sizing: border-box !important;
        `;
        
        // --- SMART HEADER WITH LINK ---
        var header = document.createElement('div');
        header.style.borderBottom = '1px solid #444';
        header.style.marginBottom = '15px';
        header.style.paddingBottom = '5px';
        header.style.textAlign = 'right'; // Move number to right for cleaner look
        
        var link = document.createElement('a');
        link.href = originalBaseURL + "#" + slideNumber;
        link.target = "_blank";
        link.innerText = 'Slide ' + slideNumber;
        link.style.textDecoration = 'none';
        link.style.color = '#5dade2'; // Light blue link color (readable on dark)
        link.style.fontWeight = 'bold';
        link.style.fontSize = '0.9em';
        link.style.fontFamily = 'monospace';
        link.title = "Open this slide in the original presentation view";

        header.appendChild(link);
        slideClone.insertBefore(header, slideClone.firstChild);

        // --- AGGRESSIVE NOTE CLEANING ---
        var noteEl = slideClone.querySelector('[role="note"], .note, footer');
        if (noteEl) {
            // Get text content and replace non-breaking spaces (\u00A0) with normal spaces
            // Then remove all whitespace to see if anything real is left
            var rawText = noteEl.textContent.replace(/\u00A0/g, " ").trim();
            
            if (rawText.length === 0) {
                // If it's empty or just whitespace/tags, hide it
                noteEl.style.display = 'none';
            } else {
                // Style existing notes to look good in dark mode
                noteEl.style.display = 'block';
                noteEl.style.borderTop = "1px solid #444";
                noteEl.style.marginTop = "20px";
                noteEl.style.padding = "10px";
                noteEl.style.color = "#ccc"; // Light grey text for notes
                noteEl.style.backgroundColor = "#1a1a1a"; // Dark grey background for notes
                noteEl.style.fontSize = "0.9em";
            }
        }

        newContainer.appendChild(slideClone);
    });

    // 5. Apply Dark Theme to Body
    document.body.innerHTML = '';
    document.body.style.cssText = 'overflow-y: auto !important; background-color: #111 !important; color: #eee !important; height: auto !important; margin: 0; padding: 0;';
    document.body.appendChild(newContainer);
    
    // 6. Remove Scripts
    document.querySelectorAll('script').forEach(el => el.remove());

    // 7. Force Scrollability
    document.documentElement.style.overflow = 'auto';
    document.documentElement.style.height = 'auto';

    console.log("Layout converted (Dark Mode).");

    // 8. Generate and Download
    setTimeout(function() {
        var htmlContent = '<!DOCTYPE html>\n<html>\n<head>\n<meta charset="utf-8">\n<title>' + (document.title || 'Slides Export') + '</title>\n' +
        // Inject a small style block to ensure links and fonts look right globally
        '<style>body { font-family: sans-serif; } a { color: #5dade2; }</style>\n' +
        '</head>\n' + document.body.outerHTML + '\n</html>';
        
        var blob = new Blob([htmlContent], {type: 'text/html'});
        var url = URL.createObjectURL(blob);
        
        var a = document.createElement('a');
        a.href = url;
        a.download = newFilename; 
        document.body.appendChild(a);
        a.click();
        
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
    }, 500);
})();