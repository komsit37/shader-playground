// Main entry point for Shader Playground - Refactored modular version
import { ShaderPlayground } from './app.js';

// Global application instance
let app = null;

// Legacy global functions for backward compatibility with HTML controls
// Define these immediately so they're available when HTML loads
window.changeCursorType = function(width, height) {
  if (app) {
    app.changeCursorType(width, height);
  } else {
    console.warn('App not yet initialized, cursor type change ignored');
  }
};

window.changeMode = function(mode) {
  if (app) {
    app.changeMode(mode);
  } else {
    console.warn('App not yet initialized, mode change ignored');
  }
};

// Initialize the application
async function initializeApp() {
  try {
    console.log('Initializing Shader Playground...');
    
    // Get playground element
    const playground = document.getElementById('playground');
    if (!playground) {
      throw new Error('Playground element not found in DOM');
    }

    // Create and initialize application
    app = new ShaderPlayground(playground);
    await app.init();
    
    console.log('Shader Playground ready!');
    
    // Expose app to global scope for debugging
    if (typeof window !== 'undefined') {
      window.shaderPlayground = app;
    }
    
  } catch (error) {
    console.error('Failed to initialize Shader Playground:', error);
    
    // Show error message to user
    showErrorMessage(error);
  }
}

// Show error message in the playground
function showErrorMessage(error) {
  const playground = document.getElementById('playground');
  if (!playground) return;
  
  playground.innerHTML = `
    <div style="
      display: flex;
      align-items: center;
      justify-content: center;
      height: 100vh;
      background: #1a1a1a;
      color: #ff6b6b;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      text-align: center;
      padding: 20px;
      box-sizing: border-box;
    ">
      <div>
        <h2 style="margin: 0 0 16px 0; color: #ff6b6b;">Failed to Load Shader Playground</h2>
        <p style="margin: 0 0 16px 0; color: #cccccc; max-width: 600px;">
          ${error.message || 'Unknown error occurred'}
        </p>
        <button onclick="location.reload()" style="
          background: #ff6b6b;
          color: white;
          border: none;
          padding: 12px 24px;
          border-radius: 6px;
          cursor: pointer;
          font-size: 14px;
        ">
          Reload Page
        </button>
      </div>
    </div>
  `;
}

// Handle application lifecycle
document.addEventListener('DOMContentLoaded', () => {
  initializeApp();
});

// Handle page unload
window.addEventListener('beforeunload', () => {
  if (app) {
    app.destroy();
  }
});

// Export for module usage
export { app };

// Development helpers
if ((typeof process !== 'undefined' && process?.env?.NODE_ENV === 'development') || 
    (typeof window !== 'undefined' && window.location.hostname === 'localhost')) {
  
  // Hot reload support
  window.reloadShaders = async function() {
    if (app) {
      await app.reload();
    }
  };
  
  // Debug helpers
  window.getAppState = function() {
    return app ? app.getState() : null;
  };
  
  window.getShaderCards = function() {
    return app ? app.getShaderCards() : [];
  };
  
  console.log('Development mode enabled. Available commands:');
  console.log('- window.reloadShaders() - Reload all shaders');
  console.log('- window.getAppState() - Get application state');
  console.log('- window.getShaderCards() - Get all shader cards');
  console.log('- window.shaderPlayground - Main app instance');
}