import { defineStore } from 'pinia';
import { ref } from 'vue';
import eventPlugin from '../plugins/event.plugin';

interface ProgressbarState {
    opened: boolean;
    maxTime: number | null;
    time: number | null;
    text: string;
    interval: NodeJS.Timer | null;

    percent: number;
}

export const useProgressStore = defineStore("ProgressStore", () => {
    const store = ref<ProgressbarState>({
        opened: false,
        maxTime: null,
        time: null,
        text: "",
        interval: null,
        percent: 0
    });

    function startProgress(text: string, time: number) {
        if (store.value.interval) {
            clearInterval(store.value.interval);
            store.value.interval = null;
        }

        store.value.time = time;
        store.value.maxTime = time;
        store.value.text = text;
        store.value.opened = true;

        store.value.interval = setInterval(() => {
            if (store.value.time != null && store.value.maxTime != null) {
                store.value.time -= 500;

                store.value.percent = ((store.value.time / store.value.maxTime) * 100) - 100;

                if (store.value.time < 1) {
                    store.value.opened = false;

                    if (store.value.interval) {
                        clearInterval(store.value.interval);
                        store.value.interval = null;
                    }
                }
            }

        }, 500);
    }

    return {
        store,
        startProgress
    }
});

eventPlugin.on("StartProgress", ({ text, time }) => {
    const progressStore = useProgressStore();
    progressStore.startProgress(text, time);
});
