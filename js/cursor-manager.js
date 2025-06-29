// Cursor state management and interaction handling
import { CONFIG } from './config.js';
import { randomPosition, calculatePresetPosition, clamp } from './utils.js';

export class CursorManager {
  constructor() {
    this.currentCursor = { ...CONFIG.DEFAULT_CURSOR };
    this.previousCursor = { ...CONFIG.DEFAULT_CURSOR };
    this.mode = CONFIG.MODES.CLICK;
    this.intervalId = null;
    this.option = 0;
    this.masterCanvas = null;
    this.sandboxes = [];
    
    this.setupEventListeners();
  }

  // Set the master canvas reference
  setMasterCanvas(canvas) {
    this.masterCanvas = canvas;
  }

  // Add a sandbox to the collection
  addSandbox(sandbox) {
    this.sandboxes.push(sandbox);
  }

  // Clear all sandboxes
  clearSandboxes() {
    this.sandboxes = [];
  }

  // Change cursor dimensions
  changeCursorType(width, height) {
    this.currentCursor.z = clamp(width, 1, 100);
    this.currentCursor.w = clamp(height, 1, 100);
  }

  // Move cursor to new position
  moveCursor(x, y) {
    this.previousCursor = { ...this.currentCursor };
    this.currentCursor.x = x;
    this.currentCursor.y = y;
    this.setCursorUniforms();
  }

  // Generate random cursor position
  randomCursor() {
    if (!this.masterCanvas) return;
    
    const position = randomPosition(
      this.masterCanvas.width,
      this.masterCanvas.height
    );
    this.moveCursor(position.x, position.y);
  }

  // Change interaction mode
  changeMode(newMode) {
    if (!Object.values(CONFIG.MODES).includes(newMode)) {
      console.warn(`Invalid mode: ${newMode}`);
      return;
    }

    this.mode = newMode;
    this.clearInterval();

    switch (newMode) {
      case CONFIG.MODES.AUTO:
        this.intervalId = setInterval(() => {
          this.changePresetPosition(1);
        }, CONFIG.INTERVAL);
        break;
        
      case CONFIG.MODES.RANDOM:
        this.intervalId = setInterval(() => {
          this.randomCursor();
        }, CONFIG.INTERVAL);
        break;
        
      case CONFIG.MODES.CLICK:
        // Manual mode - no interval needed
        break;
    }
  }

  // Clear current interval
  clearInterval() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }

  // Change to preset position (for auto mode)
  changePresetPosition(increment) {
    if (!this.masterCanvas) return;

    this.option = (this.option + increment) % CONFIG.PRESET_POSITIONS;
    
    const position = calculatePresetPosition(
      this.option,
      this.masterCanvas.width,
      this.masterCanvas.height
    );
    
    this.moveCursor(position.x, position.y);
  }

  // Update shader uniforms
  setCursorUniforms() {
    this.sandboxes.forEach((sandbox) => {
      try {
        sandbox.setUniform(
          "iCurrentCursor",
          this.currentCursor.x,
          this.currentCursor.y,
          this.currentCursor.z,
          this.currentCursor.w
        );
        
        sandbox.setUniform(
          "iPreviousCursor",
          this.previousCursor.x,
          this.previousCursor.y,
          this.previousCursor.z,
          this.previousCursor.w
        );
        
        // Set cursor change time
        const now = sandbox.uniforms["u_time"]?.value?.[0] || 0;
        sandbox.setUniform("iTimeCursorChange", now);
      } catch (error) {
        console.error('Failed to set cursor uniforms:', error);
      }
    });
  }

  // Handle canvas click events
  handleCanvasClick(event, canvas) {
    if (this.mode !== CONFIG.MODES.CLICK) return;
    
    const rect = canvas.getBoundingClientRect();
    const x = event.clientX - rect.left;
    const y = canvas.height - (event.clientY - rect.top);
    
    this.moveCursor(x, y);
  }

  // Handle keyboard navigation
  handleKeyPress(event) {
    if (!event.key) return;

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

    this.moveCursor(
      this.currentCursor.x + increment.x,
      this.currentCursor.y + increment.y
    );
  }

  // Handle global click events (for auto mode)
  handleGlobalClick() {
    if (this.mode === CONFIG.MODES.AUTO) {
      this.changePresetPosition(1);
    }
  }

  // Handle right-click events (for auto mode)
  handleContextMenu(event) {
    event.preventDefault();
    if (this.mode === CONFIG.MODES.AUTO) {
      this.changePresetPosition(-1);
    }
  }

  // Setup global event listeners
  setupEventListeners() {
    // Keyboard navigation
    document.addEventListener("keydown", (event) => {
      this.handleKeyPress(event);
    });

    // Global click for auto mode
    document.addEventListener("click", () => {
      this.handleGlobalClick();
    });

    // Right-click for auto mode
    document.addEventListener("contextmenu", (event) => {
      this.handleContextMenu(event);
    });
  }

  // Cleanup method
  destroy() {
    this.clearInterval();
    this.clearSandboxes();
    this.masterCanvas = null;
  }

  // Get current state for debugging
  getState() {
    return {
      mode: this.mode,
      currentCursor: { ...this.currentCursor },
      previousCursor: { ...this.previousCursor },
      option: this.option,
      sandboxCount: this.sandboxes.length,
      hasInterval: !!this.intervalId
    };
  }
}