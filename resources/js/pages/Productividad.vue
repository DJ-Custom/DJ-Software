<template>
  <div>
    <!-- Estado: Cargando -->
    <div v-if="isLoading" class="auth-state-container">
      <div class="auth-state-icon loading">
        <i class="fas fa-spinner fa-spin"></i>
      </div>
      <h3>{{ i18n.t('productividad_verificando_sesion') }}</h3>
    </div>

    <!-- Estado: No autenticado -->
    <div v-else-if="!isAuthenticated" class="auth-state-container">
      <div class="auth-state-icon offline">
        <i class="fas fa-user-lock"></i>
      </div>
      <h3>{{ i18n.t('productividad_sesion_no_activa') }}</h3>
      <p>{{ i18n.t('productividad_mensaje_no_auth') }}</p>
      <button class="btn btn-primary" @click="router.push('/login')">
        <i class="fas fa-sign-in-alt"></i> {{ i18n.t('productividad_ir_login') }}
      </button>
    </div>

    <!-- Estado: Autenticado - Mostrar datos -->
    <template v-else>
      <div class="flex items-center gap-sm mb-lg flex-wrap">
        <input v-model="desde" type="date" class="form-control" @change="cargar">
        <input v-model="hasta" type="date" class="form-control" @change="cargar">
        <button class="btn btn-primary btn-sm" @click="cargar"><i class="fas fa-sync"></i> {{ i18n.t('productividad_actualizar') }}</button>
      </div>

      <div class="stats-row">
        <div class="stat-card">
          <div class="stat-icon"><i class="fas fa-clock"></i></div>
          <div class="stat-content">
            <div class="stat-value">{{ formatTime(stats.totalMinutos) }}</div>
            <div class="stat-label">{{ i18n.t('productividad_horas_totales') }}</div>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon sales"><i class="fas fa-dollar-sign"></i></div>
          <div class="stat-content">
            <div class="stat-value">{{ fm(stats.totalVentas) }}</div>
            <div class="stat-label">{{ i18n.t('productividad_ventas_generadas') }}</div>
          </div>
        </div>
        <div class="stat-card">
          <div class="stat-icon users"><i class="fas fa-users"></i></div>
          <div class="stat-content">
            <div class="stat-value">{{ stats.usuariosEnLinea }}/{{ stats.totalUsuarios }}</div>
            <div class="stat-label">{{ i18n.t('productividad_en_linea') }}</div>
          </div>
        </div>
      </div>

      <div class="card">
        <div class="card-header"><h3 class="card-title"><i class="fas fa-user-clock"></i> {{ i18n.t('productividad') }}</h3></div>
        <div class="card-body" style="padding:0;">
          <div class="table-responsive">
          <table class="data-table">
            <thead>
            <tr>
              <th>{{ i18n.t('productividad_usuario') }}</th>
              <th>{{ i18n.t('productividad_estado') }}</th>
              <th>{{ i18n.t('productividad_horas_totales') }}</th>
              <th>{{ i18n.t('productividad_ventas_generadas') }}</th>
              <th>{{ i18n.t('productividad_cant_ventas') }}</th>
              <th>{{ i18n.t('productividad_promedio_sesion') }}</th>
            </tr>
            </thead>
            <tbody>
              <tr v-for="u in usuariosDisplay" :key="u.id">
                <td>
                  <strong>{{ u.nombre }}</strong>
                  <div style="font-size:11px;color:var(--text-muted);">{{ u.email }}</div>
                </td>
                <td>
                  <span v-if="u.en_linea && !u.en_pausa" class="badge badge-success">
                    <i class="fas fa-circle" style="font-size:6px;vertical-align:middle;margin-right:4px;"></i>
                    {{ i18n.t('productividad_estado_activo') }}
                  </span>
                  <span v-else-if="u.en_linea && u.en_pausa" class="badge badge-warning">
                    <i class="fas fa-pause-circle" style="font-size:10px;vertical-align:middle;margin-right:4px;"></i>
                    {{ i18n.t('productividad_estado_pausa') }}
                  </span>
                  <span v-else class="badge badge-secondary">
                    <i class="fas fa-circle" style="font-size:6px;vertical-align:middle;margin-right:4px;"></i>
                    {{ i18n.t('productividad_offline') }}
                  </span>
                </td>
                <td>
                  <span :class="{'live-pulse': u.en_linea && !u.en_pausa}" style="font-weight:600;">
                    {{ formatTime(u.total_minutos) }}
                  </span>
                  <span v-if="u.en_linea && !u.en_pausa" class="live-dot" :title="i18n.t('productividad_sesion_activa')"></span>
                </td>
                <td style="font-weight:700;color:var(--success);">{{ fm(u.ventas_generadas) }}</td>
                <td>{{ u.cantidad_ventas }}</td>
                <td>{{ fm(u.promedio_por_sesion) }}</td>
              </tr>
            </tbody>
          </table>
          </div>
          <div v-if="!usuariosDisplay.length" style="text-align:center;color:var(--text-muted);padding:30px;">
            {{ i18n.t('productividad_sin_datos') }}
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import api from '../services/api';
import { useI18nStore } from '../stores/i18n';
import { useCurrency } from '../composables/useCurrency';
import { useAuthStore } from '../stores/auth';

const i18n = useI18nStore();
const { fm } = useCurrency();
const router = useRouter();
const authStore = useAuthStore();
const desde = ref(new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().split('T')[0]);
const hasta = ref(new Date().toISOString().split('T')[0]);
const usuariosRaw = ref([]);
const tick = ref(0);
const isLoading = ref(true);
const isAuthenticated = ref(false);

function formatTime(minutes) {
  if (!minutes || minutes <= 0) return '0m';
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  if (h === 0) return `${m}m`;
  return `${h}h ${m < 10 ? '0' : ''}${m}m`;
}

async function verificarAutenticacion() {
  try {
    if (!authStore.isAuthenticated) {
      isAuthenticated.value = false;
      isLoading.value = false;
      return false;
    }
    const { data } = await api.get('/auth/check');
    isAuthenticated.value = data.authenticated === true;
    return isAuthenticated.value;
  } catch (e) {
    isAuthenticated.value = false;
    return false;
  }
}

async function cargar() {
  if (!isAuthenticated.value) return;
  try {
    const { data } = await api.get('/productividad', { params: { desde: desde.value, hasta: hasta.value } });
    usuariosRaw.value = data.usuarios || [];
  } catch (e) {
    if (e.response?.status === 401) {
      isAuthenticated.value = false;
    }
  }
}

const usuariosDisplay = computed(() => {
  const now = Date.now();
  return usuariosRaw.value.map(u => {
    if (!u.en_linea || !u.ultima_actividad || u.en_pausa) {
      return { ...u };
    }
    const ultima = new Date(u.ultima_actividad).getTime();
    const diffSec = Math.max(0, Math.floor((now - ultima) / 1000));
    const extraMin = diffSec < 60 ? Math.ceil(diffSec / 60) : 0;
    const totalMin = (u.total_minutos || 0) + extraMin;
    return {
      ...u,
      total_minutos: totalMin,
    };
  });
});

const stats = computed(() => {
  const display = usuariosDisplay.value;
  return {
    totalMinutos: display.reduce((sum, u) => sum + (u.total_minutos || 0), 0),
    totalVentas: display.reduce((sum, u) => sum + (u.ventas_generadas || 0), 0),
    usuariosEnLinea: display.filter(u => u.en_linea).length,
    totalUsuarios: display.length,
  };
});

let refreshTimer = null;
onMounted(async () => {
  const autenticado = await verificarAutenticacion();
  if (autenticado) {
    await cargar();
    refreshTimer = setInterval(() => {
      tick.value++;
      cargar();
    }, 60000);
  }
  isLoading.value = false;
});

onUnmounted(() => {
  if (refreshTimer) clearInterval(refreshTimer);
});
</script>

<style scoped>
.table-responsive {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

.auth-state-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  text-align: center;
}
.auth-state-container h3 {
  margin: 16px 0 8px;
  font-size: 18px;
  font-weight: 600;
  color: var(--text);
}
.auth-state-container p {
  margin: 0 0 20px;
  font-size: 14px;
  color: var(--text-muted);
  max-width: 400px;
}
.auth-state-icon {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
}
.auth-state-icon.loading {
  background: rgba(59, 130, 246, 0.1);
  color: #3b82f6;
}
.auth-state-icon.offline {
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
}
.stats-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}
.stat-card {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 18px 20px;
  background: var(--card-bg);
  border: 1px solid var(--border);
  border-radius: 12px;
  transition: transform 0.15s ease, box-shadow 0.15s ease;
}
.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.06);
}
.stat-icon {
  width: 44px;
  height: 44px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  background: rgba(59, 130, 246, 0.1);
  color: #3b82f6;
  flex-shrink: 0;
}
.stat-icon.sales {
  background: rgba(16, 185, 129, 0.1);
  color: #10b981;
}
.stat-icon.users {
  background: rgba(245, 158, 11, 0.1);
  color: #f59e0b;
}
.stat-content {
  display: flex;
  flex-direction: column;
}
.stat-value {
  font-size: 20px;
  font-weight: 700;
  line-height: 1.2;
  color: var(--text);
}
.stat-label {
  font-size: 12px;
  color: var(--text-muted);
  margin-top: 2px;
}
.live-dot {
  display: inline-block;
  width: 8px;
  height: 8px;
  background: #10b981;
  border-radius: 50%;
  margin-left: 6px;
  animation: live-blink 1.5s infinite;
}
@keyframes live-blink {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.3; }
}
.live-pulse {
  animation: text-pulse 2s infinite;
}
@keyframes text-pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.85; }
}
.badge {
  display: inline-flex;
  align-items: center;
  padding: 3px 10px;
  border-radius: 12px;
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.3px;
}
.badge-success {
  background: rgba(16, 185, 129, 0.12);
  color: #10b981;
}
.badge-warning {
  background: rgba(245, 158, 11, 0.12);
  color: #f59e0b;
}
.badge-secondary {
  background: rgba(107, 114, 128, 0.12);
  color: #6b7280;
}

@media (max-width: 768px) {
  .stats-row {
    grid-template-columns: 1fr;
  }
  
  .stat-card {
    padding: 14px 16px;
  }
  
  .stat-value {
    font-size: clamp(16px, 4vw, 20px);
  }
  
  .stat-icon {
    width: 40px;
    height: 40px;
    font-size: 16px;
  }
  
  .form-control {
    min-height: 44px;
  }
  
  .btn {
    min-height: 44px;
    min-width: 44px;
  }
  
  .table-responsive {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
  }
  
  .auth-state-container {
    padding: 40px 16px;
  }
  
  .auth-state-icon {
    width: 60px;
    height: 60px;
    font-size: 24px;
  }
}

@media (max-width: 480px) {
  .flex.items-center.gap-sm.mb-lg.flex-wrap {
    flex-direction: column;
    align-items: stretch;
  }
  
  .flex.items-center.gap-sm.mb-lg.flex-wrap > * {
    min-width: 100%;
  }
  
  .card-body {
    padding: 8px;
  }
  
  .stat-label {
    font-size: clamp(11px, 2.5vw, 12px);
  }
  
  .badge {
    font-size: clamp(10px, 2vw, 11px);
  }
  
  .live-dot {
    width: 6px;
    height: 6px;
  }
}
</style>
