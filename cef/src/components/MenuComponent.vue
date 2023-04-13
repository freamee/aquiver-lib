<template>
    <div class="center-div">
        <div v-if="store.opened" class="click-menu-parent">
            <div class="click-menu-header">
                {{ store.menuData.header }}
            </div>
            <div class="click-menu-entry" v-for="(menu, index) in store.menuData.menus"
                @click.prevent.left="menuStore.executeClick(menu)">
                <i :class="menu.icon"></i> {{ menu.name }}
            </div>
        </div>
    </div>
</template>

<script lang="ts" setup>
import { computed } from 'vue';
import { useMenuStore } from '../store/menu.store';

const menuStore = useMenuStore();
const store = computed(() => menuStore.store);
</script>

<style lang="scss" scoped>
$textstroke: -1px -1px 0 #000, 1px -1px 0 #000, -1px 1px 0 #000, 1px 1px 0 #000;
$background-gradient: linear-gradient(90deg, rgba(20, 20, 20, 0.55) 0%, transparent 100%);
$background-gradient-hover: linear-gradient(90deg, rgba(230, 150, 3, 0.25) 0%, transparent 100%);

.click-menu-parent {
    position: absolute;
    left: 55%;
    z-index: 99999;
    border-radius: .25vw;
    transform: skewY(-2deg);
    text-shadow: $textstroke;

    .click-menu-header {
        position: relative;
        font-size: 1.2vw;
        color: rgb(220, 220, 220);
        font-variant: small-caps;
        width: 100%;
        text-align: center;
    }

    .click-menu-entry {
        position: relative;
        color: rgb(200, 200, 200);
        font-size: .8vw;
        padding: .45vw 1vw;
        padding-left: .4vw;
        background: $background-gradient;
        transition: ease();
        transition-duration: .1s;
        border-left: .15vw solid transparent;
        margin: .25vw 0;

        &:hover {
            border-left: .15vw solid orange;
            background: $background-gradient-hover;
        }

        i {
            margin-right: .35vw;
        }
    }
}
</style>