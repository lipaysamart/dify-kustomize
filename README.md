[English](./README.en.md)

## 项目描述

本项目提供了一组 kustomize 的基础资源，用于在 K8s 启动 Dify 服务。项目预配置了 `dev` 和 `prod` 环境。但它不一定满足你的需求，你可以根据需要来编写一个 `kustomization.yaml` 来定制你的环境覆盖 base 资源。

## 追踪版本

当前追踪上游 Dify 版本：`v1.12.1`

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

## 升级说明 (v1.11.1 → v1.12.1)

### 安全性变更

1. **SSL/TLS 协议强化**：Nginx 默认不再支持 TLSv1.1 协议，仅支持 TLSv1.2 和 TLSv1.3
2. **Swagger UI 默认禁用**：出于安全考虑，Swagger UI 默认已禁用

### 升级注意事项

1. **镜像更新**：所有相关镜像需要更新到 1.12.1 版本
