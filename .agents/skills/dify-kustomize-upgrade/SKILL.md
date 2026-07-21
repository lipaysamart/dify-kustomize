---
name: dify-kustomize-upgrade
description: 升级 Dify Kustomize 部署版本。当用户说 "dify version upgrade"、"升级 dify 版本"、"dify upgrade x.x.x to x.x.x" 时触发。
---

# Dify Kustomize Upgrade

Upgrade Dify Kustomize resources to track new upstream Dify versions.

## Workflow

### 1. Compare & Analyze

If user did NOT provide both old_version and new_version, ask user for version info.

Use the compare script and download the upstream nginx template in one pass:

```bash
./scripts/compare.sh old_version new_version
curl -s "https://raw.githubusercontent.com/langgenius/dify/refs/tags/<NEW_VERSION>/docker/nginx/conf.d/default.conf.template" -o /tmp/upstream-nginx.conf
```

<!-- Fallback if compare.sh is unavailable:
curl -s "https://raw.githubusercontent.com/langgenius/dify/refs/tags/<OLD_VERSION>/docker/docker-compose.yaml" -o /tmp/old.yaml
curl -s "https://raw.githubusercontent.com/langgenius/dify/refs/tags/<NEW_VERSION>/docker/docker-compose.yaml" -o /tmp/new.yaml
diff -u /tmp/old.yaml /tmp/new.yaml
-->

Document changes in a diff file for reference, then extract:

- **Image version changes**: api, worker, web, plugin-daemon, sandbox
- **Modified environment variables** and **new environment variables** (only add if used in project)
- **Security changes**: TLS versions, Swagger UI defaults
- **New services**: e.g., api_websocket in v1.14.2
- **Nginx changes**: New location blocks, proxy settings, headers

### 2. Update Resources

**a. Base image tags** in:

- `base/api/statefulset.yaml`
- `base/worker/statefulset.yaml`
- `base/worker-beta/statefulset.yaml`
- `base/web/deployment.yaml`
- `base/plugin/statefulset.yaml`

**b. Nginx** — compare upstream template with local:

```bash
diff -u base/nginx/nginx.conf /tmp/upstream-nginx.conf
```

Carefully merge new location blocks, updated proxy settings, and new headers. **Preserve** local customizations (e.g., custom proxy paths, timeout settings). Document any changes merged or intentionally skipped.

**c. Shared config** — update `base/shared/dify-shared-config`:

- Modify changed variables
- Add new required variables only if used
- Pay special attention to `SANDBOX_*` and `CODE_EXECUTION_*` — these change frequently

**d. Overlays** — update `newTag` in:

- `overlays/production/kustomization.yaml`
- `overlays/development/kustomization.yaml`

### 3. Handle New Services (conditional)

If upstream added new services (e.g., `api_websocket` in v1.14.2):

- Create corresponding base resources under `base/<service>/`
- Add the new service to both overlays' `resources:` list
- Check if existing overlay patches need to be adapted

### 4. Update Docs

- Update version number in `README.md` "追踪版本" section; if the upgrade involves major changes (new services, security, breaking changes), add a brief note
- Update [CHANGELOGS.md](../../../CHANGELOGS.md) with image versions, env vars, nginx changes, and upgrade notes. Follow newest-to-oldest order.

### 5. Verify

```bash
# 验证 base 资源可以被正确渲染
kubectl kustomize overlays/development > /dev/null && echo "✅ development overlay valid"
kubectl kustomize overlays/production > /dev/null && echo "✅ production overlay valid"

# 验证镜像标签已全部更新
kubectl kustomize overlays/development | grep -E 'image:.*dify' | sort -u
```

## Version-Specific Changes

See [references/full-changes.md](references/full-changes.md) for detailed changes between specific versions.
