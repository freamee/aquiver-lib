import axios from "axios";

export const AxiosInstance = axios.create({
    // @ts-ignore
    baseURL: typeof GetParentResourceName === "function" ? `https://${GetParentResourceName()}/` : `https://aquiver-lib/`
})