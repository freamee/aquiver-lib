<template>
    <div class="notificationParent">
        <transition-group enter-active-class="animate__animated animate__faster animate__fadeIn"
            leave-active-class="animate__animated animate__faster animate__fadeOut">
            <div :key="a.unique" class="notifyEntry" v-for="a in notiStore.notifications">
                <div class="notin">
                    <i v-if="a.icon" :style="{ color: a.color }" :class="a.icon"></i>
                    <span>{{ a.message }}</span>
                </div>
            </div>
        </transition-group>
    </div>
</template>

<script lang="ts" setup>
import { useNotiStore } from '../store/notifications.store';

const notiStore = useNotiStore();

</script>

<style lang="scss" scoped>
.notificationParent {
    position: absolute;
    top: 1%;
    width: 100%;
    display: flex;
    justify-content: center;
    align-items: center;
    flex-wrap: wrap;
    overflow: hidden;

    .notifyEntry {
        position: relative;
        width: 100%;
        color: white;
        font-size: 0.75vw;
        padding: 0.2vw 0.5vw;
        text-align: center;
        display: flex;
        justify-content: center;

        .notin {
            position: relative;
            max-width: 100%;
            background: rgba(0, 0, 0, 0.55);
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 0.25vw 0.55vw;
            border: 0.025vw solid rgba(10, 10, 10, 0.25);
            border-radius: 0.15vw;
            overflow: hidden;

            span {
                margin-left: .5vw;
            }
        }
    }
}
</style>