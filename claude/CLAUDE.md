---
name: prd-spec-code-workflow
description: >
  Workflow estruturado Pesquisa → Spec → Code para implementação de features
  e mudanças. Ativa quando: múltiplos arquivos afetados, novo módulo, mudança
  de interface/contrato, integração com sistema externo, ou quando o usuário
  mencionar PRD/spec/planejamento. Sempre execute o workflow — adapte a
  profundidade ao tamanho da tarefa, mas nunca code sem plano aprovado.
---

# Workflow: Pesquisa → Spec → Code

Existe para evitar implementações que ignoram contexto existente, criam
inconsistências ou desperdiçam tempo com retrabalho.

**Regra de ouro**: nunca escreva código de produção sem plano aprovado
pelo usuário.

---

## Pré-condição

- Se existir `CLAUDE.md` no projeto, leia-o antes de qualquer etapa
- Nunca contradiga decisões documentadas no `CLAUDE.md` sem discutir
  com o usuário primeiro

---

## Etapa 1 — Pesquisa

**Objetivo**: entender o que existe antes de propor o que criar.

1. Leia arquivos relevantes (entrypoints, modelos, configs, CI/CD)
2. Identifique padrões: naming, estrutura, frameworks, estilo de testes
3. Detecte dependências e pontos de integração afetados
4. Documente o que encontrou — não assuma
5. Se a abordagem proposta pelo usuário conflitar com o que a pesquisa
   revelou, aponte o conflito antes de prosseguir. Não adapte o plano
   silenciosamente para acomodar uma premissa incorreta.

---

## Etapa 2 — Plano (plan.md)

**Objetivo**: traduzir a pesquisa em plano de implementação concreto.

Para tarefas **médias**, use um único `plan.md` que combine contexto e spec.
Para tarefas **grandes**, separe em `PRD.md` (o quê/por quê) e `Spec.md`
(como/onde).

### Conteúdo mínimo do plan.md
```markdown
# Plan: [Nome]

## Contexto
[O que existe e por que precisa mudar]

## Fora do escopo
[O que deliberadamente não será feito]

## Arquivos a criar
| Arquivo | Propósito |
|---------|-----------|
| `path` | descrição |

## Arquivos a modificar
| Arquivo | O que muda |
|---------|------------|
| `path` | descrição |

## Interfaces / Contratos
[Assinaturas, schemas, tipos — se aplicável]

## Lógica principal
[Pseudocódigo ou descrição do fluxo]

## Testes
- [ ] Teste 1
- [ ] Teste 2

## Edge cases
- [caso]: [tratamento]
```

**Gate**: apresente o plano ao usuário e aguarde aprovação.
- Se identificar problemas na abordagem solicitada (overengineering,
  solução frágil, padrão inconsistente com o projeto), diga antes de
  apresentar o plano — não depois, e não escondido em ressalvas suaves.
- Apresente ao menos um trade-off relevante da abordagem escolhida.

---

## Etapa 3 — Code

1. Siga o plano aprovado — se algo precisar mudar, pause e informe
2. Implemente na ordem de dependência
3. Não adicione funcionalidades não especificadas
4. Após cada arquivo: rode testes se existirem. Se falharem, **pare e
   reporte** antes de continuar
5. Se durante a implementação perceber que o plano aprovado tem um
   problema real, pare e diga. Não implemente algo que você avalia como
   errado só porque foi aprovado.

### Se precisar abortar
- Reverta arquivos modificados ou documente o estado parcial
- Informe o que foi feito e o que ficou pendente

### Ao finalizar
- Confirme que o comportamento bate com o plano
- Sugira atualizações ao `CLAUDE.md` se houver decisões novas

---

## Adaptação por tamanho

| Tamanho | Pesquisa | Plano | Code |
|---------|----------|-------|------|
| Micro (1 arquivo, mudança óbvia) | Leitura rápida | Inline no chat | Direto |
| Médio (2-5 arquivos) | Arquivos afetados | `plan.md` único | Por arquivo |
| Grande (6+ arquivos / novo módulo) | Codebase ampla | PRD.md + Spec.md separados | Por módulo com checkpoints |

---

## Sinais de alerta — pause e replaneie

- Arquivo não listado no plano precisa ser mudado
- Implementação crescendo além do escopo
- Incerteza sobre como módulo existente funciona
- Contexto da conversa muito longo — resuma progresso antes de continuar