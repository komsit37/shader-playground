// Individual shader card component
import { createStyledElement, addHoverEffect } from './styles.js';
import { getCanvasDimensions, extractDescription, addEventListenerSafe } from './utils.js';
import { Modal } from './modal.js';

export class ShaderCard {
  constructor(config, wrappedShader, markdown, cursorManager) {
    this.config = config;
    this.wrappedShader = wrappedShader;
    this.markdown = markdown;
    this.cursorManager = cursorManager;
    this.description = extractDescription(markdown);
    
    this.gridItem = null;
    this.canvas = null;
    this.sandbox = null;
    this.cleanupFunctions = [];
    
    this.createElement();
  }

  // Create the complete shader card element
  createElement() {
    this.gridItem = this.createGridItem();
    const canvasWrapper = this.createCanvasWrapper();
    const descSection = this.createDescriptionSection();

    this.gridItem.appendChild(canvasWrapper);
    this.gridItem.appendChild(descSection);

    return this.gridItem;
  }

  // Create main grid item container
  createGridItem() {
    return createStyledElement('div', 'gridItem', 'grid-item');
  }

  // Create canvas wrapper and canvas
  createCanvasWrapper() {
    const wrapper = createStyledElement('div', 'canvasWrapper', '_canvas-wrapper');
    
    this.canvas = document.createElement('canvas');
    wrapper.appendChild(this.canvas);

    // Setup canvas click handler
    const cleanup = addEventListenerSafe(this.canvas, 'click', (event) => {
      this.cursorManager.handleCanvasClick(event, this.canvas);
    });
    
    if (cleanup) this.cleanupFunctions.push(cleanup);

    return wrapper;
  }

  // Create description section with title, metadata, and description
  createDescriptionSection() {
    const section = createStyledElement('div', 'descSection', 'desc-section');

    // Add elements
    const title = this.createTitleElement();
    const metadata = this.createMetadataElement();
    const description = this.createDescriptionElement();
    const hint = this.createClickHintElement();

    section.appendChild(title);
    section.appendChild(metadata);
    section.appendChild(description);
    section.appendChild(hint);

    // Add hover effect
    addHoverEffect(section, 'descSection', 'descSectionHover');

    // Add click handler for modal
    const cleanup = addEventListenerSafe(section, 'click', () => {
      this.showModal();
    });
    
    if (cleanup) this.cleanupFunctions.push(cleanup);

    return section;
  }

  // Create title element
  createTitleElement() {
    const title = createStyledElement('div', 'title');
    title.textContent = this.config.name;
    return title;
  }

  // Create metadata element (filename)
  createMetadataElement() {
    const metadata = createStyledElement('div', 'metadata');
    metadata.textContent = this.config.file;
    return metadata;
  }

  // Create description text element
  createDescriptionElement() {
    const desc = createStyledElement('div', 'descText');
    desc.textContent = this.description;
    return desc;
  }

  // Create click hint element
  createClickHintElement() {
    const hint = createStyledElement('div', 'clickHint');
    hint.textContent = 'Click for full details';
    return hint;
  }

  // Initialize shader canvas and sandbox
  initializeShader() {
    if (!this.canvas) {
      console.error('Canvas not available for shader initialization');
      return null;
    }

    try {
      // Set canvas dimensions
      const dimensions = getCanvasDimensions(this.canvas.parentElement);
      this.canvas.width = dimensions.width;
      this.canvas.height = dimensions.height;

      // Create GlslCanvas instance
      this.sandbox = new GlslCanvas(this.canvas);
      this.sandbox.load(this.wrappedShader);

      // Set as master canvas if first one
      if (!this.cursorManager.masterCanvas) {
        this.cursorManager.setMasterCanvas(this.canvas);
      }

      // Add to cursor manager
      this.cursorManager.addSandbox(this.sandbox);

      return this.sandbox;
    } catch (error) {
      console.error(`Failed to initialize shader ${this.config.name}:`, error);
      return null;
    }
  }

  // Show full description modal
  showModal() {
    try {
      Modal.showMarkdown(this.config.name, this.markdown);
    } catch (error) {
      console.error('Failed to show modal:', error);
    }
  }

  // Resize canvas
  resize() {
    if (!this.canvas || !this.canvas.parentElement) return;

    const dimensions = getCanvasDimensions(this.canvas.parentElement);
    this.canvas.width = dimensions.width;
    this.canvas.height = dimensions.height;
  }

  // Get DOM element
  getElement() {
    return this.gridItem;
  }

  // Get sandbox instance
  getSandbox() {
    return this.sandbox;
  }

  // Get canvas element
  getCanvas() {
    return this.canvas;
  }

  // Get shader info
  getInfo() {
    return {
      name: this.config.name,
      file: this.config.file,
      baseName: this.config.baseName,
      description: this.description,
      initialized: !!this.sandbox,
      canvasSize: this.canvas ? {
        width: this.canvas.width,
        height: this.canvas.height
      } : null
    };
  }

  // Update description if needed
  updateDescription(newMarkdown) {
    this.markdown = newMarkdown;
    this.description = extractDescription(newMarkdown);
    
    // Update description element if it exists
    const descElement = this.gridItem?.querySelector('.desc-section div:nth-child(3)');
    if (descElement) {
      descElement.textContent = this.description;
    }
  }

  // Cleanup method
  destroy() {
    // Clean up event listeners
    this.cleanupFunctions.forEach(cleanup => {
      try {
        cleanup();
      } catch (error) {
        console.warn('Error during cleanup:', error);
      }
    });

    // Clean up sandbox
    if (this.sandbox) {
      try {
        // Remove from cursor manager if possible
        // Note: CursorManager doesn't have remove method yet, but sandbox will be cleaned up
        this.sandbox = null;
      } catch (error) {
        console.warn('Error cleaning up sandbox:', error);
      }
    }

    // Remove from DOM
    if (this.gridItem && this.gridItem.parentElement) {
      this.gridItem.parentElement.removeChild(this.gridItem);
    }

    // Clear references
    this.gridItem = null;
    this.canvas = null;
    this.cleanupFunctions = [];
  }
}