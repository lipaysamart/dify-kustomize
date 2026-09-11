# 变更日志

## v1.15.0 → v1.16.1

### 镜像更新

1. **dify-api**: 1.15.0 → 1.16.1
2. **dify-web**: 1.15.0 → 1.16.1
3. **dify-plugin-daemon**: 0.6.3-local (不变)
4. **dify-sandbox**: 0.2.15 (不变)
5. **dify-agent-backend**: 新增（v1.16.1 新服务）
6. **dify-agent-local-sandbox**: 新增（v1.16.1 新服务）

### 新增服务（Dify Agent 功能栈）

v1.16.1 上游新增了 Dify Agent（Agent 工作区/Shell 执行）功能栈，本次升级完整引入：

1. **agent-backend**（`base/agent-backend/`）：Agent 后端服务，监听 5050 端口；依赖 Redis（db 2）、plugin_daemon、local_sandbox
2. **local-sandbox**（`base/local-sandbox/`）：Agent 本地沙箱，监听 5004 端口，出站流量强制走 agent SSRF 代理（`HTTP_PROXY/HTTPS_PROXY`）
3. **agent-ssrf-proxy**（`base/agent-ssrf-proxy/`）：Agent 沙箱专用 Squid 正向代理（3128），白名单模式仅允许：
   - `dify-agent-backend` 的 `/agent-stub/*` 端点
   - `dify-api` 的 `/files/*` 端点
   - 拒绝其它所有私有网络目标（`to_private_networks`）
4. 复用 `base/ssrf` 的 InitContainer 模板渲染模式：`init.sh` 渲染 `squid-agent.conf.template` 与 `squid-common.conf.template`（上游将公共配置拆分到此文件）

### 配置变更

1. **新增环境变量**（`base/shared/dify-shared-config`）：
   - `AGENT_BACKEND_BASE_URL` / `AGENT_BACKEND_STREAM_READ_TIMEOUT_SECONDS` / `AGENT_BACKEND_STREAM_MAX_RECONNECTS` / `AGENT_BACKEND_RUN_TIMEOUT_SECONDS`：api/worker 访问 Agent 后端
   - `DIFY_AGENT_REDIS_PREFIX` / `DIFY_AGENT_SHUTDOWN_GRACE_SECONDS` / `DIFY_AGENT_RUN_RETENTION_SECONDS`：Agent 后端运行参数
   - `DIFY_AGENT_PLUGIN_DAEMON_URL` / `DIFY_AGENT_INNER_API_URL` / `DIFY_AGENT_SHELLCTL_ENTRYPOINT` / `DIFY_AGENT_SHELLCTL_AUTH_TOKEN` / `DIFY_AGENT_STUB_API_BASE_URL` / `DIFY_AGENT_SHELL_REDACT_PATTERNS`：Agent 服务间调用
2. **新增 Secret 字段**（`base/shared/kustomization.yaml` 的 `dify-shared-secret`）：
   - `DIFY_AGENT_API_TOKEN`：api/worker → Agent 后端 /runs 接口的 Bearer Token（api/worker 通过显式 `AGENT_BACKEND_API_TOKEN` 映射读取）
   - `DIFY_AGENT_SERVER_SECRET_KEY`：Agent Stub Bearer Token 的 JWE 加密密钥（安全敏感，生产环境需替换开发默认值）
   - `DIFY_AGENT_REDIS_URL`：Agent 后端 Redis 连接串（base: `dify-redis:6379/2`；overlay 覆盖为外部 Redis `redis.dbs.svc:6379/15`，与项目现有 Redis 约定一致）
3. **Web**：新增 `WORKFLOW_GENERATION_TIMEOUT_MS=180000`、`NEXT_PUBLIC_ENABLE_AGENT_V2=true`（Agent UI 开关）
4. **Nginx**：无需变更（upstream location 集合与 proxy 配置与 v1.15.0 完全一致，仅重构为 envsubst 模板结构）
5. **SSRF/Squid**：无需变更（upstream 仅将公共配置拆分到 `squid-common.conf.template`，有效 ACL 不变；项目本地模板已内联全部规则）

### 升级注意事项

1. **镜像同步**：本次修复了 overlay images 条目 `name` 携带旧版 tag（如 `langgenius/dify-api:1.11.1`）导致 kustomize 匹配失败、api/web/plugin-daemon/sandbox 一直从 Docker Hub 直拉的问题；现在所有镜像统一改写到阿里云镜像仓库，以下镜像需确认已存在于镜像仓库：
   - `dify-api:1.16.1`
   - `dify-web:1.16.1`
   - `dify-plugin-daemon:0.6.3-local`
   - `dify-sandbox:0.2.15`
   - `dify-agent-backend:1.16.1`（新增）
   - `dify-agent-local-sandbox:1.16.1`（新增）
2. **安全默认值**：`DIFY_AGENT_API_TOKEN` / `DIFY_AGENT_SERVER_SECRET_KEY` 的 base 值沿用上游开发默认值，两个 overlay 的 secret patch 已替换为随机生成值；如需自定请修改 `overlays/*/patches/set_shared-secret.yaml`
3. **网络隔离差异**：Docker Compose 通过独立网络将 local_sandbox 与 api 隔离，K8s 中未实施 NetworkPolicy，Agent 沙箱理论上可直连集群内服务（仅靠代理白名单限制出站），如需严格隔离请补充 NetworkPolicy
4. **Agent 文件访问**：Agent 沙箱通过代理访问 `dify-api` 的 `/files/*`，依赖 api 生成签名 URL 的主机名（`FILES_URL` / `INTERNAL_FILES_URL`）能被 local_sandbox 解析；如部署后文件上传/下载异常，请检查这两个变量

---

## v1.14.2 → v1.15.0

### 镜像更新

1. **dify-api**: 1.14.2 → 1.15.0
2. **dify-web**: 1.14.2 → 1.15.0
3. **dify-plugin-daemon**: 0.6.1-local → 0.6.3-local
4. **dify-sandbox**: 0.2.15 (不变)

### 配置变更

1. **新增环境变量**：
   - `SSRF_PROXY_ALLOW_PRIVATE_IPS`: SSRF 代理允许的私有 IP 白名单
   - `SSRF_PROXY_ALLOW_PRIVATE_DOMAINS`: SSRF 代理允许的私有域名白名单

2. **SSRF/Squid 重构**：
   - squid.conf 切换为模板文件，启动时通过 entrypoint 脚本动态生成
   - 反向代理到 sandbox 改为通过 `SSRF_SANDBOX_PROXY_PORT` 环境变量控制（等效于原 `SSRF_REVERSE_PROXY_PORT`）
   - 新增 `to_private_networks` ACL，增强出站流量安全控制
   - 新增 `allowed_domains`（marketplace.dify.ai）ACL 白名单
   - 新增性能优化配置：连接池、请求缓冲区、超时设置、内存缓存等
   - entrypoint 支持通过 `SSRF_PROXY_ALLOW_PRIVATE_IPS` / `SSRF_PROXY_ALLOW_PRIVATE_DOMAINS` 动态生成私有网络白名单

### Squid 白名单模式说明

正向代理（3128）采用白名单模式，仅允许以下出站流量：

- **私有网络**（`to_private_networks`）：默认拒绝所有私有 IP 段（10/8、172.16/12、192.168/16 等）的出站请求
- **域名白名单**（`allowed_domains`）：仅允许 `.marketplace.dify.ai`
- **源 IP**（`client_localnet`）：仅允许内网客户端访问
- **兜底**（`deny all`）：未匹配规则的请求一律拒绝
- **端口安全**：`Safe_ports` 和 `SSL_ports` 校验始终生效

反向代理（8194）不受上述 ACL 限制，通过 `http_port 8194 accel vhost` + `http_access allow src_all` 全放通，专用于 sandbox 代码执行请求的转发。

### Nginx 配置变更

1. **新增 `/openapi` location**：路由到 api 服务，支持 OpenAPI 端点

### 升级注意事项

1. **镜像更新**：所有相关镜像需要更新到 1.15.0 版本
2. **SSRF/Squid 配置变更**：squid.conf 已切换为模板文件格式，在部署时会通过 entrypoint 脚本自动处理
3. **配置更新**：新增的环境变量已添加到 `base/shared/dify-shared-config`，使用默认值即可正常工作
4. **Nginx 更新**：`base/nginx/nginx.conf` 已添加 `/openapi` location

---

## v1.14.0 → v1.14.2

### 镜像更新

1. **dify-api**: 1.14.0 → 1.14.2
2. **dify-web**: 1.14.0 → 1.14.2
3. **dify-plugin-daemon**: 0.6.0-local → 0.6.1-local
4. **dify-sandbox**: 0.2.15 (不变)

### 配置变更

1. **新增环境变量**（83 个）：
   - `API_WEBSOCKET_WORKER_CLASS` / `API_WEBSOCKET_WORKER_CONNECTIONS` / `API_WEBSOCKET_GUNICORN_TIMEOUT`: WebSocket 协作模式
   - `CELERY_BACKEND`: Celery backend 类型
   - `OPS_TRACE_RETRYABLE_DISPATCH_MAX_RETRIES` / `OPS_TRACE_RETRYABLE_DISPATCH_DELAY_SECONDS`: 运维追踪重试
   - `GRAPH_ENGINE_MIN_WORKERS` / `GRAPH_ENGINE_MAX_WORKERS` / `GRAPH_ENGINE_SCALE_UP_THRESHOLD` / `GRAPH_ENGINE_SCALE_DOWN_IDLE_TIME`: 图引擎 worker 池
   - `WORKFLOW_NODE_EXECUTION_STORAGE`: 工作流节点执行存储
   - `CORE_WORKFLOW_EXECUTION_REPOSITORY` / `CORE_WORKFLOW_NODE_EXECUTION_REPOSITORY`: 工作流执行仓库
   - `API_WORKFLOW_RUN_REPOSITORY` / `API_WORKFLOW_NODE_EXECUTION_REPOSITORY`: API 工作流仓库
   - `ENABLE_HUMAN_INPUT_TIMEOUT_TASK` / `HUMAN_INPUT_TIMEOUT_TASK_INTERVAL`: 人工输入超时
   - `RESPECT_XFORWARD_HEADERS_ENABLED`: X-Forwarded headers
   - `CODE_EXECUTION_SSL_VERIFY` / `CODE_EXECUTION_POOL_*`: 代码执行连接池
   - `SSRF_POOL_*`: SSRF 代理连接池
   - `PLUGIN_MODEL_SCHEMA_CACHE_TTL`: 插件模型 schema 缓存
   - `PLUGIN_SENTRY_ENABLED` / `PLUGIN_SENTRY_DSN`: 插件 Sentry
   - `WORKFLOW_LOG_CLEANUP_*`: 工作流日志清理
   - `ENABLE_WORKFLOW_SCHEDULE_POLLER_TASK` / `WORKFLOW_SCHEDULE_POLLER_*`: 工作流调度轮询
   - `TENANT_ISOLATED_TASK_CONCURRENCY`: 租户隔离任务并发
   - `ENABLE_CLEAN_*` / `ENABLE_DATASETS_QUEUE_MONITOR`: 清理任务开关
   - `QUEUE_MONITOR_*`: 队列监控
   - `SWAGGER_UI_PATH`: Swagger UI 路径
   - `DSL_EXPORT_ENCRYPT_DATASET_ID`: DSL 导出加密
   - `DATASET_MAX_SEGMENTS_PER_REQUEST`: 分段限制
   - `EMAIL_REGISTER_TOKEN_EXPIRY_MINUTES` / `CHANGE_EMAIL_TOKEN_EXPIRY_MINUTES` / `OWNER_TRANSFER_TOKEN_EXPIRY_MINUTES`: Token 过期
   - `ANNOTATION_IMPORT_*`: 标注导入限制
   - `CREATORS_PLATFORM_*`: 创作者平台
   - `ALIYUN_SLS_*`: 阿里云 SLS 日志
   - `LOGSTORE_*`: 日志存储双写
   - `PLUGIN_REMOTE_INSTALL_*` / `INNER_API_KEY_FOR_PLUGIN`: 插件远程安装
   - `EXPERIMENTAL_ENABLE_VINEXT` / `ALLOW_INLINE_STYLES` / `ALLOW_UNSAFE_DATA_SCHEME` / `ALLOW_EMBED`: 前端安全/实验功能
   - `AMPLITUDE_API_KEY` / `NEXT_PUBLIC_BATCH_CONCURRENCY`: 前端配置
   - `SANDBOX_EXPIRED_RECORDS_CLEAN_*`: Sandbox 过期记录清理
   - `EVENT_BUS_REDIS_*`: 事件总线 Redis

2. **修改默认值**：
   - `CODE_MAX_NUMBER`: 9223372036854776000 → 9223372036854775807
   - `CODE_MIN_NUMBER`: -9223372036854776000 → -9223372036854775808
   - `CODE_MAX_STRING_LENGTH`: 80000 → 400000
   - `TEMPLATE_TRANSFORM_MAX_LENGTH`: 80000 → 400000
   - `MAX_ITERATIONS_NUM`: 5 → 99

3. **修复破损行**：
   - `UPLOAD_FILE_EXTENSION_BLACKLIST` 与 `SINGLE_CHUNK_ATTACHMENT_LIMIT` 粘连
   - `WEAVIATE_GRPC_ENDPOINT` 和 `WEAVIATE_TOKENIZATION` 多余 `}` 字符

### Nginx 配置

上游重构为模板化（`include proxy.conf`），功能等价。本地 nginx.conf 保持不变。

### 升级注意事项

1. **镜像更新**：dify-api、dify-web、dify-plugin-daemon 需要更新
2. **配置更新**：新增环境变量已添加到 `base/shared/dify-shared-config`，使用默认值即可正常工作
3. **Nginx**：无需变更，现有配置兼容

---

## v1.13.2 → v1.14.0

### 镜像更新

1. **dify-api**: 1.13.2 → 1.14.0
2. **dify-web**: 1.13.2 → 1.14.0
3. **dify-plugin-daemon**: 0.5.4-local → 0.6.0-local
4. **dify-sandbox**: 0.2.12 → 0.2.15

### 配置变更

1. **新增环境变量**：
   - `ENABLE_COLLABORATION_MODE`: 协作模式功能开关
   - `REDIS_KEY_PREFIX`: Redis key 前缀配置
   - `REDIS_RETRY_RETRIES`: Redis 重试次数配置
   - `REDIS_RETRY_BACKOFF_BASE`: Redis 重试退避基数
   - `REDIS_RETRY_BACKOFF_CAP`: Redis 重试退避上限
   - `REDIS_SOCKET_TIMEOUT`: Redis socket 超时时间
   - `REDIS_SOCKET_CONNECT_TIMEOUT`: Redis socket 连接超时时间
   - `REDIS_HEALTH_CHECK_INTERVAL`: Redis 健康检查间隔
   - `NEXT_PUBLIC_SOCKET_URL`: WebSocket URL 配置
   - `S3_ADDRESS_STYLE`: S3 地址样式配置
   - `DB_SSL_MODE`: 数据库 SSL 模式配置

2. **修改默认值**：
   - `CELERY_WORKER_AMOUNT`: 空 → 4
   - `POSTGRES_MAX_CONNECTIONS`: 100 → 200

### Nginx 配置变更

1. **新增 `/socket.io/` location**：支持 WebSocket 连接
2. **修复 `/e/` location header**：`Dify-Hook-Url` header 格式修正

### 升级注意事项

1. **镜像更新**：所有相关镜像需要更新到 1.14.0 版本
2. **配置更新**：新增的环境变量已添加到 `base/shared/dify-shared-config`，使用默认值即可正常工作
3. **Nginx 更新**：`base/nginx/nginx.conf` 已添加 WebSocket 支持和 header 修正

---

## v1.12.1 → v1.13.2

### 镜像更新

1. **dify-api**: 1.12.1 → 1.13.2
2. **dify-web**: 1.12.1 → 1.13.2
3. **dify-plugin-daemon**: 0.5.3-local → 0.5.4-local

### 配置变更

1. **新增环境变量**：
   - `UV_CACHE_DIR`: uv 包管理工具缓存目录
   - `REDIS_MAX_CONNECTIONS`: Redis 最大连接数配置
   - `CELERY_TASK_ANNOTATIONS`: Celery 任务注解配置

2. **移除环境变量**：
   - `PM2_INSTANCES`: 已从 web 服务中移除

### 升级注意事项

1. **镜像更新**：所有相关镜像需要更新到 1.13.2 版本
2. **配置更新**：新增的环境变量已添加到 `base/shared/dify-shared-config`，使用默认值即可正常工作

---

## v1.11.1 → v1.12.1

### 镜像更新

1. **dify-api**: 1.11.1 → 1.12.1
2. **dify-web**: 1.11.1 → 1.12.1
3. **dify-plugin-daemon**: 0.5.1-local → 0.5.3-local

### 配置变更

1. **新增环境变量**：
   - `PLUGIN_DAEMON_TIMEOUT`: 插件守护进程超时时间
   - `LOG_OUTPUT_FORMAT`: 日志输出格式
   - `SWAGGER_UI_ENABLED`: Swagger UI 开关（默认禁用）

2. **修改默认值**：
   - `LANG`: en_US.UTF-8 → C.UTF-8
   - `LC_ALL`: en_US.UTF-8 → C.UTF-8

### Nginx 配置变更

1. **SSL/TLS 协议强化**：移除 TLSv1.1 支持，仅保留 TLSv1.2 和 TLSv1.3

### 升级注意事项

1. **镜像更新**：所有相关镜像需要更新到 1.12.1 版本
2. **安全更新**：Nginx SSL 协议已收紧，Swagger UI 默认禁用
