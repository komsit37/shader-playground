// Grid layout management for shader playground
import { calculateGridDimensions, debounce } from './utils.js';

export class GridLayout {
  constructor(playgroundElement) {
    this.playground = playgroundElement;
    this.shaderCount = 0;
    this.initialized = false;
    
    this.setupResizeHandler();
  }

  // Set the number of shaders in the grid
  setShaderCount(count) {
    this.shaderCount = Math.max(0, count);
    this.updateGrid();
  }

  // Update grid layout based on current shader count
  updateGrid() {
    if (!this.playground || this.shaderCount === 0) {
      this.clearGrid();
      return;
    }

    const { cols, rows } = calculateGridDimensions(this.shaderCount);
    
    this.playground.style.gridTemplateColumns = `repeat(${cols}, 1fr)`;
    this.playground.style.gridTemplateRows = `repeat(${rows}, 1fr)`;
    
    console.log(`Grid updated: ${cols}x${rows} for ${this.shaderCount} shaders`);
    this.initialized = true;
  }

  // Clear grid layout
  clearGrid() {
    if (!this.playground) return;
    
    this.playground.style.gridTemplateColumns = '';
    this.playground.style.gridTemplateRows = '';
    this.initialized = false;
  }

  // Handle window resize with debouncing
  setupResizeHandler() {
    const debouncedResize = debounce(() => {
      if (this.initialized) {
        this.updateGrid();
      }
    }, 250);

    window.addEventListener('resize', debouncedResize);
    
    // Store cleanup function
    this.cleanup = () => {
      window.removeEventListener('resize', debouncedResize);
    };
  }

  // Get current grid dimensions
  getGridDimensions() {
    return calculateGridDimensions(this.shaderCount);
  }

  // Get grid statistics
  getStats() {
    const { cols, rows } = this.getGridDimensions();
    return {
      shaderCount: this.shaderCount,
      cols,
      rows,
      totalCells: cols * rows,
      emptyCells: (cols * rows) - this.shaderCount,
      initialized: this.initialized
    };
  }

  // Force grid recalculation
  recalculate() {
    this.updateGrid();
  }

  // Cleanup method
  destroy() {
    if (this.cleanup) {
      this.cleanup();
    }
    this.clearGrid();
    this.playground = null;
  }
}