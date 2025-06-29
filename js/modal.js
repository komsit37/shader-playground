// Modal system for displaying shader documentation
import { STYLES, MODAL_CONTENT_STYLES, createStyledElement } from './styles.js';
import { markdownToHtml, addEventListenerSafe } from './utils.js';

export class Modal {
  constructor() {
    this.currentModal = null;
    this.styleElement = null;
    this.cleanupFunctions = [];
  }

  // Show modal with markdown content
  static showMarkdown(shaderName, markdown) {
    const modal = new Modal();
    return modal.createMarkdownModal(shaderName, markdown);
  }

  // Create and show markdown modal
  createMarkdownModal(shaderName, markdown) {
    this.cleanup(); // Clean up any existing modal

    // Create modal elements
    const modal = this.createModalBackdrop();
    const modalContent = this.createModalContent();
    const header = this.createModalHeader(shaderName);
    const body = this.createModalBody(markdown);

    // Assemble modal
    modalContent.appendChild(header);
    modalContent.appendChild(body);
    modal.appendChild(modalContent);

    // Add styles for markdown content
    this.addModalStyles();

    // Setup event handlers
    this.setupEventHandlers(modal);

    // Show modal
    document.body.appendChild(modal);
    this.currentModal = modal;

    return this;
  }

  // Create modal backdrop
  createModalBackdrop() {
    return createStyledElement('div', 'modalBackdrop');
  }

  // Create modal content container
  createModalContent() {
    return createStyledElement('div', 'modalContent');
  }

  // Create modal header with title and close button
  createModalHeader(shaderName) {
    const header = createStyledElement('div', 'modalHeader');
    
    // Title
    const title = createStyledElement('h2', 'modalTitle');
    title.textContent = `${shaderName} Cursor`;
    
    // Close button
    const closeBtn = createStyledElement('button', 'modalCloseBtn');
    closeBtn.innerHTML = '×';
    closeBtn.setAttribute('aria-label', 'Close modal');
    
    // Add hover effect to close button
    const cleanup1 = addEventListenerSafe(closeBtn, 'mouseenter', () => {
      closeBtn.style.cssText = STYLES.modalCloseBtnHover;
    });
    
    const cleanup2 = addEventListenerSafe(closeBtn, 'mouseleave', () => {
      closeBtn.style.cssText = STYLES.modalCloseBtn;
    });
    
    // Close handler
    const cleanup3 = addEventListenerSafe(closeBtn, 'click', () => {
      this.close();
    });

    if (cleanup1) this.cleanupFunctions.push(cleanup1);
    if (cleanup2) this.cleanupFunctions.push(cleanup2);
    if (cleanup3) this.cleanupFunctions.push(cleanup3);

    header.appendChild(title);
    header.appendChild(closeBtn);
    
    return header;
  }

  // Create modal body with markdown content
  createModalBody(markdown) {
    const body = createStyledElement('div', 'modalBody');
    body.className = 'modal-content';
    
    // Convert markdown to HTML and set content
    const htmlContent = markdownToHtml(markdown);
    body.innerHTML = htmlContent;
    
    return body;
  }

  // Add CSS styles for modal content
  addModalStyles() {
    this.styleElement = document.createElement('style');
    this.styleElement.textContent = MODAL_CONTENT_STYLES;
    document.head.appendChild(this.styleElement);
  }

  // Setup event handlers for modal
  setupEventHandlers(modal) {
    // Close on backdrop click
    const cleanup1 = addEventListenerSafe(modal, 'click', (e) => {
      if (e.target === modal) {
        this.close();
      }
    });

    // Close on Escape key
    const escHandler = (e) => {
      if (e.key === 'Escape') {
        this.close();
      }
    };
    
    const cleanup2 = addEventListenerSafe(document, 'keydown', escHandler);

    if (cleanup1) this.cleanupFunctions.push(cleanup1);
    if (cleanup2) this.cleanupFunctions.push(cleanup2);
  }

  // Close the modal
  close() {
    this.cleanup();
  }

  // Cleanup modal and event handlers
  cleanup() {
    // Remove modal from DOM
    if (this.currentModal && this.currentModal.parentNode) {
      this.currentModal.parentNode.removeChild(this.currentModal);
    }

    // Remove styles
    if (this.styleElement && this.styleElement.parentNode) {
      this.styleElement.parentNode.removeChild(this.styleElement);
    }

    // Clean up event listeners
    this.cleanupFunctions.forEach(cleanupFn => {
      try {
        cleanupFn();
      } catch (error) {
        console.warn('Error cleaning up event listener:', error);
      }
    });

    // Reset state
    this.currentModal = null;
    this.styleElement = null;
    this.cleanupFunctions = [];
  }

  // Check if modal is currently open
  isOpen() {
    return !!this.currentModal;
  }

  // Static convenience method for quick modal creation
  static show(title, content, isMarkdown = true) {
    const modal = new Modal();
    
    if (isMarkdown) {
      return modal.createMarkdownModal(title, content);
    } else {
      // For future: plain HTML content support
      console.warn('Plain HTML modals not yet implemented');
      return modal;
    }
  }
}

// Export convenience function for backward compatibility
export function showFullDescription(shaderName, markdown) {
  return Modal.showMarkdown(shaderName, markdown);
}