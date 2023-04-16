import { defineStore } from 'pinia';
import { ref } from 'vue';
import { playAudio } from '../plugins/audio.plugin';
import eventPlugin from '../plugins/event.plugin';

type INotification = {
    message: string;
    icon: string;
    color: string;
    unique: number;
}

export const useNotiStore = defineStore("NotificationStore", () => {
    const notifications = ref<INotification[]>([]);

    function sendNotification(type: "error" | "success" | "info" | "warning", message: string) {
        let icon: string, color: string;

        switch (type) {
            case "error": {
                icon = "fa-solid fa-times-circle";
                color = "red";
                playAudio("sfx/e.mp3");
                break;
            }
            case "info": {
                icon = "fa-solid fa-info-circle";
                color = "lightblue";
                playAudio("sfx/i.mp3");
                break;
            }
            case "success": {
                icon = "fa-solid fa-circle-check";
                color = "lightgreen";
                playAudio("sfx/s.mp3");
                break;
            }
            case "warning": {
                icon = "fa-solid fa-exclamation-circle";
                color = "yellow";
                playAudio("sfx/w.mp3");
                break;
            }
        }

        /** Probably not neccessary, and there are better solutions, but y. */
        const unique = Math.floor(Math.random() * 10000);

        notifications.value.push({
            message,
            icon,
            color,
            unique
        });

        setTimeout(() => {
            const idx = notifications.value.findIndex(a => a.unique == unique);
            if (notifications.value[idx]) {
                notifications.value.splice(idx, 1);
            }
        }, 5000);
    }

    return {
        notifications,
        sendNotification
    }
});

eventPlugin.on("SEND_NOTIFICATION", ({ type, message }) => {
    const notiStore = useNotiStore();
    notiStore.sendNotification(type, message);
});