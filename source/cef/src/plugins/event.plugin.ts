import { AxiosInstance } from "./axios.plugin";

const RegisteredEvents: Record<string, (...args: any) => void> = {}

export default {

    post(event: string, args?: any) {
        return AxiosInstance.post(event, args);
    },

    on(eventName: string, cb: (...args: any) => void) {
        if (typeof RegisteredEvents[eventName] === "function") return;

        RegisteredEvents[eventName] = cb;
    },

    focusNui(state: boolean) {
        this.post("focus_nui", state);
    },

    triggerServer(eventName: string, eventArgs: any) {
        this.post("trigger_server", {
            event: eventName,
            args: eventArgs
        });
    },
    triggerClient(eventName: string, eventArgs: any) {
        this.post("trigger_client", {
            event: eventName,
            args: eventArgs
        });
    }
}

window.addEventListener("message", (e) => {
    const d = e.data;

    if (typeof RegisteredEvents[d.event] === "function") {
        RegisteredEvents[d.event](d);
    }
});