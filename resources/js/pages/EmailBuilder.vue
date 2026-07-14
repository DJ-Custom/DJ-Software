<template>
  <div class="email-builder-page" :data-theme="currentTheme">
    <!-- ===== TOPBAR ===== -->
    <div class="builder-topbar">
      <div class="topbar-left">
        <button class="tb-icon" @click="goBack" :title="i18n.t('email_builder_volver')"><i class="fas fa-arrow-left"></i></button>
        <div class="tb-fields">
          <input v-model="nombre" class="tb-name" :placeholder="i18n.t('email_builder_nombre_campana')">
          <input v-model="asunto" class="tb-subject" :placeholder="i18n.t('email_builder_asunto_correo')">
        </div>
      </div>

      <div class="topbar-center">
        <div class="device-bar">
          <span class="device-label">{{ i18n.t('email_builder_vista') }}</span>
          <button class="d-btn" :class="{ active: device === 'desktop' }" @click="setDevice('desktop')" :title="i18n.t('email_builder_desktop')"><i class="fas fa-desktop"></i> Desktop</button>
          <button class="d-btn" :class="{ active: device === 'tablet' }" @click="setDevice('tablet')" :title="i18n.t('email_builder_tablet')"><i class="fas fa-tablet-alt"></i> Tablet</button>
          <button class="d-btn" :class="{ active: device === 'mobile' }" @click="setDevice('mobile')" :title="i18n.t('email_builder_mobile')"><i class="fas fa-mobile-alt"></i> Mobile</button>
        </div>
      </div>

      <div class="topbar-right">
        <button class="tb-btn" @click="showTemplates = true" :title="i18n.t('email_builder_plantillas')"><i class="fas fa-layer-group"></i> {{ i18n.t('email_builder_plantillas') }}</button>
        <div class="mode-toggle" :class="{ advanced: modoAvanzado }" @click="modoAvanzado = !modoAvanzado" :title="i18n.t('configurar')">
          <span class="mode-knob"></span>
          <span class="mode-text">{{ modoAvanzado ? i18n.t('email_builder_avanzado') : i18n.t('email_builder_simple') }}</span>
        </div>
        <button class="tb-icon" @click="undo" :title="i18n.t('email_builder_deshacer')"><i class="fas fa-undo"></i></button>
        <button class="tb-icon" @click="redo" :title="i18n.t('email_builder_rehacer')"><i class="fas fa-redo"></i></button>
        <button class="tb-btn" @click="openPreview" :title="i18n.t('email_builder_vista_previa')"><i class="fas fa-eye"></i></button>
        <button class="tb-btn tb-save" @click="saveCampaign" :disabled="isSaving"><i class="fas fa-save"></i> {{ isSaving ? i18n.t('cargando') : (templateId ? i18n.t('email_builder_guardar_plantilla') : i18n.t('guardar')) }}</button>
        <button v-if="!templateId" class="tb-btn tb-send" @click="prepareAndSend" :disabled="isSaving"><i class="fas fa-paper-plane"></i> {{ i18n.t('email_builder_enviar') }}</button>
      </div>
    </div>

    <!-- ===== BODY ===== -->
    <div class="builder-body">
      <!-- Left: Blocks -->
      <div class="panel-left">
        <div class="left-header">
          <i class="fas fa-plus-circle"></i>
          <span>{{ i18n.t('email_builder_agregar_elementos') }}</span>
        </div>
        <div class="left-sub">{{ i18n.t('email_builder_arrastre_elemento') }}</div>

        <div class="blocks-grid">
          <div v-for="b in visibleBlocks" :key="b.id" class="block-card" draggable="true" @dragstart="onDragStart($event, b)" @click="addBlock(b)">
            <div class="block-icon"><i :class="b.icon"></i></div>
            <div class="block-title">{{ b.label }}</div>
            <div class="block-desc">{{ b.desc }}</div>
          </div>
        </div>
      </div>

      <!-- Center: Canvas -->
      <div class="panel-center" @dragover.prevent @drop="onCanvasDrop">
        <div class="sheet-wrapper" :class="device">
          <div ref="editorContainer" class="editor-area"></div>
        </div>

        <div v-if="!hasContent" class="empty-overlay">
          <div class="empty-box">
            <div class="empty-illustration">
              <i class="fas fa-envelope-open-text"></i>
            </div>
            <h3>{{ i18n.t('email_builder_correo_vacio') }}</h3>
            <p>{{ i18n.t('email_builder_arrastre_disenar') }}</p>
            <div class="empty-hint">
              <span><i class="fas fa-hand-pointer"></i> {{ i18n.t('email_builder_tambien_clic') }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Right: Simple editor (only when selected) -->
      <transition name="slide">
        <div v-if="selectedEl && showRightPanel" class="panel-right">
          <div class="right-header">
            <span><i class="fas fa-paint-brush"></i> {{ i18n.t('email_builder_editar') }} {{ selectedTypeLabel }}</span>
            <button class="close-right" @click="showRightPanel = false"><i class="fas fa-times"></i></button>
          </div>

          <!-- Text controls -->
          <div v-if="selectedType === 'text'" class="prop-group">
            <div class="prop-row">
              <label>{{ i18n.t('email_builder_texto') }}</label>
              <textarea v-model="selTextContent" class="prop-input" rows="3" @input="updateTextContent"></textarea>
            </div>
            <div class="prop-row">
              <label>{{ i18n.t('email_builder_fuente') }}</label>
              <select v-model="selStyles.fontFamily" class="prop-select" @change="updateStyle('font-family', selStyles.fontFamily)">
                <option value="Arial, sans-serif">Arial</option>
                <option value="Georgia, serif">Georgia</option>
                <option value="'Times New Roman', serif">Times New Roman</option>
                <option value="'Segoe UI', sans-serif">Segoe UI</option>
                <option value="Verdana, sans-serif">Verdana</option>
              </select>
            </div>
            <div class="prop-row">
              <label>{{ i18n.t('email_builder_tamano') }}</label>
              <select v-model="selStyles.fontSize" class="prop-select" @change="updateStyle('font-size', selStyles.fontSize)">
                <option value="12px">{{ i18n.t('email_builder_pequeno') }}</option>
                <option value="14px">{{ i18n.t('email_builder_normal_label') }}</option>
                <option value="16px">{{ i18n.t('email_builder_mediano') }}</option>
                <option value="20px">{{ i18n.t('email_builder_grande') }}</option>
                <option value="24px">{{ i18n.t('email_builder_muy_grande') }}</option>
                <option value="32px">{{ i18n.t('email_builder_titulo_label') }}</option>
              </select>
            </div>
            <div class="prop-row">
              <label>{{ i18n.t('email_builder_color_label') }}</label>
              <div class="color-row">
                <input type="color" v-model="selStyles.color" @input="updateStyle('color', selStyles.color)">
                <span>{{ selStyles.color }}</span>
              </div>
            </div>
            <div class="prop-row">
              <label>{{ i18n.t('email_builder_alineacion') }}</label>
              <div class="align-btns">
                <button :class="{ active: selStyles.textAlign === 'left' }" @click="updateStyle('text-align', 'left')"><i class="fas fa-align-left"></i></button>
                <button :class="{ active: selStyles.textAlign === 'center' }" @click="updateStyle('text-align', 'center')"><i class="fas fa-align-center"></i></button>
                <button :class="{ active: selStyles.textAlign === 'right' }" @click="updateStyle('text-align', 'right')"><i class="fas fa-align-right"></i></button>
              </div>
            </div>
            <div class="prop-row">
              <label>{{ i18n.t('email_builder_estilo') }}</label>
              <div class="toggle-row">
                <button :class="{ active: selStyles.fontWeight === 'bold' }" @click="toggleBold"><i class="fas fa-bold"></i> {{ i18n.t('email_builder_negrita') }}</button>
                <button :class="{ active: selStyles.fontStyle === 'italic' }" @click="toggleItalic"><i class="fas fa-italic"></i> {{ i18n.t('email_builder_cursiva') }}</button>
              </div>
            </div>
          </div>

          <!-- Image controls -->
          <div v-else-if="selectedType === 'image'" class="prop-group">
            <div class="prop-row">
              <label>{{ i18n.t('email_builder_url_imagen') }}</label>
              <input v-model="selAttributes.src" class="prop-input" @change="updateAttribute('src', selAttributes.src)">
            </div>
            <div class="prop-row">
              <label>{{ i18n.t('email_builder_texto_alternativo') }}</label>
              <input v-model="selAttributes.alt" class="prop-input" @change="updateAttribute('alt', selAttributes.alt)">
            </div>
            <div class="prop-row">
              <label>{{ i18n.t('email_builder_enlace_opcional') }}</label>
              <input v-model="selAttributes.href" class="prop-input" placeholder="https://..." @change="wrapLink('href', selAttributes.href)">
            </div>
            <div class="prop-row">
              <label>{{ i18n.t('email_builder_ancho') }}</label>
              <input type="range" min="20" max="100" v-model="selWidthPct" @input="updateWidth" class="prop-range">
              <span class="range-val">{{ selWidthPct }}%</span>
            </div>
            <div class="prop-row">
              <label>{{ i18n.t('email_builder_bordes_redondeados') }}</label>
              <input type="range" min="0" max="24" v-model="selStyles.borderRadius" @input="updateStyle('border-radius', selStyles.borderRadius + 'px')" class="prop-range">
              <span class="range-val">{{ selStyles.borderRadius }}px</span>
            </div>
          </div>

          <!-- Button controls -->
          <div v-else-if="selectedType === 'button'" class="prop-group">
            <div class="prop-row">
              <label>{{ i18n.t('email_builder_texto_boton') }}</label>
              <input v-model="selTextContent" class="prop-input" @input="updateTextContent">
            </div>
            <div class="prop-row">
              <label>{{ i18n.t('email_builder_enlace_label') }}</label>
              <input v-model="selAttributes.href" class="prop-input" placeholder="https://..." @change="updateLink('href', selAttributes.href)">
            </div>
            <div class="prop-row">
              <label>{{ i18n.t('email_builder_color_fondo') }}</label>
              <div class="color-row">
                <input type="color" v-model="selStyles.backgroundColor" @input="updateStyle('background-color', selStyles.backgroundColor)">
                <span>{{ selStyles.backgroundColor }}</span>
              </div>
            </div>
            <div class="prop-row">
              <label>{{ i18n.t('email_builder_color_texto') }}</label>
              <div class="color-row">
                <input type="color" v-model="selStyles.color" @input="updateStyle('color', selStyles.color)">
                <span>{{ selStyles.color }}</span>
              </div>
            </div>
            <div class="prop-row">
              <label>{{ i18n.t('email_builder_redondeo') }}</label>
              <input type="range" min="0" max="32" v-model="selStyles.borderRadius" @input="updateStyle('border-radius', selStyles.borderRadius + 'px')" class="prop-range">
              <span class="range-val">{{ selStyles.borderRadius }}px</span>
            </div>
            <div class="prop-row">
              <label>Padding</label>
              <input type="range" min="4" max="32" v-model="selStyles.padding" @input="updateStyle('padding', selStyles.padding + 'px ' + (selStyles.padding * 2) + 'px')" class="prop-range">
              <span class="range-val">{{ selStyles.padding }}px</span>
            </div>
          </div>

          <!-- Section / Container controls -->
          <div v-else class="prop-group">
            <div class="prop-row">
              <label>{{ i18n.t('email_builder_fondo') }}</label>
              <div class="color-row">
                <input type="color" v-model="selStyles.backgroundColor" @input="updateStyle('background-color', selStyles.backgroundColor)">
                <span>{{ selStyles.backgroundColor }}</span>
              </div>
            </div>
            <div class="prop-row">
              <label>{{ i18n.t('email_builder_espacio_arriba') }}</label>
              <input type="range" min="0" max="60" v-model="selStyles.paddingTop" @input="updateStyle('padding-top', selStyles.paddingTop + 'px')" class="prop-range">
              <span class="range-val">{{ selStyles.paddingTop }}px</span>
            </div>
            <div class="prop-row">
              <label>{{ i18n.t('email_builder_espacio_abajo') }}</label>
              <input type="range" min="0" max="60" v-model="selStyles.paddingBottom" @input="updateStyle('padding-bottom', selStyles.paddingBottom + 'px')" class="prop-range">
              <span class="range-val">{{ selStyles.paddingBottom }}px</span>
            </div>
          </div>

          <!-- Common actions -->
          <div class="prop-actions">
            <button class="pa-btn" @click="duplicateSelected"><i class="fas fa-copy"></i> {{ i18n.t('duplicar') }}</button>
            <button class="pa-btn danger" @click="deleteSelected"><i class="fas fa-trash"></i> {{ i18n.t('eliminar') }}</button>
          </div>
        </div>
      </transition>
    </div>

    <!-- ===== PREVIEW MODAL ===== -->
    <teleport to="body">
      <div v-if="showPreview" class="preview-overlay" @click.self="showPreview = false">
        <div class="preview-box">
          <div class="pv-header">
            <div class="pv-title">
              <i class="fas fa-eye"></i>
              <div>
                <h4>{{ i18n.t('email_builder_vista_previa') }}</h4>
                <p>{{ i18n.t('email_builder_vista_previa_sub') }}</p>
              </div>
            </div>
            <div class="pv-devices">
              <button :class="{ active: previewDevice === 'desktop' }" @click="previewDevice = 'desktop'"><i class="fas fa-desktop"></i> Desktop</button>
              <button :class="{ active: previewDevice === 'tablet' }" @click="previewDevice = 'tablet'"><i class="fas fa-tablet-alt"></i> Tablet</button>
              <button :class="{ active: previewDevice === 'mobile' }" @click="previewDevice = 'mobile'"><i class="fas fa-mobile-alt"></i> Mobile</button>
            </div>
            <button class="pv-close" @click="showPreview = false"><i class="fas fa-times"></i></button>
          </div>
          <div class="pv-body">
            <div class="pv-frame" :class="previewDevice">
              <iframe :srcdoc="previewSrcdoc" frameborder="0"></iframe>
            </div>
            <div class="pv-caption">{{ previewCaption }}</div>
          </div>
        </div>
      </div>
    </teleport>

    <!-- ===== TEMPLATES MODAL ===== -->
    <teleport to="body">
      <div v-if="showTemplates" class="preview-overlay" @click.self="showTemplates = false">
        <div class="preview-box preview-box-responsive">
          <div class="pv-header">
            <div class="pv-title"><i class="fas fa-layer-group"></i><h4>{{ i18n.t('email_builder_plantillas') }}</h4></div>
            <button class="pv-close" @click="showTemplates = false"><i class="fas fa-times"></i></button>
          </div>
          <div class="pv-body" style="padding:20px;">
            <!-- Predefinidas -->
            <p style="margin:0 0 12px;color:var(--text-muted);font-size:13px;font-weight:600;">{{ i18n.t('email_builder_predefinidas') }}</p>
            <p style="margin:0 0 16px;color:var(--text-muted);font-size:13px;">{{ i18n.t('email_builder_seleccionar_plantilla') }}</p>
            <div class="templates-grid-simple" style="margin-bottom:24px;">
              <div v-for="t in predefinedTemplates" :key="t.id" class="tmpl-card" @click="loadTemplate(t)">
                <div class="tmpl-preview" :style="{ background: t.thumbBg }">
                  <i :class="t.icon" :style="{ color: t.thumbColor }"></i>
                </div>
                <div class="tmpl-name">{{ t.name }}</div>
                <div class="tmpl-desc">{{ t.desc }}</div>
              </div>
            </div>

            <!-- Guardadas -->
            <template v-if="savedTemplates.length">
              <p style="margin:0 0 12px;color:var(--text-muted);font-size:13px;font-weight:600;">{{ i18n.t('email_builder_guardadas') }}</p>
              <div class="templates-grid-simple">
                <div v-for="t in savedTemplates" :key="t.id" class="tmpl-card" @click="loadSavedTemplate(t)">
                  <div class="tmpl-preview" style="background:linear-gradient(135deg,#3b82f6,#1e40af);">
                    <i class="fas fa-save" style="color:#fff;"></i>
                  </div>
                  <div class="tmpl-name">{{ t.nombre }}</div>
                  <div class="tmpl-desc">{{ t.categoria || i18n.t('plantillas_email_general') }}</div>
                </div>
              </div>
            </template>
            <div v-else style="text-align:center;color:var(--text-muted);padding:16px;font-size:13px;">
              {{ i18n.t('email_builder_no_guardadas') }}
            </div>
          </div>
        </div>
      </div>
    </teleport>

    <!-- ===== SEND MODAL ===== -->
    <EmailSendModal
      v-if="showSendModal"
      :campaign-id="campaignId"
      :asunto="asunto"
      @close="showSendModal = false"
      @sent="onSent"
    />
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, nextTick, computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import api from '../services/api';
import { useToastStore } from '../stores/toast';
import { useI18nStore } from '../stores/i18n';
import { useSubmitLock } from '../composables/useSubmitLock';
import EmailSendModal from '../components/EmailSendModal.vue';

const toast = useToastStore();
const i18n = useI18nStore();
const { isSubmitting: isSaving, execute: executeSave } = useSubmitLock({ loadingText: i18n.t('email_builder_guardando_campana') });
import grapesjs from 'grapesjs';

const route = useRoute();
const router = useRouter();

const editorContainer = ref(null);
const editor = ref(null);

const device = ref('desktop');
const nombre = ref('');
const asunto = ref('');
const campaignId = ref(route.params.id ? parseInt(route.params.id) : null);
const templateId = ref(route.query.template ? parseInt(route.query.template) : null);
const modoAvanzado = ref(false);
const currentTheme = ref('light');
const hasContent = ref(false);

const showPreview = ref(false);
const previewDevice = ref('desktop');
const previewSrcdoc = ref('');
const showTemplates = ref(false);
const showSendModal = ref(false);
const savedTemplates = ref([]);

function onSent(data) {
  showSendModal.value = false;
}

async function cargarPlantillasGuardadas() {
  try {
    const { data } = await api.get('/email-builder/templates');
    savedTemplates.value = data.templates?.data || [];
  } catch (e) {
    savedTemplates.value = [];
  }
}

import { watch } from 'vue';
watch(showTemplates, (val) => {
  if (val) cargarPlantillasGuardadas();
});

// Selection state
const selectedEl = ref(false);
const showRightPanel = ref(true);
const selectedType = ref('');
const selectedTypeLabel = ref('');
const selTextContent = ref('');
const selAttributes = ref({ src: '', alt: '', href: '' });
const selStyles = ref({ fontFamily: 'Arial', fontSize: '16px', color: '#1a2332', textAlign: 'left', fontWeight: 'normal', fontStyle: 'normal', backgroundColor: '#ffffff', borderRadius: 0, padding: 10, paddingTop: 20, paddingBottom: 20 });
const selWidthPct = ref(100);

function detectTheme() {
  const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
  currentTheme.value = isDark ? 'dark' : 'light';
}
const observer = new MutationObserver(detectTheme);

// All blocks
const allBlocks = computed(() => [
  { id: 'header', label: i18n.t('email_builder_bloques'), desc: i18n.t('email_builder_tus_datos'), icon: 'fas fa-heading', category: 'basico', content: '<table width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#ffffff;"><tr><td style="padding:28px 20px;text-align:center;"><h1 style="margin:0;font-family:Arial,sans-serif;color:#1a2332;font-size:22px;">Tu Empresa</h1><p style="margin:4px 0 0;font-family:Arial,sans-serif;color:#64748b;font-size:13px;">Eslogan</p></td></tr></table>' },
  { id: 'hero', label: i18n.t('email_builder_imagen'), desc: i18n.t('email_builder_imagen'), icon: 'fas fa-image', category: 'avanzado', content: '<table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding:0;text-align:center;"><img src="https://via.placeholder.com/600x280/3b82f6/ffffff?text=Banner" style="max-width:100%;display:block;" alt="Banner"></td></tr></table>' },
  { id: 'text', label: i18n.t('email_builder_texto'), desc: i18n.t('email_builder_texto'), icon: 'fas fa-paragraph', category: 'basico', content: '<table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding:20px;font-family:Arial,sans-serif;font-size:16px;line-height:1.7;color:#374151;"><p style="margin:0;">Escribe aquí tu mensaje. Haz doble clic para editar el contenido.</p></td></tr></table>' },
  { id: 'image', label: i18n.t('email_builder_imagen'), desc: i18n.t('email_builder_imagen'), icon: 'fas fa-camera', category: 'basico', content: '<table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding:0;text-align:center;"><img src="https://via.placeholder.com/600x320/e2e8f0/475569?text=Tu+Imagen" style="max-width:100%;display:block;border-radius:8px;" alt="Imagen"></td></tr></table>' },
  { id: 'button', label: i18n.t('email_builder_boton'), desc: i18n.t('email_builder_boton'), icon: 'fas fa-mouse-pointer', category: 'basico', content: '<table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding:20px;text-align:center;"><a href="#" style="display:inline-block;padding:14px 32px;background:#3b82f6;color:#ffffff;text-decoration:none;border-radius:8px;font-family:Arial,sans-serif;font-size:15px;font-weight:600;">Click aquí</a></td></tr></table>' },
  { id: '2cols', label: i18n.t('email_builder_columnas'), desc: i18n.t('email_builder_columnas'), icon: 'fas fa-columns', category: 'avanzado', content: '<table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td width="50%" valign="top" style="padding:16px;"><p style="margin:0;font-family:Arial,sans-serif;font-size:14px;color:#374151;">Columna izquierda</p></td><td width="50%" valign="top" style="padding:16px;"><p style="margin:0;font-family:Arial,sans-serif;font-size:14px;color:#374151;">Columna derecha</p></td></tr></table>' },
  { id: 'divider', label: i18n.t('email_builder_divisor'), desc: i18n.t('email_builder_divisor'), icon: 'fas fa-minus', category: 'basico', content: '<table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding:12px 20px;"><div style="border-top:1px solid #e2e8f0;"></div></td></tr></table>' },
  { id: 'video', label: i18n.t('email_builder_video'), desc: i18n.t('email_builder_video'), icon: 'fas fa-play-circle', category: 'avanzado', content: '<table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding:20px;text-align:center;"><div style="background:#1a2332;border-radius:12px;height:200px;display:flex;align-items:center;justify-content:center;"><i class="fas fa-play" style="color:#fff;font-size:32px;"></i></div></td></tr></table>' },
  { id: 'social', label: i18n.t('email_builder_sociales'), desc: i18n.t('email_builder_sociales'), icon: 'fas fa-share-alt', category: 'avanzado', content: '<table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding:20px;text-align:center;"><a href="#" style="margin:0 6px;"><img src="https://cdn.simpleicons.org/facebook/1877F2" width="28" style="border-radius:50%;" alt="FB"></a><a href="#" style="margin:0 6px;"><img src="https://cdn.simpleicons.org/instagram/E4405F" width="28" style="border-radius:50%;" alt="IG"></a></td></tr></table>' },
  { id: 'footer', label: i18n.t('email_builder_divisor'), desc: i18n.t('email_builder_divisor'), icon: 'fas fa-copyright', category: 'basico', content: '<table width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#f8fafc;"><tr><td style="padding:24px 20px;text-align:center;font-family:Arial,sans-serif;font-size:12px;color:#94a3b8;"><p style="margin:0 0 6px;">© 2026 Tu Empresa</p><p style="margin:0;"><a href="#" style="color:#64748b;text-decoration:underline;">Desuscribirse</a></p></td></tr></table>' },
  { id: 'spacer', label: i18n.t('email_builder_espaciado'), desc: i18n.t('email_builder_espaciado'), icon: 'fas fa-arrows-alt-v', category: 'basico', content: '<table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding:30px 20px;"></td></tr></table>' },
  { id: 'product', label: i18n.t('producto'), desc: i18n.t('producto'), icon: 'fas fa-tag', category: 'avanzado', content: '<table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding:16px;"><table width="100%" cellpadding="0" cellspacing="0" border="0" style="border:1px solid #e2e8f0;border-radius:12px;overflow:hidden;"><tr><td style="padding:16px;text-align:center;"><img src="https://via.placeholder.com/180x180/f1f5f9/94a3b8?text=Producto" style="max-width:100%;border-radius:10px;margin-bottom:10px;" alt=""><h4 style="margin:0 0 4px;font-family:Arial,sans-serif;font-size:16px;color:#1e293b;">Producto</h4><span style="font-family:Arial,sans-serif;font-size:18px;font-weight:700;color:#10b981;">₡0.00</span><br><br><a href="#" style="display:inline-block;padding:8px 20px;background:#3b82f6;color:#fff;text-decoration:none;border-radius:6px;font-family:Arial,sans-serif;font-size:13px;">Comprar</a></td></tr></table></td></tr></table>' },
]);

const visibleBlocks = computed(() => {
  if (modoAvanzado.value) return allBlocks.value;
  return allBlocks.value.filter(b => b.category === 'basico');
});

const previewCaption = computed(() => {
  const map = {
    desktop: i18n.t('email_builder_desktop') + ' — Full width',
    tablet: i18n.t('email_builder_tablet') + ' — Medium width',
    mobile: i18n.t('email_builder_mobile') + ' — Reduced width'
  };
  return map[previewDevice.value];
});

const predefinedTemplates = [
  { id: 'promo', name: 'Promoción', desc: 'Oferta destacada con banner y botón', icon: 'fas fa-percent', thumbBg: 'linear-gradient(135deg,#f59e0b,#ef4444)', thumbColor: '#fff' },
  { id: 'welcome', name: 'Bienvenida', desc: 'Saludo personal con imagen', icon: 'fas fa-hand-sparkles', thumbBg: 'linear-gradient(135deg,#3b82f6,#8b5cf6)', thumbColor: '#fff' },
  { id: 'news', name: 'Noticias', desc: 'Boletín con texto e imágenes', icon: 'fas fa-newspaper', thumbBg: 'linear-gradient(135deg,#10b981,#059669)', thumbColor: '#fff' },
  { id: 'product', name: 'Producto', desc: 'Destacar un artículo', icon: 'fas fa-shopping-bag', thumbBg: 'linear-gradient(135deg,#6366f1,#a855f7)', thumbColor: '#fff' },
  { id: 'event', name: 'Evento', desc: 'Invitación con detalles', icon: 'fas fa-calendar-star', thumbBg: 'linear-gradient(135deg,#ec4899,#f43f5e)', thumbColor: '#fff' },
];

// Template HTML maps
const templateHtml = {
  promo: '<table width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#fff;"><tr><td style="padding:32px 24px;text-align:center;background:linear-gradient(135deg,#f59e0b,#ef4444);"><h2 style="margin:0 0 8px;font-family:Arial,sans-serif;color:#fff;font-size:26px;">¡Oferta Especial!</h2><p style="margin:0 0 20px;font-family:Arial,sans-serif;color:rgba(255,255,255,0.9);font-size:16px;">Aprovecha hasta 50% de descuento</p><a href="#" style="display:inline-block;padding:14px 32px;background:#fff;color:#ef4444;text-decoration:none;border-radius:8px;font-family:Arial,sans-serif;font-size:15px;font-weight:700;">Ver oferta</a></td></tr></table><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding:24px;font-family:Arial,sans-serif;font-size:15px;line-height:1.7;color:#374151;"><p style="margin:0;">No dejes pasar esta oportunidad única. Válido por tiempo limitado.</p></td></tr></table>',
  welcome: '<table width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#fff;"><tr><td style="padding:24px;text-align:center;"><img src="https://via.placeholder.com/120/3b82f6/ffffff?text=Logo" style="border-radius:50%;margin-bottom:16px;" alt=""><h2 style="margin:0 0 8px;font-family:Arial,sans-serif;color:#1a2332;font-size:24px;">¡Bienvenido!</h2><p style="margin:0;font-family:Arial,sans-serif;color:#64748b;font-size:15px;">Gracias por unirte a nosotros.</p></td></tr></table><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding:20px;font-family:Arial,sans-serif;font-size:15px;line-height:1.7;color:#374151;"><p style="margin:0;">Estamos emocionados de tenerte con nosotros. Explora todo lo que tenemos para ofrecerte.</p></td></tr></table><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding:0 20px 24px;text-align:center;"><a href="#" style="display:inline-block;padding:12px 28px;background:#3b82f6;color:#fff;text-decoration:none;border-radius:8px;font-family:Arial,sans-serif;font-size:14px;font-weight:600;">Comenzar ahora</a></td></tr></table>',
  news: '<table width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#fff;"><tr><td style="padding:24px;"><h2 style="margin:0 0 12px;font-family:Arial,sans-serif;color:#1a2332;font-size:22px;">Últimas noticias</h2><p style="margin:0 0 16px;font-family:Arial,sans-serif;color:#64748b;font-size:14px;">Resumen semanal</p></td></tr></table><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding:0 24px 16px;"><img src="https://via.placeholder.com/600x220/e2e8f0/475569?text=Noticia" style="max-width:100%;display:block;border-radius:8px;" alt=""></td></tr></table><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding:0 24px 24px;font-family:Arial,sans-serif;font-size:15px;line-height:1.7;color:#374151;"><p style="margin:0;">Mantente informado con las últimas actualizaciones de nuestra empresa.</p></td></tr></table>',
  product: '<table width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#fff;"><tr><td style="padding:24px;text-align:center;"><h2 style="margin:0 0 16px;font-family:Arial,sans-serif;color:#1a2332;font-size:22px;">Producto Destacado</h2><img src="https://via.placeholder.com/280x280/f1f5f9/94a3b8?text=Producto" style="max-width:100%;border-radius:12px;margin-bottom:14px;" alt=""><h3 style="margin:0 0 6px;font-family:Arial,sans-serif;font-size:18px;color:#1e293b;">Nombre del producto</h3><p style="margin:0 0 14px;font-family:Arial,sans-serif;font-size:14px;color:#64748b;">Descripción corta del producto.</p><span style="font-family:Arial,sans-serif;font-size:22px;font-weight:700;color:#10b981;">₡0.00</span><br><br><a href="#" style="display:inline-block;padding:12px 28px;background:#3b82f6;color:#fff;text-decoration:none;border-radius:8px;font-family:Arial,sans-serif;font-size:14px;font-weight:600;">Comprar ahora</a></td></tr></table>',
  event: '<table width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#fff;"><tr><td style="padding:32px 24px;text-align:center;background:linear-gradient(135deg,#ec4899,#f43f5e);"><h2 style="margin:0 0 8px;font-family:Arial,sans-serif;color:#fff;font-size:26px;">¡Te invitamos!</h2><p style="margin:0;font-family:Arial,sans-serif;color:rgba(255,255,255,0.9);font-size:16px;">No te pierdas este evento especial</p></td></tr></table><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding:24px;font-family:Arial,sans-serif;font-size:15px;line-height:1.7;color:#374151;"><p style="margin:0 0 16px;"><strong>Fecha:</strong> 15 de junio, 2026<br><strong>Hora:</strong> 7:00 PM<br><strong>Lugar:</strong> Centro de Convenciones</p><p style="margin:0;">Reserva tu lugar hoy mismo.</p></td></tr></table><table width="100%" cellpadding="0" cellspacing="0" border="0"><tr><td style="padding:0 24px 24px;text-align:center;"><a href="#" style="display:inline-block;padding:12px 28px;background:#ec4899;color:#fff;text-decoration:none;border-radius:8px;font-family:Arial,sans-serif;font-size:14px;font-weight:600;">Confirmar asistencia</a></td></tr></table>',
};

async function initEditor() {
  await nextTick();
  detectTheme();

  const gjs = grapesjs.init({
    container: editorContainer.value,
    height: '100%',
    width: 'auto',
    storageManager: false,
    canvas: {
      styles: ['https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css'],
    },
    panels: { defaults: [] },
    blockManager: { blocks: [] },
    styleManager: false,
    layerManager: false,
    selectorManager: false,
    traitManager: false,
    deviceManager: {
      devices: [
        { name: 'Desktop', width: '' },
        { name: 'Tablet', width: '768px', widthMedia: '991px' },
        { name: 'Mobile', width: '375px', widthMedia: '575px' }
      ]
    },
  });

  editor.value = gjs;
  gjs.getConfig().forceClass = false;

  // Listen for selection
  gjs.on('component:selected', (model) => {
    selectedEl.value = true;
    showRightPanel.value = true;
    syncSelection(model);
  });
  gjs.on('component:deselected', () => {
    selectedEl.value = false;
  });
  gjs.on('component:add', () => { hasContent.value = true; });
  gjs.on('component:remove', () => {
    hasContent.value = gjs.getWrapper().components().length > 0;
  });

  // Load campaign
  if (campaignId.value) {
    try {
      const { data } = await api.get(`/email-builder/campaigns/${campaignId.value}`);
      const camp = data.campaign;
      nombre.value = camp.nombre || '';
      asunto.value = camp.asunto || '';
      let cargado = false;
      if (camp.json_content) {
        try {
          const jsonStr = typeof camp.json_content === 'string' ? camp.json_content : JSON.stringify(camp.json_content);
          const parsed = JSON.parse(jsonStr);
          if (parsed && (parsed.components || parsed.styles)) {
            gjs.loadProjectData(parsed);
            cargado = true;
          }
        } catch (parseErr) {
          console.warn('Error cargando json_content, fallback a html_content', parseErr);
        }
      }
      if (!cargado && camp.html_content) {
        gjs.setComponents(camp.html_content);
        cargado = true;
      }
      hasContent.value = cargado;
      if (cargado) {
        gjs.refresh();
        await nextTick();
      }
    } catch (e) {
      toast.error(i18n.t('email_builder_error_cargar_campana'));
      console.error(e);
    }
  }

  // Load template (from query param)
  if (templateId.value && !campaignId.value) {
    try {
      const { data } = await api.get(`/email-builder/templates/${templateId.value}`);
      const t = data.template;
      if (t) {
        nombre.value = t.nombre || '';
        asunto.value = t.asunto || '';
        if (t.json_content) {
          try {
            const jsonStr = typeof t.json_content === 'string' ? t.json_content : JSON.stringify(t.json_content);
            const parsed = JSON.parse(jsonStr);
            if (parsed && (parsed.components || parsed.styles)) {
              gjs.loadProjectData(parsed);
              hasContent.value = true;
            }
          } catch (parseErr) {
            console.warn('Error cargando json_content de plantilla, fallback a html_content', parseErr);
            if (t.html_content) { gjs.setComponents(t.html_content); hasContent.value = true; }
          }
        } else if (t.html_content) {
          gjs.setComponents(t.html_content);
          hasContent.value = true;
        }
        if (hasContent.value) {
          gjs.refresh();
          await nextTick();
        }
      }
    } catch (e) {
      toast.error(i18n.t('email_builder_error_cargar_plantilla'));
      console.error(e);
    }
  }

  applyTheme(currentTheme.value === 'dark');
}

function applyTheme(isDark) {
  const gjs = editor.value;
  if (!gjs) return;
  const body = gjs.Canvas.getBody();
  if (body) {
    // Emails siempre se diseñan sobre fondo blanco (como se ven en clientes de correo)
    body.style.backgroundColor = '#ffffff';
  }
  // Forzar fondo blanco en el wrapper de GrapesJS también
  const wrapper = gjs.Canvas.getWrapperEl();
  if (wrapper) {
    wrapper.style.backgroundColor = '#ffffff';
  }
}

function onDragStart(e, blk) { e.dataTransfer.setData('text/html', blk.content); }
function onCanvasDrop(e) {
  e.preventDefault();
  const html = e.dataTransfer.getData('text/html');
  if (html && editor.value) {
    editor.value.getWrapper().components().add(html);
    hasContent.value = true;
  }
}
function addBlock(blk) {
  if (!editor.value) return;
  editor.value.getWrapper().components().add(blk.content);
  hasContent.value = true;
}

function setDevice(dev) {
  device.value = dev;
  if (!editor.value) return;
  const map = { desktop: 'Desktop', tablet: 'Tablet', mobile: 'Mobile' };
  editor.value.DeviceManager.select(map[dev]);
}
function undo() { editor.value?.Commands.run('core:undo'); }
function redo() { editor.value?.Commands.run('core:redo'); }

function syncSelection(model) {
  const tag = model.get('tagName')?.toLowerCase() || '';
  const classes = model.getClasses() || [];
  let type = 'section';
  let label = i18n.t('email_builder_seccion');

  if (tag === 'img') { type = 'image'; label = i18n.t('email_builder_imagen'); }
  else if (tag === 'a' || (tag === 'table' && classes.includes('btn'))) { type = 'button'; label = i18n.t('email_builder_boton'); }
  else if (tag === 'p' || tag === 'h1' || tag === 'h2' || tag === 'h3' || tag === 'h4' || tag === 'span' || tag === 'div') { type = 'text'; label = i18n.t('email_builder_texto'); }

  const parent = model.parent();
  if (parent) {
    const pTag = parent.get('tagName')?.toLowerCase() || '';
    if (pTag === 'a' && type === 'text') { type = 'button'; label = 'Botón'; }
  }

  selectedType.value = type;
  selectedTypeLabel.value = label;

  const st = model.getStyle() || {};
  selStyles.value = {
    fontFamily: st['font-family'] || 'Arial, sans-serif',
    fontSize: st['font-size'] || '16px',
    color: st['color'] || '#1a2332',
    textAlign: st['text-align'] || 'left',
    fontWeight: st['font-weight'] || 'normal',
    fontStyle: st['font-style'] || 'normal',
    backgroundColor: st['background-color'] || '#ffffff',
    borderRadius: parseInt(st['border-radius']) || 0,
    padding: parseInt(st['padding']) || 10,
    paddingTop: parseInt(st['padding-top']) || 20,
    paddingBottom: parseInt(st['padding-bottom']) || 20,
  };

  const attrs = model.getAttributes() || {};
  selAttributes.value = {
    src: attrs.src || '',
    alt: attrs.alt || '',
    href: attrs.href || '',
  };

  selTextContent.value = model.getInnerHTML ? model.getInnerHTML() : (model.get('content') || '');

  const w = model.getStyle()['width'];
  selWidthPct.value = w ? parseInt(w) : 100;
}

function updateStyle(prop, val) {
  const sel = editor.value?.getSelected();
  if (!sel) return;
  sel.addStyle({ [prop]: val });
}
function updateAttribute(attr, val) {
  const sel = editor.value?.getSelected();
  if (!sel) return;
  sel.addAttributes({ [attr]: val });
}
function updateTextContent() {
  const sel = editor.value?.getSelected();
  if (!sel) return;
  sel.set('content', selTextContent.value);
}
function toggleBold() {
  const sel = editor.value?.getSelected();
  if (!sel) return;
  const isBold = selStyles.value.fontWeight === 'bold';
  selStyles.value.fontWeight = isBold ? 'normal' : 'bold';
  sel.addStyle({ 'font-weight': selStyles.value.fontWeight });
}
function toggleItalic() {
  const sel = editor.value?.getSelected();
  if (!sel) return;
  const isItalic = selStyles.value.fontStyle === 'italic';
  selStyles.value.fontStyle = isItalic ? 'normal' : 'italic';
  sel.addStyle({ 'font-style': selStyles.value.fontStyle });
}
function updateWidth() {
  const sel = editor.value?.getSelected();
  if (!sel) return;
  sel.addStyle({ 'width': selWidthPct.value + '%', 'max-width': '100%' });
}
function wrapLink(attr, val) {
  const sel = editor.value?.getSelected();
  if (!sel) return;
  if (val) {
    sel.addAttributes({ [attr]: val });
  }
}
function updateLink(attr, val) {
  const sel = editor.value?.getSelected();
  if (!sel) return;
  sel.addAttributes({ [attr]: val });
}
function duplicateSelected() {
  const sel = editor.value?.getSelected();
  if (!sel) return;
  const clone = sel.clone();
  sel.parent().append(clone);
}
function deleteSelected() {
  const sel = editor.value?.getSelected();
  if (!sel) return;
  sel.remove();
  selectedEl.value = false;
}

function buildSavePayload() {
  const html = editor.value.getHtml();
  const css = editor.value.getCss();
  const projectData = editor.value.getProjectData();
  let json = JSON.stringify(projectData);
  if (json.includes('"data:')) {
    json = json.replace(/"src"\s*:\s*"data:[^"]*"/g, '"src":""');
  }
  const fullHtml = `<!DOCTYPE html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><style>${css}</style></head><body>${html}</body></html>`;
  return { fullHtml, json };
}

async function prepareAndSend() {
  if (templateId.value) { toast.error(i18n.t('email_builder_no_enviar_plantilla')); return; }
  if (!nombre.value) { toast.error(i18n.t('email_builder_ingresar_nombre')); return; }
  if (!asunto.value) { toast.error(i18n.t('email_builder_ingresar_asunto')); return; }
  if (!campaignId.value) {
    try {
      await executeSave(async () => {
        const { fullHtml, json } = buildSavePayload();
        const { data } = await api.post('/email-builder/campaigns', { nombre: nombre.value, asunto: asunto.value, html_content: fullHtml, json_content: json });
        campaignId.value = data.campaign.id;
        toast.success(i18n.t('email_builder_campana_guardada'));
      });
    } catch (e) {
      toast.error(i18n.t('email_builder_error_guardar_enviar'));
      return;
    }
  } else {
    await saveCampaign();
  }
  showSendModal.value = true;
}

async function saveCampaign() {
  if (!nombre.value?.trim()) { toast.error(i18n.t('email_builder_ingresar_nombre_guardar')); return; }
  try {
    await executeSave(async () => {
      const { fullHtml, json } = buildSavePayload();

      if (templateId.value) {
        await api.put(`/email-builder/templates/${templateId.value}`, { nombre: nombre.value.trim(), asunto: asunto.value, html_content: fullHtml, json_content: json });
        toast.success(i18n.t('email_builder_plantilla_actualizada'));
      } else if (campaignId.value) {
        await api.put(`/email-builder/campaigns/${campaignId.value}`, { nombre: nombre.value.trim(), asunto: asunto.value, html_content: fullHtml, json_content: json });
        toast.success(i18n.t('email_builder_campana_actualizada'));
      } else {
        const { data } = await api.post('/email-builder/campaigns', { nombre: nombre.value.trim(), asunto: asunto.value, html_content: fullHtml, json_content: json });
        campaignId.value = data.campaign.id;
        toast.success(i18n.t('email_builder_campana_creada'));
      }
    });
  } catch (e) {
    if (e.name === 'CanceledError' || e.name === 'AbortError') {
      toast.warning(i18n.t('email_builder_solicitud_cancelada'));
      return;
    }
    console.error('Save error:', e);
    if (e.response?.status === 429) {
      toast.warning('La solicitud ya está siendo procesada. Por favor espere.');
    } else if (e.response?.status === 422) {
      const msg = e.response?.data?.error || e.response?.data?.message || i18n.t('email_builder_datos_invalidos');
      toast.error(msg);
    } else if (e.response?.status) {
      const msg = e.response?.data?.error || e.response?.data?.message || `${i18n.t('email_builder_error_servidor')} (${e.response.status})`;
      toast.error(msg);
    } else {
      toast.error(e.message || i18n.t('error_guardar'));
    }
  }
}

function openPreview() {
  const html = editor.value.getHtml();
  const css = editor.value.getCss();
  const isDark = currentTheme.value === 'dark';
  const bg = isDark ? '#0f172a' : '#f1f5f9';
  const emailBg = isDark ? '#1e293b' : '#ffffff';
  previewSrcdoc.value = `<!DOCTYPE html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{background:${bg};margin:0;padding:20px;display:flex;justify-content:center;min-height:100vh;font-family:Arial,sans-serif;}#email{width:100%;max-width:600px;background:${emailBg};border-radius:12px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.1);}${css}</style></head><body><div id="email">${html}</div></body></html>`;
  showPreview.value = true;
  previewDevice.value = device.value;
}

function loadTemplate(t) {
  if (!editor.value) return;
  const html = templateHtml[t.id];
  if (html) {
    editor.value.setComponents(html);
    hasContent.value = true;
    showTemplates.value = false;
  }
}

function loadSavedTemplate(t) {
  if (!editor.value) return;
  templateId.value = t.id;
  campaignId.value = null;
  nombre.value = t.nombre || '';
  asunto.value = t.asunto || '';
  let loaded = false;
  if (t.json_content) {
    try {
      const jsonStr = typeof t.json_content === 'string' ? t.json_content : JSON.stringify(t.json_content);
      const parsed = JSON.parse(jsonStr);
      if (parsed && (parsed.components || parsed.styles)) {
        editor.value.loadProjectData(parsed);
        loaded = true;
      }
    } catch (e) {
      console.warn('Error cargando json de plantilla', e);
    }
  }
  if (!loaded && t.html_content) {
    const bodyMatch = t.html_content.match(/<body[^>]*>([\s\S]*)<\/body>/i);
    const content = bodyMatch ? bodyMatch[1] : t.html_content;
    editor.value.setComponents(content);
    loaded = true;
  }
  editor.value.refresh();
  hasContent.value = loaded;
  showTemplates.value = false;
  router.push({ path: '/email-builder', query: { template: String(t.id) } });
}

function goBack() {
  try {
    if (editor.value) {
      editor.value.destroy();
      editor.value = null;
    }
  } catch (e) { /* ignore */ }
  router.push('/email-builder');
}

onMounted(() => { initEditor(); observer.observe(document.documentElement, { attributes: true, attributeFilter: ['data-theme'] }); });
onBeforeUnmount(() => {
  observer.disconnect();
  try {
    if (editor.value) {
      editor.value.destroy();
      editor.value = null;
    }
  } catch (e) { /* ignore destroy errors */ }
});
</script>

<style scoped>
/* ===== Layout ===== */
.email-builder-page { position: fixed; inset: 0; z-index: 1000; display: flex; flex-direction: column; background: var(--bg-body, #f1f5f9); font-family: var(--font-main, Inter, sans-serif); }

/* ===== Topbar ===== */
.builder-topbar { display: flex; align-items: center; justify-content: space-between; padding: 10px 18px; background: rgba(255,255,255,0.92); backdrop-filter: blur(20px) saturate(180%); border-bottom: 1px solid rgba(0,0,0,0.05); flex-shrink: 0; gap: 12px; }
[data-theme="dark"] .builder-topbar { background: rgba(15,23,42,0.95); border-bottom-color: rgba(255,255,255,0.06); }

.topbar-left { display: flex; align-items: center; gap: 12px; flex: 1; min-width: 0; }
.topbar-center { display: flex; align-items: center; }
.topbar-right { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }

.tb-icon { width: 36px; min-width: 36px; height: 36px; border-radius: 10px; background: var(--bg-input, #f5f5f5); border: none; color: var(--text-secondary, #475569); font-size: 14px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all 0.2s; }
.tb-icon:hover { background: var(--bg-hover, rgba(0,0,0,0.04)); color: var(--primary-dark, #0d496b); transform: translateY(-1px); }

.tb-fields { display: flex; flex-direction: column; gap: 3px; min-width: 0; }
.tb-name { background: transparent; border: 1px solid transparent; border-radius: 6px; padding: 4px 8px; font-size: 14px; font-weight: 600; color: var(--text-primary, #1a2332); width: 220px; max-width: 100%; transition: all 0.2s; font-family: var(--font-main); }
.tb-name:focus { outline: none; border-color: var(--primary-gold, #1f5f7c); background: var(--bg-input); }
.tb-subject { background: transparent; border: 1px solid transparent; border-radius: 6px; padding: 3px 8px; font-size: 12px; color: var(--text-muted, #64748b); width: 220px; max-width: 100%; transition: all 0.2s; font-family: var(--font-main); }
.tb-subject:focus { outline: none; border-color: var(--primary-gold); background: var(--bg-input); }

.device-bar { display: flex; align-items: center; gap: 2px; padding: 3px; background: var(--bg-input, #f5f5f5); border-radius: 10px; }
.device-label { font-size: 11px; color: var(--text-muted, #94a3b8); padding: 0 6px; font-weight: 500; }
.d-btn { display: flex; align-items: center; gap: 5px; padding: 6px 12px; border: none; border-radius: 8px; background: transparent; color: var(--text-muted, #94a3b8); font-size: 12px; font-weight: 500; cursor: pointer; transition: all 0.2s; white-space: nowrap; }
.d-btn.active { background: var(--bg-card); color: var(--primary-dark, #0d496b); box-shadow: var(--shadow-sm); }
[data-theme="dark"] .d-btn.active { background: #1e293b; color: #e2e8f0; }

.tb-btn { display: flex; align-items: center; gap: 5px; padding: 7px 14px; border: none; border-radius: 10px; background: transparent; color: var(--text-secondary, #475569); font-size: 12px; font-weight: 600; cursor: pointer; transition: all 0.2s; white-space: nowrap; }
.tb-btn:hover { background: var(--bg-hover); color: var(--primary-dark); }
.tb-btn.tb-save { background: var(--gradient-main); color: #fff; box-shadow: 0 2px 8px rgba(13,73,107,0.25); }
.tb-btn.tb-save:hover { transform: translateY(-1px); box-shadow: 0 4px 14px rgba(13,73,107,0.35); }
.tb-btn.tb-send { background: linear-gradient(135deg,#10b981,#059669); color: #fff; box-shadow: 0 2px 8px rgba(16,185,129,0.25); }
.tb-btn.tb-send:hover { transform: translateY(-1px); box-shadow: 0 4px 14px rgba(16,185,129,0.35); }

.mode-toggle { display: flex; align-items: center; gap: 6px; padding: 4px 10px 4px 4px; background: var(--bg-input); border-radius: 20px; cursor: pointer; transition: all 0.3s; border: 1px solid transparent; }
.mode-toggle:hover { border-color: var(--primary-gold); }
.mode-knob { width: 16px; height: 16px; border-radius: 50%; background: var(--primary-gold); transition: transform 0.3s; }
.mode-toggle.advanced .mode-knob { transform: translateX(4px); background: var(--danger, #ef4444); }
.mode-text { font-size: 11px; font-weight: 600; color: var(--text-muted); }

/* ===== Body ===== */
.builder-body { display: flex; flex: 1; overflow: hidden; }

/* ===== Left Panel ===== */
.panel-left { width: 230px; flex-shrink: 0; background: rgba(255,255,255,0.95); backdrop-filter: blur(20px); border-right: 1px solid rgba(0,0,0,0.05); display: flex; flex-direction: column; padding: 16px; gap: 10px; overflow-y: auto; }
[data-theme="dark"] .panel-left { background: rgba(15,23,42,0.97); border-right-color: rgba(255,255,255,0.06); }

.left-header { display: flex; align-items: center; gap: 8px; font-size: 14px; font-weight: 700; color: var(--text-primary, #1a2332); }
[data-theme="dark"] .left-header { color: #e2e8f0; }
.left-header i { color: var(--primary-gold, #1f5f7c); font-size: 16px; }
.left-sub { font-size: 11px; color: var(--text-muted, #94a3b8); margin-top: -6px; }

.blocks-grid { display: grid; grid-template-columns: 1fr; gap: 8px; margin-top: 4px; }
.block-card { display: flex; flex-direction: column; align-items: center; gap: 6px; padding: 14px 10px; background: var(--bg-input, #f5f5f5); border: 1px solid transparent; border-radius: 12px; cursor: grab; transition: all 0.2s cubic-bezier(0.4,0,0.2,1); text-align: center; }
.block-card:hover { border-color: var(--primary-gold, #1f5f7c); box-shadow: 0 2px 10px rgba(13,73,107,0.08); transform: translateY(-2px); }
.block-card:active { cursor: grabbing; }
.block-icon { width: 36px; height: 36px; border-radius: 10px; background: var(--gradient-main); display: flex; align-items: center; justify-content: center; color: #fff; font-size: 15px; }
.block-title { font-size: 12px; font-weight: 600; color: var(--text-primary, #1a2332); }
.block-desc { font-size: 10px; color: var(--text-muted, #94a3b8); line-height: 1.3; }

/* ===== Center ===== */
.panel-center { flex: 1; display: flex; align-items: center; justify-content: center; position: relative; overflow: auto; background: var(--bg-body, #f1f5f9); }
[data-theme="dark"] .panel-center { background: #0b1120; }

.sheet-wrapper { width: 100%; max-width: 700px; height: 100%; padding: 24px; transition: max-width 0.3s ease; }
.sheet-wrapper.tablet { max-width: 520px; }
.sheet-wrapper.mobile { max-width: 360px; }

.editor-area { width: 100%; height: 100%; min-height: 600px; }

.empty-overlay { position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; pointer-events: none; }
.empty-box { text-align: center; pointer-events: auto; padding: 40px; }
.empty-illustration { width: 80px; height: 80px; border-radius: 24px; background: var(--gradient-main); display: flex; align-items: center; justify-content: center; margin: 0 auto 20px; color: #fff; font-size: 32px; box-shadow: var(--shadow-md); }
.empty-box h3 { margin: 0 0 8px; font-size: 18px; color: var(--text-primary, #1a2332); }
.empty-box p { margin: 0 0 16px; font-size: 14px; color: var(--text-muted, #64748b); max-width: 280px; }
.empty-hint { display: inline-flex; align-items: center; gap: 6px; padding: 8px 14px; background: var(--bg-input); border-radius: 20px; font-size: 12px; color: var(--text-muted); }

/* ===== Right Panel ===== */
.panel-right { width: 260px; flex-shrink: 0; background: rgba(255,255,255,0.95); backdrop-filter: blur(20px); border-left: 1px solid rgba(0,0,0,0.05); display: flex; flex-direction: column; overflow-y: auto; }
[data-theme="dark"] .panel-right { background: rgba(15,23,42,0.97); border-left-color: rgba(255,255,255,0.06); }

.right-header { display: flex; align-items: center; justify-content: space-between; padding: 14px 16px; border-bottom: 1px solid rgba(0,0,0,0.05); font-size: 13px; font-weight: 600; color: var(--text-primary); }
[data-theme="dark"] .right-header { color: #e2e8f0; border-bottom-color: rgba(255,255,255,0.06); }
.close-right { width: 28px; height: 28px; border: none; border-radius: 8px; background: transparent; color: var(--text-muted); cursor: pointer; transition: all 0.2s; }
.close-right:hover { background: var(--danger-bg); color: var(--danger); }

.prop-group { padding: 14px 16px; display: flex; flex-direction: column; gap: 14px; }
.prop-row { display: flex; flex-direction: column; gap: 5px; }
.prop-row label { font-size: 11px; font-weight: 600; color: var(--text-muted, #94a3b8); text-transform: uppercase; letter-spacing: 0.4px; }
.prop-input, .prop-select { padding: 8px 10px; border: 1px solid rgba(0,0,0,0.08); border-radius: 8px; background: var(--bg-input, #f5f5f5); color: var(--text-primary, #1a2332); font-size: 13px; font-family: var(--font-main); transition: all 0.2s; }
.prop-input:focus, .prop-select:focus { outline: none; border-color: var(--primary-gold); }
[data-theme="dark"] .prop-input, [data-theme="dark"] .prop-select { background: #1e293b; border-color: rgba(255,255,255,0.08); color: #e2e8f0; }

.color-row { display: flex; align-items: center; gap: 10px; }
.color-row input[type="color"] { width: 36px; height: 36px; border: none; border-radius: 8px; cursor: pointer; padding: 0; background: none; }
.color-row span { font-size: 12px; color: var(--text-muted); font-family: var(--font-mono); }

.align-btns { display: flex; gap: 4px; }
.align-btns button { flex: 1; padding: 8px; border: 1px solid rgba(0,0,0,0.06); border-radius: 8px; background: var(--bg-input); color: var(--text-muted); font-size: 13px; cursor: pointer; transition: all 0.2s; min-height: 44px; }
.align-btns button.active { background: var(--gradient-main); color: #fff; border-color: transparent; }

.toggle-row { display: flex; gap: 6px; }
.toggle-row button { flex: 1; padding: 8px; border: 1px solid rgba(0,0,0,0.06); border-radius: 8px; background: var(--bg-input); color: var(--text-muted); font-size: 12px; cursor: pointer; transition: all 0.2s; display: flex; align-items: center; justify-content: center; gap: 5px; min-height: 44px; }
.toggle-row button.active { background: var(--gradient-main); color: #fff; border-color: transparent; }

.prop-range { width: 100%; accent-color: var(--primary-gold); }
.range-val { font-size: 11px; color: var(--text-muted); text-align: right; margin-top: 2px; }

.prop-actions { display: flex; gap: 8px; padding: 0 16px 16px; }
.pa-btn { flex: 1; padding: 8px; border: 1px solid rgba(0,0,0,0.06); border-radius: 8px; background: var(--bg-input); color: var(--text-secondary); font-size: 12px; font-weight: 600; cursor: pointer; transition: all 0.2s; display: flex; align-items: center; justify-content: center; gap: 5px; min-height: 44px; }
.pa-btn:hover { background: var(--bg-hover); }
.pa-btn.danger { color: var(--danger); border-color: var(--danger-bg); }
.pa-btn.danger:hover { background: var(--danger-bg); }

/* Transitions */
.slide-enter-active, .slide-leave-active { transition: transform 0.25s ease, opacity 0.25s ease; }
.slide-enter-from, .slide-leave-to { transform: translateX(20px); opacity: 0; }

/* ===== Preview Overlay ===== */
.preview-overlay { position: fixed; inset: 0; z-index: 2000; background: rgba(0,0,0,0.45); backdrop-filter: blur(10px); display: flex; align-items: center; justify-content: center; padding: 20px; }
.preview-box { background: var(--bg-card); border-radius: 20px; box-shadow: var(--shadow-xl); width: 100%; max-width: min(90vw, 960px); max-height: 90vh; display: flex; flex-direction: column; overflow: hidden; animation: popIn 0.3s cubic-bezier(0.34,1.56,0.64,1); }
.preview-box-responsive { max-width: min(90vw, 700px); }
@keyframes popIn { from { transform: scale(0.92); opacity: 0; } to { transform: scale(1); opacity: 1; } }

.pv-header { display: flex; align-items: center; justify-content: space-between; padding: 14px 20px; border-bottom: 1px solid rgba(0,0,0,0.05); flex-shrink: 0; gap: 10px; flex-wrap: wrap; }
.pv-title { display: flex; align-items: center; gap: 12px; }
.pv-title h4 { margin: 0; font-size: 15px; font-weight: 700; color: var(--text-primary); }
.pv-title p { margin: 2px 0 0; font-size: 12px; color: var(--text-muted); }
.pv-devices { display: flex; gap: 3px; padding: 3px; background: var(--bg-input); border-radius: 10px; }
.pv-devices button { display: flex; align-items: center; gap: 5px; padding: 6px 12px; border: none; border-radius: 8px; background: transparent; color: var(--text-muted); font-size: 12px; font-weight: 500; cursor: pointer; transition: all 0.2s; min-height: 44px; }
.pv-devices button.active { background: var(--bg-card); color: var(--primary-dark); box-shadow: var(--shadow-sm); }
.pv-close { width: 32px; min-width: 32px; height: 32px; border: none; border-radius: 10px; background: transparent; color: var(--text-muted); font-size: 14px; cursor: pointer; transition: all 0.2s; }
.pv-close:hover { background: var(--danger-bg); color: var(--danger); }

.pv-body { flex: 1; overflow: auto; padding: 20px; display: flex; flex-direction: column; align-items: center; gap: 12px; background: #f1f5f9; }
[data-theme="dark"] .pv-body { background: #0b1120; }
.pv-frame { width: 100%; transition: max-width 0.3s ease; display: flex; justify-content: center; }
.pv-frame.tablet { max-width: 768px; }
.pv-frame.mobile { max-width: 375px; }
.pv-frame iframe { width: 100%; min-height: 480px; border-radius: 12px; background: #fff; box-shadow: 0 4px 24px rgba(0,0,0,0.1); }
.pv-caption { font-size: 12px; color: var(--text-muted); text-align: center; }
.pv-footer { display: flex; justify-content: flex-end; gap: 10px; padding: 14px 20px; border-top: 1px solid rgba(0,0,0,0.05); }

/* Templates grid */
.templates-grid-simple { display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; }
.tmpl-card { cursor: pointer; border-radius: 14px; overflow: hidden; border: 1px solid rgba(0,0,0,0.06); transition: all 0.2s; background: var(--bg-input); }
.tmpl-card:hover { transform: translateY(-3px); box-shadow: var(--shadow-md); border-color: var(--primary-gold); }
.tmpl-preview { height: 90px; display: flex; align-items: center; justify-content: center; font-size: 24px; }
.tmpl-name { padding: 10px 12px 2px; font-size: 13px; font-weight: 600; color: var(--text-primary); }
.tmpl-desc { padding: 0 12px 12px; font-size: 11px; color: var(--text-muted); }

/* Simple form */
.simple-form { display: flex; flex-direction: column; gap: 14px; }
.simple-form label { font-size: 11px; font-weight: 600; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.4px; }
.sf-input { width: 100%; padding: 10px 12px; border: 1px solid rgba(0,0,0,0.08); border-radius: 10px; background: var(--bg-input); color: var(--text-primary); font-size: 13px; font-family: var(--font-main); }
.sf-input:focus { outline: none; border-color: var(--primary-gold); }
.sf-link { display: inline-flex; align-items: center; gap: 6px; padding: 6px 10px; background: var(--info-bg); color: var(--info); border-radius: 8px; font-size: 12px; font-weight: 600; border: none; cursor: pointer; margin-bottom: 6px; }
.sf-chips { display: flex; flex-wrap: wrap; gap: 6px; }
.sf-chip { padding: 4px 10px; border-radius: 10px; background: var(--bg-hover); color: var(--text-muted); font-size: 12px; cursor: pointer; transition: all 0.15s; }
.sf-chip.active { background: var(--gradient-main); color: #fff; }
.sf-btn { padding: 10px 18px; border: none; border-radius: 10px; font-size: 13px; font-weight: 600; cursor: pointer; transition: all 0.2s; min-height: 44px; }
.sf-btn.ghost { background: transparent; color: var(--text-secondary); }
.sf-btn.ghost:hover { background: var(--bg-hover); }
.sf-btn.send { background: linear-gradient(135deg,#10b981,#059669); color: #fff; box-shadow: 0 2px 8px rgba(16,185,129,0.25); }
.sf-btn.send:hover { transform: translateY(-1px); box-shadow: 0 4px 14px rgba(16,185,129,0.35); }

/* Scrollbar */
::-webkit-scrollbar { width: 5px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: rgba(0,0,0,0.12); border-radius: 3px; }
[data-theme="dark"] ::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.12); }

/* Responsive */
@media (max-width: 1100px) {
  .panel-right { position: absolute; right: 0; top: 0; bottom: 0; z-index: 50; box-shadow: var(--shadow-lg); }
  .tb-name, .tb-subject { width: 160px; }
}
@media (max-width: 768px) {
  .panel-left { width: 160px; padding: 8px; }
  .device-label { display: none; }
  .tb-btn span { display: none; }
  .d-btn span { display: none; }
  .templates-grid-simple { grid-template-columns: repeat(2, 1fr); }
  .builder-topbar { padding: 6px 10px; gap: 6px; }
  .tb-name, .tb-subject { width: 120px; font-size: 12px; padding: 6px 8px; }
  .pv-devices button { min-height: 38px; padding: 5px 6px; font-size: 10px; }
  .sheet-wrapper { padding: 10px; }
  .panel-right { width: min(260px, 80vw); }
}
@media (max-width: 520px) {
  .panel-left { display: none; }
  .panel-right {
    position: fixed;
    top: 0;
    right: 0;
    bottom: 0;
    width: min(280px, 85vw);
    z-index: 100;
    box-shadow: -4px 0 20px rgba(0,0,0,0.2);
  }
  .sheet-wrapper { padding: 8px; max-width: 100% !important; }
  .topbar-right { gap: 4px; }
  .tb-btn { padding: 6px 8px; font-size: 10px; min-height: 36px; }
  .tb-name, .tb-subject { width: 100px; font-size: 11px; padding: 5px 6px; }
  .templates-grid-simple { grid-template-columns: 1fr 1fr; gap: 8px; }
  .pv-header { padding: 8px 12px; }
  .pv-body { padding: 10px; }
  .builder-topbar { flex-wrap: wrap; }
}

/* GrapesJS minimal overrides */
:deep(.gjs-cv-canvas) { background: #ffffff !important; }
:deep(.gjs-frame) { border-radius: 12px !important; box-shadow: 0 4px 20px rgba(0,0,0,0.08) !important; background: #ffffff !important; }
:deep(.gjs-frame body) { background: #ffffff !important; }
:deep(.gjs-comp-selected) { outline: 2px solid var(--primary-gold, #1f5f7c) !important; outline-offset: 2px !important; }
:deep(.gjs-toolbar) { background: var(--bg-card) !important; border-radius: 10px !important; box-shadow: var(--shadow-md) !important; border: 1px solid rgba(0,0,0,0.06) !important; }
:deep(.gjs-toolbar-item) { color: var(--text-secondary) !important; border-radius: 6px !important; padding: 6px 10px !important; }
:deep(.gjs-toolbar-item:hover) { background: var(--bg-hover) !important; color: var(--primary-dark) !important; }
:deep(.gjs-badge) { background: var(--gradient-main) !important; color: #fff !important; border-radius: 6px !important; font-size: 10px !important; font-weight: 600 !important; padding: 3px 8px !important; }
</style>
