import { createPinia } from 'pinia';
import { createApp } from 'vue'
import App from './App.vue'
import "./global.scss";
import $ from "jquery";
import 'animate.css';

import CircleProgress from 'vue3-circle-progress';

createApp(App)
    .use(createPinia())
    .component("CircleProgress", CircleProgress)
    .mount('#app');

if (import.meta.env.DEV) {
    $("body").css({
        'backgroundColor': 'rgb(15,15,15)'
    })
}