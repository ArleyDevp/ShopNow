
require('dotenv').config();

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

if (!supabaseUrl || !anonKey || !serviceKey) {
  console.error('Faltan variables de configuracion de Supabase.');
  process.exit(1);
}

if (!/^https:\/\/[^/]+\.supabase\.co$/.test(supabaseUrl)) {
  console.error('SUPABASE_URL no tiene un formato valido.');
  process.exit(1);
}

// Cliente para autenticacion de usuarios.
const supabaseAuth = createClient(supabaseUrl, anonKey, {
  auth: {
    persistSession: false,
    autoRefreshToken: false
  }
});

// Cliente administrativo.
// La clave secreta nunca debe salir de Express.
const supabaseAdmin = createClient(supabaseUrl, serviceKey, {
  auth: {
    persistSession: false,
    autoRefreshToken: false
  }
});

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
