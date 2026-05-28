[English](./README.en.md)

## 项目描述

本项目提供了一组 kustomize 的基础资源，用于在 K8s 启动 Dify 服务。项目预配置了 `dev` 和 `prod` 环境。但它不一定满足你的需求，你可以根据需要来编写一个 `kustomization.yaml` 来定制你的环境覆盖 base 资源。

## 追踪版本

当前追踪上游 Dify 版本：`v1.14.0`

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

## 升级说明 (v1.13.2 → v1.14.0)

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
