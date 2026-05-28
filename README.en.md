[简体中文](./README.md)

## Project Description

This project provides a set of Kustomize base resources for deploying Dify services on Kubernetes. It comes pre-configured with `dev` and `prod` environments. However, it may not perfectly meet your specific needs; you can write a `kustomization.yaml` to customize your environment and override the base resources.

## Upstream Tracking

Currently tracking upstream Dify version: `v1.14.0`

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

## Upgrade Guide (v1.13.2 → v1.14.0)

### Image Updates

1. **dify-api**: 1.13.2 → 1.14.0
2. **dify-web**: 1.13.2 → 1.14.0
3. **dify-plugin-daemon**: 0.5.4-local → 0.6.0-local
4. **dify-sandbox**: 0.2.12 → 0.2.15

### Configuration Changes

1. **New Environment Variables**:
   - `ENABLE_COLLABORATION_MODE`: Collaboration mode feature toggle
   - `REDIS_KEY_PREFIX`: Redis key prefix configuration
   - `REDIS_RETRY_RETRIES`: Redis retry count configuration
   - `REDIS_RETRY_BACKOFF_BASE`: Redis retry backoff base
   - `REDIS_RETRY_BACKOFF_CAP`: Redis retry backoff cap
   - `REDIS_SOCKET_TIMEOUT`: Redis socket timeout
   - `REDIS_SOCKET_CONNECT_TIMEOUT`: Redis socket connect timeout
   - `REDIS_HEALTH_CHECK_INTERVAL`: Redis health check interval
   - `NEXT_PUBLIC_SOCKET_URL`: WebSocket URL configuration
   - `S3_ADDRESS_STYLE`: S3 address style configuration
   - `DB_SSL_MODE`: Database SSL mode configuration

2. **Modified Default Values**:
   - `CELERY_WORKER_AMOUNT`: empty → 4
   - `POSTGRES_MAX_CONNECTIONS`: 100 → 200

### Nginx Configuration Changes

1. **New `/socket.io/` location**: WebSocket support
2. **Fixed `/e/` location header**: `Dify-Hook-Url` header format correction

### Upgrade Notes

1. **Image Update**: All related images need to be updated to version 1.14.0
2. **Configuration Update**: New environment variables have been added to `base/shared/dify-shared-config` and work with default values
3. **Nginx Update**: `base/nginx/nginx.conf` has added WebSocket support and header correction
