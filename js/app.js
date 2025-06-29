// Main application class for Shader Playground
import { CONFIG } from './config.js';
import { CursorManager } from './cursor-manager.js';
import { GridLayout } from './grid-layout.js';
import { ShaderLoader } from './shader-loader.js';
import { ShaderCard } from './shader-card.js';
import { debounce } from './utils.js';

export class ShaderPlayground {
  constructor(playgroundElement) {
    this.playground = playgroundElement || document.getElementById('playground');
    if (!this.playground) {
      throw new Error('Playground element not found');
    }

    // Initialize managers
    this.cursorManager = new CursorManager();
    this.gridLayout = new GridLayout(this.playground);
    this.shaderLoader = new ShaderLoader();
    
    // State
    this.shaderCards = [];
    this.initialized = false;
    this.loading = false;

    console.log('Shader Playground initialized');
  }

  // Initialize the application
  async init() {
    if (this.initialized) {
      console.warn('Application already initialized');
      return;
    }

    if (this.loading) {
      console.warn('Application already loading');
      return;
    }

    try {
      this.loading = true;
      console.log('Loading shader playground...');

      // Load all assets
      const assets = await this.shaderLoader.loadAll();
      console.log('Assets loaded successfully');

      // Process assets into usable format
      const processedAssets = ShaderLoader.processAssets(assets);
      console.log(`Processed ${processedAssets.length} shader configurations`);

      // Create shader cards
      await this.createShaderCards(processedAssets);

      // Setup grid layout
      this.gridLayout.setShaderCount(this.shaderCards.length);

      // Auto-start with auto mode
      this.cursorManager.changeMode(CONFIG.MODES.AUTO);

      this.initialized = true;
      this.loading = false;
      
      console.log('Shader playground initialized successfully');
    } catch (error) {
      this.loading = false;
      console.error('Failed to initialize shader playground:', error);
      throw error;
    }
  }

  // Create shader cards from processed assets
  async createShaderCards(processedAssets) {
    const cardPromises = processedAssets.map(async (asset) => {
      try {
        // Create shader card
        const card = new ShaderCard(
          asset.config,
          asset.wrappedShader,
          asset.markdown,
          this.cursorManager
        );

        // Add to playground
        this.playground.appendChild(card.getElement());

        // Initialize shader
        card.initializeShader();

        return card;
      } catch (error) {
        console.error(`Failed to create shader card for ${asset.config.name}:`, error);
        return null;
      }
    });

    // Wait for all cards to be created
    const cards = await Promise.all(cardPromises);
    
    // Filter out failed cards
    this.shaderCards = cards.filter(card => card !== null);
    
    console.log(`Created ${this.shaderCards.length} shader cards`);
  }

  // Resize all shader cards
  resizeCards() {
    this.shaderCards.forEach(card => {
      try {
        card.resize();
      } catch (error) {
        console.warn('Failed to resize shader card:', error);
      }
    });
  }

  // Setup additional event listeners
  setupEventListeners() {
    // Debounced resize handler for shader cards
    const debouncedResize = debounce(() => {
      this.resizeCards();
    }, 250);

    window.addEventListener('resize', debouncedResize);

    // Store cleanup function
    this.cleanup = () => {
      window.removeEventListener('resize', debouncedResize);
    };
  }

  // Change cursor mode
  changeMode(mode) {
    this.cursorManager.changeMode(mode);
  }

  // Change cursor type
  changeCursorType(width, height) {
    this.cursorManager.changeCursorType(width, height);
  }

  // Get application state
  getState() {
    return {
      initialized: this.initialized,
      loading: this.loading,
      shaderCount: this.shaderCards.length,
      cursorState: this.cursorManager.getState(),
      gridStats: this.gridLayout.getStats(),
      cacheStats: this.shaderLoader.getCacheStats()
    };
  }

  // Get shader cards
  getShaderCards() {
    return [...this.shaderCards];
  }

  // Get specific shader card by name
  getShaderCard(name) {
    return this.shaderCards.find(card => 
      card.config.name === name || card.config.baseName === name
    );
  }

  // Reload shaders (useful for development)
  async reload() {
    console.log('Reloading shader playground...');
    
    try {
      // Clear existing cards
      this.destroy();
      
      // Clear cache
      this.shaderLoader.clearCache();
      
      // Reinitialize
      this.initialized = false;
      await this.init();
      
      console.log('Shader playground reloaded successfully');
    } catch (error) {
      console.error('Failed to reload shader playground:', error);
      throw error;
    }
  }

  // Add new shader dynamically
  async addShader(config, shaderContent, markdownContent) {
    if (!this.initialized) {
      throw new Error('Application not initialized');
    }

    try {
      // Load wrapper if not cached
      const wrapper = await this.shaderLoader.loadGhosttyWrapper();
      const wrappedShader = ShaderLoader.wrapShader(shaderContent, wrapper);

      // Create card
      const card = new ShaderCard(
        config,
        wrappedShader,
        markdownContent,
        this.cursorManager
      );

      // Add to playground
      this.playground.appendChild(card.getElement());
      card.initializeShader();

      // Update state
      this.shaderCards.push(card);
      this.gridLayout.setShaderCount(this.shaderCards.length);

      console.log(`Added shader: ${config.name}`);
      return card;
    } catch (error) {
      console.error(`Failed to add shader ${config.name}:`, error);
      throw error;
    }
  }

  // Remove shader card
  removeShader(nameOrCard) {
    const card = typeof nameOrCard === 'string' 
      ? this.getShaderCard(nameOrCard)
      : nameOrCard;

    if (!card) {
      console.warn('Shader card not found for removal');
      return false;
    }

    try {
      // Remove from array
      const index = this.shaderCards.indexOf(card);
      if (index > -1) {
        this.shaderCards.splice(index, 1);
      }

      // Destroy card
      card.destroy();

      // Update grid
      this.gridLayout.setShaderCount(this.shaderCards.length);

      console.log(`Removed shader: ${card.config.name}`);
      return true;
    } catch (error) {
      console.error('Failed to remove shader card:', error);
      return false;
    }
  }

  // Cleanup and destroy
  destroy() {
    console.log('Destroying shader playground...');

    // Destroy all shader cards
    this.shaderCards.forEach(card => {
      try {
        card.destroy();
      } catch (error) {
        console.warn('Error destroying shader card:', error);
      }
    });

    // Clear managers
    if (this.cursorManager) {
      this.cursorManager.destroy();
    }

    if (this.gridLayout) {
      this.gridLayout.destroy();
    }

    // Clear playground
    if (this.playground) {
      this.playground.innerHTML = '';
    }

    // Clean up event listeners
    if (this.cleanup) {
      this.cleanup();
    }

    // Reset state
    this.shaderCards = [];
    this.initialized = false;
    this.loading = false;

    console.log('Shader playground destroyed');
  }
}