// api/index.js
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import express from 'express';
import bodyParser from 'body-parser';
import cookieSession from 'cookie-session';

// Reuse core modules from the project to preserve behaviour
import { initUserStorage, getCookieSecret, getCookieSessionName, setUserDataMiddleware, loginPageMiddleware } from '../src/users.js';
import { router as usersPublicRouter } from '../src/endpoints/users-public.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const serverDirectory = path.resolve(path.join(__dirname, '..'));

if (!globalThis.DATA_ROOT) {
  // Default data root inside repository so node-persist has a place to store data
  globalThis.DATA_ROOT = process.env.DATA_ROOT || path.join(serverDirectory, 'data');
}

let appPromise = null;

async function createApp() {
  const app = express();

  app.use(bodyParser.json({ limit: '50mb' }));
  app.use(bodyParser.urlencoded({ extended: true, limit: '50mb' }));

  // Basic cookie session using project's helpers
  app.use(cookieSession({
    name: getCookieSessionName(),
    sameSite: 'lax',
    httpOnly: true,
    maxAge: 24 * 60 * 60 * 1000,
    secret: getCookieSecret(globalThis.DATA_ROOT),
  }));

  // Initialize storage used by existing endpoints
  await initUserStorage(globalThis.DATA_ROOT);

  // Reuse middleware that attaches user data to requests
  app.use(setUserDataMiddleware);

  // Mount existing public user endpoints
  app.use('/api/users', usersPublicRouter);

  // Serve login page using project's middleware (preserves existing auto-login logic)
  app.get('/login', loginPageMiddleware);

  // Serve static assets from public/
  app.use(express.static(path.join(serverDirectory, 'public')));

  // Route for root to serve index.html (SPA)
  app.get('/', (req, res) => {
    return res.sendFile(path.join(serverDirectory, 'public', 'index.html'));
  });

  // Basic ping for health
  app.get('/api/ping', (req, res) => res.status(204).send());

  // Fallback 404
  app.use((req, res) => res.status(404).send('Not found'));

  return app;
}

async function getApp() {
  if (!appPromise) appPromise = createApp();
  return appPromise;
}

export default async function handler(req, res) {
  // Keep the health check independent from user-storage initialization so it
  // remains reliable in Vercel's ephemeral serverless runtime.
  if ((req.method === 'GET' || req.method === 'HEAD') && req.url?.split('?')[0] === '/api/ping') {
    return res.status(204).send();
  }

  const app = await getApp();
  return app(req, res);
}
