
const path = require('path');
require('dotenv').config();
require('dotenv').config({ path: path.join(__dirname, '..', '.env.local') });

const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');

const app = express();
const PORT = process.env.PORT || 3000;

// =====================================
// CONFIGURACION GENERAL
// =====================================

app.use(cors());
app.use(express.json({ limit: '20kb' }));

// =====================================
// CONEXION CON SUPABASE
// =====================================

const supabaseUrl = process.env.SUPABASE_URL;
const anonKey = process.env.SUPABASE_ANON_KEY;
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

// URL a la que regresara el usuario despues
// de confirmar su correo.
const APP_REDIRECT_URL =
  process.env.APP_REDIRECT_URL || 'http://localhost:5000';

let supabaseAuth = null;
let supabaseAdmin = null;

if (supabaseUrl && anonKey && serviceKey && /^https:\/\/[^/]+\.supabase\.co$/.test(supabaseUrl)) {
  // Cliente para autenticacion de usuarios.
  supabaseAuth = createClient(supabaseUrl, anonKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false
    }
  });

  // Cliente administrativo.
  // La clave secreta nunca debe salir de Express.
  supabaseAdmin = createClient(supabaseUrl, serviceKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false
    }
  });
} else {
  console.warn('Supabase no configurado: rutas legacy deshabilitadas.');
}

// =====================================
// MANEJO DE ERRORES
// =====================================

app.use((error, req, res, next) => {
  console.error('Error del servidor:', error.message);

  res.status(500).json({
    error: 'Ocurrio un error interno en ShopNow.'
  });
});

// =====================================
// RUTA PRINCIPAL
// =====================================

app.get('/', (req, res) => {
  res.json({
    aplicacion: 'ShopNow',
    mensaje: 'API funcionando correctamente.',
    estado: 'OK'
  });
});

// =====================================
// COMPROBAR CONEXION CON SUPABASE
// =====================================

app.get('/api/health', async (req, res) => {
  if (!supabaseAdmin) {
    return res.status(503).json({ servidor: 'activo', baseDeDatos: 'no configurado' });
  }
  try {
    const { error } = await supabaseAdmin
      .from('categorias')
      .select('id')
      .limit(1);

    if (error) {
      console.error('Error de Supabase:', error.message);

      return res.status(503).json({
        servidor: 'activo',
        baseDeDatos: 'error'
      });
    }

    return res.json({
      servidor: 'activo',
      baseDeDatos: 'conectado'
    });

  } catch (error) {
    console.error('Error de conexion:', error.message);

    return res.status(503).json({
      servidor: 'activo',
      baseDeDatos: 'error'
    });
  }
});

// =====================================
// VERIFICAR USERNAME
// =====================================

app.get('/api/auth/check-username', async (req, res) => {
  try {
    const username = String(req.query.username || '').trim();

    if (!username) {
      return res.status(400).json({
        available: false,
        message: 'El username es obligatorio.'
      });
    }

    if (!/^[a-zA-Z0-9_.-]{3,30}$/.test(username)) {
      return res.status(400).json({
        available: false,
        message: 'El username no tiene un formato valido.'
      });
    }

    const { data, error } = await supabaseAdmin
      .from('perfiles')
      .select('id')
      .eq('usuario', username)
      .maybeSingle();

    if (error) throw error;

    return res.json({
      available: !data
    });

  } catch (error) {
    console.error('Error verificando username:', error.message);

    return res.status(500).json({
      available: false,
      message: 'No se pudo verificar el username.'
    });
  }
});

// =====================================
// REGISTRO DE USUARIOS
// =====================================

app.post('/api/auth/register', async (req, res) => {
  if (!supabaseAdmin || !supabaseAuth) {
    return res.status(503).json({ error: 'Supabase no configurado.' });
  }
  try {
    const {
      nombre,
      apellidos,
      apellido,
      usuario,
      username,
      email,
      correo,
      password,
      confirmarPassword,
      confirmPassword
    } = req.body || {};

    // Normalizar informacion.
    const nombreFinal = String(nombre || '').trim();

    const apellidoFinal = String(
      apellidos || apellido || ''
    ).trim();

    const usuarioFinal = String(
      usuario || username || ''
    ).trim();

    const emailFinal = String(
      email || correo || ''
    ).trim().toLowerCase();

    const passwordFinal = String(password || '');

    const confirmacion = String(
      confirmarPassword || confirmPassword || ''
    );

    // -------------------------------------
    // VALIDAR CAMPOS OBLIGATORIOS
    // -------------------------------------

    if (
      !nombreFinal ||
      !apellidoFinal ||
      !usuarioFinal ||
      !emailFinal ||
      !passwordFinal ||
      !confirmacion
    ) {
      return res.status(400).json({
        error: 'Todos los campos son obligatorios.'
      });
    }

    // -------------------------------------
    // VALIDAR CORREO
    // -------------------------------------

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (!emailRegex.test(emailFinal)) {
      return res.status(400).json({
        error: 'El correo electronico no tiene un formato valido.'
      });
    }

    // -------------------------------------
    // VALIDAR USERNAME
    // -------------------------------------

    if (!/^[a-zA-Z0-9_.-]{3,30}$/.test(usuarioFinal)) {
      return res.status(400).json({
        error: 'El username debe tener entre 3 y 30 caracteres y solo puede contener letras, numeros, puntos, guiones y guiones bajos.'
      });
    }

    // -------------------------------------
    // VALIDAR CONTRASENA
    // -------------------------------------

    if (passwordFinal.length < 8) {
      return res.status(400).json({
        error: 'La contrasena debe tener minimo 8 caracteres.'
      });
    }

    if (passwordFinal.length > 72) {
      return res.status(400).json({
        error: 'La contrasena es demasiado larga.'
      });
    }

    if (passwordFinal !== confirmacion) {
      return res.status(400).json({
        error: 'Las contrasenas no coinciden.'
      });
    }

    // -------------------------------------
    // VERIFICAR USERNAME EN POSTGRESQL
    // -------------------------------------

    const { data: usuarioExistente, error: consultaError } =
      await supabaseAdmin
        .from('perfiles')
        .select('id')
        .eq('usuario', usuarioFinal)
        .maybeSingle();

    if (consultaError) throw consultaError;

    if (usuarioExistente) {
      return res.status(409).json({
        error: 'Este username ya esta registrado.'
      });
    }

    // -------------------------------------
    // REGISTRAR EN SUPABASE AUTH
    // -------------------------------------

    const { data, error } = await supabaseAuth.auth.signUp({
      email: emailFinal,
      password: passwordFinal,

      options: {
        data: {
          nombre: nombreFinal,
          apellido: apellidoFinal,
          usuario: usuarioFinal
        },

        emailRedirectTo: APP_REDIRECT_URL
      }
    });

    if (error) {
      console.error('Error de Supabase Auth:', error.message);

      if (
        error.message.toLowerCase().includes('already registered') ||
        error.message.toLowerCase().includes('already exists')
      ) {
        return res.status(409).json({
          error: 'Este correo electronico ya esta registrado.'
        });
      }

      return res.status(400).json({
        error: 'No se pudo completar el registro. Verifica los datos e intenta nuevamente.'
      });
    }

    if (!data.user) {
      return res.status(500).json({
        error: 'Supabase no devolvio los datos del usuario.'
      });
    }

    // El trigger de PostgreSQL debe crear el perfil.
    // No insertamos un segundo perfil manualmente.

    return res.status(201).json({
      ok: true,

      message: data.session
        ? 'Cuenta creada correctamente.'
        : 'Cuenta creada. Revisa tu correo para confirmar el registro.',

      requiereConfirmacion: !data.session,

      usuario: {
        id: data.user.id,
        email: data.user.email
      }
    });

  } catch (error) {
    console.error('Error en registro:', error.message);

    return res.status(500).json({
      error: 'Ocurrio un error interno al registrar la cuenta.'
    });
  }
});

// =====================================
// NEON AUTH (Managed Better Auth)
// =====================================

app.post('/api/auth/neon/signup', async (req, res) => {
  try {
    const { neonSignUp } = await import('./neonAuthRoute.mjs');
    const result = await neonSignUp(req, res);
    return result;
  } catch (error) {
    console.error('Error en Neon signup:', error.message);
    return res.status(500).json({ error: 'No se pudo completar el registro con Neon Auth.' });
  }
});

app.post('/api/auth/neon/signin', async (req, res) => {
  try {
    const { neonSignIn } = await import('./neonAuthRoute.mjs');
    const result = await neonSignIn(req, res);
    return result;
  } catch (error) {
    console.error('Error en Neon signin:', error.message);
    return res.status(500).json({ error: 'No se pudo iniciar sesion con Neon Auth.' });
  }
});

app.post('/api/auth/neon/update-user', async (req, res) => {
  try {
    const { neonUpdateUser } = await import('./neonAuthRoute.mjs');
    return await neonUpdateUser(req, res);
  } catch (error) {
    console.error('Error actualizando usuario Neon:', error.message);
    return res.status(500).json({ error: 'No se pudo actualizar el perfil.' });
  }
});

app.get('/api/auth/neon/me', async (req, res) => {
  try {
    const { neonMe } = await import('./neonAuthRoute.mjs');
    return await neonMe(req, res);
  } catch (error) {
    console.error('Error leyendo usuario Neon:', error.message);
    return res.status(500).json({ error: 'No se pudo leer el usuario actual.' });
  }
});

app.get('/api/products', async (req, res) => {
  try {
    const { fetchProducts } = await import('./neonProducts.mjs');
    const products = await fetchProducts();
    return res.json({ ok: true, products });
  } catch (error) {
    console.error('Error leyendo productos:', error.message);
    return res.status(500).json({ error: 'No se pudieron leer los productos.' });
  }
});

// =====================================
// RUTA NO ENCONTRADA
// =====================================

app.use((req, res) => {
  res.status(404).json({
    error: 'La ruta solicitada no existe.',
    ruta: req.originalUrl
  });
});

// =====================================
// INICIAR SERVIDOR
// =====================================

app.listen(PORT, '0.0.0.0', () => {
  console.log('================================');
  console.log(' SHOPNOW API');
  console.log('================================');
  console.log(`Servidor: http://localhost:${PORT}`);
  console.log('Supabase: configurado');
  console.log('Estado: activo');
  console.log('================================');
});
