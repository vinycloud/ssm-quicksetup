#!/bin/bash
# Script para preparar e fazer o primeiro commit no GitHub

set -e

echo "🚀 Preparando repositório para GitHub..."
echo ""

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar se já é um repositório git
if [ -d .git ]; then
    echo -e "${YELLOW}⚠️  Repositório Git já existe. Pulando inicialização.${NC}"
else
    echo "📦 Inicializando repositório Git..."
    git init
    echo -e "${GREEN}✓${NC} Repositório inicializado"
fi

# Verificar arquivos que serão commitados
echo ""
echo "📋 Arquivos que serão adicionados ao Git:"
git status --short

echo ""
echo -e "${YELLOW}⚠️  IMPORTANTE: Verifique se nenhum arquivo sensível será commitado!${NC}"
echo ""
echo "Os seguintes arquivos/diretórios estão sendo IGNORADOS (correto):"
echo "  - terraform.tfstate (contém IDs de recursos e dados sensíveis)"
echo "  - terraform.tfstate.backup"
echo "  - .terraform/ (binários e plugins)"
echo "  - .terraform.lock.hcl"
echo "  - main.tfvars (pode conter dados sensíveis)"
echo "  - .vscode/ (configurações do editor)"
echo ""

read -p "Deseja continuar com o commit? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Operação cancelada."
    exit 1
fi

# Adicionar arquivos
echo ""
echo "➕ Adicionando arquivos ao Git..."
git add .

# Mostrar status final
echo ""
echo "📊 Status final:"
git status --short

# Criar commit inicial
echo ""
echo "💾 Criando commit inicial..."
git commit -m "feat: Initial commit - AWS SSM QuickSetup Terraform automation

- Add Terraform configuration for SSM QuickSetup with Patch Policy
- Add IAM roles with comprehensive permissions
- Add dynamic patch baseline mapping for 15+ operating systems
- Add comprehensive documentation (README, troubleshooting guide)
- Add .gitignore following Terraform best practices
- Configure daily patch scanning at 01:00 UTC (scan-only mode)"

echo ""
echo -e "${GREEN}✓${NC} Commit criado com sucesso!"
echo ""
echo "📝 Próximos passos:"
echo ""
echo "1. Crie um repositório no GitHub:"
echo "   https://github.com/new"
echo ""
echo "2. Configure o remote (substitua YOUR_USERNAME e REPO_NAME):"
echo "   git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git"
echo ""
echo "   OU com SSH:"
echo "   git remote add origin git@github.com:YOUR_USERNAME/REPO_NAME.git"
echo ""
echo "3. Configure a branch principal:"
echo "   git branch -M main"
echo ""
echo "4. Faça push para o GitHub:"
echo "   git push -u origin main"
echo ""
echo -e "${GREEN}🎉 Repositório pronto para ser publicado!${NC}"
