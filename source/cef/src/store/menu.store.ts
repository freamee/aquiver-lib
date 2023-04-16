import { defineStore } from 'pinia';
import { ref, watch } from 'vue';
import eventPlugin from '../plugins/event.plugin';
import axios from "axios";

type IMenu = {
    name: string;
    icon: string;
}

type DataState = {
    opened: boolean;
    menuData: {
        header: string;
        executeInResource: string;
        menus: IMenu[]
    };
}

export const useMenuStore = defineStore("MenuStore", () => {

    const store = ref<DataState>({
        opened: false,
        menuData: {
            header: "Cserép",
            executeInResource: "",
            menus: []
        }
    });

    function keyupHandler(e: KeyboardEvent) {
        if (e.key != "Escape") return;

        if (store.value.opened) {
            store.value.opened = false;
        }
    }

    function executeClick(index: number) {
        axios.post(`https://${store.value.menuData.executeInResource}/menuExecuteCallback`, {
            index: index
        });
        store.value.opened = false;
    }

    watch(() => store.value.opened, (newState) => {
        if (newState) {
            window.addEventListener("keyup", keyupHandler);
        }
        else {
            window.removeEventListener("keyup", keyupHandler);
        }

        eventPlugin.focusNui(newState);
    });

    return {
        store,
        executeClick
    }
});

eventPlugin.on("MenuOpen", ({ menuData }) => {
    const menuStore = useMenuStore();
    menuStore.store.opened = true;
    menuStore.store.menuData = menuData;
});

eventPlugin.on("MenuClose", () => {
    const menuStore = useMenuStore();
    menuStore.store.opened = false;
});