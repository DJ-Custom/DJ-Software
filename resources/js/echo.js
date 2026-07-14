import Echo from 'laravel-echo';
import Pusher from 'pusher-js';
import { getToken } from './services/authToken';

window.Pusher = Pusher;

let echo = null;

const reverbKey = import.meta.env.VITE_REVERB_APP_KEY;

if (reverbKey) {
    echo = new Echo({
        broadcaster: 'reverb',
        key: reverbKey,
        wsHost: import.meta.env.VITE_REVERB_HOST,
        wsPort: import.meta.env.VITE_REVERB_PORT ?? 8080,
        wssPort: import.meta.env.VITE_REVERB_PORT ?? 443,
        forceTLS: (import.meta.env.VITE_REVERB_SCHEME ?? 'https') === 'https',
        enabledTransports: ['ws', 'wss'],
        authorizer: (channel, options) => {
            return {
                authorize: (socketId, callback) => {
                    const token = getToken();
                    fetch('/api/broadcasting/auth', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'Accept': 'application/json',
                            'Authorization': `Bearer ${token || ''}`,
                        },
                        body: JSON.stringify({
                            socket_id: socketId,
                            channel_name: channel.name,
                        }),
                    })
                    .then(response => response.json())
                    .then(data => callback(null, data))
                    .catch(error => callback(error));
                },
            };
        },
    });

    window.Echo = echo;
} else {
    console.warn('Reverb app key not configured. Real-time features disabled.');
}

export default echo;
