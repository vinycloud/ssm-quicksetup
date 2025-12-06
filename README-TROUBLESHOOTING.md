# AWS SSM QuickSetup - Troubleshooting Guide

## Problema Original

Erro ao executar `terraform apply`:
```
Error: AccessDeniedException: Role AWS-QuickSetup-PatchPolicy-LocalAdministrationRole can't be accessed
```

## Causa Raiz

As IAM roles necessárias para o SSM QuickSetup não existiam na conta AWS. O Terraform assumia que essas roles já estavam criadas (como mencionado nas instruções do projeto), mas elas só são criadas automaticamente quando você usa o QuickSetup pela primeira vez através do AWS Console.

## Solução Implementada

Foi criado o arquivo `iam.tf` que define:

### 1. **LocalAdministrationRole** 
Role assumida pelo CloudFormation e SSM para orquestrar a criação dos recursos.

**Trust Policy:**
- `ssm.amazonaws.com`
- `cloudformation.amazonaws.com`

**Permissões:**
- CloudFormation (criar/atualizar/deletar stacks)
- IAM (gerenciar roles do QuickSetup)
- SSM (documentos, associações, automação)
- Organizations (listar contas)

### 2. **LocalExecutionRole**
Role assumida pelos recursos criados pelo QuickSetup para executar tarefas.

**Trust Policy:**
- `ssm.amazonaws.com`
- `LocalAdministrationRole` (permite que o admin role assuma esta role)

**Permissões:**
- SSM (completo: documentos, associações, comandos, patch baselines, tagging, Explorer)
- CloudFormation (criar/gerenciar stacks)
- EC2 (descrever instâncias e tags)
- IAM (gerenciar roles do QuickSetup, tagging)
- S3 (criar/gerenciar buckets para logs do QuickSetup)
- Lambda (criar/gerenciar funções do QuickSetup)
- Resource Groups Tagging API

## Permissões Adicionadas Iterativamente

Durante o troubleshooting, as seguintes permissões foram adicionadas conforme os erros apareciam:

1. ✅ Trust policy do CloudFormation no LocalAdministrationRole
2. ✅ Permissões de CloudFormation no LocalExecutionRole
3. ✅ `ssm:CreateDocument`, `ssm:UpdateDocument`, `ssm:DeleteDocument`
4. ✅ `ssm:AddTagsToResource`, `ssm:RemoveTagsFromResource`, `ssm:ListTagsForResource`
5. ✅ `iam:TagRole`, `iam:UntagRole`, `iam:ListRoleTags`
6. ✅ Permissões completas de S3 para buckets `aws-quicksetup-patchpolicy-*`
7. ✅ `s3:PutBucketOwnershipControls`, `s3:PutBucketAcl`, `s3:PutBucketLogging`
8. ✅ Permissões Lambda para funções `AWS-QuickSetup-*`
9. ✅ `ssm:CreateResourceDataSync`, `ssm:UpdateServiceSetting`, `ssm:GetServiceSetting`

## Erro Atual (em investigação)

```
ResourceLogicalId:QuickSetupEnableExplorerAssociation
ResourceType:AWS::SSM::Association
ResourceStatusReason:Resource handler returned message: "Error occurred during operation 'CreateAssociation'."
```

**Possíveis Causas:**
- SSM Explorer pode não estar habilitado na conta
- Pode requerer configuração prévia de service settings
- Pode estar relacionado à falta de instâncias EC2 gerenciadas

**Próximos Passos para Investigação:**
1. Verificar se SSM Explorer está habilitado:
   ```bash
   aws ssm get-service-setting --setting-id arn:aws:ssm:us-east-1:ACCOUNT_ID:servicesetting/ssm/opsitem/ssm-patchmanager
   ```

2. Verificar o stack CloudFormation criado para mais detalhes:
   ```bash
   aws cloudformation describe-stack-events \
     --stack-name <stack-name-from-error> \
     --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`]'
   ```

3. Considerar desabilitar Explorer temporariamente (se possível via parâmetros do QuickSetup)

## Arquivos Criados/Modificados

- ✅ **`iam.tf`** - Novo arquivo com definição das IAM roles
- ✅ **`ssmquicksetup.tf`** - Atualizado para referenciar as roles criadas via Terraform

## Comandos Úteis

```bash
# Ver estado atual do terraform
terraform show

# Ver roles criadas
aws iam get-role --role-name AWS-QuickSetup-PatchPolicy-LocalAdministrationRole
aws iam get-role --role-name AWS-QuickSetup-PatchPolicy-LocalExecutionRole

# Ver policies inline
aws iam get-role-policy \
  --role-name AWS-QuickSetup-PatchPolicy-LocalExecutionRole \
  --policy-name QuickSetupExecPolicy

# Destruir recursos se necessário
terraform destroy -var-file=main.tfvars
```

## Referências

- [AWS SSM QuickSetup Documentation](https://docs.aws.amazon.com/systems-manager/latest/userguide/quick-setup.html)
- [AWS SSM Patch Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/patch-manager.html)
- [Terraform AWS Provider - ssmquicksetup_configuration_manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssmquicksetup_configuration_manager)
