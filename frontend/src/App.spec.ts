import Antd from "ant-design-vue";
import { flushPromises, mount } from "@vue/test-utils";
import { createPinia } from "pinia";
import { createMemoryHistory, createRouter } from "vue-router";
import { describe, expect, it, vi } from "vitest";

import App from "@/App.vue";
import BasicLayout from "@/layouts/BasicLayout.vue";
import HomeView from "@/views/HomeView.vue";

vi.mock("@/api/health", () => ({
  fetchHealth: vi.fn().mockResolvedValue({ status: "ok" }),
}));

describe("应用骨架", () => {
  it("渲染布局，并把 /api/health 的结果显示出来", async () => {
    const router = createRouter({
      history: createMemoryHistory(),
      routes: [
        {
          path: "/",
          component: BasicLayout,
          children: [{ path: "", component: HomeView }],
        },
      ],
    });

    await router.push("/");
    await router.isReady();

    const wrapper = mount(App, {
      global: { plugins: [createPinia(), router, Antd] },
    });

    await flushPromises();

    expect(wrapper.text()).toContain("云图库");
    expect(wrapper.text()).toContain("已连通");
  });
});
