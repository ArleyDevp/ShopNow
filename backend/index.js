
require('dotenv').config();

const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    mensaje: 'API de la tienda funcionando correctamente',
    estado: 'OK'
  });
});

app.get('/api/health', (req, res) => {
  res.json({
    servidor: 'activo',
    baseDeDatos: 'pendiente de conectar'
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Servidor iniciado en http://localhost:${PORT}`);
  console.log('Presiona Ctrl + C para detenerlo');
});
