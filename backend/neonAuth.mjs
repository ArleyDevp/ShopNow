import dotenv from 'dotenv';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.resolve(__dirname, '..', '.env.local') });

import { createAuthClient } from '@neon/auth';
import { BetterAuthVanillaAdapter } from '@neon/auth/vanilla';

function baseUrl() {
  const url = process.env.NEON_AUTH_BASE_URL;
  if (!url) throw new Error('NEON_AUTH_BASE_URL is not configured');
  return url;
}

export async function signUpWithEmail({ email, password, name, origin }) {
  const base = baseUrl();
  const resolvedOrigin = origin || 'http://localhost:3000';
  let capturedCookie = null;
  const originalFetch = globalThis.fetch;
  globalThis.fetch = async (input, init) => {
    const res = await originalFetch(input, init);
    try {
      const sc = res.headers.getSetCookie?.();
      if (sc && sc.length) capturedCookie = sc[0].split(';')[0];
    } catch {}
    return res;
  };
  try {
    const auth = createAuthClient(base, {
      adapter: BetterAuthVanillaAdapter({
        fetchOptions: { headers: { Origin: resolvedOrigin } }
      })
    });
    const { data, error } = await auth.signUp.email({ email, password, name });
    if (error) throw new Error(error.message || 'Sign up failed');
    return { user: data?.user, sessionCookie: capturedCookie };
  } finally {
    globalThis.fetch = originalFetch;
  }
}

export async function signInWithEmail({ email, password, origin }) {
  const base = baseUrl();
  const resolvedOrigin = origin || 'http://localhost:3000';
  let capturedCookie = null;
  const originalFetch = globalThis.fetch;
  globalThis.fetch = async (input, init) => {
    const res = await originalFetch(input, init);
    try {
      const sc = res.headers.getSetCookie?.();
      if (sc && sc.length) capturedCookie = sc[0].split(';')[0];
    } catch {}
    return res;
  };
  try {
    const auth = createAuthClient(base, {
      adapter: BetterAuthVanillaAdapter({
        fetchOptions: { headers: { Origin: resolvedOrigin } }
      })
    });
    const { data, error } = await auth.signIn.email({ email, password });
    if (error) throw new Error(error.message || 'Sign in failed');
    return { user: data?.user, sessionCookie: capturedCookie };
  } finally {
    globalThis.fetch = originalFetch;
  }
}

export async function readCurrentUser({ sessionCookie, origin }) {
  const base = baseUrl();
  const resolvedOrigin = origin || 'http://localhost:3000';
  const auth = createAuthClient(base, {
    adapter: BetterAuthVanillaAdapter({
      fetchOptions: { headers: { Origin: resolvedOrigin, Cookie: sessionCookie } }
    })
  });
  const { data, error } = await auth.getSession();
  if (error) throw new Error(error.message || 'Session lookup failed');
  return data?.user || null;
}

export async function updateUserProfile({ sessionCookie, name, origin }) {
  const base = baseUrl();
  const resolvedOrigin = origin || 'http://localhost:3000';
  const auth = createAuthClient(base, {
    adapter: BetterAuthVanillaAdapter({
      fetchOptions: { headers: { Origin: resolvedOrigin, Cookie: sessionCookie } }
    })
  });
  const { data, error } = await auth.updateUser({ name });
  if (error) throw new Error(error.message || 'Update failed');
  return data?.user || null;
}