[English](./README.en.md)

## 项目描述

本项目提供了一组 kustomize 的基础资源，用于在 K8s 启动 Dify 服务。项目预配置了 `dev` 和 `prod` 环境。但它不一定满足你的需求，你可以根据需要来编写一个 `kustomization.yaml` 来定制你的环境覆盖 base 资源。

## 追踪版本

当前追踪上游 Dify 版本：`v1.14.2`

## 前置要求

- kubectl
- kustomize

## 目录结构

```sh
.
├── base # 基础资源目录，包含所有服务的默认配置
│   ├── api
│   ├── kustomization.yaml
│   ├── nginx
│   ├── plugin
│   ├── postgres
│   ├── redis
│   ├── sandbox
│   ├── shared
│   ├── ssrf
│   ├── weaviate
│   ├── web
│   ├── worker
│   └── worker-beta
└── overlays # 环境差异化覆盖
    ├── development # 开发环境
    └── production # 生产环境
```

## 快速开始

#### 1. 预览最终生成的 YAML

在部署前，先查看渲染后的结果

```sh
kubectl kustomize overlays/development
```

#### 2. 执行部署

```sh
# 部署到开发环境
kubectl apply -k overlays/development

# 部署到生产环境
kubectl apply -k overlays/production
```

## 环境对比

| 特性               | Base (默认) | Development     | Production      |
| :----------------- | :---------- | :-------------- | :-------------- |
| **配置域名**       | N/A         | dev.example.com | app.example.com |
| **Shared Storage** | LocalPV     | nfs             | nfs             |
| **StorageClass**   | N/A         | 自定义          | 自定义          |
| **命名空间**       | default     | dify-test       | dify-prod       |
| **配置文件**       | 默认        | 自定义          | 自定义          |
| **镜像**           | 默认        | 自定义          | 自定义          |
| **数据库**         | 默认        | 默认            | 自定义          |

## 感谢

- [dify-kubernetes](https://github.com/Winson-030/dify-kubernetes)

## 升级说明 (v1.14.0 → v1.14.2)

### 镜像更新

1. **dify-api**: 1.14.0 → 1.14.2
2. **dify-web**: 1.14.0 → 1.14.2
3. **dify-plugin-daemon**: 0.6.0-local → 0.6.1-local
4. **dify-sandbox**: 0.2.15 (不变)

### 配置变更

1. **新增环境变量**：
   - `API_WEBSOCKET_WORKER_CLASS`: WebSocket worker 类配置
   - `API_WEBSOCKET_WORKER_CONNECTIONS`: WebSocket worker 连接数
   - `API_WEBSOCKET_GUNICORN_TIMEOUT`: WebSocket gunicorn 超时
   - `CELERY_BACKEND`: Celery backend 类型
   - `OPS_TRACE_RETRYABLE_DISPATCH_MAX_RETRIES`: 重试分发最大重试次数
   - `OPS_TRACE_RETRYABLE_DISPATCH_DELAY_SECONDS`: 重试分发延迟
   - `GRAPH_ENGINE_*`: 图引擎 worker 池配置
   - `WORKFLOW_NODE_EXECUTION_STORAGE`: 工作流节点执行存储
   - `CORE_WORKFLOW_EXECUTION_REPOSITORY` / `CORE_WORKFLOW_NODE_EXECUTION_REPOSITORY`: 工作流执行仓库
   - `API_WORKFLOW_RUN_REPOSITORY` / `API_WORKFLOW_NODE_EXECUTION_REPOSITORY`: API 工作流仓库
   - `ENABLE_HUMAN_INPUT_TIMEOUT_TASK` / `HUMAN_INPUT_TIMEOUT_TASK_INTERVAL`: 人工输入超时任务
   - `RESPECT_XFORWARD_HEADERS_ENABLED`: X-Forwarded headers 支持
   - `CODE_EXECUTION_SSL_VERIFY` / `CODE_EXECUTION_POOL_*`: 代码执行连接池配置
   - `SSRF_POOL_*`: SSRF 代理连接池配置
   - `PLUGIN_MODEL_SCHEMA_CACHE_TTL`: 插件模型 schema 缓存 TTL
   - `PLUGIN_SENTRY_ENABLED` / `PLUGIN_SENTRY_DSN`: 插件 Sentry 配置
   - `WORKFLOW_LOG_CLEANUP_*`: 工作流日志清理配置
   - `ENABLE_WORKFLOW_SCHEDULE_POLLER_TASK` / `WORKFLOW_SCHEDULE_POLLER_*`: 工作流调度轮询
   - `TENANT_ISOLATED_TASK_CONCURRENCY`: 租户隔离任务并发
   - `ENABLE_CLEAN_*` / `ENABLE_DATASETS_QUEUE_MONITOR`: 各种清理任务开关
   - `QUEUE_MONITOR_*`: 队列监控配置
   - `SWAGGER_UI_PATH`: Swagger UI 路径
   - `DSL_EXPORT_ENCRYPT_DATASET_ID`: DSL 导出加密数据集 ID
   - `DATASET_MAX_SEGMENTS_PER_REQUEST`: 每次请求最大分段数
   - `EMAIL_REGISTER_TOKEN_EXPIRY_MINUTES` / `CHANGE_EMAIL_TOKEN_EXPIRY_MINUTES` / `OWNER_TRANSFER_TOKEN_EXPIRY_MINUTES`: Token 过期配置
   - `ANNOTATION_IMPORT_*`: 标注导入限制配置
   - `CREATORS_PLATFORM_*`: 创作者平台配置
   - `ALIYUN_SLS_*`: 阿里云 SLS 日志配置
   - `LOGSTORE_*`: 日志存储双写配置
   - `PLUGIN_REMOTE_INSTALL_*`: 插件远程安装配置
   - `INNER_API_KEY_FOR_PLUGIN`: 插件内部 API Key
   - `EXPERIMENTAL_ENABLE_VINEXT`: VINext 实验功能
   - `ALLOW_INLINE_STYLES` / `ALLOW_UNSAFE_DATA_SCHEME`: 安全相关
   - `ALLOW_EMBED`: 嵌入允许
   - `AMPLITUDE_API_KEY`: Amplitude 分析
   - `NEXT_PUBLIC_BATCH_CONCURRENCY`: 批量并发
   - `SANDBOX_EXPIRED_RECORDS_CLEAN_*`: Sandbox 过期记录清理
   - `EVENT_BUS_REDIS_*`: 事件总线 Redis 配置

2. **修改默认值**：
   - `UPLOAD_FILE_SIZE_LIMIT`: 100 → 15
   - `CODE_MAX_NUMBER`: 9223372036854776000 → 9223372036854775807
   - `CODE_MIN_NUMBER`: -9223372036854776000 → -9223372036854775808
   - `CODE_MAX_STRING_LENGTH`: 80000 → 400000
   - `TEMPLATE_TRANSFORM_MAX_LENGTH`: 80000 → 400000
   - `MAX_ITERATIONS_NUM`: 5 → 99

### Nginx 配置

上游 Nginx 配置重构为模板化（使用 `include proxy.conf`），功能等价。本地 nginx.conf 保持不变，已包含所有必要的 location 块。

### 升级注意事项

1. **镜像更新**：dify-api、dify-web、dify-plugin-daemon 需要更新
2. **配置更新**：新增环境变量已添加到 `base/shared/dify-shared-config`，使用默认值即可正常工作
3. **Nginx**：无需变更，现有配置兼容
