# ShopNow - Inicio rápido

## Requisitos
- [Node.js](https://nodejs.org/) (para el backend)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (para la app)

## Base de datos (Neon)
Ya configurada en `.env.local`:
```
NEON_AUTH_BASE_URL=https://ep-wild-cherry-b56ee0s6.neonauth.c-7.us-east-2.aws.neon.tech/neondb/auth
```

## Cómo iniciar el proyecto (Backend + Flutter)

Desde la carpeta `ShopNow\ShopNow\`, ejecuta uno de estos scripts:

### Windows (PowerShell) — recomendado
```powershell
.\start.ps1
```

### Windows (CMD)
```cmd
start.bat
```

### Mac / Linux
```bash
./start.sh
```

## Qué hace el script
1. Verifica que Node.js y Flutter estén instalados.
2. Instala las dependencias del backend (`npm install` en `backend/`) si faltan.
3. Inicia el servidor backend en `http://localhost:3000`.
4. Espera a que el backend responda.
5. Lanza `flutter run`.
6. Cuando cierras Flutter, el backend se detiene automáticamente.

## Puerto de la app
La app Flutter (web) corre en `http://localhost:61609` (puerto asignado por Flutter) y se conecta al backend en `http://localhost:3000`.

## Usuario de prueba (ya creado en Neon)
- Correo: `emersonarleyvalencia@gmail.com`
- Contraseña: `Arley.006`

## Solución de problemas
- Si el backend no inicia, ejecuta `npm install` dentro de `ShopNow\ShopNow\backend\` y vuelve a intentar.
- Si Flutter no encuentra `flutter`, asegúrate de que el SDK esté en tu PATH.
- Si ves error de CORS, el backend ya incluye `cors()` permitiendo todas las origens.
