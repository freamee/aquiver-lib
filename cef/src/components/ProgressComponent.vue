<template>
    <Transition enterActiveClass="animate__animated animate__fadeIn animate__faster"
        leaveActiveClass="animate__animated animate__fadeOut animate__faster">
        <div v-show="store.opened" class="center-div">
            <div class="circle-progress-parent">
                <circle-progress :percent="store.percent" />
                <div class="progress-text">{{ store.text }}</div>
            </div>
        </div>
    </Transition>
</template>

<script lang="ts" setup>
import { Transition, computed } from 'vue';
import { useProgressStore } from '../store/progress.store';

const progressStore = useProgressStore();
const store = computed(() => progressStore.store);

</script>

<style lang="scss" scoped>
.circle-progress-parent {
    position: absolute;
    bottom: 20%;
    display: flex;
    align-items: center;
    justify-content: center;
    height: 6.5vw;
    width: 6.5vw;
    flex-wrap: wrap;
    pointer-events: none;

    .progress-text {
        position: absolute;
        white-space: nowrap;
        overflow: hidden;
        color: rgb(220, 220, 220);
        bottom: -2vw;
        font-size: 1.1vw;
    }
}
</style>