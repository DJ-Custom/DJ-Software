<template>
  <div class="app-layout">
    <div class="sidebar-backdrop" :class="{ active: mobileOpen }" @click="mobileOpen = false"></div>

    <aside class="sidebar" :class="{ collapsed: sidebarCollapsed, 'mobile-open': mobileOpen }" :style="sidebarStyle" ref="sidebarRef" @contextmenu="onSidebarContextMenu($event)">
      <div class="sidebar-resize-handle" @mousedown.prevent="startResize"></div>
      <div class="sidebar-header">
        <img src="/images/logo-dark-theme.png" alt="Logo" class="sidebar-logo" />
        <div class="sidebar-brand">
          <h2>Dreepo</h2>
          <span>{{ nombreNegocio || 'ERP' }}</span>
        </div>
      </div>

      <nav class="sidebar-nav">
        <div class="nav-section" v-if="visibleFavorites.length">
          <div class="nav-section-title fav-section-title">
            <i class="fas fa-star" style="color: #f59e0b; margin-right: 6px;"></i>{{ i18nStore.t('favoritos') }}
          </div>
          <div
            v-for="slug in visibleFavorites"
            :key="'fav-' + slug"
            class="nav-item-wrapper"
            :data-slug="slug"
            :class="{ 'long-pressing': isPressing && longPressTarget === slug, 'reorder-active': reorderActiveSlug === slug }"
            @pointerdown="onItemPointerDown(slug, $event)"
            @pointerup="onItemPointerUp"
            @pointerleave="onItemPointerLeave"
            @contextmenu.prevent
          >
            <router-link
              :to="moduleMap[slug].route"
              class="nav-item"
              :class="{ active: $route.path === moduleMap[slug].route }"
              @click="mobileOpen = false"
            >
              <i :class="moduleMap[slug].icon"></i>
              <span>{{ i18nStore.t(moduleMap[slug].labelKey) }}</span>
              <button class="fav-toggle fav-active" @click.prevent="toggleFavorite(slug, $event)" :title="i18nStore.t('remover_favorito')">
                <i class="fas fa-star"></i>
              </button>
            </router-link>
            <div v-if="reorderActiveSlug === slug" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem(slug, 'up')" :title="'Subir'"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem(slug, 'down')" :title="'Bajar'"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder" :title="'Cerrar'"><i class="fas fa-times"></i></button>
            </div>
          </div>
        </div>

        <div class="nav-section" v-if="hasAnyModule('dashboard', 'business_intelligence', 'reportes')">
          <div class="nav-section-title">{{ i18nStore.t('sec_principal') }}</div>
          <div class="nav-item-wrapper" data-slug="dashboard"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'dashboard', 'reorder-active': reorderActiveSlug === 'dashboard' }"
            @pointerdown="onItemPointerDown('dashboard', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('dashboard')" to="/dashboard" class="nav-item" :class="{ active: $route.path === '/dashboard' }" @click="mobileOpen = false"><i class="fas fa-home"></i><span>{{ i18nStore.t('dashboard') }}</span></router-link>
            <button v-if="authStore.hasModule('dashboard')" class="fav-toggle" :class="{ 'fav-active': isFavorite('dashboard') }" @click="toggleFavorite('dashboard', $event)" :title="isFavorite('dashboard') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'dashboard'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('dashboard', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('dashboard', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="business_intelligence"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'business_intelligence', 'reorder-active': reorderActiveSlug === 'business_intelligence' }"
            @pointerdown="onItemPointerDown('business_intelligence', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('business_intelligence')" to="/business-intelligence" class="nav-item" :class="{ active: $route.path === '/business-intelligence' }" @click="mobileOpen = false"><i class="fas fa-brain"></i><span>{{ i18nStore.t('business_intelligence') }}</span></router-link>
            <button v-if="authStore.hasModule('business_intelligence')" class="fav-toggle" :class="{ 'fav-active': isFavorite('business_intelligence') }" @click="toggleFavorite('business_intelligence', $event)" :title="isFavorite('business_intelligence') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'business_intelligence'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('business_intelligence', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('business_intelligence', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="reportes"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'reportes', 'reorder-active': reorderActiveSlug === 'reportes' }"
            @pointerdown="onItemPointerDown('reportes', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('reportes')" to="/reportes" class="nav-item" :class="{ active: $route.path === '/reportes' }" @click="mobileOpen = false"><i class="fas fa-chart-bar"></i><span>{{ i18nStore.t('reportes') }}</span></router-link>
            <button v-if="authStore.hasModule('reportes')" class="fav-toggle" :class="{ 'fav-active': isFavorite('reportes') }" @click="toggleFavorite('reportes', $event)" :title="isFavorite('reportes') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'reportes'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('reportes', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('reportes', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
        </div>
        <div class="nav-section" v-if="hasAnyModule('caja', 'ventas', 'devoluciones', 'notas_credito', 'cotizaciones', 'enviar_cotizacion', 'pedidos', 'combos', 'ticket_designer', 'cotizacion_designer')">
          <div class="nav-section-title">{{ i18nStore.t('sec_punto_venta') }}</div>
          <div class="nav-item-wrapper" data-slug="caja"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'caja', 'reorder-active': reorderActiveSlug === 'caja' }"
            @pointerdown="onItemPointerDown('caja', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('caja')" to="/caja" class="nav-item" :class="{ active: $route.path === '/caja' }" @click="mobileOpen = false"><i class="fas fa-cash-register"></i><span>{{ i18nStore.t('caja_rapida') }}</span></router-link>
            <button v-if="authStore.hasModule('caja')" class="fav-toggle" :class="{ 'fav-active': isFavorite('caja') }" @click="toggleFavorite('caja', $event)" :title="isFavorite('caja') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'caja'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('caja', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('caja', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="ventas"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'ventas', 'reorder-active': reorderActiveSlug === 'ventas' }"
            @pointerdown="onItemPointerDown('ventas', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('ventas')" to="/ventas" class="nav-item" :class="{ active: $route.path === '/ventas' }" @click="mobileOpen = false"><i class="fas fa-receipt"></i><span>{{ i18nStore.t('historial_ventas') }}</span></router-link>
            <button v-if="authStore.hasModule('ventas')" class="fav-toggle" :class="{ 'fav-active': isFavorite('ventas') }" @click="toggleFavorite('ventas', $event)" :title="isFavorite('ventas') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'ventas'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('ventas', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('ventas', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="devoluciones"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'devoluciones', 'reorder-active': reorderActiveSlug === 'devoluciones' }"
            @pointerdown="onItemPointerDown('devoluciones', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('devoluciones')" to="/devoluciones" class="nav-item" :class="{ active: $route.path === '/devoluciones' }" @click="mobileOpen = false"><i class="fas fa-undo"></i><span>{{ i18nStore.t('devoluciones') }}</span></router-link>
            <button v-if="authStore.hasModule('devoluciones')" class="fav-toggle" :class="{ 'fav-active': isFavorite('devoluciones') }" @click="toggleFavorite('devoluciones', $event)" :title="isFavorite('devoluciones') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'devoluciones'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('devoluciones', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('devoluciones', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="notas_credito"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'notas_credito', 'reorder-active': reorderActiveSlug === 'notas_credito' }"
            @pointerdown="onItemPointerDown('notas_credito', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('notas_credito')" to="/notas-credito" class="nav-item" :class="{ active: $route.path === '/notas-credito' }" @click="mobileOpen = false"><i class="fas fa-file-invoice"></i><span>{{ i18nStore.t('notas_credito') }}</span></router-link>
            <button v-if="authStore.hasModule('notas_credito')" class="fav-toggle" :class="{ 'fav-active': isFavorite('notas_credito') }" @click="toggleFavorite('notas_credito', $event)" :title="isFavorite('notas_credito') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'notas_credito'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('notas_credito', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('notas_credito', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="cotizaciones"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'cotizaciones', 'reorder-active': reorderActiveSlug === 'cotizaciones' }"
            @pointerdown="onItemPointerDown('cotizaciones', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('cotizaciones')" to="/cotizaciones" class="nav-item" :class="{ active: $route.path === '/cotizaciones' }" @click="mobileOpen = false"><i class="fas fa-file-alt"></i><span>{{ i18nStore.t('cotizaciones') }}</span></router-link>
            <button v-if="authStore.hasModule('cotizaciones')" class="fav-toggle" :class="{ 'fav-active': isFavorite('cotizaciones') }" @click="toggleFavorite('cotizaciones', $event)" :title="isFavorite('cotizaciones') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'cotizaciones'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('cotizaciones', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('cotizaciones', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="enviar_cotizacion"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'enviar_cotizacion', 'reorder-active': reorderActiveSlug === 'enviar_cotizacion' }"
            @pointerdown="onItemPointerDown('enviar_cotizacion', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('cotizaciones')" to="/enviar-cotizacion" class="nav-item" :class="{ active: $route.path === '/enviar-cotizacion' }" @click="mobileOpen = false"><i class="fas fa-paper-plane"></i><span>{{ i18nStore.t('enviar_cotizacion') }}</span></router-link>
            <button v-if="authStore.hasModule('cotizaciones')" class="fav-toggle" :class="{ 'fav-active': isFavorite('enviar_cotizacion') }" @click="toggleFavorite('enviar_cotizacion', $event)" :title="isFavorite('enviar_cotizacion') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'enviar_cotizacion'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('enviar_cotizacion', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('enviar_cotizacion', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="pedidos"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'pedidos', 'reorder-active': reorderActiveSlug === 'pedidos' }"
            @pointerdown="onItemPointerDown('pedidos', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('pedidos')" to="/pedidos" class="nav-item" :class="{ active: $route.path === '/pedidos' }" @click="mobileOpen = false"><i class="fas fa-clipboard-list"></i><span>{{ i18nStore.t('pedidos') }}</span></router-link>
            <button v-if="authStore.hasModule('pedidos')" class="fav-toggle" :class="{ 'fav-active': isFavorite('pedidos') }" @click="toggleFavorite('pedidos', $event)" :title="isFavorite('pedidos') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'pedidos'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('pedidos', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('pedidos', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="combos"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'combos', 'reorder-active': reorderActiveSlug === 'combos' }"
            @pointerdown="onItemPointerDown('combos', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('combos')" to="/combos" class="nav-item" :class="{ active: $route.path === '/combos' }" @click="mobileOpen = false"><i class="fas fa-tags"></i><span>{{ i18nStore.t('combos') }}</span></router-link>
            <button v-if="authStore.hasModule('combos')" class="fav-toggle" :class="{ 'fav-active': isFavorite('combos') }" @click="toggleFavorite('combos', $event)" :title="isFavorite('combos') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'combos'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('combos', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('combos', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="ticket_designer"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'ticket_designer', 'reorder-active': reorderActiveSlug === 'ticket_designer' }"
            @pointerdown="onItemPointerDown('ticket_designer', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('ticket_designer')" to="/ticket-designer" class="nav-item" :class="{ active: $route.path === '/ticket-designer' }" @click="mobileOpen = false"><i class="fas fa-print"></i><span>{{ i18nStore.t('ticket_designer') }}</span></router-link>
            <button v-if="authStore.hasModule('ticket_designer')" class="fav-toggle" :class="{ 'fav-active': isFavorite('ticket_designer') }" @click="toggleFavorite('ticket_designer', $event)" :title="isFavorite('ticket_designer') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'ticket_designer'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('ticket_designer', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('ticket_designer', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="cotizacion_designer"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'cotizacion_designer', 'reorder-active': reorderActiveSlug === 'cotizacion_designer' }"
            @pointerdown="onItemPointerDown('cotizacion_designer', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('cotizacion_designer')" to="/cotizacion-designer" class="nav-item" :class="{ active: $route.path === '/cotizacion-designer' }" @click="mobileOpen = false"><i class="fas fa-file-invoice"></i><span>{{ i18nStore.t('cotizacion_designer') }}</span></router-link>
            <button v-if="authStore.hasModule('cotizacion_designer')" class="fav-toggle" :class="{ 'fav-active': isFavorite('cotizacion_designer') }" @click="toggleFavorite('cotizacion_designer', $event)" :title="isFavorite('cotizacion_designer') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'cotizacion_designer'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('cotizacion_designer', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('cotizacion_designer', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
        </div>
        <div class="nav-section" v-if="hasAnyModule('productos', 'catalogo', 'inventario_ubicacion', 'etiquetas', 'traspasos', 'ajustes_inventario', 'rentabilidad')">
          <div class="nav-section-title">{{ i18nStore.t('sec_inventario') }}</div>
          <div class="nav-item-wrapper" data-slug="productos"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'productos', 'reorder-active': reorderActiveSlug === 'productos' }"
            @pointerdown="onItemPointerDown('productos', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('productos')" to="/productos" class="nav-item" :class="{ active: $route.path === '/productos' }" @click="mobileOpen = false"><i class="fas fa-boxes-stacked"></i><span>{{ i18nStore.t('productos') }}</span></router-link>
            <button v-if="authStore.hasModule('productos')" class="fav-toggle" :class="{ 'fav-active': isFavorite('productos') }" @click="toggleFavorite('productos', $event)" :title="isFavorite('productos') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'productos'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('productos', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('productos', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="catalogo"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'catalogo', 'reorder-active': reorderActiveSlug === 'catalogo' }"
            @pointerdown="onItemPointerDown('catalogo', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('catalogo')" to="/catalogo" class="nav-item" :class="{ active: $route.path === '/catalogo' }" @click="mobileOpen = false"><i class="fas fa-book-open"></i><span>{{ i18nStore.t('catalogo') }}</span></router-link>
            <button v-if="authStore.hasModule('catalogo')" class="fav-toggle" :class="{ 'fav-active': isFavorite('catalogo') }" @click="toggleFavorite('catalogo', $event)" :title="isFavorite('catalogo') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'catalogo'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('catalogo', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('catalogo', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="inventario_ubicacion"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'inventario_ubicacion', 'reorder-active': reorderActiveSlug === 'inventario_ubicacion' }"
            @pointerdown="onItemPointerDown('inventario_ubicacion', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('productos')" to="/inventario-ubicacion" class="nav-item" :class="{ active: $route.path === '/inventario-ubicacion' }" @click="mobileOpen = false"><i class="fas fa-warehouse"></i><span>{{ i18nStore.t('inventario_ubicacion') }}</span></router-link>
            <button v-if="authStore.hasModule('productos')" class="fav-toggle" :class="{ 'fav-active': isFavorite('inventario_ubicacion') }" @click="toggleFavorite('inventario_ubicacion', $event)" :title="isFavorite('inventario_ubicacion') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'inventario_ubicacion'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('inventario_ubicacion', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('inventario_ubicacion', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="etiquetas"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'etiquetas', 'reorder-active': reorderActiveSlug === 'etiquetas' }"
            @pointerdown="onItemPointerDown('etiquetas', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('etiquetas')" to="/etiquetas" class="nav-item" :class="{ active: $route.path === '/etiquetas' }" @click="mobileOpen = false"><i class="fas fa-tag"></i><span>{{ i18nStore.t('etiquetas') }}</span></router-link>
            <button v-if="authStore.hasModule('etiquetas')" class="fav-toggle" :class="{ 'fav-active': isFavorite('etiquetas') }" @click="toggleFavorite('etiquetas', $event)" :title="isFavorite('etiquetas') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'etiquetas'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('etiquetas', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('etiquetas', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="traspasos"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'traspasos', 'reorder-active': reorderActiveSlug === 'traspasos' }"
            @pointerdown="onItemPointerDown('traspasos', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('traspasos')" to="/traspasos" class="nav-item" :class="{ active: $route.path === '/traspasos' }" @click="mobileOpen = false"><i class="fas fa-exchange-alt"></i><span>{{ i18nStore.t('traspasos') }}</span></router-link>
            <button v-if="authStore.hasModule('traspasos')" class="fav-toggle" :class="{ 'fav-active': isFavorite('traspasos') }" @click="toggleFavorite('traspasos', $event)" :title="isFavorite('traspasos') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'traspasos'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('traspasos', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('traspasos', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="ajustes_inventario"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'ajustes_inventario', 'reorder-active': reorderActiveSlug === 'ajustes_inventario' }"
            @pointerdown="onItemPointerDown('ajustes_inventario', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('ajustes_inventario')" to="/ajustes-inventario" class="nav-item" :class="{ active: $route.path === '/ajustes-inventario' }" @click="mobileOpen = false"><i class="fas fa-sliders-h"></i><span>{{ i18nStore.t('ajustes_inventario') }}</span></router-link>
            <button v-if="authStore.hasModule('ajustes_inventario')" class="fav-toggle" :class="{ 'fav-active': isFavorite('ajustes_inventario') }" @click="toggleFavorite('ajustes_inventario', $event)" :title="isFavorite('ajustes_inventario') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'ajustes_inventario'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('ajustes_inventario', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('ajustes_inventario', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="rentabilidad"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'rentabilidad', 'reorder-active': reorderActiveSlug === 'rentabilidad' }"
            @pointerdown="onItemPointerDown('rentabilidad', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('rentabilidad')" to="/rentabilidad" class="nav-item" :class="{ active: $route.path === '/rentabilidad' }" @click="mobileOpen = false"><i class="fas fa-coins"></i><span>{{ i18nStore.t('rentabilidad') }}</span></router-link>
            <button v-if="authStore.hasModule('rentabilidad')" class="fav-toggle" :class="{ 'fav-active': isFavorite('rentabilidad') }" @click="toggleFavorite('rentabilidad', $event)" :title="isFavorite('rentabilidad') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'rentabilidad'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('rentabilidad', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('rentabilidad', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
        </div>
        <div class="nav-section" v-if="hasAnyModule('compras', 'proveedores')">
          <div class="nav-section-title">{{ i18nStore.t('sec_compras') }}</div>
          <div class="nav-item-wrapper" data-slug="compras"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'compras', 'reorder-active': reorderActiveSlug === 'compras' }"
            @pointerdown="onItemPointerDown('compras', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('compras')" to="/compras" class="nav-item" :class="{ active: $route.path === '/compras' }" @click="mobileOpen = false"><i class="fas fa-shopping-cart"></i><span>{{ i18nStore.t('compras') }}</span></router-link>
            <button v-if="authStore.hasModule('compras')" class="fav-toggle" :class="{ 'fav-active': isFavorite('compras') }" @click="toggleFavorite('compras', $event)" :title="isFavorite('compras') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'compras'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('compras', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('compras', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="proveedores"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'proveedores', 'reorder-active': reorderActiveSlug === 'proveedores' }"
            @pointerdown="onItemPointerDown('proveedores', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('proveedores')" to="/proveedores" class="nav-item" :class="{ active: $route.path === '/proveedores' }" @click="mobileOpen = false"><i class="fas fa-truck"></i><span>{{ i18nStore.t('proveedores') }}</span></router-link>
            <button v-if="authStore.hasModule('proveedores')" class="fav-toggle" :class="{ 'fav-active': isFavorite('proveedores') }" @click="toggleFavorite('proveedores', $event)" :title="isFavorite('proveedores') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'proveedores'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('proveedores', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('proveedores', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
        </div>
        <div class="nav-section" v-if="hasAnyModule('clientes', 'crm', 'email_builder', 'formularios', 'geo_business')">
          <div class="nav-section-title">{{ i18nStore.t('sec_crm') }}</div>
          <div class="nav-item-wrapper" data-slug="clientes"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'clientes', 'reorder-active': reorderActiveSlug === 'clientes' }"
            @pointerdown="onItemPointerDown('clientes', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('clientes')" to="/clientes" class="nav-item" :class="{ active: $route.path === '/clientes' }" @click="mobileOpen = false"><i class="fas fa-users"></i><span>{{ i18nStore.t('clientes') }}</span></router-link>
            <button v-if="authStore.hasModule('clientes')" class="fav-toggle" :class="{ 'fav-active': isFavorite('clientes') }" @click="toggleFavorite('clientes', $event)" :title="isFavorite('clientes') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'clientes'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('clientes', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('clientes', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="crm"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'crm', 'reorder-active': reorderActiveSlug === 'crm' }"
            @pointerdown="onItemPointerDown('crm', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('crm')" to="/crm" class="nav-item" :class="{ active: $route.path === '/crm' }" @click="mobileOpen = false"><i class="fas fa-handshake"></i><span>{{ i18nStore.t('crm') }}</span></router-link>
            <button v-if="authStore.hasModule('crm')" class="fav-toggle" :class="{ 'fav-active': isFavorite('crm') }" @click="toggleFavorite('crm', $event)" :title="isFavorite('crm') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'crm'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('crm', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('crm', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="email_builder"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'email_builder', 'reorder-active': reorderActiveSlug === 'email_builder' }"
            @pointerdown="onItemPointerDown('email_builder', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('email_builder')" to="/email-builder" class="nav-item" :class="{ active: $route.path.startsWith('/email-builder') }" @click="mobileOpen = false"><i class="fas fa-paint-brush"></i><span>{{ i18nStore.t('email_builder') }}</span></router-link>
            <button v-if="authStore.hasModule('email_builder')" class="fav-toggle" :class="{ 'fav-active': isFavorite('email_builder') }" @click="toggleFavorite('email_builder', $event)" :title="isFavorite('email_builder') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'email_builder'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('email_builder', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('email_builder', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="formularios"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'formularios', 'reorder-active': reorderActiveSlug === 'formularios' }"
            @pointerdown="onItemPointerDown('formularios', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('formularios')" to="/formularios" class="nav-item" :class="{ active: $route.path === '/formularios' }" @click="mobileOpen = false"><i class="fas fa-globe"></i><span>{{ i18nStore.t('formularios') }}</span></router-link>
            <button v-if="authStore.hasModule('formularios')" class="fav-toggle" :class="{ 'fav-active': isFavorite('formularios') }" @click="toggleFavorite('formularios', $event)" :title="isFavorite('formularios') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'formularios'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('formularios', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('formularios', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="geo_business"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'geo_business', 'reorder-active': reorderActiveSlug === 'geo_business' }"
            @pointerdown="onItemPointerDown('geo_business', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('geo_business')" to="/geo-business" class="nav-item" :class="{ active: $route.path === '/geo-business' }" @click="mobileOpen = false"><i class="fas fa-map-marked-alt"></i><span>{{ i18nStore.t('geo_business') }}</span></router-link>
            <button v-if="authStore.hasModule('geo_business')" class="fav-toggle" :class="{ 'fav-active': isFavorite('geo_business') }" @click="toggleFavorite('geo_business', $event)" :title="isFavorite('geo_business') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'geo_business'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('geo_business', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('geo_business', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
        </div>
        <div class="nav-section" v-if="hasAnyModule('cuentas_cobrar', 'listas_precios', 'tesoreria', 'presupuestos', 'facturacion_electronica')">
          <div class="nav-section-title">{{ i18nStore.t('sec_finanzas') }}</div>
          <div class="nav-item-wrapper" data-slug="cuentas_cobrar"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'cuentas_cobrar', 'reorder-active': reorderActiveSlug === 'cuentas_cobrar' }"
            @pointerdown="onItemPointerDown('cuentas_cobrar', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('cuentas_cobrar')" to="/cuentas-cobrar" class="nav-item" :class="{ active: $route.path === '/cuentas-cobrar' }" @click="mobileOpen = false"><i class="fas fa-hand-holding-usd"></i><span>{{ i18nStore.t('cuentas_cobrar') }}</span></router-link>
            <button v-if="authStore.hasModule('cuentas_cobrar')" class="fav-toggle" :class="{ 'fav-active': isFavorite('cuentas_cobrar') }" @click="toggleFavorite('cuentas_cobrar', $event)" :title="isFavorite('cuentas_cobrar') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'cuentas_cobrar'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('cuentas_cobrar', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('cuentas_cobrar', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="listas_precios"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'listas_precios', 'reorder-active': reorderActiveSlug === 'listas_precios' }"
            @pointerdown="onItemPointerDown('listas_precios', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('listas_precios')" to="/listas-precios" class="nav-item" :class="{ active: $route.path === '/listas-precios' }" @click="mobileOpen = false"><i class="fas fa-list-ol"></i><span>{{ i18nStore.t('listas_precios') }}</span></router-link>
            <button v-if="authStore.hasModule('listas_precios')" class="fav-toggle" :class="{ 'fav-active': isFavorite('listas_precios') }" @click="toggleFavorite('listas_precios', $event)" :title="isFavorite('listas_precios') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'listas_precios'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('listas_precios', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('listas_precios', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <!-- <router-link v-if="authStore.hasModule('contabilidad')" to="/contabilidad" class="nav-item" :class="{ active: $route.path === '/contabilidad' }" @click="mobileOpen = false"><i class="fas fa-calculator"></i><span>{{ i18nStore.t('contabilidad') }}</span></router-link> -->
          <div class="nav-item-wrapper" data-slug="tesoreria"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'tesoreria', 'reorder-active': reorderActiveSlug === 'tesoreria' }"
            @pointerdown="onItemPointerDown('tesoreria', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('tesoreria')" to="/tesoreria" class="nav-item" :class="{ active: $route.path === '/tesoreria' }" @click="mobileOpen = false"><i class="fas fa-vault"></i><span>{{ i18nStore.t('tesoreria') }}</span></router-link>
            <button v-if="authStore.hasModule('tesoreria')" class="fav-toggle" :class="{ 'fav-active': isFavorite('tesoreria') }" @click="toggleFavorite('tesoreria', $event)" :title="isFavorite('tesoreria') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'tesoreria'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('tesoreria', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('tesoreria', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="presupuestos"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'presupuestos', 'reorder-active': reorderActiveSlug === 'presupuestos' }"
            @pointerdown="onItemPointerDown('presupuestos', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('presupuestos')" to="/presupuestos" class="nav-item" :class="{ active: $route.path === '/presupuestos' }" @click="mobileOpen = false"><i class="fas fa-file-invoice-dollar"></i><span>{{ i18nStore.t('presupuestos') }}</span></router-link>
            <button v-if="authStore.hasModule('presupuestos')" class="fav-toggle" :class="{ 'fav-active': isFavorite('presupuestos') }" @click="toggleFavorite('presupuestos', $event)" :title="isFavorite('presupuestos') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'presupuestos'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('presupuestos', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('presupuestos', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="facturacion_electronica"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'facturacion_electronica', 'reorder-active': reorderActiveSlug === 'facturacion_electronica' }"
            @pointerdown="onItemPointerDown('facturacion_electronica', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('facturacion_electronica')" to="/facturacion-electronica" class="nav-item" :class="{ active: $route.path === '/facturacion-electronica' }" @click="mobileOpen = false"><i class="fas fa-file-signature"></i><span>{{ i18nStore.t('facturacion_electronica') }}</span></router-link>
            <button v-if="authStore.hasModule('facturacion_electronica')" class="fav-toggle" :class="{ 'fav-active': isFavorite('facturacion_electronica') }" @click="toggleFavorite('facturacion_electronica', $event)" :title="isFavorite('facturacion_electronica') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'facturacion_electronica'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('facturacion_electronica', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('facturacion_electronica', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
        </div>
        <div class="nav-section" v-if="hasAnyModule('usuarios', 'roles', 'chats', 'chats_cerrados', 'notificaciones', 'planilla', 'productividad', 'auditoria', 'configuracion')">
          <div class="nav-section-title">{{ i18nStore.t('sec_admin') }}</div>
          <div class="nav-item-wrapper" data-slug="usuarios"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'usuarios', 'reorder-active': reorderActiveSlug === 'usuarios' }"
            @pointerdown="onItemPointerDown('usuarios', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('usuarios')" to="/usuarios" class="nav-item" :class="{ active: $route.path === '/usuarios' }" @click="mobileOpen = false"><i class="fas fa-user-shield"></i><span>{{ i18nStore.t('usuarios') }}</span></router-link>
            <button v-if="authStore.hasModule('usuarios')" class="fav-toggle" :class="{ 'fav-active': isFavorite('usuarios') }" @click="toggleFavorite('usuarios', $event)" :title="isFavorite('usuarios') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'usuarios'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('usuarios', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('usuarios', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="roles"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'roles', 'reorder-active': reorderActiveSlug === 'roles' }"
            @pointerdown="onItemPointerDown('roles', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('roles')" to="/roles" class="nav-item" :class="{ active: $route.path === '/roles' }" @click="mobileOpen = false"><i class="fas fa-user-cog"></i><span>{{ i18nStore.t('roles') }}</span></router-link>
            <button v-if="authStore.hasModule('roles')" class="fav-toggle" :class="{ 'fav-active': isFavorite('roles') }" @click="toggleFavorite('roles', $event)" :title="isFavorite('roles') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'roles'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('roles', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('roles', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="chats"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'chats', 'reorder-active': reorderActiveSlug === 'chats' }"
            @pointerdown="onItemPointerDown('chats', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('chats')" to="/chats" class="nav-item" :class="{ active: $route.path === '/chats' }" @click="mobileOpen = false"><i class="fas fa-comments"></i><span>{{ i18nStore.t('chat_interno') }}</span></router-link>
            <button v-if="authStore.hasModule('chats')" class="fav-toggle" :class="{ 'fav-active': isFavorite('chats') }" @click="toggleFavorite('chats', $event)" :title="isFavorite('chats') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'chats'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('chats', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('chats', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="chats_cerrados"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'chats_cerrados', 'reorder-active': reorderActiveSlug === 'chats_cerrados' }"
            @pointerdown="onItemPointerDown('chats_cerrados', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('chats_cerrados')" to="/chats-cerrados" class="nav-item" :class="{ active: $route.path === '/chats-cerrados' }" @click="mobileOpen = false"><i class="fas fa-lock"></i><span>{{ i18nStore.t('chats_cerrados') }}</span></router-link>
            <button v-if="authStore.hasModule('chats_cerrados')" class="fav-toggle" :class="{ 'fav-active': isFavorite('chats_cerrados') }" @click="toggleFavorite('chats_cerrados', $event)" :title="isFavorite('chats_cerrados') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'chats_cerrados'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('chats_cerrados', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('chats_cerrados', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="notificaciones"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'notificaciones', 'reorder-active': reorderActiveSlug === 'notificaciones' }"
            @pointerdown="onItemPointerDown('notificaciones', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('notificaciones')" to="/notificaciones" class="nav-item" :class="{ active: $route.path === '/notificaciones' }" @click="mobileOpen = false"><i class="fas fa-bell"></i><span>{{ i18nStore.t('notificaciones') }}</span></router-link>
            <button v-if="authStore.hasModule('notificaciones')" class="fav-toggle" :class="{ 'fav-active': isFavorite('notificaciones') }" @click="toggleFavorite('notificaciones', $event)" :title="isFavorite('notificaciones') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'notificaciones'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('notificaciones', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('notificaciones', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="planilla"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'planilla', 'reorder-active': reorderActiveSlug === 'planilla' }"
            @pointerdown="onItemPointerDown('planilla', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('planilla')" to="/planilla" class="nav-item" :class="{ active: $route.path === '/planilla' }" @click="mobileOpen = false"><i class="fas fa-money-check-alt"></i><span>{{ i18nStore.t('planilla') }}</span></router-link>
            <button v-if="authStore.hasModule('planilla')" class="fav-toggle" :class="{ 'fav-active': isFavorite('planilla') }" @click="toggleFavorite('planilla', $event)" :title="isFavorite('planilla') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'planilla'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('planilla', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('planilla', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="productividad"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'productividad', 'reorder-active': reorderActiveSlug === 'productividad' }"
            @pointerdown="onItemPointerDown('productividad', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('productividad')" to="/productividad" class="nav-item" :class="{ active: $route.path === '/productividad' }" @click="mobileOpen = false"><i class="fas fa-user-clock"></i><span>{{ i18nStore.t('productividad') }}</span></router-link>
            <button v-if="authStore.hasModule('productividad')" class="fav-toggle" :class="{ 'fav-active': isFavorite('productividad') }" @click="toggleFavorite('productividad', $event)" :title="isFavorite('productividad') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'productividad'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('productividad', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('productividad', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="auditoria"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'auditoria', 'reorder-active': reorderActiveSlug === 'auditoria' }"
            @pointerdown="onItemPointerDown('auditoria', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('auditoria')" to="/auditoria" class="nav-item" :class="{ active: $route.path === '/auditoria' }" @click="mobileOpen = false"><i class="fas fa-shield-alt"></i><span>{{ i18nStore.t('auditoria') }}</span></router-link>
            <button v-if="authStore.hasModule('auditoria')" class="fav-toggle" :class="{ 'fav-active': isFavorite('auditoria') }" @click="toggleFavorite('auditoria', $event)" :title="isFavorite('auditoria') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'auditoria'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('auditoria', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('auditoria', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
          <div class="nav-item-wrapper" data-slug="configuracion"
            :class="{ 'long-pressing': isPressing && longPressTarget === 'configuracion', 'reorder-active': reorderActiveSlug === 'configuracion' }"
            @pointerdown="onItemPointerDown('configuracion', $event)" @pointerup="onItemPointerUp" @pointerleave="onItemPointerLeave" @contextmenu.prevent>
            <router-link v-if="authStore.hasModule('configuracion')" to="/configuracion" class="nav-item" :class="{ active: $route.path === '/configuracion' }" @click="mobileOpen = false"><i class="fas fa-cog"></i><span>{{ i18nStore.t('configuracion') }}</span></router-link>
            <button v-if="authStore.hasModule('configuracion')" class="fav-toggle" :class="{ 'fav-active': isFavorite('configuracion') }" @click="toggleFavorite('configuracion', $event)" :title="isFavorite('configuracion') ? i18nStore.t('remover_favorito') : i18nStore.t('agregar_favorito')"><i class="fas fa-star"></i></button>
            <div v-if="reorderActiveSlug === 'configuracion'" class="reorder-arrows">
              <button class="reorder-btn" @click.stop="moveItem('configuracion', 'up')"><i class="fas fa-chevron-up"></i></button>
              <button class="reorder-btn" @click.stop="moveItem('configuracion', 'down')"><i class="fas fa-chevron-down"></i></button>
              <button class="reorder-btn reorder-close" @click.stop="cancelReorder"><i class="fas fa-times"></i></button>
            </div>
          </div>
        </div>
      </nav>

      <div class="sidebar-footer">
        <div class="sidebar-user" @click="authStore.logout()">
          <div class="user-avatar">{{ authStore.userInitials }}</div>
          <div class="user-info">
            <div class="user-name">{{ authStore.userName }}</div>
            <div class="user-role">{{ authStore.userRole }}</div>
          </div>
        </div>
      </div>
    </aside>

    <!-- Context Menu for reordering -->
    <div v-if="contextMenu.show" class="context-menu" :style="{ top: contextMenu.y + 'px', left: contextMenu.x + 'px' }" @click.stop>
      <button class="context-menu-item" @click="moveItem(contextMenu.slug, 'up'); closeContextMenu()">
        <i class="fas fa-chevron-up"></i> Subir
      </button>
      <button class="context-menu-item" @click="moveItem(contextMenu.slug, 'down'); closeContextMenu()">
        <i class="fas fa-chevron-down"></i> Bajar
      </button>
    </div>

    <main class="main-content" :style="mainContentStyle">
      <header class="top-header">
        <div class="header-left">
          <button class="toggle-sidebar" @click="toggleSidebar">
            <i class="fas fa-bars"></i>
          </button>
          <h1 class="page-title">{{ pageTitle }}</h1>
        </div>
        <div class="header-right">
          <button class="header-btn" @click="authStore.toggleTheme()" :title="i18nStore.t('cambiar_tema')">
            <i :class="authStore.theme === 'dark' ? 'fas fa-sun' : 'fas fa-moon'"></i>
          </button>
          <button
            v-if="authStore.hasModule('chats')"
            class="header-btn"
            title="Chats internos"
            @click="chatDrawer.toggle"
          >
            <i class="fas fa-comments"></i>
            <span v-if="chatDrawer.hasUnread" class="notif-badge">{{ chatDrawer.totalUnread }}</span>
          </button>
          <div class="notif-dropdown-wrapper">
            <button class="header-btn" title="Notificaciones" @click="toggleNotificaciones">
              <i class="fas fa-bell"></i>
              <span v-if="notifSinLeer > 0" class="notif-badge">{{ notifSinLeer }}</span>
            </button>
            <div v-if="showNotificaciones" class="notif-dropdown" v-click-outside="closeNotificaciones">
              <div class="notif-header">
                <strong>Notificaciones</strong>
                <div style="display:flex;gap:8px;align-items:center;">
                  <span v-if="notifSinLeer > 0" class="notif-count">{{ notifSinLeer }} no leídas</span>
                  <button v-if="notificaciones.length" class="btn btn-xs btn-ghost" @click.stop="marcarTodasLeidas">Marcar todo</button>
                </div>
              </div>
              <div v-if="!notificaciones.length" class="notif-empty">Sin notificaciones</div>
              <div v-else class="notif-list">
                <div v-for="n in notificaciones" :key="n.id" class="notif-item" :class="{ unread: !n.leido }" @click="irNotificacion(n)">
                  <div class="notif-icon" :style="{ background: n.color + '22', color: n.color }"><i :class="n.icono || 'fas fa-bell'"></i></div>
                  <div class="notif-body">
                    <div style="display:flex;justify-content:space-between;align-items:center;">
                      <div class="notif-title">{{ n.titulo }}</div>
                      <span v-if="!n.leido" class="notif-dot"></span>
                    </div>
                    <div class="notif-msg">{{ n.mensaje }}</div>
                    <div class="notif-time">{{ formatoFecha(n.enviada_en) }}</div>
                  </div>
                </div>
              </div>
              <div class="notif-footer">
                <router-link to="/notificaciones" @click="closeNotificaciones">Ver todas</router-link>
              </div>
            </div>
          </div>
          <button class="header-btn" @click="authStore.logout()" :title="i18nStore.t('cerrar_sesion')">
            <i class="fas fa-sign-out-alt"></i>
          </button>
        </div>
      </header>

      <div class="content-area">
        <router-view />
      </div>

      <!-- Floating Chat Button -->
      <button
        v-if="authStore.hasModule('chats')"
        class="fab-chat"
        title="Abrir chat interno"
        @click="chatDrawer.toggle"
      >
        <i class="fas fa-comments"></i>
        <span v-if="chatDrawer.hasUnread" class="fab-badge">{{ chatDrawer.totalUnread }}</span>
      </button>
    </main>

    <!-- Mobile Bottom Navigation -->
    <nav class="mobile-bottom-nav">
      <router-link to="/dashboard" class="mob-nav-item" :class="{ active: $route.path === '/dashboard' }">
        <i class="fas fa-home"></i>
        <span>{{ i18nStore.t('dashboard') }}</span>
      </router-link>
      <button class="mob-nav-item" @click="toggleSidebar" :class="{ 'mob-nav-search': true }">
        <i class="fas fa-bars"></i>
        <span>{{ i18nStore.t('menu') }}</span>
      </button>
      <router-link v-if="authStore.hasModule('caja')" to="/caja" class="mob-nav-item mob-nav-action" :class="{ active: $route.path === '/caja' }">
        <div class="mob-nav-action-icon"><i class="fas fa-cash-register"></i></div>
        <span>{{ i18nStore.t('caja_rapida') }}</span>
      </router-link>
      <button class="mob-nav-item" @click="toggleNotificaciones" :class="{ active: showNotificaciones }">
        <i class="fas fa-bell"></i>
        <span>{{ i18nStore.t('notificaciones') }}</span>
        <span v-if="notifSinLeer > 0" class="mob-nav-badge">{{ notifSinLeer }}</span>
      </button>
      <button class="mob-nav-item" @click="authStore.logout()">
        <i class="fas fa-sign-out-alt"></i>
        <span>{{ i18nStore.t('salir') }}</span>
      </button>
    </nav>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import { useChatDrawerStore } from '../stores/chatDrawer';
import { useI18nStore } from '../stores/i18n';
import { useCurrencyStore } from '../stores/currency';
import api from '../services/api';

const route = useRoute();
const router = useRouter();
const authStore = useAuthStore();
const chatDrawer = useChatDrawerStore();
const i18nStore = useI18nStore();
const currencyStore = useCurrencyStore();
const sidebarCollapsed = ref(false);
const mobileOpen = ref(false);
const nombreNegocio = ref('');

// --- Reordenar módulos con press largo ---
const longPressTimer = ref(null);
const longPressTarget = ref(null);
const reorderActiveSlug = ref(null);
const isPressing = ref(false);

// --- Context Menu ---
const contextMenu = ref({ show: false, x: 0, y: 0, slug: null });

function onSidebarContextMenu(e) {
    const wrapper = e.target.closest('.nav-item-wrapper');
    if (!wrapper) return;
    const slug = wrapper.dataset.slug;
    if (!slug) return;
    e.preventDefault();
    e.stopPropagation();
    contextMenu.value = { show: true, x: e.clientX, y: e.clientY, slug };
}

function closeContextMenu() {
    contextMenu.value.show = false;
}

function onDocumentClick() {
    closeContextMenu();
}

function onItemPointerDown(slug, e) {
    if (e.button && e.button !== 0) return;
    if (e.target.closest('.fav-toggle') || e.target.closest('.reorder-arrows')) return;
    isPressing.value = true;
    longPressTarget.value = slug;
    longPressTimer.value = setTimeout(() => {
        reorderActiveSlug.value = slug;
        isPressing.value = false;
        try { navigator.vibrate?.(30); } catch {}
    }, 1000);
}

function onItemPointerUp() {
    clearTimeout(longPressTimer.value);
    longPressTimer.value = null;
    isPressing.value = false;
    longPressTarget.value = null;
}

function onItemPointerLeave() {
    clearTimeout(longPressTimer.value);
    longPressTimer.value = null;
    isPressing.value = false;
}

function cancelReorder() {
    reorderActiveSlug.value = null;
}

function moveItem(slug, direction) {
    const wrapper = document.querySelector(`[data-slug="${slug}"]`);
    if (!wrapper) return;
    const section = wrapper.closest('.nav-section');
    if (!section) return;
    const items = [...section.querySelectorAll('.nav-item-wrapper')];
    const idx = items.indexOf(wrapper);
    if (idx < 0) return;
    const targetIdx = direction === 'up' ? idx - 1 : idx + 1;
    if (targetIdx < 0 || targetIdx >= items.length) return;
    if (direction === 'up') {
        section.insertBefore(wrapper, items[targetIdx]);
    } else {
        section.insertBefore(wrapper, items[targetIdx].nextSibling);
    }
    saveSidebarOrder();
}

function saveSidebarOrder() {
    const order = {};
    document.querySelectorAll('.nav-item-wrapper[data-slug]').forEach(el => {
        order[el.dataset.slug] = el.style.order || '0';
    });
    localStorage.setItem('sidebar_order', JSON.stringify(order));
}

function loadSidebarOrder() {
    try {
        const order = JSON.parse(localStorage.getItem('sidebar_order') || '{}');
        document.querySelectorAll('.nav-item-wrapper[data-slug]').forEach(el => {
            const slug = el.dataset.slug;
            if (order[slug] !== undefined) {
                el.style.order = order[slug];
            }
        });
        const sections = document.querySelectorAll('.nav-section');
        sections.forEach(section => {
            const wrappers = [...section.querySelectorAll('.nav-item-wrapper')];
            wrappers.sort((a, b) => {
                const oa = parseInt(a.style.order || '0', 10);
                const ob = parseInt(b.style.order || '0', 10);
                return oa - ob;
            });
            wrappers.forEach(w => section.appendChild(w));
        });
    } catch {}
}

const hasAnyModule = (...modules) => modules.some(m => authStore.hasModule(m));

// --- Favoritos ---
const moduleMap = {
    dashboard:                   { route: '/dashboard',              icon: 'fas fa-home',               labelKey: 'dashboard' },
    business_intelligence:       { route: '/business-intelligence',  icon: 'fas fa-brain',              labelKey: 'business_intelligence' },
    reportes:                    { route: '/reportes',               icon: 'fas fa-chart-bar',          labelKey: 'reportes' },
    caja:                        { route: '/caja',                   icon: 'fas fa-cash-register',      labelKey: 'caja_rapida' },
    ventas:                      { route: '/ventas',                 icon: 'fas fa-receipt',            labelKey: 'historial_ventas' },
    devoluciones:                { route: '/devoluciones',           icon: 'fas fa-undo',               labelKey: 'devoluciones' },
    notas_credito:               { route: '/notas-credito',          icon: 'fas fa-file-invoice',       labelKey: 'notas_credito' },
    cotizaciones:                { route: '/cotizaciones',           icon: 'fas fa-file-alt',           labelKey: 'cotizaciones' },
    enviar_cotizacion:           { route: '/enviar-cotizacion',      icon: 'fas fa-paper-plane',        labelKey: 'enviar_cotizacion' },
    pedidos:                     { route: '/pedidos',                icon: 'fas fa-clipboard-list',     labelKey: 'pedidos' },
    combos:                      { route: '/combos',                 icon: 'fas fa-tags',               labelKey: 'combos' },
    ticket_designer:             { route: '/ticket-designer',        icon: 'fas fa-print',              labelKey: 'ticket_designer' },
    cotizacion_designer:         { route: '/cotizacion-designer',    icon: 'fas fa-file-invoice',       labelKey: 'cotizacion_designer' },
    productos:                   { route: '/productos',              icon: 'fas fa-boxes-stacked',      labelKey: 'productos' },
    catalogo:                    { route: '/catalogo',               icon: 'fas fa-book-open',          labelKey: 'catalogo' },
    inventario_ubicacion:        { route: '/inventario-ubicacion',   icon: 'fas fa-warehouse',          labelKey: 'inventario_ubicacion' },
    etiquetas:                   { route: '/etiquetas',              icon: 'fas fa-tag',                labelKey: 'etiquetas' },
    traspasos:                   { route: '/traspasos',              icon: 'fas fa-exchange-alt',       labelKey: 'traspasos' },
    ajustes_inventario:          { route: '/ajustes-inventario',     icon: 'fas fa-sliders-h',          labelKey: 'ajustes_inventario' },
    rentabilidad:                { route: '/rentabilidad',           icon: 'fas fa-coins',              labelKey: 'rentabilidad' },
    compras:                     { route: '/compras',                icon: 'fas fa-shopping-cart',      labelKey: 'compras' },
    proveedores:                 { route: '/proveedores',            icon: 'fas fa-truck',              labelKey: 'proveedores' },
    clientes:                    { route: '/clientes',               icon: 'fas fa-users',              labelKey: 'clientes' },
    crm:                         { route: '/crm',                    icon: 'fas fa-handshake',          labelKey: 'crm' },
    email_builder:               { route: '/email-builder',          icon: 'fas fa-paint-brush',        labelKey: 'email_builder' },
    formularios:                 { route: '/formularios',            icon: 'fas fa-globe',              labelKey: 'formularios' },
    geo_business:                { route: '/geo-business',           icon: 'fas fa-map-marked-alt',     labelKey: 'geo_business' },
    cuentas_cobrar:              { route: '/cuentas-cobrar',         icon: 'fas fa-hand-holding-usd',   labelKey: 'cuentas_cobrar' },
    listas_precios:              { route: '/listas-precios',         icon: 'fas fa-list-ol',            labelKey: 'listas_precios' },
    tesoreria:                   { route: '/tesoreria',              icon: 'fas fa-vault',              labelKey: 'tesoreria' },
    presupuestos:                { route: '/presupuestos',           icon: 'fas fa-file-invoice-dollar',labelKey: 'presupuestos' },
    facturacion_electronica:     { route: '/facturacion-electronica',icon: 'fas fa-file-signature',     labelKey: 'facturacion_electronica' },
    usuarios:                    { route: '/usuarios',               icon: 'fas fa-user-shield',        labelKey: 'usuarios' },
    roles:                       { route: '/roles',                  icon: 'fas fa-user-cog',           labelKey: 'roles' },
    chats:                       { route: '/chats',                  icon: 'fas fa-comments',           labelKey: 'chat_interno' },
    chats_cerrados:              { route: '/chats-cerrados',         icon: 'fas fa-lock',               labelKey: 'chats_cerrados' },
    notificaciones:              { route: '/notificaciones',         icon: 'fas fa-bell',               labelKey: 'notificaciones' },
    planilla:                    { route: '/planilla',               icon: 'fas fa-money-check-alt',    labelKey: 'planilla' },
    productividad:               { route: '/productividad',          icon: 'fas fa-user-clock',         labelKey: 'productividad' },
    auditoria:                   { route: '/auditoria',              icon: 'fas fa-shield-alt',         labelKey: 'auditoria' },
    configuracion:               { route: '/configuracion',          icon: 'fas fa-cog',                labelKey: 'configuracion' },
};

const favorites = ref([]);

const favoritesKey = computed(() => `favoritos_${authStore.user?.id || 'guest'}`);

function loadFavorites() {
    try {
        favorites.value = JSON.parse(localStorage.getItem(favoritesKey.value) || '[]');
    } catch { favorites.value = []; }
}

function saveFavorites() {
    localStorage.setItem(favoritesKey.value, JSON.stringify(favorites.value));
}

function isFavorite(slug) {
    return favorites.value.includes(slug);
}

function toggleFavorite(slug, e) {
    if (e) e.stopPropagation();
    const idx = favorites.value.indexOf(slug);
    if (idx >= 0) {
        favorites.value.splice(idx, 1);
    } else {
        favorites.value.push(slug);
    }
    saveFavorites();
}

const visibleFavorites = computed(() =>
    favorites.value.filter(slug => moduleMap[slug] && authStore.hasModule(slug))
);

const sidebarRef = ref(null);
const sidebarWidth = ref(parseInt(localStorage.getItem('sidebarWidth')) || 0);
const isResizing = ref(false);

const sidebarStyle = computed(() => {
    if (sidebarWidth.value && !sidebarCollapsed.value && window.innerWidth > 1024) {
        return { width: sidebarWidth.value + 'px' };
    }
    return {};
});

const mainContentStyle = computed(() => {
    if (window.innerWidth <= 1024) return {};
    if (sidebarCollapsed.value) return {};
    if (sidebarWidth.value) {
        return { marginLeft: sidebarWidth.value + 'px' };
    }
    return {};
});

function startResize(e) {
    if (window.innerWidth <= 1024) return;
    isResizing.value = true;
    const startX = e.clientX;
    const startWidth = sidebarRef.value?.offsetWidth || 260;
    // Deshabilitar transición durante el drag para respuesta inmediata
    document.documentElement.style.setProperty('--transition-main', '0s');
    const onMove = (ev) => {
        const newWidth = Math.min(400, Math.max(180, startWidth + (ev.clientX - startX)));
        sidebarWidth.value = newWidth;
    };
    const onUp = () => {
        isResizing.value = false;
        document.removeEventListener('mousemove', onMove);
        document.removeEventListener('mouseup', onUp);
        document.body.style.cursor = '';
        document.body.style.userSelect = '';
        // Restaurar transición
        document.documentElement.style.removeProperty('--transition-main');
        localStorage.setItem('sidebarWidth', sidebarWidth.value);
    };
    document.body.style.cursor = 'col-resize';
    document.body.style.userSelect = 'none';
    document.addEventListener('mousemove', onMove);
    document.addEventListener('mouseup', onUp);
}
const showNotificaciones = ref(false);
const notificaciones = ref([]);
const notifSinLeer = ref(0);

const vClickOutside = {
  mounted(el, binding) {
    el._clickOutside = (e) => { if (!el.contains(e.target)) binding.value(); };
    document.addEventListener('click', el._clickOutside, true);
  },
  unmounted(el) {
    document.removeEventListener('click', el._clickOutside, true);
  }
};

function toggleNotificaciones() { showNotificaciones.value = !showNotificaciones.value; }
function closeNotificaciones() { showNotificaciones.value = false; }
async function irNotificacion(n) {
    closeNotificaciones();
    try {
        await api.delete(`/notificaciones/${n.id}/descartar`);
        const idx = notificaciones.value.findIndex(x => x.id === n.id);
        if (idx >= 0) notificaciones.value.splice(idx, 1);
        await cargarUnreadCount();
    } catch (e) {}
}

async function marcarTodasLeidas() {
    try {
        await api.post('/notificaciones/leer-todas');
        notificaciones.value.forEach(n => { n.leido = true; n.leido_at = new Date().toISOString(); });
        notifSinLeer.value = 0;
    } catch (e) {}
}

async function cargarNotificaciones() {
  try {
    const { data } = await api.get('/notificaciones');
    notificaciones.value = (data.notificaciones || []).slice(0, 15);
  } catch (e) {}
}

async function cargarUnreadCount() {
    try {
        const { data } = await api.get('/notificaciones/unread-count');
        notifSinLeer.value = data.unread || 0;
    } catch (e) {}
}

function formatoFecha(fecha) {
  if (!fecha) return '';
  const d = new Date(fecha);
  const now = new Date();
  const diff = Math.floor((now - d) / 1000);
  if (diff < 60) return 'Hace un momento';
  if (diff < 3600) return `Hace ${Math.floor(diff / 60)} min`;
  if (diff < 86400) return `Hace ${Math.floor(diff / 3600)} h`;
  return d.toLocaleDateString('es-CR', { day: '2-digit', month: 'short' });
}

let echoUserChannel = null;
onMounted(async () => {
    loadFavorites();
    cargarNotificaciones();
    cargarUnreadCount();
    setTimeout(loadSidebarOrder, 50);
    document.addEventListener('click', onDocumentClick);
    document.addEventListener('contextmenu', onDocumentClick);

    try {
        const { data } = await api.get('/configuracion/preferencias');
        i18nStore.loadFromServer(data.idioma);
        currencyStore.loadFromServer(data.divisa, data.tasas);
    } catch(e) {}

    try {
        const { data } = await api.get('/configuracion/empresa');
        nombreNegocio.value = data.empresa?.nombre_negocio || '';
    } catch(e) {}

    // El tracking de productividad se gestiona desde auth.js store -> useActivityTracker

    const userId = authStore.user?.id;
    if (userId && window.Echo) {
        echoUserChannel = window.Echo.private(`user.${userId}`);
        echoUserChannel.listen('.NuevaNotificacion', (data) => {
            if (data.notificacion) {
                notificaciones.value.unshift({
                    ...data.notificacion,
                    leido: false,
                });
                notificaciones.value = notificaciones.value.slice(0, 15);
                notifSinLeer.value++;
            }
        });
    }
});
onBeforeUnmount(() => {
    clearTimeout(longPressTimer.value);
    document.removeEventListener('click', onDocumentClick);
    document.removeEventListener('contextmenu', onDocumentClick);
    const userId = authStore.user?.id;
    if (userId) {
        window.Echo?.leave(`user.${userId}`);
    }
});

const pageTitle = computed(() => {
    const path = route.path;
    const t = i18nStore.t;
    if (path.startsWith('/email-builder/edit/')) return t('email_builder');
    if (path.startsWith('/email-builder/analytics/')) return 'Analytics';
    if (path === '/email-builder/new') return t('nueva_campana');

    const titleMap = {
        '/dashboard': 'dashboard', '/caja': 'caja_rapida', '/ventas': 'historial_ventas',
        '/productos': 'productos', '/catalogo': 'catalogo', '/inventario-ubicacion': 'inventario_ubicacion', '/clientes': 'clientes',
        '/usuarios': 'usuarios', '/cotizaciones': 'cotizaciones', '/enviar-cotizacion': 'enviar_cotizacion', '/pedidos': 'pedidos',
        '/compras': 'compras', '/proveedores': 'proveedores', '/devoluciones': 'devoluciones',
        '/notas-credito': 'notas_credito', '/traspasos': 'traspasos',
        '/ajustes-inventario': 'ajustes_inventario', '/combos': 'combos',
        '/reportes': 'reportes', '/configuracion': 'configuracion',
        '/business-intelligence': 'business_intelligence', '/geo-business': 'geo_business',
        '/rentabilidad': 'rentabilidad', '/etiquetas': 'etiquetas', '/planilla': 'planilla',
        '/roles': 'roles', '/chats': 'chat_interno', '/chats-cerrados': 'chats_cerrados',
        '/notificaciones': 'notificaciones', '/auditoria': 'auditoria', '/email-builder': 'email_builder',
        '/formularios': 'formularios', '/productividad': 'productividad',
        '/ticket-designer': 'ticket_designer', '/cotizacion-designer': 'cotizacion_designer', '/crm': 'crm',
        '/cuentas-cobrar': 'cuentas_cobrar', '/listas-precios': 'listas_precios',
        '/contabilidad': 'contabilidad', '/tesoreria': 'tesoreria',
        '/presupuestos': 'presupuestos', '/facturacion-electronica': 'facturacion_electronica',
    };
    const key = titleMap[path];
    return key ? t(key) : t('dashboard');
});

function toggleSidebar() {
    if (window.innerWidth <= 1024) {
        mobileOpen.value = !mobileOpen.value;
    } else {
        sidebarCollapsed.value = !sidebarCollapsed.value;
    }
}
</script>

<style>
.sidebar span, .sidebar-brand span, .nav-item span {
    color: white;
}

.notif-dropdown-wrapper {
    position: relative;
}

.notif-badge {
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
    line-height: 1;
}

.notif-dropdown {
    position: absolute;
    top: calc(100% + 8px);
    right: -8px;
    width: min(360px, calc(100vw - 32px));
    max-height: min(460px, 70vh);
    background: #ffffff;
    border: 1px solid rgba(0,0,0,0.08);
    border-radius: 12px;
    box-shadow: 0 20px 50px rgba(0,0,0,0.18);
    z-index: 2000;
    display: flex;
    flex-direction: column;
    overflow: hidden;
}

@media (max-width: 768px) {
    .notif-dropdown {
        position: fixed;
        top: 56px;
        right: 8px;
        left: 8px;
        width: auto;
        max-height: 65vh;
        border-radius: var(--mobile-radius, 16px);
        animation: notifSlideDown 0.25s ease-out;
    }
    @keyframes notifSlideDown {
        from { opacity: 0; transform: translateY(-8px); }
        to { opacity: 1; transform: translateY(0); }
    }
    .notif-item {
        padding: 12px 14px;
        gap: 10px;
        min-height: 56px;
    }
    .notif-icon {
        width: 36px;
        height: 36px;
        border-radius: 10px;
        font-size: 15px;
    }
    .notif-title { font-size: 13px; }
    .notif-msg { font-size: 12px; }
    .notif-time { font-size: 10px; }
    .notif-footer { padding: 12px 14px; }
}

[data-theme="dark"] .notif-dropdown {
    background: #0f172a;
    border-color: rgba(255,255,255,0.08);
    box-shadow: 0 20px 50px rgba(0,0,0,0.5);
}

.notif-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 14px 16px;
    border-bottom: 1px solid rgba(0,0,0,0.06);
    font-size: 14px;
    color: #111827;
    flex-wrap: wrap;
    gap: 8px;
}

[data-theme="dark"] .notif-header {
    border-bottom-color: rgba(255,255,255,0.06);
    color: #f1f5f9;
}

.notif-count {
    background: var(--primary, #3b82f6);
    color: #fff;
    font-size: 11px;
    padding: 2px 8px;
    border-radius: 10px;
    font-weight: 600;
}

.notif-empty {
    padding: 30px;
    text-align: center;
    color: #6b7280;
    font-size: 13px;
}

[data-theme="dark"] .notif-empty {
    color: #94a3b8;
}

.notif-list {
    overflow-y: auto;
    max-height: min(400px, 50vh);
}

.notif-item {
    display: flex;
    gap: 12px;
    padding: 12px 16px;
    border-bottom: 1px solid rgba(0,0,0,0.04);
    cursor: pointer;
    transition: background 0.15s;
}

.notif-item:hover {
    background: rgba(59,130,246,0.06);
}

[data-theme="dark"] .notif-item {
    border-bottom-color: rgba(255,255,255,0.04);
}

[data-theme="dark"] .notif-item:hover {
    background: rgba(59,130,246,0.12);
}

.notif-icon {
    width: 34px;
    height: 34px;
    border-radius: 8px;
    background: #f3f4f6;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    font-size: 14px;
}

[data-theme="dark"] .notif-icon {
    background: #1e293b;
}

.notif-body {
    flex: 1;
    min-width: 0;
}

.notif-title {
    font-weight: 600;
    font-size: 13px;
    color: #111827;
    margin-bottom: 2px;
}

[data-theme="dark"] .notif-title {
    color: #f8fafc;
}

.notif-msg {
    font-size: 12px;
    color: #4b5563;
    line-height: 1.4;
    overflow: hidden;
    text-overflow: ellipsis;
    display: -webkit-box;
    line-clamp: 2;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
}

[data-theme="dark"] .notif-msg {
    color: #cbd5e1;
}

.notif-time {
    font-size: 11px;
    color: #9ca3af;
    margin-top: 4px;
}

[data-theme="dark"] .notif-time {
    color: #64748b;
}

.notif-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #3b82f6;
    flex-shrink: 0;
}

.notif-item.unread {
    background: rgba(59,130,246,0.06);
}

[data-theme="dark"] .notif-item.unread {
    background: rgba(59,130,246,0.12);
}

.notif-footer {
    padding: 10px 16px;
    border-top: 1px solid rgba(0,0,0,0.06);
    text-align: center;
    font-size: 13px;
}

.notif-footer a {
    color: #3b82f6;
    text-decoration: none;
    font-weight: 500;
}

.notif-footer a:hover {
    text-decoration: underline;
}

[data-theme="dark"] .notif-footer {
    border-top-color: rgba(255,255,255,0.06);
}

.btn-xs {
    padding: 3px 8px;
    font-size: 11px;
}

/* Sidebar Resize Handle */
.sidebar-resize-handle {
    position: absolute;
    top: 0;
    right: -4px;
    width: 8px;
    height: 100%;
    cursor: col-resize;
    z-index: 100;
    transition: background 0.2s;
}
.sidebar-resize-handle:hover,
.sidebar-resize-handle:active {
    background: rgba(59,130,246,0.3);
}

/* Floating Chat Button */
.fab-chat {
    position: fixed;
    bottom: 24px;
    right: 24px;
    width: 56px;
    height: 56px;
    border-radius: 50%;
    border: none;
    background: var(--gradient-main, linear-gradient(135deg, #0e3b58, #006bb3));
    color: #fff;
    font-size: 22px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    box-shadow: 0 6px 20px rgba(14,59,88,0.35);
    transition: all 0.25s cubic-bezier(0.34, 1.56, 0.64, 1);
    z-index: 90;
    animation: fabEnter 0.4s ease;
}

.fab-chat:hover {
    transform: scale(1.08) translateY(-2px);
    box-shadow: 0 10px 28px rgba(14,59,88,0.45);
}

.fab-chat:active {
    transform: scale(0.95);
}

.fab-badge {
    position: absolute;
    top: -4px;
    right: -4px;
    min-width: 20px;
    height: 20px;
    border-radius: 10px;
    background: #ef4444;
    color: #fff;
    font-size: 11px;
    font-weight: 700;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 0 5px;
    border: 2px solid #fff;
    box-shadow: 0 2px 6px rgba(0,0,0,0.2);
}

@keyframes fabEnter {
    from { opacity: 0; transform: scale(0.5) translateY(20px); }
    to { opacity: 1; transform: scale(1) translateY(0); }
}

/* --- Favoritos --- */
.nav-item-wrapper {
    position: relative;
    display: flex;
    align-items: center;
}

.nav-item-wrapper .nav-item {
    flex: 1;
    min-width: 0;
}

/* Mobile sidebar improvements */
@media (max-width: 768px) {
    .nav-item {
        padding: 10px 12px;
        font-size: 13px;
        gap: 10px;
        min-height: 42px;
        border-radius: 12px;
    }
    .nav-item i {
        font-size: 16px;
        width: 18px;
    }
    .nav-section-title {
        font-size: 9px;
        padding: 10px 12px 4px;
        letter-spacing: 1px;
    }
    .sidebar-header {
        padding: 14px;
        min-height: 56px;
    }
    .sidebar-logo {
        width: 36px;
        height: 36px;
    }
    .sidebar-brand h2 {
        font-size: 14px;
    }
    .sidebar-brand span {
        font-size: 10px;
    }
    .sidebar-footer {
        padding: 12px;
    }
    .sidebar-user {
        padding: 8px;
    }
    .user-avatar {
        width: 32px;
        height: 32px;
        font-size: 12px;
    }
    .user-info .user-name {
        font-size: 12px;
    }
    .user-info .user-role {
        font-size: 10px;
    }
    .fav-toggle {
        opacity: 1;
        width: 22px;
        height: 22px;
        font-size: 10px;
    }
}


.fav-toggle {
    position: absolute;
    right: 8px;
    top: 50%;
    transform: translateY(-50%);
    background: none;
    border: none;
    color: rgba(255,255,255,0.2);
    font-size: 9px;
    cursor: pointer;
    padding: 2px;
    border-radius: 4px;
    opacity: 0;
    transition: all 0.2s;
    z-index: 2;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 18px;
    height: 18px;
}

.nav-item-wrapper:hover .fav-toggle {
    opacity: 1;
}

.fav-toggle:hover {
    color: #f59e0b;
    background: rgba(245,158,11,0.15);
}

.fav-toggle.fav-active {
    opacity: 1;
    color: #f59e0b;
}

.fav-toggle.fav-active:hover {
    color: #d97706;
    background: rgba(245,158,11,0.2);
}

.fav-section-title {
    display: flex;
    align-items: center;
}

/* --- Reordenar modulos --- */
.nav-item-wrapper {
    touch-action: pan-y;
    -webkit-user-select: none;
    user-select: none;
}

.nav-item-wrapper.long-pressing .nav-item {
    background: rgba(59, 130, 246, 0.15);
    border-radius: 6px;
    transition: background 0.3s;
}

[data-theme="dark"] .nav-item-wrapper.long-pressing .nav-item {
    background: rgba(59, 130, 246, 0.25);
}

.nav-item-wrapper.reorder-active {
    background: rgba(59, 130, 246, 0.12);
    border-radius: 6px;
    box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.4);
}

[data-theme="dark"] .nav-item-wrapper.reorder-active {
    background: rgba(59, 130, 246, 0.2);
    box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.5);
}

.reorder-arrows {
    position: absolute;
    right: 4px;
    top: 50%;
    transform: translateY(-50%);
    display: flex;
    gap: 2px;
    z-index: 10;
    animation: reorderFadeIn 0.2s ease;
}

@keyframes reorderFadeIn {
    from { opacity: 0; transform: translateY(-50%) scale(0.8); }
    to { opacity: 1; transform: translateY(-50%) scale(1); }
}

.reorder-btn {
    width: 22px;
    height: 22px;
    border-radius: 4px;
    border: none;
    background: rgba(59, 130, 246, 0.9);
    color: #fff;
    font-size: 10px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.15s;
    padding: 0;
}

.reorder-btn:hover {
    background: #2563eb;
    transform: scale(1.1);
}

.reorder-btn:active {
    transform: scale(0.95);
}

.reorder-btn.reorder-close {
    background: rgba(239, 68, 68, 0.8);
}

.reorder-btn.reorder-close:hover {
    background: #dc2626;
}


.context-menu {
    position: fixed;
    z-index: 9999;
    background: #1e293b;
    border: 1px solid rgba(255,255,255,0.12);
    border-radius: 8px;
    padding: 4px;
    box-shadow: 0 8px 24px rgba(0,0,0,0.4);
    min-width: 140px;
}
.context-menu-item {
    display: flex;
    align-items: center;
    gap: 8px;
    width: 100%;
    padding: 8px 12px;
    background: none;
    border: none;
    color: #e2e8f0;
    font-size: 13px;
    cursor: pointer;
    border-radius: 6px;
    transition: background 0.15s;
    text-align: left;
}
.context-menu-item:hover {
    background: rgba(99,102,241,0.2);
    color: #fff;
}
.context-menu-item i {
    font-size: 11px;
    width: 14px;
    text-align: center;
}

@media (max-width: 1023px) {
    .sidebar-resize-handle { display: none; }
    .sidebar {
        box-shadow: none;
        transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        z-index: 100;
        width: min(300px, 85vw);
    }
    .sidebar.mobile-open {
        box-shadow: 8px 0 40px rgba(0,0,0,0.35);
    }
}

/* Mobile Bottom Nav Items */
.mob-nav-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 3px;
    padding: 6px 0;
    width: 20%;
    color: var(--text-muted, #9ca3af);
    font-size: 10px;
    font-weight: 600;
    text-decoration: none;
    transition: color 0.2s ease;
    position: relative;
    -webkit-tap-highlight-color: transparent;
    min-height: 48px;
    background: none;
    border: none;
    cursor: pointer;
    font-family: inherit;
}
.mob-nav-item i {
    font-size: 18px;
    transition: transform 0.2s ease;
}
.mob-nav-item:active i {
    transform: scale(0.88);
}
.mob-nav-item.active {
    color: var(--primary-dark, #0d496b);
}
.mob-nav-item.active i {
    color: var(--primary-dark, #0d496b);
}
.mob-nav-item.active::before {
    content: '';
    position: absolute;
    top: 0;
    left: 50%;
    transform: translateX(-50%);
    width: 28px;
    height: 3px;
    background: var(--gradient-main, linear-gradient(135deg, #0e3b58, #006bb3));
    border-radius: 0 0 4px 4px;
}

/* Center action button */
.mob-nav-action-icon {
    width: 42px;
    height: 42px;
    border-radius: 50%;
    background: var(--gradient-main, linear-gradient(135deg, #0e3b58, #006bb3));
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 18px;
    margin-top: -12px;
    box-shadow: 0 4px 12px rgba(14, 59, 88, 0.3);
    transition: transform 0.2s ease;
}
.mob-nav-action:active .mob-nav-action-icon {
    transform: scale(0.92);
}
.mob-nav-action.active .mob-nav-action-icon {
    box-shadow: 0 4px 16px rgba(14, 59, 88, 0.5);
}

/* Badge on nav item */
.mob-nav-badge {
    position: absolute;
    top: 2px;
    right: calc(50% - 18px);
    min-width: 16px;
    height: 16px;
    border-radius: 8px;
    background: #ef4444;
    color: #fff;
    font-size: 9px;
    font-weight: 700;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 0 4px;
    line-height: 1;
}

/* Mobile header improvements */
@media (max-width: 768px) {
    .header-right { gap: 6px; }
    .header-btn { width: 40px; height: 40px; font-size: 17px; }
    .toggle-sidebar { width: 40px; height: 40px; font-size: 17px; }
    .page-title { font-size: 16px; font-weight: 700; max-width: 160px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    .fab-chat {
        bottom: calc(64px + 16px + env(safe-area-inset-bottom, 0px));
        right: 16px;
        width: 52px;
        height: 52px;
        font-size: 20px;
    }
    .notif-dropdown {
        position: fixed;
        top: 56px;
        right: 8px;
        left: 8px;
        width: auto;
        max-height: 70vh;
    }
    .sidebar-backdrop {
        z-index: 99;
    }
}

/* Mobile phone improvements */
@media (max-width: 480px) {
    .header-right { gap: 4px; }
    .header-btn { width: 38px; height: 38px; font-size: 16px; }
    .toggle-sidebar { width: 38px; height: 38px; font-size: 16px; }
    .page-title { font-size: 15px; max-width: 130px; }
    .fab-chat {
        bottom: calc(64px + 14px + env(safe-area-inset-bottom, 0px));
        right: 12px;
        width: 48px;
        height: 48px;
        font-size: 18px;
    }
    .notif-dropdown {
        top: 52px;
        right: 4px;
        left: 4px;
    }
    .mob-nav-item { font-size: 9px; gap: 2px; }
    .mob-nav-item i { font-size: 16px; }
    .mob-nav-action-icon { width: 38px; height: 38px; font-size: 16px; margin-top: -10px; }
}
</style>
