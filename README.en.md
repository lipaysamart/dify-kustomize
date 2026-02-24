[简体中文](./README.md)

## Project Description

This project provides a set of Kustomize base resources for deploying Dify services on Kubernetes. It comes pre-configured with `dev` and `prod` environments. However, it may not perfectly meet your specific needs; you can write a `kustomization.yaml` to customize your environment and override the base resources.

## Upstream Tracking

Currently tracking upstream Dify version: `v1.11.1`

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
