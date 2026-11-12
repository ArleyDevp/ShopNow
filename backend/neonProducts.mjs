import dotenv from 'dotenv';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.resolve(__dirname, '..', '.env.local') });

import { createAuthClient } from '@neon/auth';
import { BetterAuthVanillaAdapter } from '@neon/auth/vanilla';

export async function fetchProducts(limit = 50) {
  const base = process.env.NEON_AUTH_BASE_URL;
  if (!base) throw new Error('NEON_AUTH_BASE_URL is not configured');
  const auth = createAuthClient(base, {
    adapter: BetterAuthVanillaAdapter({
      fetchOptions: { headers: { Origin: 'http://localhost:3000' } }
    })
  });
  const tokenResult = await auth.getAnonymousToken();
  const token = tokenResult?.data?.token;
  if (!token) throw new Error('No se pudo obtener el token anonimo de Neon Auth');

  const apiUrl = `https://ep-wild-cherry-b56ee0s6.apirest.c-7.us-east-2.aws.neon.tech/neondb/rest/v1/Product?select=id,name,priceRetail,featured,active&active=eq.true&limit=${limit}`;
  const response = await fetch(apiUrl, {
    headers: {
      Authorization: `Bearer ${token}`,
      Accept: 'application/json'
    }
  });
  if (!response.ok) {
    throw new Error(`Data API error: ${response.status}`);
  }
  return await response.json();
}