import { PrismaPGlite } from 'pglite-prisma-adapter';
import { PrismaClient } from '@prisma/client/edge';
import pglite from './pglite';

const adapter = new PrismaPGlite(pglite);
const prisma = new PrismaClient({ adapter });

export { prisma };
export default prisma;
