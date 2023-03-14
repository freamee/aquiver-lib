import { createPinia } from 'pinia';
import { createApp } from 'vue'
import App from './App.vue'
import "./global.scss";
import $ from "jquery";
import 'animate.css';

createApp(App)
    .use(createPinia())
    .mount('#app');

if (import.meta.env.DEV) {
    $("body").css({
        'backgroundColor': 'rgb(15,15,15)'
    })
}