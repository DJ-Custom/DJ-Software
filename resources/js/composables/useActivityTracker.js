import { ref } from 'vue';
import api from '../services/api';

const SYNC_INTERVAL_MS = 30000;

let activityTracker = null;

class ActivityTracker {
    constructor() {
        this._activeSeconds = 0;
        this._isTracking = false;
        this._sessionId = null;
        this._tabId = this._generateTabId();
        this._syncTimer = null;
        this._countTimer = null;
        this._started = false;
        this._boundFns = {};
        this._channel = null;

        this.activeSeconds = ref(0);
        this.isActive = ref(false);
        this.isPaused = ref(true);
    }

    _generateTabId() {
        return 'tab_' + Date.now().toString(36) + '_' + Math.random().toString(36).slice(2, 8);
    }

    _startCounting() {
        if (this._isTracking) return;
        this._isTracking = true;
        this.isActive.value = true;
        this.isPaused.value = false;
        this._countTimer = setInterval(() => {
            if (this._isTracking) {
                this._activeSeconds++;
                this.activeSeconds.value = this._activeSeconds;
            }
        }, 1000);
    }

    _stopCounting() {
        if (!this._isTracking) return;
        this._isTracking = false;
        this.isActive.value = false;
        this.isPaused.value = true;
        if (this._countTimer) {
            clearInterval(this._countTimer);
            this._countTimer = null;
        }
    }

    _shouldTrack() {
        return !document.hidden && document.hasFocus();
    }

    _onVisibilityChange() {
        if (!this._started) return;
        if (this._shouldTrack()) {
            this._startCounting();
        } else {
            this._stopCounting();
            this._syncToServer(false);
        }
    }

    _onFocus() {
        if (!this._started) return;
        if (this._shouldTrack()) {
            this._startCounting();
        }
    }

    _onBlur() {
        if (!this._started) return;
        if (!document.hasFocus()) {
            this._stopCounting();
            this._syncToServer(false);
        }
    }

    _onBeforeUnload() {
        if (!this._started || !this._sessionId) return;
        this._syncToServer(true);
    }

    _startSyncTimer() {
        this._stopSyncTimer();
        this._syncTimer = setInterval(() => {
            if (this._isTracking && this._sessionId) {
                this._syncToServer(false);
            }
        }, SYNC_INTERVAL_MS);
    }

    _stopSyncTimer() {
        if (this._syncTimer) {
            clearInterval(this._syncTimer);
            this._syncTimer = null;
        }
    }

    async _registerSession() {
        try {
            const { data } = await api.post('/productividad/sesion', {
                tab_id: this._tabId,
            });
            this._sessionId = data.sesion_id;
        } catch (e) {
            this._sessionId = null;
        }
    }

    async _syncToServer(sendBeacon = false) {
        if (!this._sessionId) return;
        const payload = {
            active_seconds: this._activeSeconds,
            tab_id: this._tabId,
        };

        if (sendBeacon) {
            try {
                const blob = new Blob([JSON.stringify(payload)], { type: 'application/json' });
                navigator.sendBeacon('/api/productividad/sync?via=beacon', blob);
            } catch (e) {}
        } else {
            try {
                await api.post('/productividad/sync', payload);
            } catch (e) {}
        }
    }

    _bindEvents() {
        const opts = { capture: true, passive: true };
        this._boundFns = {
            visibilitychange: () => this._onVisibilityChange(),
            focus: () => this._onFocus(),
            blur: () => this._onBlur(),
            beforeunload: () => this._onBeforeUnload(),
        };

        document.addEventListener('visibilitychange', this._boundFns.visibilitychange);
        window.addEventListener('focus', this._boundFns.focus, opts);
        window.addEventListener('blur', this._boundFns.blur, opts);
        window.addEventListener('beforeunload', this._boundFns.beforeunload);
    }

    _unbindEvents() {
        const opts = { capture: true, passive: true };
        if (this._boundFns.visibilitychange) {
            document.removeEventListener('visibilitychange', this._boundFns.visibilitychange);
            window.removeEventListener('focus', this._boundFns.focus, opts);
            window.removeEventListener('blur', this._boundFns.blur, opts);
            window.removeEventListener('beforeunload', this._boundFns.beforeunload);
        }
        this._boundFns = {};
    }

    async start() {
        if (this._started) return;
        this._started = true;
        this._activeSeconds = 0;
        this.activeSeconds.value = 0;

        this._bindEvents();
        await this._registerSession();
        this._startSyncTimer();

        if (this._shouldTrack()) {
            this._startCounting();
        }

        if (this._sessionId) {
            this._syncToServer(false);
        }
    }

    async stop() {
        if (!this._started) return;
        this._started = false;

        this._stopCounting();
        this._unbindEvents();
        this._stopSyncTimer();

        await this._syncToServer(false);

        if (this._channel) {
            try { this._channel.close(); } catch (e) {}
            this._channel = null;
        }
    }

    getActiveSeconds() {
        return this._activeSeconds;
    }
}

export function useActivityTracker() {
    if (!activityTracker) {
        activityTracker = new ActivityTracker();
    }
    return activityTracker;
}
