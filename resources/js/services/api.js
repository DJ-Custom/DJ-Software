import axios from 'axios';
import router from '../router';
import { getToken, clearAuth } from './authToken';

const api = axios.create({
    baseURL: '/api',
    headers: {
        'Accept': 'application/json',
    },
});

const pendingRequests = new Map();

function getRequestKey(config) {
    const method = config.method?.toLowerCase() || 'get';
    const url = config.url || '';
    if (!['post', 'put', 'patch', 'delete'].includes(method)) {
        return null;
    }
    let key = `${method}:${url}`;
    if (config.data && !(config.data instanceof FormData)) {
        try {
            const raw = JSON.stringify(config.data);
            key += ':' + raw.length + ':' + raw.substring(0, 80);
        } catch (e) {}
    } else if (config.data instanceof FormData) {
        const entries = [];
        config.data.forEach((value, k) => {
            if (value instanceof File) {
                entries.push(`${k}=${value.name}:${value.size}`);
            } else {
                entries.push(`${k}=${value}`);
            }
        });
        key += ':formdata:' + entries.join('&');
    }
    return key;
}

function generateIdempotencyKey() {
    return `${Date.now()}-${Math.random().toString(36).substring(2, 11)}`;
}

api.interceptors.request.use((config) => {
    const token = getToken();
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    if (window.Echo?.socketId()) {
        config.headers['X-Socket-ID'] = window.Echo.socketId();
    }

    const key = getRequestKey(config);
    if (key) {
        if (pendingRequests.has(key)) {
            const prev = pendingRequests.get(key);
            if (prev && typeof prev.abort === 'function') {
                prev.abort('Duplicate request cancelled');
            }
        }
        const controller = new AbortController();
        config.signal = controller.signal;
        pendingRequests.set(key, controller);

        if (!config.headers['Idempotency-Key']) {
            config.headers['Idempotency-Key'] = generateIdempotencyKey();
        }
    }

    return config;
});

api.interceptors.response.use(
    (response) => {
        const key = getRequestKey(response.config);
        if (key && pendingRequests.has(key)) {
            pendingRequests.delete(key);
        }
        return response;
    },
    (error) => {
        if (error.config) {
            const key = getRequestKey(error.config);
            if (key && pendingRequests.has(key)) {
                pendingRequests.delete(key);
            }
        }

        if (error.name === 'CanceledError' || error.name === 'AbortError' || axios.isCancel?.(error)) {
            return Promise.reject(error);
        }

        if (error.response?.status === 401) {
            clearAuth();
            window.dispatchEvent(new CustomEvent('auth:logout'));
            router.push('/login');
        }
        return Promise.reject(error);
    }
);

export default api;
