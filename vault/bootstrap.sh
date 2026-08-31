#!/bin/sh
# Bootstrap de auth methods, policies e roles no Vault da stack eu-comida.
#
# POSIX sh de propósito (não bash) — a imagem oficial do Vault não tem bash,
# só /bin/sh. Pensado para ser executado de dentro do próprio pod (via
# `kubectl exec`) ou em qualquer shell local com o `vault` CLI instalado.
#
# Idempotente: pode ser rodado mais de uma vez sem duplicar/quebrar nada.
# NÃO revoga o root token — isso é feito manualmente, depois de validar que
# tudo aqui funcionou (ver README ou o histórico do PR que introduziu este
# script para o comando exato).
#
# Pré-requisitos:
#   - `vault` CLI disponível no PATH de onde este script é executado
#     (ex: dentro do próprio pod via `kubectl exec`, ou localmente com
#     `kubectl port-forward svc/eu-comida-vault -n vault 8200:8200`).
#   - VAULT_ADDR apontando para a instância correta.
#   - VAULT_TOKEN com permissão suficiente (root, ou um token com a policy
#     "admin" criada por este mesmo script, em execuções futuras).
#   - VAULT_ADMIN_PASSWORD definida no ambiente (senha do usuário "admin"
#     criado no auth method userpass). Não tem valor default de propósito.
#
# Este script assume que está sendo executado a partir da raiz do repositório
# (os caminhos dos arquivos de policy são relativos a vault/policies/).

set -eu

: "${VAULT_ADDR:?defina VAULT_ADDR antes de rodar este script}"
: "${VAULT_TOKEN:?defina VAULT_TOKEN antes de rodar este script}"
: "${VAULT_ADMIN_PASSWORD:?defina VAULT_ADMIN_PASSWORD antes de rodar este script}"

KV_PATH="eucomida"
K8S_ROLE="eucomida-external-secrets"
# ServiceAccount que o External Secrets Operator vai usar para autenticar
# (criada quando instalarmos o ESO — ver Passo 2/3 da integração com Vault).
ESO_SERVICE_ACCOUNT="external-secrets-sa"
ESO_NAMESPACE="external-secrets-system"

echo "==> Habilitando secrets engine KV v2 em '${KV_PATH}/' (se ainda não existir)"
if ! vault secrets list -format=json | grep -q "\"${KV_PATH}/\""; then
  vault secrets enable -path="${KV_PATH}" kv-v2
else
  echo "    já habilitado, pulando."
fi

echo "==> Habilitando auth method 'kubernetes' (se ainda não existir)"
if ! vault auth list -format=json | grep -q "\"kubernetes/\""; then
  vault auth enable kubernetes
else
  echo "    já habilitado, pulando."
fi

echo "==> Configurando auth method 'kubernetes' (API do próprio cluster)"
vault write auth/kubernetes/config \
  kubernetes_host="https://kubernetes.default.svc"

echo "==> Aplicando policy 'eucomida-readonly'"
vault policy write eucomida-readonly vault/policies/eucomida-readonly.hcl

echo "==> Criando role 'kubernetes' (${K8S_ROLE}) para a ServiceAccount do ESO"
vault write "auth/kubernetes/role/${K8S_ROLE}" \
  bound_service_account_names="${ESO_SERVICE_ACCOUNT}" \
  bound_service_account_namespaces="${ESO_NAMESPACE}" \
  policies="eucomida-readonly" \
  ttl=1h

echo "==> Habilitando auth method 'userpass' (se ainda não existir)"
if ! vault auth list -format=json | grep -q "\"userpass/\""; then
  vault auth enable userpass
else
  echo "    já habilitado, pulando."
fi

echo "==> Aplicando policy 'admin'"
vault policy write admin vault/policies/admin.hcl

echo "==> Criando/atualizando usuário administrativo 'admin'"
vault write auth/userpass/users/admin \
  password="${VAULT_ADMIN_PASSWORD}" \
  policies="admin"

echo "==> Bootstrap concluído."
echo "    Login administrativo: vault login -method=userpass username=admin"
echo "    Root token ainda ATIVO — revogue manualmente após validar tudo acima."
