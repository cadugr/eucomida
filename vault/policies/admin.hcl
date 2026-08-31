# Policy administrativa — equivalente em poder ao root token, mas atribuída
# a um usuário nomeado (auth method userpass) em vez de um token anônimo.
# Existe para que seja possível administrar o Vault no dia a dia (escrever
# segredos, ajustar policies/roles) sem depender do root token, que é
# revogado ao final do bootstrap (vault/bootstrap.sh).
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
