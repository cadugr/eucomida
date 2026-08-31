# Policy de leitura para os segredos da stack eu-comida.
#
# Usada pelo auth method Kubernetes (role "eucomida-external-secrets"),
# vinculada à ServiceAccount que o External Secrets Operator vai usar para
# autenticar no Vault (ver vault/bootstrap.sh). Intencionalmente restrita a
# "read" e só nesses dois caminhos — nada de create/update/delete/list, e
# nenhum outro caminho do Vault.
path "eucomida/data/mysql" {
  capabilities = ["read"]
}

path "eucomida/data/rabbitmq" {
  capabilities = ["read"]
}
