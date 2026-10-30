require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');

const app = express();
const PORT = process.env.PORT || 3000;
app.use(cors());
app.use(express.json());

const supabaseUrl = process.env.SUPABASE_URL;
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const supabase = supabaseUrl && serviceKey ? createClient(supabaseUrl, serviceKey) : null;

app.get('/', (req, res) => res.json({ mensaje: 'API de la tienda funcionando correctamente', estado: 'OK' }));
app.get('/api/health', (req, res) => res.json({ servidor: 'activo', baseDeDatos: supabase ? 'conectado' : 'pendiente' }));

app.get('/api/auth/check-username', async (req, res) => {
  const username = (req.query.username || '').trim();
  if (!username) return res.status(400).json({ available: false, message: 'username requerido' });
  if (!supabase) return res.json({ available: true });
  const { data, error } = await supabase.from('perfiles').select('usuario').eq('usuario', username).maybeSingle();
  if (error) return res.status(500).json({ available: false, message: error.message });
  res.json({ available: !data });
});

app.post('/api/auth/register', async (req, res) => {
  const { email, nombre, apellidos, usuario } = req.body || {};
  if (!email || !nombre || !apellidos || !usuario) return res.status(400).json({ error: 'Campos requeridos' });
  if (!supabase) return res.status(503).json({ error: 'Supabase no configurado' });
  // create user via Supabase Auth with metadata; password not handled here (Flutter uses Supabase Auth directly)
  res.json({ ok: true, message: 'Registro recibido. El trigger crea el perfil.' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Servidor iniciado en http://localhost:${PORT}`);
});