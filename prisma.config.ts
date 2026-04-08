import { defineConfig } from 'prisma/config';
export default defineConfig({
  schema: './prisma/schema.prisma',
  datasource: {
    url: 'postgres://postgres@127.0.0.1/postgres?sslmode=disable',
  },
});
