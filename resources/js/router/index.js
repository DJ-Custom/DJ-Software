import { createRouter, createWebHistory } from 'vue-router';
import { useAuthStore } from '../stores/auth';

const routes = [
    {
        path: '/login',
        name: 'Login',
        component: () => import('../pages/Login.vue'),
        meta: { guest: true },
    },
    {
        path: '/',
        component: () => import('../layouts/AppLayout.vue'),
        meta: { auth: true },
        children: [
            { path: '', redirect: '/dashboard' },
            { path: 'dashboard', name: 'Dashboard', component: () => import('../pages/Dashboard.vue') },
            { path: 'ventas', name: 'Ventas', component: () => import('../pages/Ventas.vue') },
            { path: 'productos', name: 'Productos', component: () => import('../pages/Productos.vue') },
            { path: 'catalogo', name: 'Catalogo', component: () => import('../pages/Catalogo.vue') },
            { path: 'inventario-ubicacion', name: 'InventarioUbicacion', component: () => import('../pages/InventarioUbicacion.vue') },
            { path: 'clientes', name: 'Clientes', component: () => import('../pages/Clientes.vue') },
            { path: 'usuarios', name: 'Usuarios', component: () => import('../pages/Usuarios.vue') },
            { path: 'roles', name: 'Roles', component: () => import('../pages/Roles.vue') },
            { path: 'chats', name: 'Chats', component: () => import('../pages/Chats.vue') },
            { path: 'chats-cerrados', name: 'ChatsCerrados', component: () => import('../pages/ChatsCerrados.vue') },
            { path: 'notificaciones', name: 'Notificaciones', component: () => import('../pages/Notificaciones.vue') },
            { path: 'caja', name: 'Caja', component: () => import('../pages/Caja.vue') },
            { path: 'cotizaciones', name: 'Cotizaciones', component: () => import('../pages/Cotizaciones.vue') },
            { path: 'enviar-cotizacion', name: 'EnviarCotizacion', component: () => import('../pages/EnviarCotizacion.vue') },
            { path: 'pedidos', name: 'Pedidos', component: () => import('../pages/Pedidos.vue') },
            { path: 'compras', name: 'Compras', component: () => import('../pages/Compras.vue') },
            { path: 'proveedores', name: 'Proveedores', component: () => import('../pages/Proveedores.vue') },
            { path: 'devoluciones', name: 'Devoluciones', component: () => import('../pages/Devoluciones.vue') },
            { path: 'notas-credito', name: 'NotasCredito', component: () => import('../pages/NotasCredito.vue') },
            { path: 'traspasos', name: 'Traspasos', component: () => import('../pages/Traspasos.vue') },
            { path: 'ajustes-inventario', name: 'AjustesInventario', component: () => import('../pages/AjustesInventario.vue') },
            { path: 'combos', name: 'Combos', component: () => import('../pages/Combos.vue') },
            { path: 'reportes', name: 'Reportes', component: () => import('../pages/Reportes.vue') },
            { path: 'configuracion', name: 'Configuracion', component: () => import('../pages/Configuracion.vue') },
            { path: 'business-intelligence', name: 'BusinessIntelligence', component: () => import('../pages/BusinessIntelligence.vue') },
            { path: 'auditoria', name: 'Auditoria', component: () => import('../pages/Auditoria.vue') },
            { path: 'etiquetas', name: 'Etiquetas', component: () => import('../pages/Etiquetas.vue') },
            { path: 'productividad', name: 'Productividad', component: () => import('../pages/Productividad.vue') },
            { path: 'planilla', name: 'Planilla', component: () => import('../pages/Planilla.vue') },
            { path: 'email-builder', name: 'EmailBuilder', component: () => import('../pages/EmailCampaigns.vue') },
            { path: 'email-builder/new', name: 'EmailBuilderNew', component: () => import('../pages/EmailBuilder.vue') },
            { path: 'email-builder/edit/:id', name: 'EmailBuilderEdit', component: () => import('../pages/EmailBuilder.vue') },
            { path: 'email-builder/analytics/:id', name: 'EmailBuilderAnalytics', component: () => import('../pages/EmailAnalytics.vue') },
            { path: 'formularios', name: 'Formularios', component: () => import('../pages/Formularios.vue') },
            { path: 'crm', name: 'CRM', component: () => import('../pages/CRM.vue') },
            { path: 'tesoreria', name: 'Tesoreria', component: () => import('../pages/Tesoreria.vue') },
            { path: 'presupuestos', name: 'Presupuestos', component: () => import('../pages/Presupuestos.vue') },
            { path: 'facturacion-electronica', name: 'FacturacionElectronica', component: () => import('../pages/FacturacionElectronica.vue') },
            { path: 'ticket-designer', name: 'TicketDesigner', component: () => import('../pages/TicketDesigner.vue') },
            { path: 'cotizacion-designer', name: 'CotizacionDesigner', component: () => import('../pages/CotizacionDesigner.vue') },
            { path: 'geo-business', name: 'GeoBusiness', component: () => import('../pages/GeoBusiness.vue') },
            { path: 'rentabilidad', name: 'Rentabilidad', component: () => import('../pages/Rentabilidad.vue') },
            { path: 'cuentas-cobrar', name: 'CuentasCobrar', component: () => import('../pages/CuentasCobrar.vue') },
            { path: 'listas-precios', name: 'ListasPrecios', component: () => import('../pages/ListasPrecios.vue') },
            { path: 'contabilidad', name: 'Contabilidad', component: () => import('../pages/Contabilidad.vue') },
        ],
    },
    { path: '/:pathMatch(.*)*', redirect: '/dashboard' },
];

const router = createRouter({
    history: createWebHistory(),
    routes,
});

router.beforeEach(async (to, from, next) => {
    const auth = useAuthStore();

    if (to.meta.auth && !auth.isAuthenticated) {
        return next('/login');
    }

    if (to.meta.auth && auth.isAuthenticated && !auth.checked) {
        const ok = await auth.checkAuth();
        if (!ok) return next('/login');
    }

    if (to.meta.guest && auth.isAuthenticated) {
        return next('/dashboard');
    }

    next();
});

export default router;
