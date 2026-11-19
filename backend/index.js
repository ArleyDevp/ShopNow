
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

app.post('/api/auth/neon/forgot-password', async (req, res) => {
  try {
    const { neonForgotPassword } = await import('./neonAuthRoute.mjs');
    return await neonForgotPassword(req, res);
  } catch (error) {
    console.error('Error forgot password:', error.message);
    return res.status(500).json({ error: 'No se pudo solicitar el restablecimiento.' });
  }
});

app.post('/api/auth/neon/reset-password', async (req, res) => {
  try {
    const { neonResetPassword } = await import('./neonAuthRoute.mjs');
    return await neonResetPassword(req, res);
  } catch (error) {
    console.error('Error reset password:', error.message);
    return res.status(500).json({ error: 'No se pudo restablecer la contraseña: ' + (error.message || '') });
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

app.get('/reset-password', (req, res) => {
  const token = req.query.token || '';
  res.send(`<!DOCTYPE html><html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Restablecer contraseña</title>
<style>
body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif;background:#f4f6f8;margin:0;display:flex;align-items:center;justify-content:center;min-height:100vh;padding:16px}
.card{background:#fff;border-radius:16px;box-shadow:0 10px 30px rgba(0,0,0,.08);padding:32px;max-width:420px;width:100%}
h1{margin:0 0 8px;font-size:22px;color:#122630}
p{color:#555;font-size:14px;margin:0 0 20px}
label{display:block;font-size:13px;font-weight:600;color:#555;margin:12px 0 6px}
.input-wrap{position:relative}
input{width:100%;padding:12px 44px 12px 12px;border:1px solid #ddd;border-radius:10px;font-size:15px;box-sizing:border-box}
input:focus{outline:none;border-color:#f26b5b}
.toggle{position:absolute;right:8px;top:50%;transform:translateY(-50%);background:none;border:none;cursor:pointer;color:#888;font-size:18px}
button.primary{width:100%;padding:14px;border:none;border-radius:10px;background:#f26b5b;color:#fff;font-size:15px;font-weight:700;cursor:pointer;margin-top:18px}
button.primary:disabled{opacity:.6;cursor:not-allowed}
.msg{margin-top:16px;padding:12px 14px;border-radius:10px;font-size:14px;display:none}
.msg.error{display:block;background:#fdecea;color:#b00020}
.msg.success{display:block;background:#e8f5e9;color:#1b5e20}
.req{font-size:12px;color:#888;margin-top:8px}
</style></head><body>
<div class="card">
  <h1>Restablecer contraseña</h1>
  <p>Ingresa y confirma tu nueva contraseña para volver a iniciar sesión.</p>
  <form id="f">
    <input type="hidden" id="token" value="${token}">
    <label for="p">Nueva contraseña</label>
    <div class="input-wrap"><input type="password" id="p" required minlength="8"><button type="button" class="toggle" data-target="p">👁</button></div>
    <div class="req">Mínimo 8 caracteres, una mayúscula, una minúscula y un número.</div>
    <label for="c">Confirmar contraseña</label>
    <div class="input-wrap"><input type="password" id="c" required minlength="8"><button type="button" class="toggle" data-target="c">👁</button></div>
    <button type="submit" class="primary" id="btn">Guardar</button>
  </form>
  <div id="msg" class="msg"></div>
</div>
<script>
document.querySelectorAll('.toggle').forEach(b=>b.addEventListener('click',()=>{const i=document.getElementById(b.dataset.target);i.type=i.type==='password'?'text':'password';}));
const form=document.getElementById('f'),btn=document.getElementById('btn'),msg=document.getElementById('msg');
form.addEventListener('submit',async e=>{
  e.preventDefault();
  const t=document.getElementById('token').value,p=document.getElementById('p').value,c=document.getElementById('c').value;
  if(p!==c){msg.className='msg error';msg.textContent='Las contraseñas no coinciden.';return;}
  if(!/[A-Z]/.test(p)||!/[a-z]/.test(p)||!/[0-9]/.test(p)||p.length<8){msg.className='msg error';msg.textContent='La contraseña no cumple los requisitos mínimos.';return;}
  btn.disabled=true;btn.textContent='Guardando...';
  try{
    const r=await fetch('/api/auth/neon/reset-password',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({token:t,newPassword:p})});
    const d=await r.json();
    if(r.ok){msg.className='msg success';msg.textContent='¡Listo! Tu contraseña se cambió correctamente. Ya puedes volver a la aplicación e iniciar sesión con tu nueva contraseña.';form.style.display='none';}
    else{msg.className='msg error';msg.textContent=d.error||'No se pudo restablecer la contraseña.';}
  }catch(err){msg.className='msg error';msg.textContent='Error de conexión.';}
  btn.disabled=false;btn.textContent='Guardar';
});
</script></body></html>`);
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
