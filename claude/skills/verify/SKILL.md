---
name: verify
description: >
  Verificação pós-edição: detecta e roda lint, testes e "plan"/dry-run
  apropriados ao projeto (ex: npm run lint/test, pytest, go test/vet,
  cargo test/clippy, terraform plan, nix flake check, kubectl diff) antes
  de declarar uma tarefa concluída. Ativa sempre depois de editar arquivos
  de código, config ou infraestrutura — não pule mesmo em mudanças
  pequenas, adapte apenas a profundidade.
---

# Verify

Existe pra impedir declarar "concluído" sem checar se o código/infra
realmente funciona. Substitui suposição por evidência.

**Regra de ouro**: se existe um comando de verificação disponível pro
tipo de mudança feita, rode-o antes de reportar como concluído.

---

## Etapa 1 — Detectar o que verificar

Baseado no que foi editado, identifique os comandos aplicáveis:

| Mudança | Comando |
| --- | --- |
| `.tf` / `.tf.json` | `terraform plan` / `tofu plan` (nunca `apply` sem pedido explícito) |
| manifests Kubernetes | `kubectl diff -f <arquivo>` ou `--dry-run=server` |
| `.nix` | `nix flake check` |
| JS/TS com `package.json` | scripts `lint`/`test`/`typecheck` declarados no `package.json` |
| Python | `pytest`, ou o runner configurado (`tox`, `nox`); lint via `ruff`/`flake8` se presente |
| Go | `go build ./...`, `go vet ./...`, `go test ./...` |
| Rust | `cargo check`, `cargo clippy`, `cargo test` |
| Shell scripts | `shellcheck` se disponível |

Se nada da lista se aplica, procure um `Makefile`, `justfile` ou workflow
de CI (`.github/workflows/`) pra achar o comando real do projeto — não
invente um comando genérico.

---

## Etapa 2 — Rodar e interpretar

1. Rode os comandos identificados
2. Se falhar: **pare e reporte** o erro antes de continuar ou declarar
   concluído. Não contorne a verificação (`--no-verify`, desabilitar
   teste, ignorar warning sem entender a causa) pra fazer passar
3. Se passar: siga em frente

---

## Etapa 3 — Antes de declarar concluído

- Confirme que rodou verificação para cada tipo de arquivo alterado, não
  só um
- Se algum tipo de mudança não tem verificação automatizada disponível
  (ex: mudança visual de UI), diga isso explicitamente em vez de omitir

---

## Quando pular

- Mudança é só documentação/comentário sem efeito em código executável
- Usuário pediu explicitamente para pular — mesmo assim, avise que a
  mudança não foi verificada
