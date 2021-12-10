import { WebPlugin } from '@capacitor/core';
export class NativeAudioWeb extends WebPlugin {
    constructor() {
        super({
            name: "NativeAudio",
            platforms: ["web"],
        });
    }
    resume(options) {
        console.log(options);
        throw new Error('Method not implemented.');
    }
    pause(options) {
        console.log(options);
        throw new Error('Method not implemented.');
    }
    getCurrentTime(options) {
        console.log(options);
        throw new Error('Method not implemented.');
    }
    getDuration(options) {
        console.log(options);
        throw new Error('Method not implemented.');
    }
    configure(options) {
        console.log(options);
        throw new Error("Method not implemented.");
    }
    preload(options) {
        console.log(options);
        throw new Error("Method not implemented.");
    }
    play(options) {
        console.log(options);
        throw new Error("Method not implemented.");
    }
    loop(options) {
        console.log(options);
        throw new Error("Method not implemented.");
    }
    stop(options) {
        console.log(options);
        throw new Error("Method not implemented.");
    }
    unload(options) {
        console.log(options);
        throw new Error("Method not implemented.");
    }
    setVolume(options) {
        console.log(options);
        throw new Error("Method not implemented.");
    }
}
const NativeAudio = new NativeAudioWeb();
export { NativeAudio };
//# sourceMappingURL=web.js.map