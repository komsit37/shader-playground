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
  const isVertical = window.innerHeight > window.innerWidth;
  const playground = document.getElementById("playground");
  if (!playground) {
    return;
  }
  let value = sandboxes.reduce((a, b) => a + " 1fr", "");
  console.log(value);

  if (isVertical) {
    playground.style.gridTemplateColumns = "unset";
    playground.style.gridTemplateRows = value;
  } else {
    playground.style.gridTemplateColumns = value;
    playground.style.gridTemplateRows = "unset";
  }
}
let previousCursor = { x: 0, y: 0, z: 10, w: 20 };
let currentCursor = { x: 0, y: 0, z: 10, w: 20 };
let option = 0;
Promise.all([
  fetch("/shaders/ghostty_wrapper.glsl").then((response) => response.text()),
  Promise.all([
    // fetch("/shaders/debug_cursor_animated.glsl").then((response) =>
    //   response.text(),
    // ),
    fetch("/shaders/cursor_ligthing.glsl").then((response) => response.text()),
    fetch("/shaders/cursor_smear.glsl").then((response) => response.text()),
  ]),
]).then(([ghosttyWrapper, shaders]) => {
  const wrapShader = (shader) => ghosttyWrapper.replace("//$REPLACE$", shader);
  shaders.forEach((shader) => {
    const sandbox = init(wrapShader(shader));
    sandboxes.push(sandbox);
  });
  setGrid();
});

function init(shader) {
  const canvasWrapper = document.createElement("div");
  canvasWrapper.className = "_canvas-wrapper";

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
