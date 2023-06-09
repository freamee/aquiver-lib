import { defineStore } from 'pinia';
import { onMounted, ref } from 'vue';
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

    onMounted(() => {
        if (import.meta.env.DEV) {
            helps.value.push({
                msg: "Socials",
                uid: "socials",
                icon: "fa-brands fa-discord",
                key: "F5"
            }, {
                msg: "Dashboard",
                uid: "dashboard",
                icon: "fa-solid fa-home",
                key: "F6"
            })
        }
    });

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
eventPlugin.on("HELP_ADD", ({ helpData }) => {
    const helpStore = useHelpStore();
    console.log(JSON.stringify(helpData))
    helpStore.addHelp(helpData);
});
eventPlugin.on("HELP_UPDATE", ({ helpData }) => {
    const helpStore = useHelpStore();
    console.log(JSON.stringify(helpData))
    helpStore.updateHelp(helpData);
});