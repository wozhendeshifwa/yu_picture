import { createPinia } from "pinia";

/** 本轮只把 Pinia 装进应用，等有真实共享状态时再加 store。 */
export const pinia = createPinia();
