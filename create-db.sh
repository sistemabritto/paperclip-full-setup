#!/bin/bash
# Criar database Paperclip no PostgreSQL existente

set -e

echo "🗄️  Criando database Paperclip no PostgreSQL..."
echo ""

# Configurações
POSTGRES_SERVICE="postgres_postgres"
DB_NAME="paperclip"
DB_USER="postgres"
DB_PASSWORD=${POSTGRES_PASSWORD:-"your_secure_password_here"}

echo "📊 Conectando ao PostgreSQL..."
echo "   Service: $POSTGRES_SERVICE"
echo "   Database: $DB_NAME"
echo ""

# Executar no container PostgreSQL
docker exec -it $(docker ps -q -f name=$POSTGRES_SERVICE | head -1) psql -U $DB_USER -c "CREATE DATABASE $DB_NAME;" 2>/dev/null || echo "Database já existe ✅"

echo ""
echo "✅ Database '$DB_NAME' criada!"
echo ""
echo "📋 Connection string:"
echo "   postgresql://$DB_USER:$DB_PASSWORD@postgres_postgres:5432/$DB_NAME"
echo ""
