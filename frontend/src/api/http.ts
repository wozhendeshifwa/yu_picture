import axios from "axios";

/**
 * 统一出口：浏览器只会请求同源的 VITE_API_BASE_URL（开发环境是 /api，由 Vite 代理转发）。
 * 不在业务代码里直接 import axios。
 */
export const http = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 10_000,
});
