// Shader and asset loading utilities
import { SHADER_CONFIGS } from './config.js';

export class ShaderLoader {
  constructor() {
    this.cache = new Map();
    this.loadingPromises = new Map();
  }

  // Load all shaders and related assets
  async loadAll() {
    try {
      const [ghosttyWrapper, shaders, markdownFiles] = await Promise.all([
        this.loadGhosttyWrapper(),
        this.loadShaders(SHADER_CONFIGS),
        this.loadMarkdownFiles(SHADER_CONFIGS)
      ]);

      return {
        wrapper: ghosttyWrapper,
        shaders,
        markdownFiles,
        configs: SHADER_CONFIGS
      };
    } catch (error) {
      console.error('Failed to load shader assets:', error);
      throw error;
    }
  }

  // Load the Ghostty wrapper template
  async loadGhosttyWrapper() {
    const cacheKey = 'ghostty_wrapper';
    
    if (this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey);
    }

    if (this.loadingPromises.has(cacheKey)) {
      return this.loadingPromises.get(cacheKey);
    }

    const promise = this.fetchText('shaders/ghostty_wrapper.glsl');
    this.loadingPromises.set(cacheKey, promise);

    try {
      const content = await promise;
      this.cache.set(cacheKey, content);
      this.loadingPromises.delete(cacheKey);
      return content;
    } catch (error) {
      this.loadingPromises.delete(cacheKey);
      throw error;
    }
  }

  // Load all shader files
  async loadShaders(configs) {
    const promises = configs.map(config => 
      this.loadShaderFile(config.file)
    );

    return Promise.all(promises);
  }

  // Load all markdown documentation files
  async loadMarkdownFiles(configs) {
    const promises = configs.map(config => 
      this.loadMarkdownFile(config.md)
    );

    return Promise.all(promises);
  }

  // Load individual shader file
  async loadShaderFile(filename) {
    const cacheKey = `shader_${filename}`;
    
    if (this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey);
    }

    if (this.loadingPromises.has(cacheKey)) {
      return this.loadingPromises.get(cacheKey);
    }

    const promise = this.fetchText(`shaders/${filename}`);
    this.loadingPromises.set(cacheKey, promise);

    try {
      const content = await promise;
      this.cache.set(cacheKey, content);
      this.loadingPromises.delete(cacheKey);
      return content;
    } catch (error) {
      console.error(`Failed to load shader: ${filename}`, error);
      this.loadingPromises.delete(cacheKey);
      throw error;
    }
  }

  // Load individual markdown file
  async loadMarkdownFile(filename) {
    const cacheKey = `md_${filename}`;
    
    if (this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey);
    }

    if (this.loadingPromises.has(cacheKey)) {
      return this.loadingPromises.get(cacheKey);
    }

    const promise = this.fetchText(`shaders/${filename}`);
    this.loadingPromises.set(cacheKey, promise);

    try {
      const content = await promise;
      this.cache.set(cacheKey, content);
      this.loadingPromises.delete(cacheKey);
      return content;
    } catch (error) {
      console.error(`Failed to load markdown: ${filename}`, error);
      this.loadingPromises.delete(cacheKey);
      throw error;
    }
  }

  // Fetch text content with error handling
  async fetchText(url) {
    try {
      const response = await fetch(url);
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      return await response.text();
    } catch (error) {
      if (error instanceof TypeError) {
        throw new Error(`Network error loading ${url}: ${error.message}`);
      }
      throw error;
    }
  }

  // Wrap shader with Ghostty wrapper
  static wrapShader(shader, wrapper) {
    if (!wrapper || !shader) {
      throw new Error('Invalid shader or wrapper content');
    }

    const wrappedShader = wrapper.replace('//$REPLACE$', shader);
    
    if (wrappedShader === wrapper) {
      console.warn('Shader replacement marker not found in wrapper');
    }
    
    return wrappedShader;
  }

  // Process loaded assets into usable format
  static processAssets(assets) {
    const { wrapper, shaders, markdownFiles, configs } = assets;
    
    return configs.map((config, index) => ({
      config,
      shader: shaders[index],
      wrappedShader: ShaderLoader.wrapShader(shaders[index], wrapper),
      markdown: markdownFiles[index]
    }));
  }

  // Clear cache
  clearCache() {
    this.cache.clear();
    this.loadingPromises.clear();
  }

  // Get cache statistics
  getCacheStats() {
    return {
      cacheSize: this.cache.size,
      loadingPromises: this.loadingPromises.size,
      cachedItems: Array.from(this.cache.keys())
    };
  }

  // Preload specific assets
  async preload(filenames) {
    const promises = filenames.map(filename => {
      if (filename.endsWith('.glsl')) {
        return this.loadShaderFile(filename);
      } else if (filename.endsWith('.md')) {
        return this.loadMarkdownFile(filename);
      } else {
        return this.fetchText(filename);
      }
    });

    try {
      await Promise.all(promises);
      console.log(`Preloaded ${filenames.length} assets`);
    } catch (error) {
      console.warn('Some assets failed to preload:', error);
    }
  }
}

// Export singleton instance
export const shaderLoader = new ShaderLoader();