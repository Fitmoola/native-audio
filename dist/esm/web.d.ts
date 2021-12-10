import { WebPlugin } from '@capacitor/core';
import { NativeAudio } from "./definitions";
import type { ConfigureOptions, PreloadOptions } from "./definitions";
export declare class NativeAudioWeb extends WebPlugin implements NativeAudio {
    constructor();
    resume(options: {
        assetId: string;
    }): Promise<void>;
    pause(options: {
        assetId: string;
    }): Promise<void>;
    getCurrentTime(options: {
        assetId: string;
        time: number;
    }): Promise<{
        currentTime: number;
    }>;
    getDuration(options: {
        assetId: string;
    }): Promise<{
        duration: number;
    }>;
    configure(options: ConfigureOptions): Promise<void>;
    preload(options: PreloadOptions): Promise<void>;
    play(options: {
        assetId: string;
    }): Promise<void>;
    loop(options: {
        assetId: string;
    }): Promise<void>;
    stop(options: {
        assetId: string;
    }): Promise<void>;
    unload(options: {
        assetId: string;
    }): Promise<void>;
    setVolume(options: {
        assetId: string;
    }): Promise<void>;
}
declare const NativeAudio: NativeAudioWeb;
export { NativeAudio };
