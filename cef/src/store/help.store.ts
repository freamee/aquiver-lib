import { defineStore } from 'pinia';
import { ref } from 'vue';

type IHelp = {
    uid: string;
    msg: string;
    key?: string;
    image?: string;
    icon?: string;
}

export const useHelpStore = defineStore("HelpStore", () => {
    const helps = ref<IHelp[]>([]);

    function addHelp({ uid, key, msg, image, icon }: IHelp) {
        if (helps.value.findIndex(a => a.uid == uid) >= 0) return;

        helps.value.push({
            uid,
            key,
            msg,
            image,
            icon
        });
    }

    function removeHelp(uid: string) {
        const idx = helps.value.findIndex(a => a.uid == uid);
        if (idx >= 0) {
            helps.value.splice(idx, 1);
        }
    }

    function updateHelp({ uid, key, msg, image, icon }: IHelp) {
        const idx = helps.value.findIndex(a => a.uid == uid);
        if (idx >= 0) {
            helps.value[idx].msg = msg;
            helps.value[idx].key = key;
            helps.value[idx].image = image;
            helps.value[idx].icon = icon;
        }
    }

    return { helps, addHelp, removeHelp, updateHelp }
});

window.addEventListener("message", (ev: MessageEvent) => {
    const store = useHelpStore();

    switch (ev.data.event) {
        case "HELP_REMOVE":
            store.removeHelp(ev.data.uid)
            break;

        case "HELP_ADD":
            store.addHelp(ev.data)
            break;

        case "HELP_UPDATE":
            store.updateHelp(ev.data)
            break;
    }
});