<template>
    <NotificationComponent />
    <HelpComponent />
</template>

<script lang="ts" setup>
import NotificationComponent from './components/NotificationComponent.vue';
import HelpComponent from "./components/HelpComponent.vue";

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