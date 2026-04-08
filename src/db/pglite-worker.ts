import { worker } from '@electric-sql/pglite/worker';
import pglite from './pglite';

worker({
  async init() {
    return pglite;
  },
});
