const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

function getUsers() {
    try {
        const raw = process.env.SARVITA_USERS_JSON || '[]';
        const users = JSON.parse(raw);
        return Array.isArray(users) ? users : [];
    } catch {
        return [];
    }
}

function signToken(user) {
    const secret = process.env.SARVITA_JWT_SECRET;

    if (!secret) {
        throw new Error('SARVITA_JWT_SECRET is not configured');
    }

    return jwt.sign(
        {
            id: user.id,
            username: user.username,
            email: user.email
        },
        secret,
        {
            expiresIn: '7d'
        }
    );
}

function getCookieToken(req) {
    const cookies = String(req.headers.cookie || '');

    const match = cookies.match(
        /(?:^|;\s*)sarvita_token=([^;]+)/
    );

    return match ? decodeURIComponent(match[1]) : null;
}

function setAuthCookie(res, token) {
    res.setHeader(
        'Set-Cookie',
        `sarvita_token=${encodeURIComponent(token)}; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=604800`
    );
}

function clearAuthCookie(res) {
    res.setHeader(
        'Set-Cookie',
        'sarvita_token=; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=0'
    );
}

function json(res, status, data) {
    res.status(status).json(data);
}

module.exports = async function handler(req, res) {
    const action = String(
        req.query.action ||
        req.body?.action ||
        ''
    ).toLowerCase();

    if (req.method === 'OPTIONS') {
        res.setHeader('Access-Control-Allow-Origin', '*');
        res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
        res.setHeader('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
        return res.status(204).end();
    }

    if (action === 'login') {
        if (req.method !== 'POST') {
            return json(res, 405, {
                error: 'Method not allowed'
            });
        }

        const username = String(
            req.body?.username ||
            req.body?.email ||
            ''
        ).trim();

        const password = String(
            req.body?.password || ''
        );

        if (!username || !password) {
            return json(res, 400, {
                error: 'Username/email and password are required'
            });
        }

        const users = getUsers();

        const user = users.find((item) =>
            String(item.username || '').toLowerCase() === username.toLowerCase() ||
            String(item.email || '').toLowerCase() === username.toLowerCase()
        );

        if (!user) {
            return json(res, 401, {
                error: 'Invalid username or password'
            });
        }

        const valid = await bcrypt.compare(
            password,
            String(user.passwordHash || '')
        );

        if (!valid) {
            return json(res, 401, {
                error: 'Invalid username or password'
            });
        }

        const token = signToken(user);

        setAuthCookie(res, token);

        return json(res, 200, {
            ok: true,
            user: {
                id: user.id,
                username: user.username,
                email: user.email
            }
        });
    }

    if (action === 'me') {
        if (req.method !== 'GET') {
            return json(res, 405, {
                error: 'Method not allowed'
            });
        }

        const token = getCookieToken(req);

        if (!token) {
            return json(res, 401, {
                authenticated: false
            });
        }

        try {
            const payload = jwt.verify(
                token,
                process.env.SARVITA_JWT_SECRET
            );

            return json(res, 200, {
                authenticated: true,
                user: {
                    id: payload.id,
                    username: payload.username,
                    email: payload.email
                }
            });
        } catch {
            return json(res, 401, {
                authenticated: false
            });
        }
    }

    if (action === 'logout') {
        clearAuthCookie(res);

        return json(res, 200, {
            ok: true
        });
    }

    return json(res, 400, {
        error: 'Unknown auth action'
    });
};
