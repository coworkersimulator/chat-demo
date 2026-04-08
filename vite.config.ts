import react from '@vitejs/plugin-react';
import { readFile } from 'node:fs/promises';
import { defineConfig } from 'vite';

const inlineWasmPlugin = {
  name: 'inline-wasm',
  enforce: 'pre' as const,
  async load(id: string) {
    if (!id.endsWith('.wasm')) return null;
    const buffer = await readFile(id);
    const base64 = buffer.toString('base64');
    return {
      code: `const bytes = Uint8Array.from(atob("${base64}"), c => c.charCodeAt(0));
export default await WebAssembly.compile(bytes.buffer);`,
    };
  },
};

// https://vite.dev/config/
export default defineConfig({
  base: '/chat-demo/',
  plugins: [react(), inlineWasmPlugin],
  optimizeDeps: {
    exclude: ['@electric-sql/pglite'],
  },
  worker: {
    plugins: () => [inlineWasmPlugin],
  },
});
