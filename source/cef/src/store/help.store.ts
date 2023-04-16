import { defineStore } from 'pinia';
import { ref } from 'vue';
import eventPlugin from '../plugins/event.plugin';

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

    return {
        helps,
        addHelp,
        removeHelp,
        updateHelp
    }
});

eventPlugin.on("HELP_REMOVE", ({ uid }) => {
    const helpStore = useHelpStore();
    helpStore.removeHelp(uid);
});
eventPlugin.on("HELP_ADD", (data) => {
    const helpStore = useHelpStore();
    helpStore.addHelp(data);
});
eventPlugin.on("HELP_UPDATE", (data) => {
    const helpStore = useHelpStore();
    helpStore.updateHelp(data);
});