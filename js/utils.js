// Utility functions for data processing and conversion

// Extract description from markdown content
export function extractDescription(mdContent) {
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
export function markdownToHtml(markdown) {
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

// Calculate square grid dimensions
export function calculateGridDimensions(itemCount) {
  if (itemCount === 0) return { cols: 0, rows: 0 };
  
  const cols = Math.ceil(Math.sqrt(itemCount));
  const rows = Math.ceil(itemCount / cols);
  
  return { cols, rows };
}

// Debounce function for performance optimization
export function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

// Get canvas dimensions safely
export function getCanvasDimensions(wrapper) {
  if (!wrapper) return { width: 0, height: 0 };
  
  return {
    width: wrapper.clientWidth || 300,
    height: wrapper.clientHeight || 200
  };
}

// Clamp value between min and max
export function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max);
}

// Generate random position within bounds
export function randomPosition(width, height) {
  return {
    x: Math.random() * width,
    y: Math.random() * height
  };
}

// Calculate preset positions for auto mode
export function calculatePresetPosition(option, canvasWidth, canvasHeight) {
  const bottom = canvasHeight * 0.1;
  const top = canvasHeight * 0.9;
  const left = canvasWidth * 0.1;
  const right = canvasWidth * 0.9;
  
  const positions = [
    { x: left, y: top },
    { x: right, y: bottom },
    { x: right, y: top },
    { x: left, y: top },
    { x: left, y: bottom },
    { x: right, y: bottom },
    { x: right, y: top }
  ];
  
  return positions[option] || positions[0];
}

// Safe element creation with error handling
export function createElement(tag, className = '', styles = '') {
  try {
    const element = document.createElement(tag);
    if (className) element.className = className;
    if (styles) element.style.cssText = styles;
    return element;
  } catch (error) {
    console.error(`Failed to create element: ${tag}`, error);
    return document.createElement('div'); // Fallback
  }
}

// Safe event listener addition with cleanup tracking
export function addEventListenerSafe(element, event, handler, options = {}) {
  if (!element || typeof handler !== 'function') return null;
  
  try {
    element.addEventListener(event, handler, options);
    return () => element.removeEventListener(event, handler, options);
  } catch (error) {
    console.error('Failed to add event listener:', error);
    return null;
  }
}