FROM node:lts-trixie-slim AS base
ARG USER_UID=1000
ARG USER_GID=1000

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates gosu curl git wget ripgrep python3 \
 && mkdir -p -m 755 /etc/apt/keyrings \
 && wget -nv -O/etc/apt/keyrings/githubcli-archive-keyring.gpg https://cli.github.com/packages/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends gh \
 && rm -rf /var/lib/apt/lists/* \
 && corepack enable

RUN usermod -u $USER_UID --non-unique node \
 && groupmod -g $USER_GID --non-unique node \
 && usermod -g $USER_GID -d /paperclip node

FROM base AS deps
WORKDIR /app

COPY package.json pnpm-workspace.yaml pnpm-lock.yaml .npmrc ./
COPY cli/package.json cli/
COPY server/package.json server/
COPY ui/package.json ui/
COPY packages/shared/package.json packages/shared/
COPY packages/db/package.json packages/db/
COPY packages/adapter-utils/package.json packages/adapter-utils/
COPY packages/adapters/claude-local/package.json packages/adapters/claude-local/
COPY packages/adapters/codex-local/package.json packages/adapters/codex-local/
COPY packages/adapters/cursor-local/package.json packages/adapters/cursor-local/
COPY packages/adapters/gemini-local/package.json packages/adapters/gemini-local/
COPY packages/adapters/openclaw-gateway/package.json packages/adapters/openclaw-gateway/
COPY packages/adapters/opencode-local/package.json packages/adapters/opencode-local/
COPY packages/adapters/pi-local/package.json packages/adapters/pi-local/
COPY packages/plugins/sdk/package.json packages/plugins/sdk/
COPY patches/ patches/

RUN pnpm install --frozen-lockfile

RUN python3 - <<'PY'
from pathlib import Path

p = Path("/app/node_modules/.pnpm/hermes-paperclip-adapter@0.3.0/node_modules/hermes-paperclip-adapter/dist/server/execute.js")
s = p.read_text()

old_template = """const DEFAULT_PROMPT_TEMPLATE = `You are "{{agentName}}", an AI agent employee in a Paperclip-managed company.

IMPORTANT: Use \\`terminal\\` tool with \\`curl\\` for ALL Paperclip API calls (web_extract and browser cannot access localhost).

Your Paperclip identity:
  Agent ID: {{agentId}}
  Company ID: {{companyId}}
  API Base: {{paperclipApiUrl}}

{{#taskId}}
## Assigned Task

Issue ID: {{taskId}}
Title: {{taskTitle}}

{{taskBody}}

## Workflow

1. Work on the task using your tools
2. When done, mark the issue as completed:
   \\`curl -s -X PATCH "{{paperclipApiUrl}}/issues/{{taskId}}" -H "Content-Type: application/json" -d '{"status":"done"}'\\`
3. Post a completion comment on the issue summarizing what you did:
   \\`curl -s -X POST "{{paperclipApiUrl}}/issues/{{taskId}}/comments" -H "Content-Type: application/json" -d '{"body":"DONE: <your summary here>"}'\\`
4. If this issue has a parent (check the issue body or comments for references like TRA-XX), post a brief notification on the parent issue so the parent owner knows:
   \\`curl -s -X POST "{{paperclipApiUrl}}/issues/PARENT_ISSUE_ID/comments" -H "Content-Type: application/json" -d '{"body":"{{agentName}} completed {{taskId}}. Summary: <brief>"}'\\`
{{/taskId}}

{{#commentId}}
## Comment on This Issue

Someone commented. Read it:
   \\`curl -s "{{paperclipApiUrl}}/issues/{{taskId}}/comments/{{commentId}}" | python3 -m json.tool\\`

Address the comment, POST a reply if needed, then continue working.
{{/commentId}}

{{#noTask}}
## Heartbeat Wake — Check for Work

1. List ALL open issues assigned to you (todo, backlog, in_progress):
   \\`curl -s "{{paperclipApiUrl}}/companies/{{companyId}}/issues?assigneeAgentId={{agentId}}" | python3 -c "import sys,json;issues=json.loads(sys.stdin.read());[print(f'{i[\\"identifier\\"]} {i[\\"status\\"]:>12} {i[\\"priority\\"]:>6} {i[\\"title\\"]}') for i in issues if i['status'] not in ('done','cancelled')]" \\`

2. If issues found, pick the highest priority one that is not done/cancelled and work on it:
   - Read the issue details: \\`curl -s "{{paperclipApiUrl}}/issues/ISSUE_ID"\\`
   - Do the work in the project directory: {{projectName}}
   - When done, mark complete and post a comment (see Workflow steps 2-4 above)

3. If no issues assigned to you, check for unassigned issues:
   \\`curl -s "{{paperclipApiUrl}}/companies/{{companyId}}/issues?status=backlog" | python3 -c "import sys,json;issues=json.loads(sys.stdin.read());[print(f'{i[\\"identifier\\"]} {i[\\"title\\"]}') for i in issues if not i.get('assigneeAgentId')]" \\`
   If you find a relevant issue, assign it to yourself:
   \\`curl -s -X PATCH "{{paperclipApiUrl}}/issues/ISSUE_ID" -H "Content-Type: application/json" -d '{"assigneeAgentId":"{{agentId}}","status":"todo"}'\\`

4. If truly nothing to do, report briefly what you checked.
{{/noTask}}`;"""

new_template = """const DEFAULT_PROMPT_TEMPLATE = `You are "{{agentName}}", an AI agent employee in a Paperclip-managed company.

IMPORTANT:
- Use the terminal tool for Paperclip API access because localhost is not available to browser/web tools.
- NEVER execute downloaded content from a pipe.
- NEVER use commands such as:
  - piped download-to-interpreter patterns
  - download-and-execute one-liners
  - shell pipelines that execute remote content
- Prefer safe two-step API access patterns:
  1. save the response to a local file
  2. inspect the file
  3. then act on it
- Prefer simple, auditable, reversible actions.

Your Paperclip identity:
  Agent ID: {{agentId}}
  Company ID: {{companyId}}
  API Base: {{paperclipApiUrl}}

Safe API usage examples:
- Read issue details:
  \\`curl -sS "{{paperclipApiUrl}}/issues/{{taskId}}" -o /tmp/paperclip_issue.json && cat /tmp/paperclip_issue.json\\`
- Read a comment:
  \\`curl -sS "{{paperclipApiUrl}}/issues/{{taskId}}/comments/{{commentId}}" -o /tmp/paperclip_comment.json && cat /tmp/paperclip_comment.json\\`
- Update issue status:
  \\`curl -sS -X PATCH "{{paperclipApiUrl}}/issues/{{taskId}}" -H "Content-Type: application/json" -d '{"status":"done"}'\\`
- Post a completion comment:
  \\`curl -sS -X POST "{{paperclipApiUrl}}/issues/{{taskId}}/comments" -H "Content-Type: application/json" -d '{"body":"DONE: <your summary here>"}'\\`

{{#taskId}}
## Assigned Task

Issue ID: {{taskId}}
Title: {{taskTitle}}

{{taskBody}}

## Workflow

1. Read the assigned issue safely.
2. Work on the task using your tools.
3. Keep actions small and verifiable.
4. When done, mark the issue as completed:
   \\`curl -sS -X PATCH "{{paperclipApiUrl}}/issues/{{taskId}}" -H "Content-Type: application/json" -d '{"status":"done"}'\\`
5. Post a completion comment on the issue summarizing what you did:
   \\`curl -sS -X POST "{{paperclipApiUrl}}/issues/{{taskId}}/comments" -H "Content-Type: application/json" -d '{"body":"DONE: <your summary here>"}'\\`
6. If this issue has a parent reference, post a brief notification on the parent issue:
   \\`curl -sS -X POST "{{paperclipApiUrl}}/issues/PARENT_ISSUE_ID/comments" -H "Content-Type: application/json" -d '{"body":"{{agentName}} completed {{taskId}}. Summary: <brief>"}'\\`
{{/taskId}}

{{#commentId}}
## Comment on This Issue

Someone commented. Read it safely by saving the response locally first:
   \\`curl -sS "{{paperclipApiUrl}}/issues/{{taskId}}/comments/{{commentId}}" -o /tmp/paperclip_comment.json && cat /tmp/paperclip_comment.json\\`

Address the comment, post a reply if needed, then continue working.
{{/commentId}}

{{#noTask}}
## Heartbeat Wake — Check for Work

1. List open issues assigned to you safely:
   \\`curl -sS "{{paperclipApiUrl}}/companies/{{companyId}}/issues?assigneeAgentId={{agentId}}" -o /tmp/paperclip_assigned.json && cat /tmp/paperclip_assigned.json\\`

2. If issues are found, pick the highest priority one that is not done/cancelled and work on it:
   - Read the issue details safely:
     \\`curl -sS "{{paperclipApiUrl}}/issues/ISSUE_ID" -o /tmp/paperclip_issue.json && cat /tmp/paperclip_issue.json\\`
   - Do the work in the project directory: {{projectName}}
   - When done, mark complete and post a comment

3. If no issues are assigned to you, check unassigned backlog issues safely:
   \\`curl -sS "{{paperclipApiUrl}}/companies/{{companyId}}/issues?status=backlog" -o /tmp/paperclip_backlog.json && cat /tmp/paperclip_backlog.json\\`

4. If you find a relevant issue, assign it to yourself:
   \\`curl -sS -X PATCH "{{paperclipApiUrl}}/issues/ISSUE_ID" -H "Content-Type: application/json" -d '{"assigneeAgentId":"{{agentId}}","status":"todo"}'\\`

5. If truly nothing to do, report briefly what you checked.
{{/noTask}}`;"""

if old_template not in s:
    raise SystemExit("template block not found")
s = s.replace(old_template, new_template, 1)

old_provider = """if (resolvedProvider !== "auto") {
        args.push("--provider", resolvedProvider);
    }"""
new_provider = """if (resolvedProvider !== "auto" && resolvedProvider !== "custom") {
        args.push("--provider", resolvedProvider);
    }"""
if old_provider not in s:
    raise SystemExit("provider block not found")
s = s.replace(old_provider, new_provider, 1)

old_env = """const env = {
        ...process.env,
        ...buildPaperclipEnv(ctx.agent),
    };"""
new_env = """const env = {
        ...process.env,
        HERMES_HOME: process.env.HERMES_HOME || "/paperclip/.hermes",
        ...buildPaperclipEnv(ctx.agent),
    };"""
if old_env not in s:
    raise SystemExit("env block not found")
s = s.replace(old_env, new_env, 1)

old_userenv = """    if (userEnv && typeof userEnv === "object") {
        Object.assign(env, userEnv);
    }"""
new_userenv = """    if (userEnv && typeof userEnv === "object") {
        Object.assign(env, userEnv);
    }
    if (typeof env.HERMES_HOME !== "string" || !env.HERMES_HOME.trim() || env.HERMES_HOME === "[object Object]") {
        env.HERMES_HOME = "/paperclip/.hermes";
    }"""
if old_userenv not in s:
    raise SystemExit("userEnv block not found")
s = s.replace(old_userenv, new_userenv, 1)

old_log = """    await ctx.onLog("stdout", `[hermes] Starting Hermes Agent (model=${model}, provider=${resolvedProvider} [${resolvedFrom}], timeout=${timeoutSec}s${maxTurns ? `, max_turns=${maxTurns}` : ""})\\n`);"""
new_log = """    await ctx.onLog("stdout", `[hermes] Starting Hermes Agent (model=${model}, provider=${resolvedProvider} [${resolvedFrom}], timeout=${timeoutSec}s${maxTurns ? `, max_turns=${maxTurns}` : ""})\\n`);
    await ctx.onLog("stdout", `[hermes] HERMES_HOME=${env.HERMES_HOME}\\n`);
    await ctx.onLog("stdout", `[hermes] args=${JSON.stringify(args)}\\n`);"""
if old_log not in s:
    raise SystemExit("log block not found")
s = s.replace(old_log, new_log, 1)

p.write_text(s)
print("patched", p)
PY

FROM base AS build
WORKDIR /app
COPY --from=deps /app /app
COPY . .

RUN pnpm --filter @paperclipai/ui build
RUN pnpm --filter @paperclipai/plugin-sdk build
RUN pnpm --filter @paperclipai/server build
RUN test -f server/dist/index.js || (echo "ERROR: server build output missing" && exit 1)

FROM base AS production
ARG USER_UID=1000
ARG USER_GID=1000
WORKDIR /app

COPY --chown=node:node --from=build /app /app

RUN npm install --global --omit=dev @anthropic-ai/claude-code@latest @openai/codex@latest opencode-ai \
 && mkdir -p /paperclip \
 && chown node:node /paperclip \
 && apt-get update && apt-get install -y --no-install-recommends python3-pip python3-venv git \
 && rm -rf /var/lib/apt/lists/* \
 && pip3 install --break-system-packages \
      git+https://github.com/NousResearch/hermes-agent.git@main \
      python-telegram-bot \
 && chmod +x /usr/local/bin/hermes

COPY scripts/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENV NODE_ENV=production \
    HOME=/paperclip \
    HOST=0.0.0.0 \
    PORT=3100 \
    SERVE_UI=true \
    PAPERCLIP_HOME=/paperclip \
    PAPERCLIP_INSTANCE_ID=default \
    USER_UID=${USER_UID} \
    USER_GID=${USER_GID} \
    PAPERCLIP_CONFIG=/paperclip/instances/default/config.json \
    PAPERCLIP_DEPLOYMENT_MODE=authenticated \
    PAPERCLIP_DEPLOYMENT_EXPOSURE=private \
    OPENCODE_ALLOW_ALL_MODELS=true

VOLUME ["/paperclip"]
EXPOSE 3100
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["node", "--import", "./server/node_modules/tsx/dist/loader.mjs", "server/dist/index.js"]
