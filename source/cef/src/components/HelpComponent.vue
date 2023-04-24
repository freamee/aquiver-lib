<template>
    <div class="help-notification-parent">
        <TransitionGroup enterActiveClass="animate__animated animate__fadeInLeft animate__faster"
            leaveActiveClass="animate__animated animate__fadeOutLeft animate__faster">

            <div class="help-notification-entry" :key="a.uid" v-for="a in helpStore.helps">
                <div class="indicator">
                    <div v-if="a.key">{{ a.key }}</div>
                    <div class="img" :style="{
                            backgroundImage: `url(helps/${a.image}.png)`
                        }" v-if="a.image">
                    </div>
                </div>
                <div class="text">
                    <i :class="a.icon" v-if="a.icon"></i>
                    {{ a.msg }}
                </div>
            </div>

        </TransitionGroup>
    </div>
</template>

<script lang="ts" setup>
import { useHelpStore } from '../store/help.store';

const helpStore = useHelpStore();

</script>


<style lang="scss" scoped>
$greywhite: rgb(220, 220, 220);
$textstroke: -1px -1px 0 #000, 1px -1px 0 #000, -1px 1px 0 #000, 1px 1px 0 #000;

.help-notification-parent {
    position: absolute;
    bottom: 40%;
    left: 0;
    pointer-events: none;
    text-shadow: $textstroke;

    .help-notification-entry {
        position: relative;
        max-width: 15vw;
        font-size: 0.7vw;
        color: white;
        white-space: pre-line;
        display: flex;
        align-items: center;
        padding: .25vw;
        background: linear-gradient(90deg, rgba(0, 0, 0, 0.25) 0%, transparent 100%);
        border-left: .15vw groove rgb(100, 100, 100);

        .indicator {
            position: relative;
            height: 1.5vw;
            width: 1.5vw;
            display: flex;
            justify-content: center;
            align-items: center;
            border: .125vw solid rgb(175, 175, 175);
            border-radius: 100%;
            margin-right: .5vw;
        }

        .text {
            flex: 1;
        }

        .img {
            position: relative;
            width: 75%;
            height: 75%;
            background-position: center;
            background-size: contain;
            background-repeat: no-repeat;
        }
    }
}
</style>