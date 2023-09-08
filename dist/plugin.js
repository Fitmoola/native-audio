var capacitorApp = (function (exports, core) {
    'use strict';

    const NativeAudio$1 = core.registerPlugin('NativeAudio', {
        web: () => Promise.resolve().then(function () { return web; }).then(m => new m.NativeAudioWeb()),
    });

    class NativeAudioWeb extends core.WebPlugin {
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

    var web = /*#__PURE__*/Object.freeze({
        __proto__: null,
        NativeAudioWeb: NativeAudioWeb,
        NativeAudio: NativeAudio
    });

    exports.NativeAudio = NativeAudio$1;

    Object.defineProperty(exports, '__esModule', { value: true });

    return exports;

})({}, capacitorExports);
//# sourceMappingURL=plugin.js.map
