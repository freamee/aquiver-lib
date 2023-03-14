<template>
    <NotificationComponent />
</template>

<script lang="ts" setup>
import { onMounted } from 'vue';
import { AxiosInstance } from './plugins/axios.plugin';
import NotificationComponent from './components/NotificationComponent.vue';

onMounted(() => {
    AxiosInstance.post("CEF_LOADED");
});

</script>

<style lang="scss" scoped>
.inventory-background {
    width: 100%;
    height: 100%;
    background-position: center;
    background-size: cover;
    background-repeat: no-repeat;
}
</style>