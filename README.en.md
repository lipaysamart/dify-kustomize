[简体中文](./README.md)

## Project Description

This project provides a set of Kustomize base resources for deploying Dify services on Kubernetes. It comes pre-configured with `dev` and `prod` environments. However, it may not perfectly meet your specific needs; you can write a `kustomization.yaml` to customize your environment and override the base resources.

## Upstream Tracking

Currently tracking upstream Dify version: `v1.12.1`

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

## Upgrade Guide (v1.11.1 → v1.12.1)

### Security Changes

1. **SSL/TLS Protocol Hardening**: Nginx no longer supports TLSv1.1 by default, only TLSv1.2 and TLSv1.3
2. **Swagger UI Disabled by Default**: For security reasons, Swagger UI is now disabled by default

### Upgrade Notes

1. **Image Update**: All related images need to be updated to version 1.12.1
