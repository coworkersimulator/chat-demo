import type { PGlite } from '@electric-sql/pglite';
import { createPglite } from './pglite';

const WORKER_ID = 'pglite';
const bc = new BroadcastChannel(`pglite-broadcast:${WORKER_ID}`);
const connectedTabs = new Set<string>();

const pgliteReady: Promise<PGlite> = createPglite();

bc.onmessage = async (e: MessageEvent) => {
  if (e.data.type === 'tab-here') {
    const tabId = e.data.id as string;
    if (!connectedTabs.has(tabId)) {
      connectedTabs.add(tabId);
      connectTab(tabId, await pgliteReady);
    }
  }
};

function connectTab(tabId: string, db: PGlite) {
  const tabBc = new BroadcastChannel(`pglite-tab:${tabId}`);
  let releaseQuery: (() => void) | null = null;
  let releaseTransaction: (() => void) | null = null;

  // Fires when the tab releases its pglite-tab-close lock (tab closes / worker terminates)
  navigator.locks.request(`pglite-tab-close:${tabId}`, () =>
    new Promise<void>((resolve) => {
      if (releaseTransaction) {
        void db.exec('ROLLBACK').catch(() => {});
        releaseTransaction();
        releaseTransaction = null;
      }
      releaseQuery?.();
      releaseQuery = null;
      tabBc.close();
      connectedTabs.delete(tabId);
      resolve();
    }),
  );

  const rpc: Record<string, (...args: any[]) => Promise<any>> = {
    async getDebugLevel() { return db.debug; },
    async close() { /* never close the shared db */ },
    async execProtocol(data: Uint8Array) {
      const r = await db.execProtocol(data);
      return { messages: r.messages, data: ownBuffer(r.data) };
    },
    async execProtocolRaw(data: Uint8Array) {
      return ownBuffer(await db.execProtocolRaw(data));
    },
    async execProtocolStream(data: Uint8Array) {
      return db.execProtocolStream(data);
    },
    async execProtocolRawStream(data: Uint8Array, ...rest: any[]) {
      return (db as any).execProtocolRawStream(data, ...rest);
    },
    async dumpDataDir(compression?: any) { return db.dumpDataDir(compression); },
    async syncToFs() { return (db as any).syncToFs?.(); },
    async _handleBlob(blob: any) { return (db as any)._handleBlob(blob); },
    async _getWrittenBlob() { return (db as any)._getWrittenBlob(); },
    async _cleanupBlob() { return (db as any)._cleanupBlob(); },
    async _checkReady() { return (db as any)._checkReady(); },
    async _acquireQueryLock() {
      return new Promise<void>((resolve) => {
        (db as any)._runExclusiveQuery(
          () => new Promise<void>((release) => { releaseQuery = release; resolve(); }),
        );
      });
    },
    async _releaseQueryLock() { releaseQuery?.(); releaseQuery = null; },
    async _acquireTransactionLock() {
      return new Promise<void>((resolve) => {
        (db as any)._runExclusiveTransaction(
          () => new Promise<void>((release) => { releaseTransaction = release; resolve(); }),
        );
      });
    },
    async _releaseTransactionLock() { releaseTransaction?.(); releaseTransaction = null; },
  };

  tabBc.addEventListener('message', async (e: MessageEvent) => {
    if (e.data.type !== 'rpc-call') return;
    const { callId, method, args } = e.data;
    const fn = rpc[method];
    if (!fn) {
      tabBc.postMessage({ type: 'rpc-error', callId, error: { message: `Unknown method: ${method}` } });
      return;
    }
    try {
      tabBc.postMessage({ type: 'rpc-return', callId, result: await fn(...args) });
    } catch (err: any) {
      tabBc.postMessage({ type: 'rpc-error', callId, error: { message: err.message } });
    }
  });

  tabBc.postMessage({ type: 'connected' });
}

// Ensure a Uint8Array owns its buffer (not a view into a larger one)
function ownBuffer(data: Uint8Array): Uint8Array {
  if (data.byteLength === data.buffer.byteLength) return data;
  const copy = new ArrayBuffer(data.byteLength);
  new Uint8Array(copy).set(data);
  return new Uint8Array(copy);
}

// Per-tab handshake: send "here", wait for "init", reply "ready"
self.addEventListener('connect', (e: Event) => {
  const port = (e as MessageEvent).ports[0];
  port.postMessage({ type: 'here' });
  port.addEventListener('message', (msg: MessageEvent) => {
    if (msg.data.type === 'init') {
      port.postMessage({ type: 'ready', id: WORKER_ID });
    }
  });
  port.start();
});
