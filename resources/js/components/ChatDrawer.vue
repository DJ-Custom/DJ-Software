<template>
  <teleport to="body">
    <!-- Backdrop -->
    <div
      class="cd-backdrop"
      :class="{ active: drawerStore.isOpen }"
      @click="drawerStore.close"
      aria-hidden="true"
    ></div>

    <!-- Drawer -->
    <div
      class="cd-drawer"
      :class="{ open: drawerStore.isOpen }"
      role="dialog"
      aria-modal="true"
      aria-label="Chats internos"
    >
      <!-- Header -->
      <header class="cd-header">
        <div class="cd-header-brand">
          <div class="cd-header-icon">
            <i class="fas fa-comments"></i>
          </div>
          <div>
            <h2 class="cd-header-title">Chats Internos</h2>
            <span v-if="connectionStatus" class="cd-header-status">
              <span class="cd-status-dot" :class="{ online: isConnected }"></span>
              {{ isConnected ? 'Conectado' : 'Reconectando...' }}
            </span>
          </div>
        </div>
        <div class="cd-header-actions">
          <span v-if="totalUnread > 0" class="cd-header-badge">{{ totalUnread }}</span>
          <button
            class="cd-btn-icon"
            title="Nuevo chat"
            @click="abrirModalNuevo"
            aria-label="Nuevo chat"
          >
            <i class="fas fa-plus"></i>
          </button>
          <button
            class="cd-btn-icon"
            title="Cerrar panel"
            @click="drawerStore.close"
            aria-label="Cerrar panel de chats"
          >
            <i class="fas fa-times"></i>
          </button>
        </div>
      </header>

      <!-- Body -->
      <div class="cd-body">
        <!-- Sidebar: Conversations -->
        <aside class="cd-sidebar" :class="{ 'mobile-hidden': chatActivo && isMobileView }">
          <!-- Search -->
          <div class="cd-search">
            <i class="fas fa-search"></i>
            <input
              v-model="busqueda"
              type="text"
              placeholder="Buscar conversación..."
              aria-label="Buscar conversación"
            />
          </div>

          <!-- Chat List -->
          <div class="cd-chat-list">
            <div
              v-for="chat in chatsFiltrados"
              :key="chat.id"
              class="cd-chat-item"
              :class="{ active: chatActivo?.id === chat.id, pinned: chat.pinned }"
              @click="abrirChat(chat)"
            >
              <div class="cd-chat-avatar">
                <span class="cd-avatar-text">{{ iniciales(chat.titulo) }}</span>
                <span v-if="chat.no_leidos > 0" class="cd-avatar-unread">{{ chat.no_leidos }}</span>
              </div>
              <div class="cd-chat-meta">
                <div class="cd-chat-row">
                  <span class="cd-chat-name">{{ chat.titulo }}</span>
                  <span class="cd-chat-time">{{ formatoHora(chat.ultimo_mensaje?.created_at || chat.created_at) }}</span>
                </div>
                <div class="cd-chat-row">
                  <span class="cd-chat-preview">{{ chat.ultimo_mensaje?.contenido || chat.descripcion || 'Sin mensajes' }}</span>
                </div>
                <div v-if="chat.participantes_nombres?.length" class="cd-chat-participants">
                  <i class="fas fa-users"></i>
                  {{ chat.participantes_nombres.slice(0, 2).join(', ') }}
                  <span v-if="chat.participantes_nombres.length > 2">+{{ chat.participantes_nombres.length - 2 }}</span>
                </div>
              </div>
            </div>

            <!-- Empty state -->
            <div v-if="!chatsFiltrados.length && !loadingChats" class="cd-empty">
              <i class="fas fa-inbox"></i>
              <p>{{ busqueda ? 'No se encontraron chats' : 'No tienes chats activos' }}</p>
            </div>

            <!-- Skeleton loading -->
            <template v-if="loadingChats">
              <div v-for="n in 5" :key="n" class="cd-chat-item cd-skeleton">
                <div class="cd-skeleton-avatar"></div>
                <div class="cd-skeleton-lines">
                  <div class="cd-skeleton-line short"></div>
                  <div class="cd-skeleton-line"></div>
                </div>
              </div>
            </template>
          </div>
        </aside>

        <!-- Active Chat Area -->
        <main v-if="chatActivo" class="cd-chat-area" :class="{ 'mobile-full': isMobileView }">
          <!-- Chat Header -->
          <div class="cd-chat-header">
            <button class="cd-btn-icon cd-back-btn" @click="chatActivo = null" aria-label="Volver a conversaciones">
              <i class="fas fa-arrow-left"></i>
            </button>
            <div class="cd-chat-header-avatar">
              <span class="cd-avatar-text">{{ iniciales(chatActivo.titulo) }}</span>
            </div>
            <div class="cd-chat-header-info">
              <div class="cd-chat-header-name">{{ chatActivo.titulo }}</div>
              <div class="cd-chat-header-meta">
                <span v-if="chatActivo.estado === 'abierto'" class="cd-badge cd-badge-success">Abierto</span>
                <span v-else class="cd-badge cd-badge-danger">Cerrado</span>
                <span class="cd-participants-text">{{ participantesTexto }}</span>
              </div>
            </div>
            <button
              v-if="chatActivo.estado === 'abierto'"
              class="cd-btn-icon"
              title="Cerrar chat"
              @click="cerrarChat"
              aria-label="Cerrar chat"
            >
              <i class="fas fa-lock"></i>
            </button>
          </div>

          <!-- Messages -->
          <div ref="mensajesContainer" class="cd-messages" @scroll="onScroll">
            <div
              v-for="msg in mensajes"
              :key="msg.id"
              class="cd-msg"
              :class="{ own: msg.usuario_id === userId }"
            >
              <div class="cd-msg-bubble">
                <div v-if="msg.usuario_id !== userId" class="cd-msg-author">{{ msg.usuario?.nombre || 'Usuario' }}</div>
                <div v-if="msg.contenido" class="cd-msg-text">{{ msg.contenido }}</div>
                <div v-if="msg.archivo_url" class="cd-msg-attachment">
                  <!-- Image preview -->
                  <a
                    v-if="isImageFile(msg)"
                    href="#"
                    class="cd-attachment-image-link"
                    @click.prevent="verImagen(msg)"
                  >
                    <img
                      v-if="getArchivoUrl(msg)"
                      :src="getArchivoUrl(msg)"
                      :alt="msg.archivo_nombre"
                      class="cd-attachment-image"
                      loading="lazy"
                    />
                    <div v-else-if="isArchivoError(msg)" class="cd-attachment-image-loading cd-attachment-error" @click.stop="reintentarCarga(msg)">
                      <i class="fas fa-exclamation-triangle"></i>
                      <span>No se pudo cargar. Clic para reintentar</span>
                    </div>
                    <div v-else class="cd-attachment-image-loading" @click.stop="cargarArchivoBlob(msg)">
                      <i class="fas fa-image"></i>
                      <span>Clic para cargar imagen</span>
                    </div>
                  </a>
                  <!-- Video preview -->
                  <div v-else-if="isVideoFile(msg)" class="cd-attachment-video">
                    <video
                      v-if="getArchivoUrl(msg)"
                      :src="getArchivoUrl(msg)"
                      controls
                      preload="metadata"
                      class="cd-attachment-video-el"
                    >
                      Tu navegador no soporta video.
                    </video>
                    <div v-else-if="isArchivoError(msg)" class="cd-attachment-image-loading cd-attachment-error" @click="reintentarCarga(msg)">
                      <i class="fas fa-exclamation-triangle"></i>
                      <span>No se pudo cargar. Clic para reintentar</span>
                    </div>
                    <div v-else class="cd-attachment-image-loading" @click="cargarArchivoBlob(msg)">
                      <i class="fas fa-video"></i>
                      <span>Clic para cargar video</span>
                    </div>
                  </div>
                  <!-- Audio preview -->
                  <div v-else-if="isAudioFile(msg)" class="cd-attachment-audio">
                    <div class="cd-audio-icon" :style="{ background: getFileColor(msg) }">
                      <i :class="getFileIcon(msg)"></i>
                    </div>
                    <div class="cd-audio-info">
                      <span class="cd-audio-name">{{ msg.archivo_nombre }}</span>
                      <audio
                        v-if="getArchivoUrl(msg)"
                        :src="getArchivoUrl(msg)"
                        controls
                        preload="metadata"
                        class="cd-audio-el"
                      ></audio>
                      <button v-else-if="isArchivoError(msg)" class="cd-audio-load-btn cd-audio-error" @click="reintentarCarga(msg)">
                        <i class="fas fa-exclamation-triangle"></i> Error - Reintentar
                      </button>
                      <button v-else class="cd-audio-load-btn" @click="cargarArchivoBlob(msg)">
                        <i class="fas fa-play"></i> Cargar audio
                      </button>
                    </div>
                  </div>
                  <!-- PDF / Documents -->
                  <a
                    v-else
                    href="#"
                    class="cd-attachment-file"
                    @click.prevent="abrirArchivo(msg)"
                  >
                    <div class="cd-file-icon" :style="{ background: getFileColor(msg) + '18', color: getFileColor(msg) }">
                      <i :class="getFileIcon(msg)"></i>
                    </div>
                    <div class="cd-attachment-file-info">
                      <span class="cd-attachment-file-name">{{ msg.archivo_nombre }}</span>
                      <span class="cd-attachment-file-size">{{ formatoSize(msg.archivo_size) }}</span>
                    </div>
                    <div class="cd-file-action">
                      <i class="fas fa-download"></i>
                    </div>
                  </a>
                </div>
                <div class="cd-msg-footer">
                  <span class="cd-msg-time">{{ formatoHora(msg.created_at) }}</span>
                  <span v-if="msg.usuario_id === userId" class="cd-msg-check">
                    <i class="fas fa-check-double"></i>
                  </span>
                </div>
              </div>
            </div>

            <!-- Typing indicator -->
            <div v-if="escribiendo" class="cd-msg typing">
              <div class="cd-msg-bubble">
                <div class="cd-typing-dots"><span></span><span></span><span></span></div>
              </div>
            </div>
          </div>

          <!-- Input Area -->
          <div v-if="chatActivo.estado === 'abierto'" class="cd-input-area">
            <div v-if="archivoSeleccionado" class="cd-file-preview">
              <div class="cd-file-preview-thumb" v-if="archivoPreviewUrl">
                <img :src="archivoPreviewUrl" alt="Preview" />
              </div>
              <div v-else class="cd-file-preview-icon">
                <i :class="archivoSeleccionadoPreviewIcon"></i>
              </div>
              <div class="cd-file-preview-info">
                <span class="cd-file-preview-name">{{ archivoSeleccionado.name }}</span>
                <span class="cd-file-preview-size">{{ formatoSize(archivoSeleccionado.size) }}</span>
              </div>
              <button class="cd-btn-icon cd-file-remove" @click="quitarArchivo" aria-label="Quitar archivo">
                <i class="fas fa-times"></i>
              </button>
            </div>

            <div class="cd-input-wrapper">
              <button class="cd-btn-icon cd-input-btn" title="Emojis" @click="toggleEmojiPicker" aria-label="Emojis">
                <i class="far fa-smile"></i>
              </button>
              <button class="cd-btn-icon cd-input-btn" title="Adjuntar archivo (Max: 3 MB)" @click="seleccionarArchivo" aria-label="Adjuntar archivo">
                <i class="fas fa-paperclip"></i>
              </button>

              <textarea
                ref="textareaMensaje"
                v-model="nuevoMensaje"
                class="cd-textarea"
                placeholder="Escribe un mensaje..."
                rows="1"
                @keydown="onTextareaKeydown"
                @input="autoResizeTextarea"
                aria-label="Mensaje"
              ></textarea>

              <input
                ref="inputArchivo"
                type="file"
                style="display:none"
                accept="image/*,video/*,audio/*,.pdf,.doc,.docx,.xls,.xlsx,.csv,.ppt,.pptx,.zip,.rar,.7z"
                @change="onArchivoSeleccionado"
                aria-hidden="true"
              />

              <button
                class="cd-btn-send"
                :disabled="!nuevoMensaje.trim() && !archivoSeleccionado"
                @click="enviarMensaje"
                aria-label="Enviar mensaje"
              >
                <i class="fas fa-paper-plane"></i>
              </button>

              <!-- Emoji Picker -->
              <div v-if="mostrarEmojis" v-click-outside="cerrarEmojiPicker" class="cd-emoji-picker">
                <div class="cd-emoji-header">
                  <span>Emojis</span>
                  <button class="cd-btn-icon" @click="cerrarEmojiPicker" aria-label="Cerrar emojis">
                    <i class="fas fa-times"></i>
                  </button>
                </div>
                <div class="cd-emoji-body">
                  <div v-for="(grupo, idx) in emojiGrupos" :key="idx" class="cd-emoji-group">
                    <div class="cd-emoji-group-label">{{ grupo.nombre }}</div>
                    <div class="cd-emoji-grid">
                      <span
                        v-for="emoji in grupo.emojis"
                        :key="emoji"
                        class="cd-emoji-item"
                        @click="insertarEmoji(emoji)"
                      >{{ emoji }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div v-else class="cd-closed-bar">
            <i class="fas fa-lock"></i> Este chat está cerrado. No se pueden enviar mensajes.
          </div>
        </main>

        <!-- Empty State (no chat selected) -->
        <div v-else class="cd-empty-main">
          <div class="cd-empty-center">
            <div class="cd-empty-illustration">
              <i class="fas fa-comments"></i>
            </div>
            <h3>Chat Interno</h3>
            <p>Selecciona una conversación o crea una nueva para comenzar.</p>
          </div>
        </div>
      </div>

      <!-- New Chat Modal -->
      <div v-if="showModal" class="cd-modal-overlay" @click.self="showModal = false">
        <div class="cd-modal" role="dialog" aria-modal="true" aria-label="Nuevo chat">
          <div class="cd-modal-header">
            <h3>Nuevo Chat</h3>
            <button class="cd-btn-icon" @click="showModal = false" aria-label="Cerrar">
              <i class="fas fa-times"></i>
            </button>
          </div>
          <div class="cd-modal-body">
            <div class="cd-form-group">
              <label>Título <span class="cd-required">*</span></label>
              <input v-model="form.titulo" class="cd-form-input" placeholder="Ej: Ventas del mes" />
            </div>
            <div class="cd-form-group">
              <label>Descripción</label>
              <textarea v-model="form.descripcion" class="cd-form-textarea" rows="2" placeholder="Opcional"></textarea>
            </div>
            <div class="cd-form-group">
              <label>Participantes <span class="cd-required">*</span></label>
              <div class="cd-participantes-selector">
                <div
                  v-for="u in usuariosDisponibles"
                  :key="u.id"
                  class="cd-participante-chip"
                  :class="{ selected: form.participantes.includes(u.id) }"
                  @click="toggleParticipante(u.id)"
                >
                  <i class="fas" :class="form.participantes.includes(u.id) ? 'fa-check-circle' : 'fa-circle'"></i>
                  {{ u.nombre }}
                </div>
              </div>
            </div>
          </div>
          <div class="cd-modal-footer">
            <button class="cd-btn cd-btn-ghost" @click="showModal = false">Cancelar</button>
            <button
              class="cd-btn cd-btn-primary"
              :disabled="!form.titulo || !form.participantes.length"
              @click="crearChat"
            >
              <i class="fas fa-plus"></i> Crear Chat
            </button>
          </div>
        </div>
      </div>
    </div>
  </teleport>
</template>

<script setup>
import {
  ref,
  computed,
  onMounted,
  onBeforeUnmount,
  nextTick,
  watch,
} from 'vue';
import { useAuthStore } from '../stores/auth';
import { useChatDrawerStore } from '../stores/chatDrawer';
import { useToastStore } from '../stores/toast';
import { useConfirmStore } from '../stores/confirm';
import api from '../services/api';
import { getToken } from '../services/authToken';

const authStore = useAuthStore();
const drawerStore = useChatDrawerStore();
const toast = useToastStore();
const confirm = useConfirmStore();

const userId = computed(() => authStore.user?.id);
const isMobileView = ref(false);
const connectionStatus = ref(true);
const isConnected = ref(true);

// Chat state
const chats = ref([]);
const busqueda = ref('');
const chatActivo = ref(null);
const mensajes = ref([]);
const nuevoMensaje = ref('');
const showModal = ref(false);
const escribiendo = ref(false);
const usuariosDisponibles = ref([]);
const mensajesContainer = ref(null);
const textareaMensaje = ref(null);
const inputArchivo = ref(null);
const mostrarEmojis = ref(false);
const archivoSeleccionado = ref(null);
const archivoPreviewUrl = ref(null);
const form = ref({ titulo: '', descripcion: '', participantes: [] });
const loadingChats = ref(false);

const totalUnread = computed(() => chats.value.reduce((sum, c) => sum + (c.no_leidos || 0), 0));

const archivoSeleccionadoPreviewIcon = computed(() => {
  if (!archivoSeleccionado.value) return 'fas fa-file';
  const ext = getExtension(archivoSeleccionado.value.name);
  if (IMAGE_EXTS.includes(ext)) return 'fas fa-image';
  if (VIDEO_EXTS.includes(ext)) return 'fas fa-video';
  if (AUDIO_EXTS.includes(ext)) return 'fas fa-headphones';
  if (ext === 'pdf') return 'fas fa-file-pdf';
  if (WORD_EXTS.includes(ext)) return 'fas fa-file-word';
  if (EXCEL_EXTS.includes(ext)) return 'fas fa-file-excel';
  if (PPT_EXTS.includes(ext)) return 'fas fa-file-powerpoint';
  if (ZIP_EXTS.includes(ext)) return 'fas fa-file-zipper';
  return 'fas fa-file';
});

const chatsFiltrados = computed(() => {
  const q = busqueda.value.toLowerCase().trim();
  if (!q) return chats.value;
  return chats.value.filter(c =>
    (c.titulo || '').toLowerCase().includes(q) ||
    (c.descripcion || '').toLowerCase().includes(q) ||
    (c.participantes_nombres || []).some(n => n.toLowerCase().includes(q))
  );
});

const participantesTexto = computed(() => {
  const nombres = chatActivo.value?.participantes_nombres || [];
  return nombres.join(', ');
});

const emojiGrupos = [
  {
    nombre: 'Caras',
    emojis: ['😀','😃','😄','😁','😆','😅','😂','🤣','😊','😇','🙂','🙃','😉','😌','😍','🥰','😘','😗','😙','😚','😋','😛','😝','😜','🤪','🤨','🧐','🤓','😎','🤩','🥳','😏','😒','😞','😔','😟','😕','🙁','☹️','😣','😖','😫','😩','🥺','😢','😭','😤','😠','😡','🤬','🤯','😳','🥵','🥶','😱','😨','😰','😥','😓','🤗','🤔','🤭','😶','😐','😑','😬','🙄','😯','😦','😧','😮','😲','😴','😪','🤤','😴','😵','🤐','🥴','🤢','🤮','🤧','😷','🤒','🤕','😈','👿','👹','👺','💀','☠️','👻','👽','🤖']
  },
  {
    nombre: 'Manos & Gestos',
    emojis: ['👋','🤚','🖐️','✋','🖖','👌','🤌','🤏','✌️','🤞','🤟','🤘','🤙','👈','👉','👆','🖕','👇','☝️','👍','👎','✊','👊','🤛','🤜','👏','🙌','👐','🤲','🤝','🙏','💪','🦾','🦿','🦵','🦶']
  },
  {
    nombre: 'Corazones & Amor',
    emojis: ['❤️','🧡','💛','💚','💙','💜','🖤','🤍','🤎','💔','❣️','💕','💞','💓','💗','💖','💘','💝','💟','♥️','💋','😍','🥰','😘','😻','💑','💏']
  },
  {
    nombre: 'Animales',
    emojis: ['🐶','🐱','🐭','🐹','🐰','🦊','🐻','🐼','🐻‍❄️','🐨','🐯','🦁','🐮','🐷','🐸','🐵','🙈','🙉','🙊','🐒','🐔','🐧','🐦','🐤','🐣','🐥','🦆','🦅','🦉','🦇','🐺','🐗','🐴','🦄','🐝','🐛','🦋','🐌','🐞','🐜','🦟','🦗','🕷️','🦂','🐢','🐍','🦎','🦖','🦕','🐙','🦑','🦐','🦞','🦀','🐡','🐠','🐟','🐬','🐳','🐋','🦈','🐊']
  },
  {
    nombre: 'Comida & Bebida',
    emojis: ['🍏','🍎','🍐','🍊','🍋','🍌','🍉','🍇','🍓','🫐','🍈','🍒','🍑','🥭','🍍','🥥','🥝','🍅','🍆','🥑','🥦','🥬','🥒','🌶️','🫑','🌽','🥕','🫒','🧄','🧅','🥔','🍠','🫘','🥐','🥯','🍞','🥖','🥨','🧀','🥚','🍳','🧈','🥞','🧇','🥓','🥩','🍗','🍖','🦴','🌭','🍔','🍟','🍕','🫓','🥪','🥙','🧆','🌮','🌯','🫔','🥗','🥘','🫕','🥫','🍝','🍜','🍲','🍛','🍣','🍱','🥟','🦪','🍤','🍙','🍚','🍘','🍥','🥮','🍢','🍡','🍧','🍨','🍦','🥧','🧁','🍰','🎂','🍮','🍭','🍬','🍫','🍿','🍩','🍪','🌰','🥜','🍯','🥛','🍼','🫖','☕','🍵','🧃','🥤','🧋','🍶','🍺','🍻','🥂','🍷','🥃','🍸','🍹','🧉','🍾','🧊']
  },
  {
    nombre: 'Actividades & Viajes',
    emojis: ['⚽','🏀','🏈','⚾','🥎','🎾','🏐','🏉','🥏','🎱','🪀','🏓','🏸','🏒','🥅','⛳','🪁','🏹','🎣','🤿','🥊','🥋','🎽','🛹','🛼','🛷','⛸️','🥌','🎿','🎯','🪀','🪁','🎮','🕹️','🎰','🎲','🧩','🎭','🎨','🎬','🎤','🎧','🎼','🎹','🥁','🪘','🎷','🎺','🪗','🎸','🪕','🎻','🪈','🗺️','🧭','🧳','✈️','🛩️','🚀','🛸','🚁','⛵','🚤','🛥️','🛳️','⛴️','🚢','🚗','🚕','🚌','🏎️','🚓','🚑','🚒','🚐','🛻','🚚','🚛','🚜','🦯','🦽','🦼','🛴','🚲','🛵','🏍️','🛺','🚨','🚔','🚍','🚘','🚖','🚡','🚠','🚟','🚃','🚋','🚞','🚝','🚄','🚅','🚈','🚂','🚆','🚇','🚊','🚉','🏗️','🛕','🏥','🏦','🏨','🏩','🏪','🏫','🏬','🏭','🏯','🏰','💒','🗼','🗽','⛪','🕌','🛕','🕍','⛩️','🕋','⛲','⛺','🌁','🌃','🏙️','🌄','🌅','🌆','🌇','🌉','🌌','🎆','🎇','🎑']
  },
  {
    nombre: 'Objetos',
    emojis: ['⌚','📱','📲','💻','⌨️','🖥️','🖨️','🖱️','🖲️','🕹️','🗜️','💾','💿','📀','📼','📷','📸','📹','🎥','📽️','🎞️','📞','☎️','📟','📠','📺','📻','🎙️','🎚️','🎛️','🧭','⏱️','⏲️','⏰','🕰️','📡','🔋','🔌','💡','🔦','🕯️','🧯','🛢️','💸','💵','💴','💶','💷','🪙','💰','💳','💎','⚖️','🧰','🪛','🔧','🔨','⚒️','🛠️','⛏️','🪚','🔩','⚙️','🗜️','⚗️','🔬','🔭','📡','💊','🩹','🩺','🚪','🛗','🪞','🪟','🛏️','🛋️','🪑','🚽','🪠','🚿','🛁','🪤','🪒','🧴','🧷','🧹','🧺','🧻','🪣','🧼','🪥','🧽','🧯','🛒','🚬','⚰️','🪦','⚱️','🗿','🏧','🚮','🚰','♿','🚹','🚺','🚻','🚼','🚾','🛂','🛃','🛄','🛅','⚠️','🚸','⛔','🚫','🚳','🚭','🚯','🚱','🚷','📵','🔞','☢️','☣️','⬆️','↗️','➡️','↘️','⬇️','↙️','⬅️','↖️','↕️','↔️','↩️','↪️','⤴️','⤵️','🔀','🔁','🔂','▶️','⏩','⏭️','⏯️','◀️','⏪','⏮️','🔼','⏫','🔽','⏬','⏸️','⏹️','⏺️','⏏️','🎦','🔅','🔆','📶','🛜','📳','📴','♀️','♂️','⚧️','✖️','➕','➖','➗','🟰','♾️','‼️','⁉️','❓','❔','❕','❗','〰️','💱','💲','⚕️','♻️','⚜️','🔱','📛','🔰','⭕','✅','☑️','✔️','❌','❎','➰','➿','〽️','✳️','✴️','❇️','©️','®️','™️','#️⃣','*️⃣','0️⃣','1️⃣','2️⃣','3️⃣','4️⃣','5️⃣','6️⃣','7️⃣','8️⃣','9️⃣','🔟','🔢','#️⃣','🔠','🔡','🔢','🔣','🔤','🅰️','🆎','🅱️','🆑','🆒','🆓','ℹ️','🆔','Ⓜ️','🆕','🆖','🅾️','🆗','🅿️','🆘','🆙','🆚','🈁','🈂️','🈷️','🈶','🈯','🉐','🈹','🈚','🈲','🉑','🈸','🈴','🈳','㊗️','㊙️','🈺','🈵']
  },
  {
    nombre: 'Símbolos',
    emojis: ['🔴','🟠','🟡','🟢','🔵','🟣','⚫','⚪','🟤','🔺','🔻','🔸','🔹','🔶','🔷','🔳','🔲','▪️','▫️','◾','◽','◼️','◻️','🟥','🟧','🟨','🟩','🟦','🟪','⬛','⬜','🟫','♈','♉','♊','♋','♌','♍','♎','♏','♐','♑','♒','♓','⛎','🔀','🔁','🔂','▶️','⏩','⏭️','⏯️','◀️','⏪','⏮️','🔼','⏫','🔽','⏬','⏸️','⏹️','⏺️','⏏️','🎦','🔅','🔆','📶','🛜','📳','📴','♀️','♂️','⚧️']
  }
];

// Helpers
function iniciales(texto) {
  if (!texto) return '?';
  return texto.split(' ').map(w => w[0]).join('').slice(0, 2).toUpperCase();
}

function checkMobile() {
  isMobileView.value = window.innerWidth <= 768;
}

function autoResizeTextarea() {
  const el = textareaMensaje.value;
  if (!el) return;
  el.style.height = 'auto';
  const maxH = 120;
  el.style.height = Math.min(el.scrollHeight, maxH) + 'px';
}

function onTextareaKeydown(e) {
  if (e.key === 'Enter' && !e.shiftKey) {
    e.preventDefault();
    enviarMensaje();
  }
}

// API Methods
async function cargarChats() {
  loadingChats.value = true;
  try {
    const { data } = await api.get('/chats');
    chats.value = data.chats || [];
    drawerStore.setUnread(totalUnread.value);
  } catch (e) {
    // silent
  } finally {
    loadingChats.value = false;
  }
}

async function cargarUsuarios() {
  try {
    const { data } = await api.get('/usuarios');
    usuariosDisponibles.value = (data.usuarios || []).filter(u => u.id !== userId.value);
  } catch (e) {
    // silent
  }
}

function limpiarBlobs() {
  for (const url of Object.values(archivosBlob.value)) {
    if (url && url !== 'ERROR') URL.revokeObjectURL(url);
  }
  archivosBlob.value = {};
}

function reintentarCarga(msg) {
  delete archivosBlob.value[msg.id];
  nextTick(() => cargarArchivoBlob(msg));
}

async function abrirChat(chat) {
  limpiarBlobs();
  chatActivo.value = chat;
  drawerStore.setActiveChat(chat.id);
  mensajes.value = [];
  await cargarMensajes(chat.id);
  await marcarLeido(chat.id);
}

async function cargarMensajes(chatId) {
  try {
    const { data } = await api.get(`/chats/${chatId}/mensajes`);
    mensajes.value = data.mensajes?.data || [];
    nextTick(() => {
      scrollBottom();
      cargarBlobsMensajes();
    });
  } catch (e) {
    // silent
  }
}

function cargarBlobsMensajes() {
  for (const msg of mensajes.value) {
    if (msg.archivo_url && !archivosBlob.value[msg.id]) {
      cargarArchivoBlob(msg);
    }
  }
}

async function marcarLeido(chatId) {
  try {
    await api.post(`/chats/${chatId}/leido`);
    const c = chats.value.find(ch => ch.id === chatId);
    if (c) c.no_leidos = 0;
    drawerStore.setUnread(totalUnread.value);
  } catch (e) {
    // silent
  }
}

async function enviarMensaje() {
  const texto = nuevoMensaje.value.trim();
  if (!texto && !archivoSeleccionado.value) return;
  if (!chatActivo.value) return;

  const chatId = chatActivo.value.id;
  const tempTexto = texto;
  const tempArchivo = archivoSeleccionado.value;
  nuevoMensaje.value = '';
  archivoSeleccionado.value = null;
  nextTick(() => {
    if (textareaMensaje.value) {
      textareaMensaje.value.style.height = 'auto';
    }
  });

  try {
    let data;
    if (tempArchivo) {
      const formData = new FormData();
      if (tempTexto) formData.append('contenido', tempTexto);
      formData.append('archivo', tempArchivo);
      const res = await api.post(`/chats/${chatId}/mensajes`, formData);
      data = res.data;
    } else {
      const res = await api.post(`/chats/${chatId}/mensajes`, { contenido: tempTexto });
      data = res.data;
    }
    if (data.mensaje) {
      mensajes.value.push(data.mensaje);
      if (data.mensaje.archivo_url) {
        cargarArchivoBlob(data.mensaje);
      }
      nextTick(() => scrollBottom());
    }
    await cargarChats();
  } catch (e) {
    let msg = 'Error al enviar mensaje';
    if (e.response?.data?.message) {
      msg = e.response.data.message;
    } else if (e.response?.data?.error) {
      msg = e.response.data.error;
    } else if (e.response?.status === 413) {
      msg = 'El archivo es demasiado grande para el servidor.';
    } else if (e.response?.status === 422 && e.response?.data?.errors) {
      const errs = e.response.data.errors;
      const first = Object.values(errs).flat()[0];
      if (first) msg = first;
    } else if (e.name === 'CanceledError' || e.name === 'AbortError') {
      msg = 'Envío cancelado. Intentalo de nuevo.';
    }
    toast.error(msg);
    // Restaurar el mensaje para que el usuario no lo pierda
    if (tempTexto) nuevoMensaje.value = tempTexto;
    if (tempArchivo) archivoSeleccionado.value = tempArchivo;
    nextTick(() => {
      if (textareaMensaje.value) {
        textareaMensaje.value.style.height = 'auto';
        textareaMensaje.value.style.height = textareaMensaje.value.scrollHeight + 'px';
      }
    });
  }
}

function getArchivoUrl(msg) {
  const val = archivosBlob.value[msg.id];
  if (!val || val === 'ERROR') return '';
  return val;
}

function isArchivoError(msg) {
  return archivosBlob.value[msg.id] === 'ERROR';
}

function getVerUrl(msg) {
  return `/api/chats/${msg.chat_id}/mensajes/${msg.id}/ver`;
}

const archivosBlob = ref({});

async function cargarArchivoBlob(msg) {
  if (archivosBlob.value[msg.id] || !msg.archivo_url) return;

  const token = getToken();
  const urls = [
    `/api/chats/${msg.chat_id}/mensajes/${msg.id}/ver`,
    msg.archivo_url_completa || null,
    `/storage/${msg.archivo_url}`,
  ].filter(Boolean);

  for (const url of urls) {
    try {
      const headers = token ? { Authorization: `Bearer ${token}` } : {};
      const res = await fetch(url, { headers });
      if (res.ok) {
        const blob = await res.blob();
        if (blob.size > 0) {
          archivosBlob.value[msg.id] = URL.createObjectURL(blob);
          return;
        }
      }
    } catch (e) {
      // try next url
    }
  }
  // Mark as failed so UI shows error
  archivosBlob.value[msg.id] = 'ERROR';
}

async function abrirArchivo(msg) {
  const type = getFileType(msg);
  if (type === 'pdf') {
    try {
      const token = getToken();
      const url = getVerUrl(msg);
      const res = await fetch(url, { headers: token ? { Authorization: `Bearer ${token}` } : {} });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const blob = await res.blob();
      const blobUrl = URL.createObjectURL(blob);
      window.open(blobUrl, '_blank');
      setTimeout(() => URL.revokeObjectURL(blobUrl), 60000);
    } catch (e) {
      toast.error('Error al abrir documento');
    }
  } else {
    descargarArchivo(msg);
  }
}

async function descargarArchivo(msg) {
  try {
    const token = getToken();
    const res = await fetch(`/api/chats/${msg.chat_id}/mensajes/${msg.id}/adjunto`, {
      headers: token ? { Authorization: `Bearer ${token}` } : {},
    });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const blob = await res.blob();
    const blobUrl = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = blobUrl;
    a.download = msg.archivo_nombre || 'archivo';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    setTimeout(() => URL.revokeObjectURL(blobUrl), 5000);
  } catch (e) {
    toast.error('Error al descargar archivo');
    console.error(e);
  }
}

async function verImagen(msg) {
  try {
    const token = getToken();
    const url = getVerUrl(msg);
    const res = await fetch(url, { headers: token ? { Authorization: `Bearer ${token}` } : {} });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const blob = await res.blob();
    const blobUrl = URL.createObjectURL(blob);
    window.open(blobUrl, '_blank');
    setTimeout(() => URL.revokeObjectURL(blobUrl), 60000);
  } catch (e) {
    toast.error('Error al abrir imagen');
    console.error(e);
  }
}

function seleccionarArchivo() {
  inputArchivo.value?.click();
}

function onArchivoSeleccionado(event) {
  const file = event.target.files?.[0];
  if (!file) return;

  // Validación de tamaño de archivo (máximo 3 MB)
  const maxSize = 3 * 1024 * 1024; // 3 MB
  if (file.size > maxSize) {
    toast.error('El archivo excede el tamaño máximo permitido de 3 MB.');
    if (inputArchivo.value) inputArchivo.value.value = '';
    return;
  }

  archivoSeleccionado.value = file;
  if (file.type.startsWith('image/')) {
    archivoPreviewUrl.value = URL.createObjectURL(file);
  } else {
    archivoPreviewUrl.value = null;
  }
  if (inputArchivo.value) inputArchivo.value.value = '';
}

function quitarArchivo() {
  if (archivoPreviewUrl.value) {
    URL.revokeObjectURL(archivoPreviewUrl.value);
  }
  archivoSeleccionado.value = null;
  archivoPreviewUrl.value = null;
}

function formatoSize(bytes) {
  if (!bytes) return '';
  const sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(1024));
  return (bytes / Math.pow(1024, i)).toFixed(1) + ' ' + sizes[i];
}

const IMAGE_EXTS = ['jpg','jpeg','png','gif','webp','bmp','svg','ico','avif'];
const VIDEO_EXTS = ['mp4','webm','ogg','mov','avi','mkv'];
const AUDIO_EXTS = ['mp3','wav','ogg','aac','flac','m4a'];
const DOC_EXTS    = ['pdf'];
const WORD_EXTS   = ['doc','docx'];
const EXCEL_EXTS  = ['xls','xlsx','csv'];
const PPT_EXTS    = ['ppt','pptx'];
const ZIP_EXTS    = ['zip','rar','7z','tar','gz'];

function getExtension(filename) {
  if (!filename) return '';
  return filename.split('.').pop().toLowerCase();
}

function isImageFile(msg) {
  if (msg.archivo_tipo?.startsWith('image/')) return true;
  const ext = getExtension(msg.archivo_nombre);
  return IMAGE_EXTS.includes(ext);
}

function isVideoFile(msg) {
  if (msg.archivo_tipo?.startsWith('video/')) return true;
  const ext = getExtension(msg.archivo_nombre);
  return VIDEO_EXTS.includes(ext);
}

function isAudioFile(msg) {
  if (msg.archivo_tipo?.startsWith('audio/')) return true;
  const ext = getExtension(msg.archivo_nombre);
  return AUDIO_EXTS.includes(ext);
}

function isPdfFile(msg) {
  if (msg.archivo_tipo === 'application/pdf') return true;
  return getExtension(msg.archivo_nombre) === 'pdf';
}

function getFileType(msg) {
  if (isImageFile(msg)) return 'image';
  if (isVideoFile(msg)) return 'video';
  if (isAudioFile(msg)) return 'audio';
  if (isPdfFile(msg)) return 'pdf';
  const ext = getExtension(msg.archivo_nombre);
  if (WORD_EXTS.includes(ext)) return 'word';
  if (EXCEL_EXTS.includes(ext)) return 'excel';
  if (PPT_EXTS.includes(ext)) return 'ppt';
  if (ZIP_EXTS.includes(ext)) return 'zip';
  return 'file';
}

function getFileIcon(msg) {
  const type = getFileType(msg);
  const icons = {
    image: 'fas fa-image',
    video: 'fas fa-video',
    audio: 'fas fa-headphones',
    pdf: 'fas fa-file-pdf',
    word: 'fas fa-file-word',
    excel: 'fas fa-file-excel',
    ppt: 'fas fa-file-powerpoint',
    zip: 'fas fa-file-zipper',
    file: 'fas fa-file',
  };
  return icons[type] || 'fas fa-file';
}

function getFileColor(msg) {
  const type = getFileType(msg);
  const colors = {
    image: '#8b5cf6',
    video: '#ef4444',
    audio: '#f59e0b',
    pdf: '#ef4444',
    word: '#3b82f6',
    excel: '#22c55e',
    ppt: '#f97316',
    zip: '#a855f7',
    file: '#6b7280',
  };
  return colors[type] || '#6b7280';
}

async function crearChat() {
  try {
    await api.post('/chats', {
      titulo: form.value.titulo,
      descripcion: form.value.descripcion,
      participantes: form.value.participantes,
    });
    showModal.value = false;
    resetForm();
    await cargarChats();
  } catch (e) {
    toast.error(e.response?.data?.error || 'Error al crear chat');
  }
}

async function cerrarChat() {
  if (!chatActivo.value) return;
  if (!await confirm.ask({ message: '¿Cerrar este chat? No se podrán enviar más mensajes.', confirmText: 'Cerrar', type: 'warning' })) return;
  try {
    const chatId = chatActivo.value.id;
    await api.post(`/chats/${chatId}/cerrar`);
    chatActivo.value.estado = 'cerrado';
    chatActivo.value = null;
    chats.value = chats.value.filter(c => c.id !== chatId);
  } catch (e) {
    toast.error('Error al cerrar el chat');
  }
}

function toggleParticipante(id) {
  const idx = form.value.participantes.indexOf(id);
  if (idx >= 0) {
    form.value.participantes.splice(idx, 1);
  } else {
    form.value.participantes.push(id);
  }
}

function abrirModalNuevo() {
  form.value = { titulo: '', descripcion: '', participantes: [] };
  showModal.value = true;
  cargarUsuarios();
}

function resetForm() {
  form.value = { titulo: '', descripcion: '', participantes: [] };
}

function scrollBottom() {
  const el = mensajesContainer.value;
  if (el) el.scrollTop = el.scrollHeight;
}

function onScroll() {}

function toggleEmojiPicker() {
  mostrarEmojis.value = !mostrarEmojis.value;
}

function cerrarEmojiPicker() {
  mostrarEmojis.value = false;
}

function insertarEmoji(emoji) {
  const el = textareaMensaje.value;
  if (el) {
    const start = el.selectionStart || 0;
    const end = el.selectionEnd || 0;
    const text = nuevoMensaje.value;
    nuevoMensaje.value = text.slice(0, start) + emoji + text.slice(end);
    nextTick(() => {
      el.focus();
      const pos = start + emoji.length;
      el.setSelectionRange(pos, pos);
      autoResizeTextarea();
    });
  } else {
    nuevoMensaje.value += emoji;
  }
}

function formatoHora(fecha) {
  if (!fecha) return '';
  const d = new Date(fecha);
  const hoy = new Date();
  const esHoy = d.toDateString() === hoy.toDateString();
  if (esHoy) return d.toLocaleTimeString('es-CR', { hour: '2-digit', minute: '2-digit' });
  return d.toLocaleDateString('es-CR', { day: '2-digit', month: 'short' });
}

// Keyboard
function onKeydown(e) {
  if (e.key === 'Escape') {
    if (showModal.value) {
      showModal.value = false;
    } else {
      drawerStore.close();
    }
  }
}

// Click outside directive
const vClickOutside = {
  mounted(el, binding) {
    el._clickOutside = (event) => {
      if (!(el === event.target || el.contains(event.target))) {
        binding.value();
      }
    };
    document.addEventListener('click', el._clickOutside, true);
  },
  unmounted(el) {
    document.removeEventListener('click', el._clickOutside, true);
  }
};

// Echo listeners
watch(() => chatActivo.value?.id, (newId, oldId) => {
  if (oldId) {
    window.Echo?.leave(`chat.${oldId}`);
  }
  if (newId) {
    window.Echo?.private(`chat.${newId}`)
      .listen('.NuevoMensajeChat', (data) => {
        if (data.mensaje && data.mensaje.usuario_id !== userId.value) {
          mensajes.value.push(data.mensaje);
          if (data.mensaje.archivo_url) {
            cargarArchivoBlob(data.mensaje);
          }
          nextTick(() => scrollBottom());
          marcarLeido(newId);
        }
      });
  }
});

watch(() => drawerStore.isOpen, async (open) => {
  if (open) {
    await cargarChats();
    const lastId = drawerStore.activeChatId;
    if (lastId) {
      const chat = chats.value.find(c => c.id === lastId);
      if (chat) await abrirChat(chat);
    }
  } else {
    if (chatActivo.value) {
      window.Echo?.leave(`chat.${chatActivo.value.id}`);
    }
    chatActivo.value = null;
  }
});

let resizeHandler;
onMounted(() => {
  checkMobile();
  resizeHandler = () => checkMobile();
  window.addEventListener('resize', resizeHandler);
  document.addEventListener('keydown', onKeydown);

  const uid = userId.value;
  if (uid && window.Echo) {
    window.Echo.private(`user.${uid}`)
      .listen('.NuevoMensajeChat', () => {
        cargarChats();
      });
  }
});

onBeforeUnmount(() => {
  window.removeEventListener('resize', resizeHandler);
  document.removeEventListener('keydown', onKeydown);
  if (chatActivo.value) {
    window.Echo?.leave(`chat.${chatActivo.value.id}`);
  }
  const uid = userId.value;
  if (uid && window.Echo) {
    window.Echo.private(`user.${uid}`).stopListening('.NuevoMensajeChat');
  }
});
</script>

<style scoped>
/* =============================================
   Chat Drawer - Premium SaaS Design
   ============================================= */

.cd-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.35);
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
  opacity: 0;
  visibility: hidden;
  transition: opacity 0.35s cubic-bezier(0.4, 0, 0.2, 1), visibility 0.35s;
  z-index: 2400;
  will-change: opacity;
}

.cd-backdrop.active {
  opacity: 1;
  visibility: visible;
}

.cd-drawer {
  position: fixed;
  top: 0;
  right: 0;
  width: 920px;
  max-width: 100vw;
  height: 100vh;
  background: #d6eef8;
  border-left: 1px solid rgba(14,90,126,0.12);
  box-shadow: -20px 0 60px rgba(0,0,0,0.18);
  display: flex;
  flex-direction: column;
  transform: translateX(100%);
  transition: transform 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  z-index: 2500;
  will-change: transform;
  overflow: hidden;
}

.cd-drawer.open {
  transform: translateX(0);
}

/* Header */
.cd-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 20px;
  border-bottom: 1px solid rgba(14,90,126,0.15);
  background: #c5e7f5;
  flex-shrink: 0;
  gap: 12px;
}

.cd-header-brand {
  display: flex;
  align-items: center;
  gap: 12px;
  min-width: 0;
}

.cd-header-icon {
  width: 40px;
  height: 40px;
  border-radius: 12px;
  background: linear-gradient(135deg, #3aa8c4, #2196c4);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  flex-shrink: 0;
}

.cd-header-title {
  font-size: 16px;
  font-weight: 700;
  color: var(--text-primary, #1a2332);
  margin: 0;
  line-height: 1.2;
}

.cd-header-status {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 11px;
  color: #5a8a9e;
  margin-top: 2px;
}

.cd-status-dot {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: #9ca3af;
  display: inline-block;
}

.cd-status-dot.online {
  background: #3aa8c4;
  box-shadow: 0 0 6px rgba(58,168,196,0.5);
}

.cd-header-actions {
  display: flex;
  align-items: center;
  gap: 6px;
  flex-shrink: 0;
}

.cd-header-badge {
  background: #ef4444;
  color: #fff;
  font-size: 11px;
  font-weight: 700;
  padding: 2px 8px;
  border-radius: 10px;
  line-height: 1;
}

.cd-btn-icon {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  border: none;
  background: transparent;
  color: #0e5a7e;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  transition: all 0.2s ease;
  flex-shrink: 0;
}

.cd-btn-icon:hover {
  background: rgba(14,90,126,0.12);
  color: #073d57;
}

/* Body */
.cd-body {
  flex: 1;
  display: flex;
  min-height: 0;
  overflow: hidden;
}

/* Sidebar */
.cd-sidebar {
  width: 320px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  border-right: 1px solid rgba(14,90,126,0.12);
  background: #bfe3f2;
}

.cd-search {
  padding: 10px 14px;
  position: relative;
  flex-shrink: 0;
}

.cd-search i {
  position: absolute;
  left: 26px;
  top: 50%;
  transform: translateY(-50%);
  color: #7aafbf;
  font-size: 12px;
}

.cd-search input {
  width: 100%;
  padding: 10px 14px 10px 38px;
  border-radius: 10px;
  border: 1px solid rgba(14,90,126,0.15);
  background: #eaf5fb;
  color: #1a2332;
  font-size: 13px;
  outline: none;
  transition: all 0.2s;
}

.cd-search input:focus {
  border-color: #3aa8c4;
  box-shadow: 0 0 0 3px rgba(58,168,196,0.2);
}

.cd-chat-list {
  flex: 1;
  overflow-y: auto;
  padding: 4px 8px 12px;
}

.cd-chat-item {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 12px;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
  margin-bottom: 2px;
  position: relative;
}

.cd-chat-item:hover {
  background: var(--bg-hover, rgba(0,0,0,0.04));
}

.cd-chat-item.active {
  background: rgba(58,168,196,0.15);
}

.cd-chat-item.pinned::before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 3px;
  height: 24px;
  background: #3aa8c4;
  border-radius: 0 3px 3px 0;
}

.cd-chat-avatar {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: linear-gradient(135deg, #3aa8c4, #2196c4);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 13px;
  font-weight: 700;
  flex-shrink: 0;
  position: relative;
}

.cd-avatar-unread {
  position: absolute;
  top: -2px;
  right: -2px;
  background: #ef4444;
  color: #fff;
  font-size: 10px;
  font-weight: 700;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.cd-chat-meta {
  flex: 1;
  min-width: 0;
}

.cd-chat-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 8px;
  margin-bottom: 2px;
}

.cd-chat-name {
  font-weight: 600;
  font-size: 14px;
  color: var(--text-primary, #1a2332);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.cd-chat-time {
  font-size: 11px;
  color: #7aafbf;
  flex-shrink: 0;
}

.cd-chat-preview {
  font-size: 12px;
  color: var(--text-secondary, #4b5563);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.cd-chat-participants {
  font-size: 11px;
  color: #7aafbf;
  margin-top: 2px;
}

.cd-empty {
  text-align: center;
  padding: 40px 20px;
  color: #7aafbf;
}

.cd-empty i {
  font-size: 36px;
  margin-bottom: 10px;
  opacity: 0.5;
}

/* Skeleton */
.cd-skeleton {
  pointer-events: none;
}

.cd-skeleton-avatar {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: linear-gradient(90deg, rgba(0,0,0,0.06) 25%, rgba(0,0,0,0.12) 50%, rgba(0,0,0,0.06) 75%);
  background-size: 200% 100%;
  animation: cdSkeleton 1.5s infinite;
  flex-shrink: 0;
}

.cd-skeleton-lines {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding-top: 4px;
}

.cd-skeleton-line {
  height: 10px;
  border-radius: 5px;
  background: linear-gradient(90deg, rgba(0,0,0,0.06) 25%, rgba(0,0,0,0.12) 50%, rgba(0,0,0,0.06) 75%);
  background-size: 200% 100%;
  animation: cdSkeleton 1.5s infinite;
}

.cd-skeleton-line.short {
  width: 60%;
}

@keyframes cdSkeleton {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

/* Chat Area */
.cd-chat-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
  background: #eaf5fb;
}

.cd-chat-header {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  border-bottom: 1px solid rgba(14,90,126,0.12);
  background: #c5e7f5;
  flex-shrink: 0;
}

.cd-back-btn {
  display: none;
}

.cd-chat-header-avatar {
  width: 38px;
  height: 38px;
  border-radius: 50%;
  background: linear-gradient(135deg, #3aa8c4, #2196c4);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 700;
  flex-shrink: 0;
}

.cd-chat-header-info {
  flex: 1;
  min-width: 0;
}

.cd-chat-header-name {
  font-weight: 600;
  font-size: 15px;
  color: var(--text-primary, #1a2332);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.cd-chat-header-meta {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: #5a8a9e;
  margin-top: 1px;
}

.cd-badge {
  font-size: 10px;
  font-weight: 600;
  padding: 2px 8px;
  border-radius: 6px;
  line-height: 1;
}

.cd-badge-success {
  background: rgba(58,168,196,0.15);
  color: #1a8fa8;
}

.cd-badge-danger {
  background: rgba(239,68,68,0.12);
  color: #dc2626;
}

.cd-participants-text {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* Messages */
.cd-messages {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.cd-msg {
  display: flex;
  animation: cdMsgIn 0.25s ease-out;
}

@keyframes cdMsgIn {
  from { opacity: 0; transform: translateY(6px); }
  to { opacity: 1; transform: translateY(0); }
}

.cd-msg.own {
  justify-content: flex-end;
}

.cd-msg.typing {
  justify-content: flex-start;
  animation: none;
}

.cd-msg-bubble {
  max-width: 70%;
  padding: 10px 14px;
  border-radius: 16px;
  background: #ffffff;
  border: 1px solid rgba(14,90,126,0.1);
  box-shadow: 0 1px 3px rgba(0,0,0,0.04);
}

.cd-msg.own .cd-msg-bubble {
  background: linear-gradient(135deg, #3aa8c4, #2196c4);
  color: #fff;
  border-color: transparent;
  border-bottom-right-radius: 4px;
}

.cd-msg:not(.own) .cd-msg-bubble {
  border-bottom-left-radius: 4px;
}

.cd-msg-author {
  font-size: 11px;
  font-weight: 600;
  color: #1a8fa8;
  margin-bottom: 4px;
}

.cd-msg-text {
  font-size: 13px;
  line-height: 1.5;
  word-break: break-word;
  white-space: pre-wrap;
}

.cd-msg-footer {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 6px;
  margin-top: 4px;
}

.cd-msg-time {
  font-size: 10px;
  color: #7aafbf;
}

.cd-msg.own .cd-msg-time {
  color: rgba(255,255,255,0.7);
}

.cd-msg-check {
  font-size: 10px;
  color: rgba(255,255,255,0.8);
}

/* Attachments */
.cd-msg-attachment {
  margin-top: 8px;
}

.cd-attachment-image-link {
  display: block;
  max-width: 280px;
  border-radius: 12px;
  overflow: hidden;
  border: 1px solid rgba(14,90,126,0.12);
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
}

.cd-attachment-image-link:hover {
  transform: scale(1.02);
  box-shadow: 0 4px 16px rgba(0,0,0,0.15);
}

.cd-attachment-image {
  width: 100%;
  height: auto;
  max-height: 320px;
  display: block;
  object-fit: cover;
}

.cd-attachment-image-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 24px 20px;
  border-radius: 12px;
  background: rgba(14,90,126,0.04);
  border: 2px dashed rgba(14,90,126,0.18);
  cursor: pointer;
  transition: all 0.2s;
  min-width: 180px;
  color: #7aafbf;
  font-size: 12px;
}

.cd-attachment-image-loading:hover {
  border-color: #3aa8c4;
  color: #1a8fa8;
  background: rgba(58,168,196,0.08);
}

.cd-attachment-image-loading.cd-attachment-error {
  border-color: rgba(239,68,68,0.4);
  color: #ef4444;
  background: rgba(239,68,68,0.05);
}

.cd-attachment-image-loading.cd-attachment-error:hover {
  border-color: #ef4444;
  background: rgba(239,68,68,0.1);
}

.cd-attachment-image-loading i {
  font-size: 28px;
  opacity: 0.6;
}

.cd-attachment-error i {
  color: #ef4444;
}

/* Video */
.cd-attachment-video {
  max-width: 300px;
  border-radius: 12px;
  overflow: hidden;
  border: 1px solid rgba(14,90,126,0.12);
}

.cd-attachment-video-el {
  width: 100%;
  max-height: 280px;
  display: block;
  background: #000;
  outline: none;
}

/* Audio */
.cd-attachment-audio {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px 12px;
  border-radius: 12px;
  background: #eaf5fb;
  border: 1px solid rgba(14,90,126,0.12);
  min-width: 220px;
}

.cd-audio-icon {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  font-size: 14px;
  flex-shrink: 0;
}

.cd-audio-info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.cd-audio-name {
  font-size: 12px;
  font-weight: 600;
  color: var(--text-primary, #1a2332);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.cd-audio-el {
  width: 100%;
  height: 32px;
}

.cd-audio-load-btn {
  background: none;
  border: 1px solid rgba(14,90,126,0.2);
  border-radius: 6px;
  padding: 4px 10px;
  font-size: 11px;
  color: #1a8fa8;
  cursor: pointer;
  transition: all 0.15s;
}

.cd-audio-load-btn:hover {
  background: rgba(14,90,126,0.08);
}

.cd-audio-load-btn.cd-audio-error {
  color: #ef4444;
  border-color: rgba(239,68,68,0.3);
}

/* File cards */
.cd-attachment-file {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 14px;
  border-radius: 12px;
  background: #eaf5fb;
  border: 1px solid rgba(14,90,126,0.12);
  color: #1a2332;
  font-size: 13px;
  text-decoration: none;
  transition: all 0.15s;
  cursor: pointer;
  max-width: 300px;
}

.cdattachment-file:hover {
  background: rgba(14,90,126,0.06);
  border-color: rgba(14,90,126,0.2);
}

.cd-file-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  flex-shrink: 0;
}

.cd-attachment-file-info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  line-height: 1.3;
}

.cd-attachment-file-name {
  font-weight: 600;
  font-size: 13px;
  max-width: 180px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.cd-attachment-file-size {
  font-size: 11px;
  color: #5a8a9e;
}

.cd-file-action {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #7aafbf;
  font-size: 13px;
  transition: all 0.15s;
  flex-shrink: 0;
}

.cd-attachment-file:hover .cd-file-action {
  background: rgba(14,90,126,0.08);
  color: #1a8fa8;
}

/* Own message attachments */
.cd-msg.own .cd-attachment-image-link {
  border-color: rgba(255,255,255,0.2);
}

.cd-msg.own .cd-attachment-file {
  background: rgba(255,255,255,0.12);
  border-color: rgba(255,255,255,0.15);
  color: #fff;
}

.cd-msg.own .cd-attachment-file-name {
  color: #fff;
}

.cd-msg.own .cd-attachment-file-size {
  color: rgba(255,255,255,0.6);
}

.cd-msg.own .cd-file-action {
  color: rgba(255,255,255,0.5);
}

.cd-msg.own .cd-attachment-file:hover .cd-file-action {
  background: rgba(255,255,255,0.12);
  color: #fff;
}

.cd-msg.own .cd-attachment-audio {
  background: rgba(255,255,255,0.12);
  border-color: rgba(255,255,255,0.15);
}

.cd-msg.own .cd-audio-name {
  color: #fff;
}

/* Typing */
.cd-typing-dots {
  display: flex;
  gap: 4px;
  padding: 4px 8px;
}

.cd-typing-dots span {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--text-muted, #9ca3af);
  animation: cdTypingBounce 1.2s infinite;
}

.cd-typing-dots span:nth-child(2) { animation-delay: 0.2s; }
.cd-typing-dots span:nth-child(3) { animation-delay: 0.4s; }

@keyframes cdTypingBounce {
  0%, 60%, 100% { transform: translateY(0); }
  30% { transform: translateY(-4px); }
}

/* Input Area */
.cd-input-area {
  flex-shrink: 0;
  padding: 12px 16px;
  border-top: 1px solid rgba(14,90,126,0.12);
  background: #c5e7f5;
}

.cd-file-preview {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px 12px;
  margin-bottom: 10px;
  border-radius: 10px;
  background: #eaf5fb;
  border: 1px solid rgba(14,90,126,0.12);
}

.cd-file-preview-thumb {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  overflow: hidden;
  flex-shrink: 0;
}

.cd-file-preview-thumb img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.cd-file-preview-icon {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  background: rgba(14,90,126,0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #1a8fa8;
  font-size: 16px;
  flex-shrink: 0;
}

.cd-file-preview-info {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: var(--text-primary, #1a2332);
  min-width: 0;
}

.cd-file-preview-name {
  font-weight: 600;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.cd-file-preview-size {
  font-size: 11px;
  color: var(--text-muted, #6b7280);
  flex-shrink: 0;
}

.cd-file-remove {
  color: #ef4444;
}

.cd-input-wrapper {
  display: flex;
  align-items: flex-end;
  gap: 8px;
  position: relative;
}

.cd-input-btn {
  width: 38px;
  height: 38px;
  border-radius: 50%;
  color: #0e5a7e;
  font-size: 18px;
  margin-bottom: 1px;
}

.cd-input-btn:hover {
  color: #073d57;
  background: rgba(14,90,126,0.12);
}

.cd-textarea {
  flex: 1;
  min-height: 42px;
  max-height: 120px;
  padding: 10px 14px;
  border-radius: 20px;
  border: 1px solid rgba(14,90,126,0.2);
  background: #eaf5fb;
  color: #1a2332;
  font-size: 14px;
  line-height: 1.4;
  resize: none;
  outline: none;
  transition: all 0.2s;
  font-family: inherit;
}

.cd-textarea:focus {
  border-color: #3aa8c4;
  box-shadow: 0 0 0 3px rgba(58,168,196,0.2);
}

.cd-btn-send {
  width: 42px;
  height: 42px;
  border-radius: 50%;
  border: none;
  background: linear-gradient(135deg, #3aa8c4, #2196c4);
  color: #fff;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  transition: all 0.2s ease;
  flex-shrink: 0;
  margin-bottom: 1px;
}

.cd-btn-send:hover:not(:disabled) {
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(58,168,196,0.35);
}

.cd-btn-send:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

/* Emoji Picker */
.cd-emoji-picker {
  position: absolute;
  bottom: calc(100% + 12px);
  left: 0;
  background: #ffffff;
  border: 1px solid rgba(0,73,107,0.08);
  border-radius: 16px;
  box-shadow: 0 12px 32px rgba(0,0,0,0.2);
  z-index: 100;
  width: 340px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.cd-emoji-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 14px;
  border-bottom: 1px solid rgba(14,90,126,0.12);
  font-size: 13px;
  font-weight: 600;
  color: #3a7a94;
}

.cd-emoji-body {
  max-height: 260px;
  overflow-y: auto;
  padding: 10px 12px;
}

.cd-emoji-body::-webkit-scrollbar {
  width: 6px;
}

.cd-emoji-body::-webkit-scrollbar-track {
  background: transparent;
}

.cd-emoji-body::-webkit-scrollbar-thumb {
  background: var(--bg-hover, rgba(0,0,0,0.1));
  border-radius: 3px;
}

.cd-emoji-group {
  margin-bottom: 10px;
}

.cd-emoji-group:last-child {
  margin-bottom: 0;
}

.cd-emoji-group-label {
  font-size: 11px;
  font-weight: 600;
  color: var(--text-muted, #9ca3af);
  text-transform: uppercase;
  letter-spacing: 0.4px;
  margin-bottom: 6px;
  padding-left: 2px;
}

.cd-emoji-grid {
  display: grid;
  grid-template-columns: repeat(8, 1fr);
  gap: 2px;
}

.cd-emoji-item {
  font-size: 22px;
  text-align: center;
  cursor: pointer;
  padding: 4px 2px;
  border-radius: 8px;
  transition: all 0.12s;
  user-select: none;
  line-height: 1.2;
}

.cd-emoji-item:hover {
  background: var(--bg-hover, rgba(0,0,0,0.06));
  transform: scale(1.15);
}

/* Closed bar */
.cd-closed-bar {
  padding: 14px;
  text-align: center;
  color: #5a8a9e;
  font-size: 13px;
  border-top: 1px solid rgba(14,90,126,0.12);
  background: #c5e7f5;
  flex-shrink: 0;
}

/* Empty Main */
.cd-empty-main {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #eaf5fb;
}

.cd-empty-center {
  text-align: center;
  color: var(--text-muted, #9ca3af);
  padding: 20px;
}

.cd-empty-illustration {
  width: 80px;
  height: 80px;
  border-radius: 24px;
  background: rgba(14,90,126,0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 16px;
  font-size: 32px;
  color: #7aafbf;
}

.cd-empty-center h3 {
  color: var(--text-primary, #1a2332);
  margin-bottom: 6px;
  font-size: 18px;
}

.cd-empty-center p {
  font-size: 14px;
  max-width: 280px;
  margin: 0 auto;
}

/* Modal */
.cd-modal-overlay {
  position: absolute;
  inset: 0;
  background: rgba(0,0,0,0.45);
  backdrop-filter: blur(6px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 3000;
  animation: cdFadeIn 0.2s ease;
}

@keyframes cdFadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.cd-modal {
  width: 100%;
  max-width: 480px;
  margin: 20px;
  background: #d6eef8;
  border-radius: 20px;
  box-shadow: 0 24px 60px rgba(0,0,0,0.2);
  animation: cdSlideUp 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  display: flex;
  flex-direction: column;
  max-height: calc(100vh - 40px);
  overflow: hidden;
}

@keyframes cdSlideUp {
  from { opacity: 0; transform: translateY(20px) scale(0.96); }
  to { opacity: 1; transform: translateY(0) scale(1); }
}

.cd-modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px;
  border-bottom: 1px solid rgba(14,90,126,0.12);
}

.cd-modal-header h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 700;
  color: var(--text-primary, #1a2332);
}

.cd-modal-body {
  padding: 20px;
  overflow-y: auto;
}

.cd-modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  padding: 14px 20px;
  border-top: 1px solid rgba(14,90,126,0.12);
}

/* Form */
.cd-form-group {
  margin-bottom: 16px;
}

.cd-form-group:last-child {
  margin-bottom: 0;
}

.cd-form-group label {
  display: block;
  font-size: 13px;
  font-weight: 600;
  color: var(--text-primary, #1a2332);
  margin-bottom: 6px;
}

.cd-required {
  color: var(--danger, #ef4444);
}

.cd-form-input,
.cd-form-textarea {
  width: 100%;
  padding: 10px 14px;
  border-radius: 10px;
  border: 1px solid rgba(14,90,126,0.2);
  background: #eaf5fb;
  color: #1a2332;
  font-size: 14px;
  outline: none;
  transition: all 0.2s;
  font-family: inherit;
}

.cd-form-input:focus,
.cd-form-textarea:focus {
  border-color: #3aa8c4;
  box-shadow: 0 0 0 3px rgba(58,168,196,0.2);
}

.cd-form-textarea {
  resize: vertical;
  min-height: 60px;
}

/* Participantes */
.cd-participantes-selector {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  max-height: 200px;
  overflow-y: auto;
  padding: 4px;
}

.cd-participante-chip {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  border-radius: 20px;
  border: 1px solid rgba(14,90,126,0.15);
  background: #eaf5fb;
  font-size: 13px;
  color: #1a2332;
  cursor: pointer;
  user-select: none;
  transition: all 0.15s;
}

.cd-participante-chip.selected {
  background: linear-gradient(135deg, #3aa8c4, #2196c4);
  color: #fff;
  border-color: transparent;
}

.cd-participante-chip:hover {
  border-color: #3aa8c4;
}

/* Buttons */
.cd-btn {
  padding: 8px 16px;
  border-radius: 10px;
  border: none;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-family: inherit;
}

.cd-btn-primary {
  background: linear-gradient(135deg, #3aa8c4, #2196c4);
  color: #fff;
}

.cd-btn-primary:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(14,59,88,0.25);
}

.cd-btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.cd-btn-ghost {
  background: transparent;
  color: #3a7a94;
  border: 1px solid rgba(14,90,126,0.2);
}

.cd-btn-ghost:hover {
  background: rgba(14,90,126,0.08);
}

/* Scrollbar */
.cd-chat-list::-webkit-scrollbar,
.cd-messages::-webkit-scrollbar,
.cd-modal-body::-webkit-scrollbar {
  width: 5px;
}

.cd-chat-list::-webkit-scrollbar-track,
.cd-messages::-webkit-scrollbar-track,
.cd-modal-body::-webkit-scrollbar-track {
  background: transparent;
}

.cd-chat-list::-webkit-scrollbar-thumb,
.cd-messages::-webkit-scrollbar-thumb,
.cd-modal-body::-webkit-scrollbar-thumb {
  background: rgba(14,90,126,0.2);
  border-radius: 3px;
}

/* Responsive */
@media (max-width: 1023px) {
  .cd-drawer {
    width: 480px;
  }
  .cd-sidebar {
    width: 280px;
  }
}

@media (max-width: 768px) {
  .cd-drawer {
    width: 100vw;
  }

  .cd-sidebar {
    width: 100%;
    border-right: none;
  }

  .cd-sidebar.mobile-hidden {
    display: none;
  }

  .cd-chat-area.mobile-full {
    width: 100%;
  }

  .cd-back-btn {
    display: inline-flex;
  }

  .cd-chat-header-name {
    font-size: 14px;
  }

  .cd-msg-bubble {
    max-width: 85%;
  }

  .cd-emoji-picker {
    width: min(340px, 90vw);
  }

  .cd-emoji-grid {
    grid-template-columns: repeat(6, 1fr);
  }

  .cd-btn-icon {
    min-width: 44px;
    min-height: 44px;
  }

  .cd-input-btn {
    min-width: 44px;
    min-height: 44px;
  }

  .cd-btn-send {
    min-width: 44px;
    min-height: 44px;
  }

  .cd-attachment-image-link {
    max-width: 100%;
  }

  .cd-attachment-file {
    max-width: 100%;
  }

  .cd-attachment-video {
    max-width: 100%;
  }

  .cd-attachment-audio {
    min-width: unset;
    width: 100%;
  }
}

@media (max-width: 480px) {
  .cd-header {
    padding: 10px 12px;
  }

  .cd-header-title {
    font-size: 14px;
  }

  .cd-messages {
    padding: 10px;
  }

  .cd-msg-bubble {
    max-width: 90%;
    padding: 8px 12px;
  }

  .cd-input-area {
    padding: 8px 10px;
  }

  .cd-textarea {
    font-size: 16px;
  }

  .cd-emoji-picker {
    width: min(300px, 95vw);
    left: -20px;
  }

  .cd-emoji-grid {
    grid-template-columns: repeat(6, 1fr);
  }

  .cd-modal {
    margin: 10px;
    border-radius: 14px;
  }

  .cd-modal-header {
    padding: 12px 14px;
  }

  .cd-modal-body {
    padding: 14px;
  }

  .cd-modal-footer {
    padding: 10px 14px;
    flex-direction: column;
  }

  .cd-modal-footer .cd-btn {
    width: 100%;
    justify-content: center;
    min-height: 44px;
  }
}

/* Dark theme overrides via data-theme on html */
[data-theme="dark"] .cd-drawer,
[data-theme="dark"] .cd-header,
[data-theme="dark"] .cd-sidebar,
[data-theme="dark"] .cd-chat-header,
[data-theme="dark"] .cd-input-area,
[data-theme="dark"] .cd-closed-bar,
[data-theme="dark"] .cd-modal {
  background: #0c1929;
  border-color: rgba(255,255,255,0.06);
}

[data-theme="dark"] .cd-chat-area,
[data-theme="dark"] .cd-empty-main,
[data-theme="dark"] .cd-search input,
[data-theme="dark"] .cd-textarea,
[data-theme="dark"] .cd-form-input,
[data-theme="dark"] .cd-form-textarea,
[data-theme="dark"] .cd-participante-chip,
[data-theme="dark"] .cd-attachment-file,
[data-theme="dark"] .cd-attachment-audio,
[data-theme="dark"] .cd-file-preview,
[data-theme="dark"] .cd-empty-illustration {
  background: #0a1525;
  border-color: rgba(255,255,255,0.06);
  color: var(--text-primary, #e2e8f0);
}

[data-theme="dark"] .cd-btn-icon,
[data-theme="dark"] .cd-input-btn {
  color: #7ec8e3;
}

[data-theme="dark"] .cd-btn-icon:hover,
[data-theme="dark"] .cd-input-btn:hover {
  background: rgba(58,168,196,0.15);
  color: #a3ddef;
}

[data-theme="dark"] .cd-btn-send,
[data-theme="dark"] .cd-btn-primary,
[data-theme="dark"] .cd-participante-chip.selected {
  background: linear-gradient(135deg, #2a7a8c, #1a6a7c);
}

[data-theme="dark"] .cd-chat-item:hover {
  background: rgba(255,255,255,0.04);
}

[data-theme="dark"] .cd-chat-item.active {
  background: rgba(58,168,196,0.2);
}

[data-theme="dark"] .cd-header-title,
[data-theme="dark"] .cd-chat-name,
[data-theme="dark"] .cd-chat-header-name,
[data-theme="dark"] .cd-empty-center h3,
[data-theme="dark"] .cd-modal-header h3,
[data-theme="dark"] .cd-form-group label {
  color: var(--text-primary, #e2e8f0);
}

[data-theme="dark"] .cd-chat-preview,
[data-theme="dark"] .cd-msg-author,
[data-theme="dark"] .cd-empty-center p {
  color: var(--text-secondary, #cbd5e1);
}

[data-theme="dark"] .cd-msg-author {
  color: #7ec8e3;
}

[data-theme="dark"] .cd-search input::placeholder,
[data-theme="dark"] .cd-textarea::placeholder {
  color: var(--text-muted, #64748b);
}

[data-theme="dark"] .cd-backdrop {
  background: rgba(0,0,0,0.55);
}

[data-theme="dark"] .cd-badge-success {
  background: rgba(58,168,196,0.2);
  color: #7ec8e3;
}

[data-theme="dark"] .cd-header-status {
  color: #8ab4c8;
}

[data-theme="dark"] .cd-status-dot {
  background: #5a8a9e;
}

[data-theme="dark"] .cd-status-dot.online {
  background: #3aa8c4;
  box-shadow: 0 0 6px rgba(58,168,196,0.6);
}
</style>
