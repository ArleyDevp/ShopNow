import { signUpWithEmail, signInWithEmail, readCurrentUser, updateUserProfile } from './neonAuth.mjs';

function getCookie(req, name) {
  const header = req.headers.cookie || '';
  const parts = header.split(';').map((p) => p.trim());
  for (const part of parts) {
    if (part.startsWith(name + '=')) {
      return part.slice(name.length + 1);
    }
  }
  return null;
}

export async function neonSignUp(req, res) {
  const { nombre, name, email, correo, password } = req.body || {};
  const emailFinal = String(email || correo || '').trim().toLowerCase();
  const passwordFinal = String(password || '');
  const nameFinal = String(nombre || name || '').trim() || 'User';

  if (!emailFinal || !passwordFinal) {
    return res.status(400).json({ error: 'Email y password son obligatorios.' });
  }
  if (passwordFinal.length < 8) {
    return res.status(400).json({ error: 'La contrasena debe tener minimo 8 caracteres.' });
  }

  const origin = req.headers.origin || `http://${req.headers.host || 'localhost:3000'}`;
  const result = await signUpWithEmail({
    email: emailFinal,
    password: passwordFinal,
    name: nameFinal,
    origin
  });

  if (result.sessionCookie) {
    res.setHeader('Set-Cookie', result.sessionCookie + '; Path=/; HttpOnly; Secure; SameSite=None');
  }

  return res.status(201).json({
    ok: true,
    message: 'Cuenta creada correctamente.',
    sessionToken: result.sessionCookie ? result.sessionCookie.split('=').slice(1).join('=') : null,
    usuario: {
      id: result.user?.id,
      email: result.user?.email,
      name: result.user?.name
    }
  });
}

export async function neonSignIn(req, res) {
  const { email, correo, password } = req.body || {};
  const emailFinal = String(email || correo || '').trim().toLowerCase();
  const passwordFinal = String(password || '');

  if (!emailFinal || !passwordFinal) {
    return res.status(400).json({ error: 'Email y password son obligatorios.' });
  }

  const origin = req.headers.origin || `http://${req.headers.host || 'localhost:3000'}`;
  const result = await signInWithEmail({
    email: emailFinal,
    password: passwordFinal,
    origin
  });

  if (result.sessionCookie) {
    res.setHeader('Set-Cookie', result.sessionCookie + '; Path=/; HttpOnly; Secure; SameSite=None');
  }

  return res.status(200).json({
    ok: true,
    message: 'Sesion iniciada correctamente.',
    sessionToken: result.sessionCookie ? result.sessionCookie.split('=').slice(1).join('=') : null,
    usuario: {
      id: result.user?.id,
      email: result.user?.email,
      name: result.user?.name
    }
  });
}

export async function neonMe(req, res) {
  const sessionCookieValue = getCookie(req, '__Secure-neon-auth.session_token');
  if (!sessionCookieValue) {
    return res.status(401).json({ error: 'No autenticado.' });
  }
  const origin = req.headers.origin || `http://${req.headers.host || 'localhost:3000'}`;
  const user = await readCurrentUser({
    sessionCookie: '__Secure-neon-auth.session_token=' + sessionCookieValue,
    origin
  });
  if (!user) {
    return res.status(401).json({ error: 'No autenticado.' });
  }
  return res.json({
    usuario: {
      id: user.id,
      email: user.email,
      name: user.name
    }
  });
}

export async function neonUpdateUser(req, res) {
  const sessionCookieValue = getCookie(req, '__Secure-neon-auth.session_token');
  if (!sessionCookieValue) {
    return res.status(401).json({ error: 'No autenticado.' });
  }
  const { nombre, name } = req.body || {};
  const nameFinal = String(nombre || name || '').trim();
  if (!nameFinal) {
    return res.status(400).json({ error: 'El nombre es obligatorio.' });
  }
  const origin = req.headers.origin || `http://${req.headers.host || 'localhost:3000'}`;
  const sessionCookie = '__Secure-neon-auth.session_token=' + sessionCookieValue;
  const updated = await updateUserProfile({ sessionCookie, name: nameFinal, origin });
  const user = updated || await readCurrentUser({ sessionCookie, origin });
  if (!user) {
    return res.status(401).json({ error: 'Sesion expirada. Inicia sesion de nuevo.' });
  }
  return res.json({
    ok: true,
    usuario: {
      id: user.id,
      email: user.email,
      name: user.name
    }
  });
}