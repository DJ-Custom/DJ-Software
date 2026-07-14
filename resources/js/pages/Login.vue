<template>
  <div class="login-page" :data-theme="theme">
    <div class="login-bg">
      <div class="bg-blob blob-1"></div>
      <div class="bg-blob blob-2"></div>
      <div class="bg-blob blob-3"></div>
      <div class="bg-grid"></div>
    </div>

    <button class="theme-toggle" @click="toggleTheme" :title="theme === 'dark' ? 'Modo oscuro' : 'Modo claro'">
      <i :class="theme === 'dark' ? 'fas fa-moon' : 'fas fa-sun'"></i>
    </button>

    <div class="login-container">
      <div class="login-card" :class="{ 'success-state': loginSuccess }">
        <div class="login-header">
          <div class="login-logo">
            <img :src="theme === 'dark' ? '/images/logo-dark-theme.png' : '/images/logo-light-theme.png'" alt="Logo" class="logo-icon" />
          </div>
          <h1 class="login-title">Dreepo</h1>
        </div>

        <div v-if="loginSuccess" class="success-animation">
          <div class="success-checkmark">
            <i class="fas fa-check"></i>
          </div>
          <h2>{{ i18n.t('bienvenido') }}</h2>
          <p>{{ i18n.t('redirigiendo') }}</p>
        </div>

        <form v-else @submit.prevent="handleLogin" class="login-form">
          <div class="form-group">
            <label class="form-label">{{ i18n.t('correo_electronico') }}</label>
            <div class="input-icon-wrapper">
              <i class="fas fa-envelope"></i>
              <input
                v-model="email"
                type="email"
                class="form-control"
                placeholder="tu@email.com"
                required
                autofocus
              />
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">{{ i18n.t('contrasena') }}</label>
            <div class="input-icon-wrapper">
              <i class="fas fa-lock"></i>
              <input
                v-model="password"
                :type="showPassword ? 'text' : 'password'"
                class="form-control"
                placeholder="••••••••"
                required
              />
              <button type="button" class="password-toggle" @click="showPassword = !showPassword">
                <i :class="showPassword ? 'fas fa-eye-slash' : 'fas fa-eye'"></i>
              </button>
            </div>
          </div>

          <div v-if="errorMsg" class="login-error">
            <i class="fas fa-exclamation-circle"></i>
            {{ errorMsg }}
          </div>

          <button type="submit" class="btn btn-primary btn-lg w-full" :disabled="loading">
            <i v-if="loading" class="fas fa-spinner fa-spin"></i>
            <span v-else>{{ i18n.t('iniciar_sesion') }}</span>
          </button>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useAuthStore } from '../stores/auth';
import { useI18nStore } from '../stores/i18n';

const authStore = useAuthStore();
const i18n = useI18nStore();
const email = ref('');
const password = ref('');
const showPassword = ref(false);
const loading = ref(false);
const errorMsg = ref('');
const loginSuccess = ref(false);
const theme = ref(localStorage.getItem('theme') || 'light');

function toggleTheme() {
    theme.value = theme.value === 'dark' ? 'light' : 'dark';
    localStorage.setItem('theme', theme.value);
    document.documentElement.dataset.theme = theme.value;
    authStore.theme = theme.value;
}

onMounted(() => {
    document.documentElement.dataset.theme = theme.value;
});

async function handleLogin() {
    errorMsg.value = '';
    loading.value = true;

    const result = await authStore.login(email.value, password.value);

    if (result.success) {
        loginSuccess.value = true;
    } else {
        errorMsg.value = result.error;
    }
    loading.value = false;
}
</script>

<style scoped>
.login-page {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    background: var(--bg-primary);
    position: relative;
    overflow: hidden;
}

.login-bg {
    position: absolute;
    inset: 0;
    overflow: hidden;
}

.bg-blob {
    position: absolute;
    border-radius: 50%;
    filter: blur(80px);
    opacity: 0.3;
    animation: float 8s ease-in-out infinite;
}

.bg-blob.blob-1 {
    width: 400px; height: 400px;
    background: var(--gradient-main);
    top: -100px; right: -100px;
    animation-delay: 0s;
}

.bg-blob.blob-2 {
    width: 300px; height: 300px;
    background: var(--gold-light);
    bottom: -80px; left: -80px;
    animation-delay: 2s;
}

.bg-blob.blob-3 {
    width: 250px; height: 250px;
    background: var(--primary-dark);
    top: 50%; left: 50%;
    transform: translate(-50%, -50%);
    animation-delay: 4s;
}

.login-container {
    position: relative;
    z-index: 10;
    width: 100%;
    max-width: 440px;
    padding: 20px;
}

.login-card {
    background: var(--bg-card);
    border-radius: var(--radius-xl);
    padding: 48px 40px;
    box-shadow: var(--shadow-xl);
    backdrop-filter: blur(20px);
    animation: fadeInUp 0.6s ease;
}

.login-header {
    text-align: center;
    margin-bottom: 36px;
}

.login-logo {
    display: flex;
    justify-content: center;
    margin-bottom: 20px;
}

.logo-icon {
    width: 120px; height: 120px;
    object-fit: contain;
}

.login-title {
    font-size: clamp(20px, 4vw, 24px);
    font-weight: 800;
    color: var(--text-primary);
    letter-spacing: -0.5px;
}

.login-form {
    display: flex; flex-direction: column; gap: 4px;
}

.login-form .form-label {
    color: #374151;
    font-weight: 600;
}

[data-theme="dark"] .login-form .form-label {
    color: #d1d5db;
}

.login-form .input-icon-wrapper {
    position: relative;
}

.login-form .input-icon-wrapper .form-control {
    padding-left: 44px;
    padding-right: 44px;
}

.login-form .input-icon-wrapper > i {
    position: absolute;
    left: 14px; top: 50%;
    transform: translateY(-50%);
    color: #6b7280;
    font-size: 16px;
    transition: color var(--transition-fast);
}

.password-toggle {
    position: absolute;
    right: 12px; top: 50%;
    transform: translateY(-50%);
    background: none; border: none;
    color: #6b7280;
    cursor: pointer; font-size: 16px;
    padding: 4px;
    transition: color var(--transition-fast);
}

.password-toggle:hover {
    color: #0d496b;
}

.login-form .input-icon-wrapper .form-control {
    background: rgba(255, 255, 255, 0.7);
    border: 2px solid rgba(0, 0, 0, 0.08);
    color: #1a2332;
}

.login-form .input-icon-wrapper .form-control::placeholder {
    color: #9ca3af;
}

.login-form .input-icon-wrapper .form-control:focus {
    border-color: #0d496b;
    background: white;
    box-shadow: 0 0 0 3px rgba(13, 73, 107, 0.15);
}

[data-theme="dark"] .login-form .input-icon-wrapper > i {
    color: #9ca3af;
}

[data-theme="dark"] .login-form .input-icon-wrapper .form-control {
    background: rgba(255, 255, 255, 0.08);
    border: 2px solid rgba(255, 255, 255, 0.1);
    color: #e2e8f0;
}

[data-theme="dark"] .login-form .input-icon-wrapper .form-control::placeholder {
    color: #6b7280;
}

[data-theme="dark"] .login-form .input-icon-wrapper .form-control:focus {
    border-color: #408eb3;
    background: rgba(255, 255, 255, 0.12);
    box-shadow: 0 0 0 3px rgba(64, 142, 179, 0.25);
}

[data-theme="dark"] .password-toggle {
    color: #9ca3af;
}

[data-theme="dark"] .password-toggle:hover {
    color: #e2e8f0;
}

.login-error {
    background: var(--danger-bg);
    color: var(--danger);
    padding: 12px 16px;
    border-radius: var(--radius-md);
    font-size: 13px;
    display: flex; align-items: center; gap: 8px;
    margin-bottom: 8px;
    animation: fadeInUp 0.3s ease;
}

.success-animation {
    text-align: center;
    padding: 40px 0;
}

.success-checkmark {
    width: 80px; height: 80px;
    background: var(--success);
    border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    margin: 0 auto 20px;
    font-size: 36px; color: white;
    animation: scaleIn 0.5s var(--transition-bounce);
}

.success-animation h2 {
    font-size: clamp(18px, 3.5vw, 22px);
    font-weight: 700;
    color: var(--text-primary);
    margin-bottom: 8px;
}

.success-animation p {
    color: var(--text-secondary);
    font-size: clamp(13px, 2.5vw, 14px);
}

.theme-toggle {
    position: fixed;
    top: 20px;
    right: 20px;
    z-index: 100;
    width: 44px;
    height: 44px;
    border-radius: var(--radius-full);
    background: rgba(13, 73, 107, 0.9);
    backdrop-filter: blur(12px);
    border: 1px solid rgba(255, 255, 255, 0.15);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 18px;
    color: white;
    cursor: pointer;
    transition: all var(--transition-main);
    box-shadow: 0 4px 15px rgba(13, 73, 107, 0.3);
}

.theme-toggle:hover {
    background: #0d496b;
    color: #ffd700;
    transform: scale(1.1) rotate(15deg);
    box-shadow: 0 8px 25px rgba(13, 73, 107, 0.5);
}

.theme-toggle {
    position: fixed;
    top: 20px;
    right: 20px;
    z-index: 100;
    width: 44px;
    height: 44px;
    border-radius: var(--radius-full);
    background: rgba(13, 73, 107, 0.9);
    backdrop-filter: blur(12px);
    border: 1px solid rgba(255, 255, 255, 0.15);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 18px;
    color: white;
    cursor: pointer;
    transition: all var(--transition-main);
    box-shadow: 0 4px 15px rgba(13, 73, 107, 0.3);
}

.theme-toggle:hover {
    background: #0d496b;
    color: #ffd700;
    transform: scale(1.1) rotate(15deg);
    box-shadow: 0 8px 25px rgba(13, 73, 107, 0.5);
}

.login-footer {
    margin-top: 24px;
    text-align: center;
}

@media (max-width: 1023px) {
    .bg-blob.blob-1 {
        width: 320px; height: 320px;
        top: -80px; right: -80px;
    }

    .bg-blob.blob-2 {
        width: 240px; height: 240px;
        bottom: -60px; left: -60px;
    }

    .bg-blob.blob-3 {
        width: 200px; height: 200px;
    }
}

@media (max-width: 768px) {
    .bg-blob.blob-1 {
        width: 250px; height: 250px;
        top: -60px; right: -60px;
    }

    .bg-blob.blob-2 {
        width: 200px; height: 200px;
        bottom: -50px; left: -50px;
    }

    .bg-blob.blob-3 {
        width: 160px; height: 160px;
    }

    .login-container {
        padding: 16px;
    }

    .login-card {
        padding: 36px 28px;
    }

    .login-header {
        margin-bottom: 28px;
    }

    .login-logo {
        margin-bottom: 16px;
    }

    .logo-icon {
        width: 100px; height: 100px;
    }

    .login-title {
        font-size: clamp(18px, 3.5vw, 22px);
    }

    .form-label {
        font-size: 13px;
    }

    .login-form .input-icon-wrapper .form-control {
        padding: 10px 14px 10px 40px;
        font-size: 14px;
    }

    .password-toggle {
        right: 10px;
    }
}


@media (max-width: 480px) {
    .bg-blob.blob-1 {
        width: 180px; height: 180px;
        top: -40px; right: -40px;
        filter: blur(60px);
    }

    .bg-blob.blob-2 {
        width: 140px; height: 140px;
        bottom: -30px; left: -30px;
        filter: blur(60px);
    }

    .bg-blob.blob-3 {
        width: 120px; height: 120px;
        filter: blur(60px);
    }

    .login-container {
        padding: 12px;
        max-width: 100%;
    }

    .login-card {
        padding: 24px 16px;
        border-radius: var(--radius-lg);
    }

    .login-header {
        margin-bottom: 20px;
    }

    .login-logo {
        margin-bottom: 12px;
    }

    .logo-icon {
        width: 80px; height: 80px;
    }

    .login-title {
        font-size: 18px;
    }

    .form-label {
        font-size: 12px;
        margin-bottom: 2px;
    }

    .login-form .input-icon-wrapper .form-control {
        padding: 12px 14px 12px 38px;
        font-size: 16px;
        border-radius: var(--radius-md);
    }

    .login-form .input-icon-wrapper > i {
        left: 12px;
        font-size: 14px;
    }

    .password-toggle {
        right: 8px;
        padding: 8px;
        font-size: 18px;
    }

    .login-form {
        gap: 2px;
    }

    .btn-lg {
        padding: 12px 20px;
        font-size: 15px;
    }

    .login-error {
        padding: 10px 12px;
        font-size: 12px;
        border-radius: var(--radius-sm);
    }

    .success-animation {
        padding: 24px 0;
    }

    .success-checkmark {
        width: 64px; height: 64px;
        font-size: 28px;
        margin-bottom: 16px;
    }

    .success-animation h2 {
        font-size: 18px;
        margin-bottom: 4px;
    }

    .success-animation p {
        font-size: 12px;
    }

    .theme-toggle {
        top: 12px;
        right: 12px;
        width: 40px;
        height: 40px;
        font-size: 16px;
    }

    input,
    button,
    textarea {
        -webkit-tap-highlight-color: transparent;
    }

    input:focus,
    button:focus {
        outline: none;
    }
}
</style>
