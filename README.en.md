[简体中文](./README.md)

## Project Description

This project provides a set of Kustomize base resources for deploying Dify services on Kubernetes. It comes pre-configured with `dev` and `prod` environments. However, it may not perfectly meet your specific needs; you can write a `kustomization.yaml` to customize your environment and override the base resources.

## Upstream Tracking

Currently tracking upstream Dify version: `v1.13.2`

## Prerequisites

- kubectl
- kustomize

## Directory Structure

```sh
.
├── base # Base resources directory, containing default configurations for all services
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
└── overlays # Environment-specific overrides
    ├── development # Development environment
    └── production # Production environment
```

## Quick Start

#### 1. Preview the generated YAML

View the rendered output before deployment:

```sh
kubectl kustomize overlays/development
```

#### 2. Execute Deployment

```sh
# Deploy to development environment
kubectl apply -k overlays/development

# Deploy to production environment
kubectl apply -k overlays/production
```

## Environment Comparison

| Feature            | Base (Default) | Development     | Production      |
| :----------------- | :------------- | :-------------- | :-------------- |
| **Domain Config**  | N/A            | dev.example.com | app.example.com |
| **Shared Storage** | LocalPV        | nfs             | nfs             |
| **StorageClass**   | N/A            | Custom          | Custom          |
| **Namespace**      | default        | dify-test       | dify-prod       |
| **Config Files**   | Default        | Custom          | Custom          |
| **Images**         | Default        | Custom          | Custom          |
| **Database**       | Default        | Default         | Custom          |

## Credits

- [dify-kubernetes](https://github.com/Winson-030/dify-kubernetes)

## Upgrade Guide (v1.12.1 → v1.13.2)

### Image Updates

1. **dify-api**: 1.12.1 → 1.13.2
2. **dify-web**: 1.12.1 → 1.13.2
3. **dify-plugin-daemon**: 0.5.3-local → 0.5.4-local

### Configuration Changes

1. **New Environment Variables**:
   - `UV_CACHE_DIR`: uv package manager cache directory
   - `REDIS_MAX_CONNECTIONS`: Redis max connections configuration
   - `CELERY_TASK_ANNOTATIONS`: Celery task annotations configuration

2. **Removed Environment Variables**:
   - `PM2_INSTANCES`: Removed from web service

### Upgrade Notes

1. **Image Update**: All related images need to be updated to version 1.13.2
2. **Configuration Update**: New environment variables have been added to `base/shared/dify-shared-config` and work with default values
