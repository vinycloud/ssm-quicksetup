# Problema com Terraform Destroy

## 🔴 Erro Encontrado

Ao executar `terraform destroy`, o seguinte erro ocorreu:

```
Error: waiting for SSM Quick Setup Configuration Manager delete

unexpected state 'DELETE_FAILED', wanted target ''. last error: 
CFN stack arn:aws:cloudformation:us-east-1:...
is INOPERABLE due to: User: arn:aws:sts::...:assumed-role/AWS-QuickSetup-PatchPolicy-LocalExecutionRole/... 
is not authorized to perform: cloudformation:DescribeStacks on resource: ...
because no identity-based policy allows the cloudformation:DescribeStacks action.
```

## 🔍 Análise do Problema

### Causa Raiz

1. **Permissão Faltando**: A IAM role `LocalExecutionRole` estava usando wildcard `cloudformation:DescribeStack*` mas a AWS não reconheceu isso especificamente para `cloudformation:DescribeStacks` (plural) durante a operação de delete.

2. **Estado DELETE_FAILED**: Uma tentativa anterior de delete deixou o CloudFormation stack em estado `DELETE_FAILED`, tornando impossível deletá-lo pelo Terraform mesmo após corrigir as permissões.

### Por que aconteceu?

O SSM QuickSetup cria recursos via CloudFormation. Durante a fase de **criação**, as permissões funcionaram, mas durante o **delete**, o QuickSetup precisa:

- `cloudformation:DescribeStacks` - Para verificar o status do stack
- `cloudformation:DescribeStackSet` - Para verificar stacksets
- `cloudformation:DescribeStackInstance` - Para verificar instâncias
- `cloudformation:ListStacks` - Para listar stacks relacionados

## ✅ Solução Implementada

### 1. Correção das Permissões IAM

**Arquivo**: `iam.tf`

**ANTES** (usando wildcard):
```terraform
Action = [
  "cloudformation:DescribeStack*"  # ❌ Não funcionou no delete
]
```

**DEPOIS** (permissões explícitas):
```terraform
Action = [
  "cloudformation:DescribeStacks",
  "cloudformation:DescribeStackSet",
  "cloudformation:DescribeStackSetOperation",
  "cloudformation:DescribeStackInstance",
  "cloudformation:DescribeStackEvents",
  "cloudformation:DescribeStackResources",
  "cloudformation:DescribeStackResource",
  "cloudformation:ListStacks",
  "cloudformation:ListStackSets",
  "cloudformation:ListStackInstances",
  "cloudformation:ListStackResources"
]
```

### 2. Script de Cleanup Manual

Criado `cleanup-quicksetup.sh` que:

1. **Lista recursos** criados pelo QuickSetup
2. **Deleta Stack Instances** com `RetainStacks=true` (necessário quando stack está em estado de erro)
3. **Remove Stacks órfãos** manualmente via AWS CLI
4. **Deleta StackSets**
5. **Limpa recursos adicionais**:
   - Lambda functions
   - S3 buckets
   - SSM Documents
   - SSM Associations

### 3. Processo de Destroy Corrigido

```bash
# 1. Executar cleanup manual
./cleanup-quicksetup.sh

# 2. Aguardar processamento da AWS
sleep 15

# 3. Executar terraform destroy
terraform destroy -var-file=main.tfvars
```

## 📊 Recursos Limpos

Durante o cleanup, foram removidos:

- **12 CloudFormation StackSets**
- **1 CloudFormation Stack órfão**
- **1 Lambda Function** (`baseline-overrides-*`)
- **6 S3 Buckets** (access logs)
- **SSM Documents e Associations** criados pelo QuickSetup

## 🎓 Lições Aprendidas

### 1. **Wildcards nem sempre funcionam**
AWS IAM pode interpretar wildcards de forma diferente em diferentes contextos (create vs delete).

**Recomendação**: Use permissões explícitas para operações críticas.

### 2. **CloudFormation StackSets são complexos**
QuickSetup usa StackSets que criam múltiplos stacks. Delete em cascata pode falhar.

**Recomendação**: Sempre tenha um script de cleanup manual.

### 3. **Estados DELETE_FAILED precisam cleanup manual**
Terraform não consegue recuperar de estados de erro do CloudFormation automaticamente.

**Recomendação**: Use `RetainStacks=true` ao deletar instances, depois delete stacks manualmente.

### 4. **Permissões de Delete são diferentes de Create**
Algumas ações AWS só são usadas durante delete (ex: `DescribeStacks` para verificar status antes de deletar).

**Recomendação**: Teste o ciclo completo (create + destroy) em ambiente de testes.

## 🔧 Melhorias Futuras

1. **Adicionar timeout maior** no resource do Terraform para delete operations
2. **Implementar retry logic** no cleanup script
3. **Adicionar validação de state** antes de tentar destroy
4. **Criar outputs** mostrando IDs de recursos para facilitar cleanup manual

## 📝 Atualização da Documentação

- ✅ README.md atualizado com seção de cleanup expandida
- ✅ Criado `cleanup-quicksetup.sh` com documentação inline
- ✅ Permissões IAM expandidas no `iam.tf`

## 🚀 Status

- ✅ **Problema Resolvido**: Terraform destroy funcionando
- ✅ **Script de Cleanup**: Criado e testado
- ✅ **Permissões**: Corrigidas e documentadas
- ✅ **Documentação**: Atualizada

## 🔗 Referências

- [AWS CloudFormation StackSets](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/what-is-cfnstacksets.html)
- [SSM QuickSetup Cleanup](https://docs.aws.amazon.com/systems-manager/latest/userguide/quick-setup-cleanup.html)
- [Terraform Destroy](https://developer.hashicorp.com/terraform/cli/commands/destroy)
