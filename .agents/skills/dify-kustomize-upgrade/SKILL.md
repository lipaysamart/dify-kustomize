---
name: dify-kustomize-upgrade
description: 升级 Dify Kustomize 部署版本。当用户说 "dify version upgrade"、"升级 dify 版本"、"dify upgrade x.x.x to x.x.x" 时触发。
---

# Dify Kustomize Upgrade

Upgrade Dify Kustomize resources to track new upstream Dify versions.

## Workflow

### 1. Compare Docker Compose Files

If user did NOT provide both old_version and new_version, ask user for version info.

Use the compare script:

```bash
# Usage: scripts/compare.sh <old_version> <new_version> [output_file]
./scripts/compare.sh old_version new_version
```

Or manually:

```bash
curl -s "https://raw.githubusercontent.com/langgenius/dify/refs/tags/<OLD_VERSION>/docker/docker-compose.yaml" -o /tmp/old.yaml
curl -s "https://raw.githubusercontent.com/langgenius/dify/refs/tags/<NEW_VERSION>/docker/docker-compose.yaml" -o /tmp/new.yaml
diff -u /tmp/old.yaml /tmp/new.yaml
```

Document changes in a diff file for reference.

### 2. Identify Changes

Extract from diff:

- **Image version changes**: api, worker, web, plugin-daemon, sandbox
- **Modified environment variables**: LANG, LC_ALL, SSL protocols, etc.
- **New environment variables**: Only add if used in project
- **Security changes**: TLS versions, Swagger UI defaults
- **New services**: IRIS, etc.
- **Nginx changes**: New location blocks, proxy settings, headers

### 3. Update Base Resources

Update image tags in:

- `base/api/statefulset.yaml`
- `base/worker/statefulset.yaml`
- `base/worker-beta/statefulset.yaml`
- `base/web/deployment.yaml`
- `base/plugin/statefulset.yaml`

### 4. Compare Nginx Configuration

Compare upstream nginx.conf with local:

```bash
curl -s "https://raw.githubusercontent.com/langgenius/dify/refs/tags/<NEW_VERSION>/docker/nginx/conf.d/default.conf.template" -o /tmp/upstream-nginx.conf
diff -u base/nginx/nginx.conf /tmp/upstream-nginx.conf
```

**Important**: Local nginx.conf may have custom modifications. Carefully merge:

- New location blocks from upstream
- Updated proxy settings
- New header configurations
- **Preserve** local customizations (e.g., custom proxy paths, timeout settings)

Document any nginx changes that were merged or intentionally skipped.

### 5. Update Shared Config

Update `base/shared/dify-shared-config`:

- Modify changed variables (LANG, LC_ALL, etc.)
- Add new required variables only if used

### 6. Update Overlays

Update `newTag` in:

- `overlays/production/kustomization.yaml`
- `overlays/development/kustomization.yaml`

### 7. Update Documentation

Update README files:

- Version number in "追踪版本" section
- Add "升级注意事项" section if applicable
- Document nginx config changes if merged

## Version-Specific Changes

See [references/full-changes.md](references/full-changes.md) for detailed changes between specific versions.
