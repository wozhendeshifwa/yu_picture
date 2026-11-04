# 本地开发访问 RDS 走 SSH 隧道，而不是公网直连

状态：accepted

本机连 RDS 的直连路径是坏的：TCP 能建连，但服务端在 MySQL 握手前就关掉连接，因为 RDS 白名单只放行 ECS 的出口 IP。
所以后端的数据源默认指向 `127.0.0.1:13306` 的 SSH 隧道（`deploy/tools/tunnel-rds.ps1`），出口落在 ECS，天然在白名单内。
连接串固定 `sslMode=VERIFY_CA`：隧道下 JDBC 连的是 `127.0.0.1`，用 `VERIFY_IDENTITY` 会因证书主机名与
RDS 域名不符而失败——这不是安全降级，隧道两端都在可信网络里。

## Considered Options

- **把本机公网 IP 加进 RDS 白名单**：少一层进程，但家庭宽带 IP 会变，每变一次就要去控制台，而且把库暴露在公网。
- **后端只跑在 ECS 上**：本地就没有调试环境，前端联调要连远端。
- **SSH 隧道（选中）**：不动云上任何配置，本机切换网络也不受影响。

## Consequences

- 本地开发的前提是先起隧道；没起时应用照常启动，由 `GET /api/health/db` 报 `down`——
  降级启动是有意的（`initialization-fail-timeout: -1`），不是漏配。
- 每次查询多一跳隧道，稳态 73–98ms；这不代表 RDS 的真实延迟，别拿它做性能判断。
- 生产环境把 `SPRING_DATASOURCE_URL` 换成 RDS 内网地址即可，代码不需要改。
- CA 证书从 ECS `scp` 到 `backend/.certs/`，不进仓库；`deploy/README.md` §5 有完整连接串。
