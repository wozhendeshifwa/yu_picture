# yu_picture

云图库（`yu_picture`）：图片分享站。当前状态是**前后端骨架已跑通，数据库通道已打通，但还没有业务表**。

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
- `GET /api/health` → `{"status":"ok"}`：进程活着。
- `GET /api/health/db` → `{"db":"ok","latencyMs":7}`：数据库通道通不通。断了会是
  `{"db":"down","latencyMs":3001,"detail":"..."}`，应用本身照常运行。

## 数据库通道（本地开发）

本机 IP 不在 RDS 白名单里，**直连公网地址收不到 MySQL 握手包**，所以本地一律走 SSH 隧道：

```powershell
# 终端 A：起隧道（本地 13306 -> ECS -> RDS）
.\deploy\tools\tunnel-rds.ps1 -RdsHost rm-bp11x8oy4ozq8mjf9jo.mysql.rds.aliyuncs.com

# 终端 B：填凭据（只需一次；.env.local 不进仓库）
copy backend\.env.local.example backend\.env.local
#   然后编辑 backend/.env.local，把 SPRING_DATASOURCE_PASSWORD 填成 yu_app 的密码

.\start-dev.ps1
curl http://127.0.0.1:5000/api/health/db    # {"db":"ok","latencyMs":...}
```

要点：

- **连不上库不会阻止应用启动**（Hikari `initialization-fail-timeout=-1`），状态由
  `/api/health/db` 报告——前端开发不必每次都先开隧道。
- **Flyway 本地默认关**（`SPRING_FLYWAY_ENABLED`）。它会连库并在启动期执行迁移，连不上就起不来；
  要验证迁移通道时显式打开：`$env:SPRING_FLYWAY_ENABLED='true'`，prod profile 里它是常开的。
- **CA 证书**在 `backend/.certs/`（从 ECS `scp` 而来，不进仓库）。连接串用 `sslMode=VERIFY_CA`：
  隧道下连的是 `127.0.0.1`，`VERIFY_IDENTITY` 会因主机名不符而失败。
- **生产**：把 `SPRING_DATASOURCE_URL` 换成 RDS 内网地址即可，代码不动；
  `application-prod.yml` 会要求显式给全连接参数并启用 Flyway。

表结构一律由 `backend/src/main/resources/db/migration/V*.sql` 演进，不手工改库。
接入细节与云端配置见 [deploy/README.md](deploy/README.md) §3–§5。
