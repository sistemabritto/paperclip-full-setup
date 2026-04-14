# PAPERCLIP - Empresa AI Autônoma

*Paperclip + OpenClaw = Orquestração completa de empresas AI*

---

## 🎯 O Que É Paperclip?

**Paperclip** é um orquestrador de **empresas autônomas** com agentes AI.

- **OpenClaw** = Empregado AI individual (como o Hagamenon)
- **Paperclip** = Empresa AI que gerencia múltiplos agentes

### Analogia

> "If OpenClaw is an employee, Paperclip is the company"

---

## 🚀 Recursos Principais

### Dashboard Centralizado

- **Organogramas** - Estrutura hierárquica de agentes
- **Metas e objetivos** - OKRs, missão da empresa
- **Orçamentos** - Limites de gastos por agente/tarefa
- **Tickets/Tarefas** - Sistema de gerenciamento de trabalho
- **Aprovações** - Governança e audit trail
- **Mobile-friendly** - Gerencia do celular

### Multi-Agente

Gerencia **múltiplos agentes simultaneamente**:
- ✅ OpenClaw (Hagamenon)
- ✅ Claude Code
- ✅ Codex
- ✅ Cursor
- ✅ Gemini
- ✅ Bash scripts
- ✅ HTTP endpoints

### Persistência

- **Sessões preservam** entre reboots
- **Contexto mantém** em heartbeats
- **Audit trail** completo de decisões

### Controle de Custos

- **Budget por agente** (ex: $50/mês)
- **Throttling automático** quando atinge limite
- **Tracking em tempo real** de token usage

---

## 🔗 Integração OpenClaw + Paperclip

### Arquitetura

```
┌─────────────────────────────────────────┐
│         Paperclip Dashboard             │
│  (Empresa: Sistema Britto)              │
├─────────────────────────────────────────┤
│ • Metas: "Expandir para 5 clientes"     │
│ • Orçamento: $500/mês                   │
│ • Agentes: Hagamenon + outros           │
└─────────────────────────────────────────┘
                 │
                 │ webhook / heartbeat
                 ▼
┌─────────────────────────────────────────┐
│      OpenClaw Gateway                    │
│  (Gerencia sessões e canais)            │
└─────────────────────────────────────────┘
                 │
                 │ spawn sub-agent
                 ▼
┌─────────────────────────────────────────┐
│         Hagamenon                        │
│  (Business Co-pilot)                     │
│  • Executa tarefas                       │
│  • Reporta progresso                     │
│  • Recebe heartbeats                     │
└─────────────────────────────────────────┘
```

### Fluxo de Trabalho

1. **Definir Meta** (Paperclip)
   - Empresa: "Sistema Britto"
   - Meta: "Onboarding 5 clientes até Junho/2026"
   - Orçamento: $100/mês por agente

2. **Criar Tarefas** (Paperclip)
   - Ticket: "Onboarding VGRA Jurídico"
   - Atribuir: Hagamenon
   - Prioridade: Alta
   - Deadline: 2026-04-15

3. **Executar** (OpenClaw + Hagamenon)
   - Paperclip envia task via webhook
   - OpenClaw roteia para Hagamenon
   - Hagamenon executa trabalho
   - Reporta progresso

4. **Monitorar** (Paperclip Dashboard)
   - Progresso em tempo real
   - Custos por tarefa
   - Aprovar work
   - Auditar decisões

---

## 📦 Instalação

### Requisitos

- Node.js 20+
- pnpm 9+
- Docker Swarm (infraestrutura atual)

### Setup Local

```bash
# Clone (já feito)
cd /workspace/paperclip

# Instalar dependências
pnpm install

# Iniciar dev
pnpm dev
```

Acessar: http://localhost:3100

### Deploy Docker Swarm

**Stack já configurada em:** `/workspace/paperclip/docker-compose.yml`

```bash
# Rodar setup automatizado
cd /workspace/paperclip
./setup-openclaw.sh

# Ou manual
docker stack deploy -c docker-compose.yml paperclip
```

**Acessar:** https://paperclip.workflowapi.com.br

---

## 🔧 Configuração

### Environment Variables

```bash
# .env
BETTER_AUTH_SECRET=<generated-secret>
PAPERCLIP_PUBLIC_URL=https://paperclip.workflowapi.com.br
OPENCLAW_WEBHOOK_URL=http://openclaw-gateway:8080/webhook
OPENCLAW_WEBHOOK_AUTH=Bearer <gateway-token>
```

### Webhook OpenClaw

Configurar no Gateway OpenClaw:

```bash
# Via Telegram ou config
/webhook add https://paperclip.workflowapi.com.br/api/webhooks/openclaw
```

---

## 📚 Documentação

- **Docs Oficiais:** https://paperclip.ing/docs
- **GitHub:** https://github.com/paperclipai/paperclip
- **Discord:** https://discord.gg/m4HZY7xNG3
- **Integração Local:** `/workspace/paperclip/INTEGRACAO_OPENCLAW.md`

---

## 🎯 Casos de Uso

### 1. Empresa de Serviços AI

```
Sistema Britto (Paperclip)
├── Hagamenon (Business Co-pilot)
├── DevBot (Desenvolvimento)
├── SupportBot (Atendimento)
└── FinanceBot (Finanças)
```

### 2. Multi-Cliente

```
Paperclip Instance
├── Company: VGRA Jurídico
│   └── Agent: VGRA Bot
├── Company: Cliente X
│   └── Agent: Cliente X Bot
└── Company: Cliente Y
    └── Agent: Cliente Y Bot
```

### 3. Automação 24/7

```
Heartbeats (agendados)
├── 08:00 - Relatório diário
├── 12:00 - Check emails
├── 18:00 - Backup dados
└── 22:00 - Planejamento próximo dia
```

---

## 📊 Status

- ✅ Repositório clonado
- ✅ Docker Swarm stack criada
- ✅ Script de setup automatizado
- ✅ Documentação de integração
- ⚠️ **Pendente:** Deploy e testes

---

**Última atualização:** 2026-04-02
**Responsável:** Hagamenon (Business Co-pilot)
