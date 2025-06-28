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
// Shader configurations with names
const shaderConfigs = [
  { name: "Lighting", file: "cursor_ligthing.glsl" },
  { name: "Lightning", file: "cursor_ligthing_fancy.glsl" },
  { name: "Rainbow", file: "cursor_rainbow.glsl" },
  { name: "Bounce", file: "cursor_bounce.glsl" },
  { name: "Bounce Clean", file: "cursor_bounce_clean.glsl" },
  { name: "Digital Dissolve", file: "cursor_digital_dissolve.glsl" },
];

Promise.all([
  fetch("/shaders/ghostty_wrapper.glsl").then((response) => response.text()),
  Promise.all(
    shaderConfigs.map(config => 
      fetch(`/shaders/${config.file}`).then((response) => response.text())
    )
  ),
]).then(([ghosttyWrapper, shaders]) => {
  const wrapShader = (shader) => ghosttyWrapper.replace("//$REPLACE$", shader);
  shaders.forEach((shader, index) => {
    const sandbox = init(wrapShader(shader), shaderConfigs[index].name);
    sandboxes.push(sandbox);
  });
  setGrid();
  
  // Auto-start with auto mode
  changeMode("auto");
});

function init(shader, shaderName) {
  const canvasWrapper = document.createElement("div");
  canvasWrapper.className = "_canvas-wrapper";

  // Add shader name label
  const nameLabel = document.createElement("div");
  nameLabel.className = "shader-name";
  nameLabel.textContent = shaderName;
  nameLabel.style.cssText = `
    position: absolute;
    top: 8px;
    left: 8px;
    background: rgba(0, 0, 0, 0.7);
    color: white;
    padding: 4px 8px;
    border-radius: 4px;
    font-family: monospace;
    font-size: 12px;
    z-index: 10;
    pointer-events: none;
  `;
  canvasWrapper.appendChild(nameLabel);

  const canvas = document.createElement("canvas");
  canvasWrapper.appendChild(canvas);
  playground.appendChild(canvasWrapper);
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
