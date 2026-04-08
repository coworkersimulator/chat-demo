import { worker } from '@electric-sql/pglite/worker';
import { createPglite } from './pglite';

worker({
  async init() {
    return createPglite();
  },
});
