---
name: track-issue
description: >
  Registra um problema, ideia ou aprendizado como issue no GitHub (via `gh`)
  sem interromper a tarefa atual. Ativa quando, durante outro trabalho, surge
  algo que vale a pena resolver depois mas não faz parte do escopo da tarefa
  em andamento: um bug tangencial, uma melhoria notada de passagem, uma
  decisão adiada, ou um aprendizado que merece ficar mapeado. Não é para
  issues que o usuário já pediu explicitamente para criar agora.
---

# Track Issue

Existe pra não perder nem bloquear: quando algo fora do escopo aparece no
meio de uma tarefa, a escolha não é "resolver agora" nem "esquecer", é
registrar e seguir. Issue do GitHub é o formato porque fica buscável,
sobrevive ao fim da sessão, e pode ser linkada entre projetos.

## Quando usar

- Notou um bug, débito técnico ou melhoria que não é o que está sendo pedido
  agora
- Uma decisão foi adiada de propósito ("fazer quando o atrito incomodar")
- Um aprendizado da sessão aponta uma ação futura (ex: "mover isso pro
  CLAUDE.md global depois")
- **Não pare o trabalho atual** pra isso: anuncie em uma linha que vai
  registrar, crie a issue, e continue

## Passo 1 — Decidir o projeto certo

A issue vai no repositório **onde o artefato ou fix de fato vai morar**, não
necessariamente onde o problema foi notado. Exemplos:

- Achou algo sobre Talos/Proxmox enquanto trabalhava no homelab → issue no
  homelab
- Achou que falta uma skill/MCP do Claude Code, mesmo que a motivação tenha
  sido um projeto específico → issue no **dotfiles**, porque skills pessoais
  e config global do Claude Code são gerenciadas lá (`claude/skills/`), não
  no projeto que motivou a necessidade
- Um aprendizado vale pros dois lados (ex: um gotcha de ambiente descoberto
  num projeto, mas que é fato da máquina, não do projeto) → ver "Issues
  companheiras" abaixo

Se não for óbvio, pergunte-se: "se alguém for resolver isso, em qual
repositório o `git diff` vai aparecer?"

## Passo 2 — Checar labels existentes

```bash
gh label list --repo <owner>/<repo>
```

Reusar o que já existe (`documentation`, `enhancement`, `bug`, `question`,
etc). Não inventar taxonomia de prioridade nova se o repo não tiver uma: se
for prioridade baixa/alta, dizer isso explicitamente no corpo da issue em vez
de criar uma label nova sem necessidade.

## Passo 3 — Criar a issue

```bash
gh issue create --repo <owner>/<repo> \
  --title "<tipo>: <resumo curto e específico>" \
  --label <label-existente> \
  --body "<corpo>"
```

Corpo mínimo:
- O que foi encontrado (contexto, evidência: arquivo/linha, comando que
  mostrou o problema)
- Por que importa (ou por que pode esperar, se for o caso)
- Próxima ação concreta, não vaga

Título com o mesmo padrão de Conventional Commits usado nos commits do
repo (`docs:`, `fix:`, `chore:`, etc), quando a convenção do repo já usa
isso.

## Issues companheiras entre projetos

Quando o mesmo achado afeta dois repositórios (ex: um aprendizado que devia
ser global mas está presa num `CLAUDE.md` de projeto), criar uma issue em
cada repo e linkar uma na outra pela URL completa (`gh issue create` já
retorna a URL). Deixar explícito em cada issue qual delas deve ser resolvida
primeiro, se houver dependência.

## O que não fazer

- Não pedir aprovação antes de cada issue: anunciar em uma linha o que vai
  criar e seguir. É uma ação de baixo custo e reversível (a issue pode ser
  fechada)
- Não usar isso para pedidos que o usuário já fez diretamente agora — isso é
  só para o que surge de lado, fora do escopo da tarefa atual
- Não deixar o corpo vago ("ver se isso está certo") sem contexto suficiente
  pra retomar sem reler a sessão inteira
