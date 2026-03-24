---
name: infrastructure-auditor
description: Checks infrastructure and configuration — environment variables, deployment settings, health checks, containerization. Runs on any language.
tools: Read, Grep, Glob, Bash
model: inherit
---

# Infrastructure Audit

> **Conventions:** Follow all shared conventions in `agents/CONVENTIONS.md` — audience, language detection, status block schema, severity levels, output format, execution logging, and output verification. Do not restate them here.

Output to `.claude/audits/AUDIT_INFRASTRUCTURE.md`.

Detects infrastructure and configuration files regardless of language or platform. If none exist, writes `status: SKIPPED` and stops.

| File Pattern | What It Covers |
|---|---|
| `Dockerfile`, `docker-compose*.yml` | Containerization |
| `*.tf`, `*.tfvars` | Terraform (cloud infrastructure) |
| `cloudformation*.yml`, `template.yaml` | AWS CloudFormation |
| `*kubernetes*`, `k8s/`, `*.yaml` with `kind:` | Kubernetes |
| `vercel.json`, `netlify.toml` | Frontend deployment |
| `.env.example`, `.env.sample` | Environment variable contracts |
| `.github/workflows/*.yml`, `.gitlab-ci.yml` | CI/CD pipelines |
| `nginx.conf`, `apache.conf` | Web server config |
| `fly.toml`, `render.yaml`, `railway.toml` | PaaS deployment |

If none of the above exist: write `status: SKIPPED` with a one-line explanation.

## Status Block (Required)

Every output MUST start with the canonical 10-field status block from CONVENTIONS.md:
```yaml
---
agent: infrastructure-auditor
status: COMPLETE | PARTIAL | SKIPPED | ERROR
timestamp: [ISO timestamp]
duration: [seconds]
findings: [count]
critical_count: [count]
important_count: [count]
minor_count: [count]
skipped_checks: []
errors: []
---
```

## Scope

infrastructure-auditor is the ONLY agent that checks:
- Environment variable management (.env.example, no hardcoded env-specific values)
- Production-readiness (debug mode off, error detail suppressed)
- Health checks (liveness/readiness endpoints)
- Container configuration (non-root user, minimal image, no secrets baked in)
- CI/CD pipeline (exists, runs tests, blocks on failure)
- SSL/TLS configuration

**Not in scope:** Security vulnerabilities in application code (security-auditor).
**Not in scope:** Package vulnerabilities (dependency-auditor).
**Not in scope:** CORS configuration → security-auditor.

## Checks

**1. Environment Variable Management**
```bash
ls .env .env.local .env.production .env.example .env.sample 2>/dev/null
# Hardcoded environment-specific values in config files
grep -rEn "localhost|127.0.0.1|staging|production" --include="*.yaml" --include="*.yml" --include="*.json" --include="*.toml" . --exclude-dir=node_modules --exclude-dir=venv --exclude-dir=.venv --exclude-dir=__pycache__ --exclude-dir=dist --exclude-dir=build --exclude-dir=vendor --exclude-dir=.git | grep -v "test\|spec" | head -20
```

**2. Debug Mode and Error Exposure**
```bash
grep -rEn "DEBUG[[:space:]]*=[[:space:]]*true|debug.*=.*true|NODE_ENV.*development" --include="*.yaml" --include="*.yml" --include="*.toml" --include="*.env*" . --exclude-dir=node_modules --exclude-dir=venv --exclude-dir=.venv --exclude-dir=__pycache__ --exclude-dir=dist --exclude-dir=build --exclude-dir=vendor --exclude-dir=.git | grep -v "test\|spec" | head -10
grep -rEn "SHOW_ERRORS|display_errors[[:space:]]*=[[:space:]]*On|stack_trace" --include="*.yaml" --include="*.yml" --include="*.toml" . --exclude-dir=node_modules --exclude-dir=venv --exclude-dir=.venv --exclude-dir=__pycache__ --exclude-dir=dist --exclude-dir=build --exclude-dir=vendor --exclude-dir=.git | head -10
```

**3. Health Checks**
```bash
grep -rEn "healthcheck|health_check|/health|/ping|/ready|/live" --include="*.yaml" --include="*.yml" --include="Dockerfile" . --exclude-dir=node_modules --exclude-dir=venv --exclude-dir=.venv --exclude-dir=__pycache__ --exclude-dir=dist --exclude-dir=build --exclude-dir=vendor --exclude-dir=.git | head -20
```

**4. CORS Configuration**

> CORS configuration is checked by the **security-auditor**. Do not duplicate this check here.

**5. Container Configuration**
```bash
cat Dockerfile 2>/dev/null | head -60
grep -En "USER|root|FROM|COPY|ADD|ENV|SECRET|PASSWORD" Dockerfile 2>/dev/null | head -20
cat docker-compose*.yml 2>/dev/null | grep -En "secret|password|token|privileged|root" | head -10
```

**6. CI/CD Pipeline**
```bash
ls .github/workflows/*.yml .gitlab-ci.yml .circleci/config.yml Jenkinsfile 2>/dev/null
# Does the pipeline run tests?
grep -rEn "test|pytest|jest|rspec|go test" .github/workflows/ .gitlab-ci.yml 2>/dev/null | head -10
# Does it block on failure?
grep -rEn "continue-on-error|allow_failure" .github/workflows/ .gitlab-ci.yml 2>/dev/null | head -10
```

**7. SSL/TLS**
```bash
grep -rEn "ssl|tls|https|http://" --include="*.yaml" --include="*.yml" --include="*.toml" --include="*.conf" . --exclude-dir=node_modules --exclude-dir=venv --exclude-dir=.venv --exclude-dir=__pycache__ --exclude-dir=dist --exclude-dir=build --exclude-dir=vendor --exclude-dir=.git | grep -v "test\|comment\|#" | head -20
```

## Layered Output Format

```markdown
# Infrastructure Audit

[Status block]

## Executive Summary

Plain English paragraph. Example: "Your deployment configuration has two
significant gaps: debug mode appears to still be enabled in production settings
(which can expose internal error details to the public), and there is no health
check configured (so if the app crashes, your hosting platform has no way to
automatically restart it). The CI/CD pipeline exists but does not run tests,
meaning broken code can be deployed automatically."

## Findings

### INFRA-001: [Finding Title]
**Plain English:** [What this means in everyday terms. No jargon.]
**Business Impact:** [What goes wrong if not fixed.]
**Severity:** Critical | Important | Minor
**Technical Detail:** [File name, line number, specific pattern found.]
**Fix:** [Exact change to make.]

<!-- Repeat this template for each finding. Only report findings verified with evidence from the scanned codebase. -->

## Recommendations

### Must Fix Before Launch
- [ ] [Critical and Important findings]

### Improve When Time Allows
- [ ] [Minor findings]
```
