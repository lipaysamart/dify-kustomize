# 变更日志

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
