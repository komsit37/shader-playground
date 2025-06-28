// CSS-in-JS styles for the shader playground
import { CONFIG } from './config.js';

const { COLORS, FONTS } = CONFIG;

export const STYLES = {
  // Grid item container
  gridItem: `
    display: flex;
    flex-direction: column;
    height: 100%;
    background: ${COLORS.background};
    border-radius: 8px;
    overflow: hidden;
    border: 1px solid ${COLORS.border};
  `,

  // Canvas wrapper (75% of height)
  canvasWrapper: `
    flex: ${CONFIG.GRID_RATIO.canvas};
    position: relative;
    min-height: 0;
  `,

  // Description section (25% of height)
  descSection: `
    flex: ${CONFIG.GRID_RATIO.description};
    background: ${COLORS.surface};
    padding: 12px;
    border-top: 1px solid ${COLORS.borderLight};
    cursor: pointer;
    transition: background-color 0.2s;
    display: flex;
    flex-direction: column;
    justify-content: flex-start;
    min-height: 0;
  `,

  // Description section hover state
  descSectionHover: `
    background: ${COLORS.border};
  `,

  // Title element in description
  title: `
    font-family: ${FONTS.system};
    font-size: 14px;
    font-weight: 600;
    color: ${COLORS.text.primary};
    margin-bottom: 2px;
  `,

  // Metadata element (filename)
  metadata: `
    font-family: ${FONTS.mono};
    font-size: 10px;
    color: ${COLORS.text.muted};
    margin-bottom: 8px;
  `,

  // Description text
  descText: `
    font-family: ${FONTS.system};
    font-size: 11px;
    line-height: 1.4;
    color: ${COLORS.text.secondary};
    flex: 1;
  `,

  // Click hint
  clickHint: `
    font-size: 10px;
    color: ${COLORS.text.muted};
    margin-top: 6px;
    font-style: italic;
  `,

  // Modal backdrop
  modalBackdrop: `
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
  `,

  // Modal content
  modalContent: `
    background: ${COLORS.background};
    border-radius: 12px;
    border: 1px solid ${COLORS.borderLight};
    max-width: 800px;
    max-height: 80vh;
    width: 100%;
    overflow: hidden;
    display: flex;
    flex-direction: column;
  `,

  // Modal header
  modalHeader: `
    background: ${COLORS.surface};
    padding: 16px 20px;
    border-bottom: 1px solid ${COLORS.borderLight};
    display: flex;
    justify-content: space-between;
    align-items: center;
  `,

  // Modal title
  modalTitle: `
    margin: 0;
    color: ${COLORS.text.primary};
    font-family: ${FONTS.system};
    font-size: 18px;
    font-weight: 600;
  `,

  // Modal close button
  modalCloseBtn: `
    background: none;
    border: none;
    color: ${COLORS.text.muted};
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
  `,

  // Modal close button hover
  modalCloseBtnHover: `
    background-color: ${COLORS.borderLight};
    color: ${COLORS.text.primary};
  `,

  // Modal body
  modalBody: `
    padding: 20px;
    overflow-y: auto;
    color: ${COLORS.text.secondary};
    font-family: ${FONTS.system};
    line-height: 1.6;
  `
};

// Modal content styles (for markdown rendering)
export const MODAL_CONTENT_STYLES = `
  .modal-content h1, .modal-content h2, .modal-content h3 {
    color: ${COLORS.text.primary};
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
    background: ${COLORS.border};
    padding: 2px 6px;
    border-radius: 3px;
    font-family: ${FONTS.mono};
    font-size: 13px;
  }
  .modal-content pre {
    background: ${COLORS.border};
    padding: 12px;
    border-radius: 6px;
    overflow-x: auto;
    margin: 12px 0;
  }
  .modal-content pre code {
    background: none;
    padding: 0;
  }
  .modal-content strong { color: ${COLORS.text.primary}; }
`;

// Helper function to apply styles to an element
export function applyStyles(element, styleKey) {
  if (STYLES[styleKey]) {
    element.style.cssText = STYLES[styleKey];
  }
  return element;
}

// Helper function to create styled element
export function createStyledElement(tag, styleKey, className = '') {
  const element = document.createElement(tag);
  if (className) element.className = className;
  if (STYLES[styleKey]) {
    element.style.cssText = STYLES[styleKey];
  }
  return element;
}

// Add hover effect helper
export function addHoverEffect(element, normalStyle, hoverStyle) {
  element.addEventListener('mouseenter', () => {
    if (STYLES[hoverStyle]) {
      element.style.cssText = STYLES[hoverStyle];
    }
  });
  
  element.addEventListener('mouseleave', () => {
    if (STYLES[normalStyle]) {
      element.style.cssText = STYLES[normalStyle];
    }
  });
}