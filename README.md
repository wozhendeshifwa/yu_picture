# yu_picture

云图库（`yu_picture`）：图片分享站。当前状态是**前后端骨架已跑通，未接数据库**。

| 目录 | 内容 |
| --- | --- |
| `frontend/` | Vue 3 + TypeScript + Vite 前端，端口 **3000** |
| `backend/` | Spring Boot 4 后端，端口 **5000** |
| `deploy/` | ECS + 阿里云 RDS 的部署与连通方案（见 `deploy/README.md`） |
| `docs/agents/` | 本仓库给 agent 用的约定（issue 流程、triage 标签、领域文档） |

## 环境要求

| 工具 | 版本 | 备注 |
| --- | --- | --- |
| Node.js | ≥ 20（实测 26.13.0 LTS） | |
| pnpm | 10.x | `npm install -g pnpm@10` |
| JDK | 21 | 需要设 `JAVA_HOME`；后端用 `mvnw`，不用单独装 Maven |

## 起本地环境

```powershell
pnpm --dir frontend install   # 首次
.\start-dev.ps1               # 后端 5000 + 前端 3000，各开一个窗口
```

不用脚本就开两个终端：

```powershell
# 终端 1
cd backend
.\mvnw.cmd spring-boot:run

# 终端 2
cd frontend
pnpm dev
```

打开 <http://127.0.0.1:3000>，首页会显示后端连通状态。

## 验收标准

```powershell
cd frontend
pnpm lint          # ESLint 9 flat config
pnpm test          # Vitest 冒烟测试
pnpm build         # vue-tsc + vite build

cd ..\backend
.\mvnw.cmd test    # 含 /api/health 的真实 HTTP 冒烟

# 整条链路（Vite 代理 -> 后端）
curl http://127.0.0.1:3000/api/health   # {"status":"ok"}
```

## 接口约定

- 浏览器只请求同源 `/api/...`，由 Vite 代理转发到 `http://127.0.0.1:5000`；
  上线时由 nginx 做同一件事，前端代码不用改。
- 当前唯一接口：`GET /api/health` → `{"status":"ok"}`。

## 为什么不连数据库

本轮刻意做到「零数据库」：

- `backend/pom.xml` 里没有任何 JDBC / JPA / MyBatis starter；
- `application.yml` 不写 `spring.datasource`，只写端口。

将来接入 RDS 时，连接串、SSL、连接池参数都在 `deploy/README.md` §5，密码只走环境变量。
表结构用迁移工具建，不手工改库。
