#!/bin/bash
# Script para limpar recursos do SSM QuickSetup quando terraform destroy falha

set -e

echo "🧹 Limpeza Manual de Recursos SSM QuickSetup"
echo "=============================================="
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ACCOUNT_ID="092896976173"
REGION="us-east-1"

echo -e "${YELLOW}⚠️  Este script irá deletar recursos manualmente via AWS CLI${NC}"
echo ""
read -p "Deseja continuar? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Operação cancelada."
    exit 1
fi

echo ""
echo "📋 Passo 1: Listando Configuration Managers..."
aws ssm-quicksetup list-configuration-managers --region $REGION --query 'ConfigurationManagersList[?ManagerArn!=`null`].[ManagerArn,Name,StatusSummaries[0].Status]' --output table || true

echo ""
echo "📋 Passo 2: Listando CloudFormation StackSets..."
aws cloudformation list-stack-sets --region $REGION --query 'Summaries[?StackSetName!=`null` && contains(StackSetName, `QuickSetup-PatchPolicy`)].[StackSetName,Status]' --output table || true

echo ""
echo "🗑️  Passo 3: Deletando Stack Instances com RetainStacks=true..."
STACKSETS=$(aws cloudformation list-stack-sets --region $REGION --query 'Summaries[?contains(StackSetName, `QuickSetup-PatchPolicy`)].StackSetName' --output text)

for STACKSET in $STACKSETS; do
    echo "  Processando StackSet: $STACKSET"
    
    # Listar stack instances
    INSTANCES=$(aws cloudformation list-stack-instances \
        --stack-set-name "$STACKSET" \
        --region $REGION \
        --query 'Summaries[].StackId' \
        --output text 2>/dev/null || echo "")
    
    if [ ! -z "$INSTANCES" ]; then
        echo "    Deletando stack instances..."
        aws cloudformation delete-stack-instances \
            --stack-set-name "$STACKSET" \
            --accounts "$ACCOUNT_ID" \
            --regions "$REGION" \
            --retain-stacks \
            --no-paginate \
            --region $REGION 2>/dev/null || echo "    Falha ao deletar instances (pode já estar deletado)"
        
        echo "    Aguardando conclusão..."
        sleep 5
    else
        echo "    Nenhuma stack instance encontrada"
    fi
done

echo ""
echo "🗑️  Passo 4: Deletando Stacks Órfãos..."
STACKS=$(aws cloudformation list-stacks \
    --region $REGION \
    --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE DELETE_FAILED \
    --query 'StackSummaries[?contains(StackName, `QuickSetup-PatchPolicy`)].StackName' \
    --output text)

for STACK in $STACKS; do
    echo "  Deletando stack: $STACK"
    aws cloudformation delete-stack --stack-name "$STACK" --region $REGION 2>/dev/null || echo "    Falha ao deletar (pode já estar deletado)"
done

echo ""
echo "⏳ Aguardando 10 segundos..."
sleep 10

echo ""
echo "🗑️  Passo 5: Deletando StackSets..."
for STACKSET in $STACKSETS; do
    echo "  Deletando StackSet: $STACKSET"
    aws cloudformation delete-stack-set --stack-set-name "$STACKSET" --region $REGION 2>/dev/null || echo "    Falha ao deletar StackSet (pode já estar deletado)"
done

echo ""
echo "🗑️  Passo 6: Deletando Configuration Manager via AWS CLI..."
CONFIG_MANAGER_ARN="arn:aws:ssm-quicksetup:us-east-1:092896976173:configuration-manager/8404c74a-1317-4aea-8daf-d4cf6e773971"
aws ssm-quicksetup delete-configuration-manager --manager-arn "$CONFIG_MANAGER_ARN" --region $REGION 2>/dev/null || echo "    Configuration Manager já foi deletado ou não existe"

echo ""
echo "🗑️  Passo 7: Limpando recursos adicionais..."

# Deletar Lambda Functions
echo "  Procurando Lambda functions..."
aws lambda list-functions --region $REGION --query 'Functions[?starts_with(FunctionName, `baseline-overrides`) || starts_with(FunctionName, `delete-name-tags`)].FunctionName' --output text | tr '\t' '\n' | while read func; do
    if [ ! -z "$func" ]; then
        echo "    Deletando Lambda: $func"
        aws lambda delete-function --function-name "$func" --region $REGION 2>/dev/null || true
    fi
done

# Deletar S3 Buckets
echo "  Procurando S3 buckets..."
aws s3 ls | grep "aws-quicksetup-patchpolicy" | awk '{print $3}' | while read bucket; do
    if [ ! -z "$bucket" ]; then
        echo "    Deletando objetos do bucket: $bucket"
        aws s3 rm s3://$bucket --recursive 2>/dev/null || true
        echo "    Deletando bucket: $bucket"
        aws s3 rb s3://$bucket 2>/dev/null || true
    fi
done

# Deletar SSM Documents
echo "  Procurando SSM Documents..."
aws ssm list-documents --region $REGION --filters Key=Owner,Values=Self --query 'DocumentIdentifiers[?starts_with(Name, `AWSQuickSetup`)].Name' --output text | tr '\t' '\n' | while read doc; do
    if [ ! -z "$doc" ]; then
        echo "    Deletando Document: $doc"
        aws ssm delete-document --name "$doc" --region $REGION 2>/dev/null || true
    fi
done

# Deletar SSM Associations
echo "  Procurando SSM Associations..."
aws ssm list-associations --region $REGION --query 'Associations[?contains(Name, `QuickSetup`)].AssociationId' --output text | tr '\t' '\n' | while read assoc; do
    if [ ! -z "$assoc" ]; then
        echo "    Deletando Association: $assoc"
        aws ssm delete-association --association-id "$assoc" --region $REGION 2>/dev/null || true
    fi
done

echo ""
echo -e "${GREEN}✅ Limpeza manual concluída!${NC}"
echo ""
echo "📋 Agora execute o Terraform destroy novamente:"
echo "   terraform destroy -var-file=main.tfvars"
echo ""
echo -e "${YELLOW}💡 Nota: Se ainda houver erros, pode levar alguns minutos para a AWS processar as exclusões.${NC}"
