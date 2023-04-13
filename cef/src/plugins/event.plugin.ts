import { AxiosInstance } from "./axios.plugin";

const RegisteredEvents: Record<string, (...args: any) => void> = {}

export default {

    post(event: string, args?: any) {
        return AxiosInstance.post(event, args);
    },

    on(eventName: string, cb: (...args: any) => void) {
        if (typeof RegisteredEvents[eventName] === "function") return;

        RegisteredEvents[eventName] = cb;
    }
}

window.addEventListener("message", (e) => {
    const d = e.data;

    if (typeof RegisteredEvents[d.event] === "function") {
        RegisteredEvents[d.event](d);
    }
});