let cursorWidth = 10;
let cursorHeight = 20;
let mode = "click";
let masterCanvas;
const INTERVAL = 1000;
let intervalId = undefined;
function changeCursorType(x, y) {
  cursorWidth = x;
  cursorHeight = y;
}

function changeMode(_mode) {
  mode = _mode;
  if (intervalId) {
    clearInterval(intervalId);
  }
  switch (_mode) {
    case "auto":
      intervalId = setInterval(() => {
        changePresetPosition(1);
      }, INTERVAL);
      break;
    case "rnd":
      intervalId = setInterval(() => {
        randomCursor();
      }, INTERVAL);
      break;
    case "click":
      break;
  }
}

const playground = document.getElementById("playground");
let sandboxes = [];
window.addEventListener("resize", function () {
  setGrid();
});

function setGrid() {
  const playground = document.getElementById("playground");
  if (!playground) {
    return;
  }
  
  const shaderCount = sandboxes.length;
  if (shaderCount === 0) return;
  
  // Calculate square grid dimensions
  const cols = Math.ceil(Math.sqrt(shaderCount));
  const rows = Math.ceil(shaderCount / cols);
  
  playground.style.gridTemplateColumns = `repeat(${cols}, 1fr)`;
  playground.style.gridTemplateRows = `repeat(${rows}, 1fr)`;
  
  console.log(`Grid: ${cols}x${rows} for ${shaderCount} shaders`);
}
let previousCursor = { x: 0, y: 0, z: 10, w: 20 };
let currentCursor = { x: 0, y: 0, z: 10, w: 20 };
let option = 0;
// Shader names - files and titles are inferred
const shaderNames = [
  "cursor_ligthing",
  "cursor_ligthing_fancy", 
  "cursor_rainbow",
  "cursor_bounce",
  "cursor_bounce_clean",
  "cursor_digital_dissolve",
];

// Convert shader name to display title
function shaderNameToTitle(shaderName) {
  return shaderName
    .replace(/^cursor_/, '') // Remove "cursor_" prefix
    .split('_') // Split on underscores
    .map(word => word.charAt(0).toUpperCase() + word.slice(1)) // Capitalize each word
    .join(' '); // Join with spaces
}

// Generate shader configs from names
const shaderConfigs = shaderNames.map(name => ({
  name: shaderNameToTitle(name),
  file: `${name}.glsl`,
  md: `${name}.md`
}));

// Extract description from markdown content
function extractDescription(mdContent) {
  // Find the first paragraph after the title
  const lines = mdContent.split('\n');
  let description = '';
  let foundTitle = false;
  
  for (let line of lines) {
    line = line.trim();
    if (line.startsWith('#') && !foundTitle) {
      foundTitle = true;
      continue;
    }
    if (foundTitle && line && !line.startsWith('#') && !line.startsWith('##')) {
      description = line;
      break;
    }
  }
  
  return description || 'Cursor effect shader';
}

// Convert markdown to HTML for display
function markdownToHtml(markdown) {
  return markdown
    .replace(/^### (.*$)/gim, '<h3>$1</h3>')
    .replace(/^## (.*$)/gim, '<h2>$1</h2>')
    .replace(/^# (.*$)/gim, '<h1>$1</h1>')
    .replace(/\*\*(.*?)\*\*/gim, '<strong>$1</strong>')
    .replace(/\*(.*?)\*/gim, '<em>$1</em>')
    .replace(/`(.*?)`/gim, '<code>$1</code>')
    .replace(/```([\s\S]*?)```/gim, '<pre><code>$1</code></pre>')
    .replace(/^- (.*$)/gim, '<li>$1</li>')
    .replace(/(<li>.*<\/li>)/s, '<ul>$1</ul>')
    .replace(/\n\n/gim, '</p><p>')
    .replace(/^(.*)$/gim, '<p>$1</p>')
    .replace(/<p><\/p>/gim, '')
    .replace(/<p>(<h[1-6]>.*<\/h[1-6]>)<\/p>/gim, '$1')
    .replace(/<p>(<ul>.*<\/ul>)<\/p>/gim, '$1')
    .replace(/<p>(<pre>.*<\/pre>)<\/p>/gim, '$1');
}

// Show full description modal
function showFullDescription(shaderName, markdown) {
  // Create modal backdrop
  const modal = document.createElement('div');
  modal.style.cssText = `
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.8);
    z-index: 1000;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 20px;
    box-sizing: border-box;
  `;

  // Create modal content
  const modalContent = document.createElement('div');
  modalContent.style.cssText = `
    background: #1a1a1a;
    border-radius: 12px;
    border: 1px solid #444;
    max-width: 800px;
    max-height: 80vh;
    width: 100%;
    overflow: hidden;
    display: flex;
    flex-direction: column;
  `;

  // Modal header
  const header = document.createElement('div');
  header.style.cssText = `
    background: #2a2a2a;
    padding: 16px 20px;
    border-bottom: 1px solid #444;
    display: flex;
    justify-content: space-between;
    align-items: center;
  `;

  const title = document.createElement('h2');
  title.style.cssText = `
    margin: 0;
    color: white;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    font-size: 18px;
    font-weight: 600;
  `;
  title.textContent = `${shaderName} Cursor`;

  const closeBtn = document.createElement('button');
  closeBtn.style.cssText = `
    background: none;
    border: none;
    color: #888;
    font-size: 24px;
    cursor: pointer;
    padding: 0;
    width: 32px;
    height: 32px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 4px;
    transition: background-color 0.2s;
  `;
  closeBtn.innerHTML = '×';
  closeBtn.addEventListener('mouseenter', () => {
    closeBtn.style.backgroundColor = '#444';
    closeBtn.style.color = '#fff';
  });
  closeBtn.addEventListener('mouseleave', () => {
    closeBtn.style.backgroundColor = 'transparent';
    closeBtn.style.color = '#888';
  });

  header.appendChild(title);
  header.appendChild(closeBtn);

  // Modal body
  const body = document.createElement('div');
  body.style.cssText = `
    padding: 20px;
    overflow-y: auto;
    color: #cccccc;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    line-height: 1.6;
  `;

  // Add markdown content
  const htmlContent = markdownToHtml(markdown);
  body.innerHTML = htmlContent;

  // Style the HTML content
  const style = document.createElement('style');
  style.textContent = `
    .modal-content h1, .modal-content h2, .modal-content h3 {
      color: #ffffff;
      margin-top: 24px;
      margin-bottom: 12px;
    }
    .modal-content h1 { font-size: 24px; }
    .modal-content h2 { font-size: 20px; }
    .modal-content h3 { font-size: 16px; }
    .modal-content p { margin-bottom: 12px; }
    .modal-content ul { margin: 12px 0; padding-left: 20px; }
    .modal-content li { margin: 4px 0; }
    .modal-content code {
      background: #333;
      padding: 2px 6px;
      border-radius: 3px;
      font-family: 'Monaco', 'Consolas', monospace;
      font-size: 13px;
    }
    .modal-content pre {
      background: #333;
      padding: 12px;
      border-radius: 6px;
      overflow-x: auto;
      margin: 12px 0;
    }
    .modal-content pre code {
      background: none;
      padding: 0;
    }
    .modal-content strong { color: #ffffff; }
  `;
  document.head.appendChild(style);
  body.className = 'modal-content';

  modalContent.appendChild(header);
  modalContent.appendChild(body);
  modal.appendChild(modalContent);

  // Close handlers
  const closeModal = () => {
    document.body.removeChild(modal);
    document.head.removeChild(style);
  };

  closeBtn.addEventListener('click', closeModal);
  modal.addEventListener('click', (e) => {
    if (e.target === modal) closeModal();
  });

  document.addEventListener('keydown', function escHandler(e) {
    if (e.key === 'Escape') {
      closeModal();
      document.removeEventListener('keydown', escHandler);
    }
  });

  document.body.appendChild(modal);
}

Promise.all([
  fetch("/shaders/ghostty_wrapper.glsl").then((response) => response.text()),
  Promise.all(
    shaderConfigs.map(config => 
      fetch(`/shaders/${config.file}`).then((response) => response.text())
    )
  ),
  Promise.all(
    shaderConfigs.map(config => 
      fetch(`/shaders/${config.md}`).then((response) => response.text())
    )
  ),
]).then(([ghosttyWrapper, shaders, markdownFiles]) => {
  const wrapShader = (shader) => ghosttyWrapper.replace("//$REPLACE$", shader);
  shaders.forEach((shader, index) => {
    const config = shaderConfigs[index];
    const fullMarkdown = markdownFiles[index];
    const description = extractDescription(fullMarkdown);
    const sandbox = init(wrapShader(shader), config.name, description, fullMarkdown, config.file);
    sandboxes.push(sandbox);
  });
  setGrid();
  
  // Auto-start with auto mode
  changeMode("auto");
});

function init(shader, shaderName, description, fullMarkdown, fileName) {
  const gridItem = document.createElement("div");
  gridItem.className = "grid-item";
  gridItem.style.cssText = `
    display: flex;
    flex-direction: column;
    height: 100%;
    background: #1a1a1a;
    border-radius: 8px;
    overflow: hidden;
    border: 1px solid #333;
  `;

  // Canvas wrapper - 75% of height
  const canvasWrapper = document.createElement("div");
  canvasWrapper.className = "_canvas-wrapper";
  canvasWrapper.style.cssText = `
    flex: 3;
    position: relative;
    min-height: 0;
  `;

  // Remove name overlay from canvas - will be in description

  const canvas = document.createElement("canvas");
  canvasWrapper.appendChild(canvas);

  // Description section - 25% of height
  const descSection = document.createElement("div");
  descSection.className = "desc-section";
  descSection.style.cssText = `
    flex: 1;
    background: #2a2a2a;
    padding: 12px;
    border-top: 1px solid #444;
    cursor: pointer;
    transition: background-color 0.2s;
    display: flex;
    flex-direction: column;
    justify-content: flex-start;
    min-height: 0;
  `;

  // Title and metadata
  const titleElement = document.createElement("div");
  titleElement.style.cssText = `
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    font-size: 14px;
    font-weight: 600;
    color: #ffffff;
    margin-bottom: 2px;
  `;
  titleElement.textContent = shaderName;

  const metaElement = document.createElement("div");
  metaElement.style.cssText = `
    font-family: 'Monaco', 'Consolas', monospace;
    font-size: 10px;
    color: #888;
    margin-bottom: 8px;
  `;
  metaElement.textContent = fileName;

  const descText = document.createElement("div");
  descText.style.cssText = `
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    font-size: 11px;
    line-height: 1.4;
    color: #cccccc;
    flex: 1;
  `;
  descText.textContent = description;

  const clickHint = document.createElement("div");
  clickHint.style.cssText = `
    font-size: 10px;
    color: #888;
    margin-top: 6px;
    font-style: italic;
  `;
  clickHint.textContent = "Click for full details";

  descSection.appendChild(titleElement);
  descSection.appendChild(metaElement);
  descSection.appendChild(descText);
  descSection.appendChild(clickHint);

  // Add hover effect
  descSection.addEventListener('mouseenter', () => {
    descSection.style.backgroundColor = '#333';
  });
  descSection.addEventListener('mouseleave', () => {
    descSection.style.backgroundColor = '#2a2a2a';
  });

  // Add click handler for full description
  descSection.addEventListener('click', () => {
    showFullDescription(shaderName, fullMarkdown);
  });

  gridItem.appendChild(canvasWrapper);
  gridItem.appendChild(descSection);
  playground.appendChild(gridItem);
  canvas.width = canvasWrapper.clientWidth;
  canvas.height = canvasWrapper.clientHeight;
  const sandbox = new GlslCanvas(canvas);
  sandbox.load(shader);
  canvas.addEventListener("click", (event) => {
    if (mode != "click") {
      return;
    }
    const rect = canvas.getBoundingClientRect();
    const x = event.clientX - rect.left;
    const y = canvas.height - (event.clientY - rect.top);
    console.log(x, y);
    moveCursor(x, y);
    setCursorUniforms();
  });
  masterCanvas = canvas;
  return sandbox;
}

//
function setCursorUniforms() {
  sandboxes.forEach((sandbox) => {
    sandbox.setUniform(
      "iCurrentCursor",
      currentCursor.x,
      currentCursor.y,
      currentCursor.z,
      currentCursor.w,
    );
    sandbox.setUniform(
      "iPreviousCursor",
      previousCursor.x,
      previousCursor.y,
      previousCursor.z,
      previousCursor.w,
    );
    let now = sandbox.uniforms["u_time"].value[0];
    sandbox.setUniform("iTimeCursorChange", now);
  });
}
function randomCursor() {
  const x = Math.random() * masterCanvas.width;
  const y = Math.random() * masterCanvas.height;
  moveCursor(x, y);
  setCursorUniforms();
}
document.addEventListener("keydown", function (event) {
  if (event.key) {
    let increment = { x: 0, y: 0 };
    switch (event.key) {
      case "Enter":
      case "ArrowDown":
        increment.y = -20;
        break;
      case "ArrowLeft":
      case "Backspace":
        increment.x = -10;
        break;
      case "ArrowUp":
        increment.y = 20;
        break;
      default:
        increment.x = 10;
        break;
    }

    console.log(event.key);
    // You can specify a specific key if needed
    moveCursor(currentCursor.x + increment.x, currentCursor.y + increment.y);
    setCursorUniforms();
  }
});
function moveCursor(x, y) {
  previousCursor = { ...currentCursor };
  currentCursor = {
    x: x,
    y: y,
    z: cursorWidth,
    w: cursorHeight,
  };
}
document.addEventListener("click", function () {
  if (mode != "auto") {
    return;
  }
  changePresetPosition(1);
});

document.addEventListener("contextmenu", function (event) {
  event.preventDefault(); // Prevent default context menu from appearing
  if (mode != "auto") {
    return;
  }
  changePresetPosition(-1);
});

function changePresetPosition(increment) {
  console.log("magia negra");
  let bottom = masterCanvas.height * 0.1;
  let top = masterCanvas.height * 0.9;
  let left = masterCanvas.width * 0.1;
  let right = masterCanvas.width * 0.9;

  option = (option + increment) % 7;
  console.log(option, top, bottom, left, right);
  switch (option) {
    case 0:
      moveCursor(left, top);
      break;
    case 1:
      moveCursor(right, bottom);
      break;
    case 2:
      moveCursor(right, top);
      break;
    case 3:
      moveCursor(left, top);
      break;
    case 4:
      moveCursor(left, bottom);
      break;
    case 5:
      moveCursor(right, bottom);
      break;
    case 6:
      moveCursor(right, top);
      moveCursor(left, bottom);
      break;
  }
  setCursorUniforms();
}
