import react from '@vitejs/plugin-react';
import { readFile } from 'node:fs/promises';
import { defineConfig } from 'vite';
import wasm from 'vite-plugin-wasm';

const esbuildWasmPlugin = {
  name: 'wasm',
  setup(build: { onLoad: Function }) {
    build.onLoad({ filter: /\.wasm$/ }, async (args: { path: string }) => {
      const buffer = await readFile(args.path);
      const base64 = buffer.toString('base64');
      return {
        contents: `
          const bytes = Uint8Array.from(atob("${base64}"), c => c.charCodeAt(0));
          export default await WebAssembly.compile(bytes.buffer);
        `,
        loader: 'js',
      };
    });
  },
};

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), wasm()],
  optimizeDeps: {
    exclude: ['@electric-sql/pglite'],
    esbuildOptions: {
      plugins: [esbuildWasmPlugin],
    },
  },
});
