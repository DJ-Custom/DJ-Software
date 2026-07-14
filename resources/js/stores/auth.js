import { defineStore } from 'pinia';
import api from '../services/api';
import { getToken, setToken, getUser, setUser, clearAuth } from '../services/authToken';
import { useActivityTracker } from '../composables/useActivityTracker';
import router from '../router';

const activityTracker = useActivityTracker();

export const useAuthStore = defineStore('auth', {
    state: () => ({
        user: null,
        token: null,
        theme: localStorage.getItem('theme') || 'light',
        loading: false,
        checked: false,
    }),

    getters: {
        isAuthenticated: (state) => !!state.token,
        userName: (state) => state.user?.nombre || '',
        userRole: (state) => state.user?.rol_nombre || '',
        userInitials: (state) => {
            if (!state.user?.nombre) return '?';
            return state.user.nombre.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase();
        },
        hasModule: (state) => (modulo) => {
            if (state.user.rol_nombre === 'admin' || state.user.rol_nombre === 'Administrador') return true;
            const modulos = state.user?.modulos_acceso?.length ? state.user.modulos_acceso : (state.user?.permisos || []);
            if (!modulos || !modulos.length) return true;
            return modulos.includes(modulo);
        },
        hasPermission: (state) => (permiso) => {
            if (!state.user?.permisos) return false;
            if (state.user.rol_nombre === 'admin' || state.user.rol_nombre === 'Administrador') return true;
            return state.user.permisos.includes(permiso);
        },
    },

    actions: {
        async login(email, password) {
            this.loading = true;
            try {
                const { data } = await api.post('/login', { email, password });
                this.token = data.token;
                this.user = data.user;
                this.theme = data.user.theme_mode || 'light';
                setToken(data.token);
                setUser(data.user);
                localStorage.setItem('theme', this.theme);
                await activityTracker.start();
                router.push('/dashboard');
                return { success: true };
            } catch (error) {
                return { success: false, error: error.response?.data?.error || 'Error de conexion' };
            } finally {
                this.loading = false;
            }
        },

        async logout() {
            await activityTracker.stop();
            try {
                await api.post('/logout');
            } catch (e) {}
            this.token = null;
            this.user = null;
            clearAuth();
            router.push('/login');
        },

        forceLogout() {
            activityTracker.stop();
            const currentToken = getToken();
            if (currentToken) {
                try {
                    const data = new Blob([JSON.stringify({ token: currentToken })], { type: 'application/json' });
                    navigator.sendBeacon('/api/auth/invalidate-token', data);
                } catch (e) {}
            }
            this.token = null;
            this.user = null;
            clearAuth();
            if (window.Echo) {
                try { window.Echo.disconnect(); } catch (e) {}
            }
        },

        async checkAuth() {
            if (!this.token) return false;
            try {
                const { data } = await api.get('/auth/check');
                this.user = data.user;
                setUser(data.user);
                this.theme = data.user.theme_mode || this.theme;
                this.checked = true;
                await activityTracker.start();
                return true;
            } catch {
                this.token = null;
                this.user = null;
                clearAuth();
                this.checked = true;
                return false;
            }
        },

        async toggleTheme() {
            try {
                const { data } = await api.post('/auth/toggle-theme');
                this.theme = data.theme;
                localStorage.setItem('theme', this.theme);
            } catch {
                this.theme = this.theme === 'dark' ? 'light' : 'dark';
                localStorage.setItem('theme', this.theme);
            }
        },
    },
});
