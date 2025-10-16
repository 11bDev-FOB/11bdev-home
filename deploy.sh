#!/bin/bash
set -e

echo "🚀 11bDev Docker Deployment Script"
echo "===================================="
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  No .env file found!"
    echo "📝 Creating .env from .env.example..."
    cp .env.example .env
    echo ""
    echo "✅ Created .env file"
    echo "⚠️  Please edit .env and set your RAILS_MASTER_KEY and other credentials"
    echo "   Run: nano .env"
    echo ""
    exit 1
fi

# Check if RAILS_MASTER_KEY is set
if ! grep -q "RAILS_MASTER_KEY=.\+" .env; then
    echo "❌ RAILS_MASTER_KEY is not set in .env file"
    echo "   Please set RAILS_MASTER_KEY in .env before continuing"
    exit 1
fi

echo "✅ Environment file configured"
echo ""

# Build the application
echo "🔨 Building Docker images..."
docker compose build --pull

echo ""
echo "✅ Build complete"
echo ""

# Start services
echo "🚀 Starting services..."
docker compose up -d

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 10

# Check if services are running
if ! docker compose ps | grep -q "Up"; then
    echo "❌ Services failed to start"
    echo "   Check logs with: docker compose logs"
    exit 1
fi

echo "✅ Services are running"
echo ""

# Run database migrations
echo "🗄️  Running database migrations..."
docker compose exec -T app bin/rails db:migrate

echo ""
echo "✅ Database migrations complete"
echo ""

# Show status
echo "📊 Container Status:"
docker compose ps
echo ""

# Show important URLs
echo "🌐 Application URLs:"
echo "   - Local: http://localhost"
echo "   - Admin: http://localhost/admin"
echo "   - Health: http://localhost/up"
echo ""

echo "📚 Useful commands:"
echo "   - View logs: docker compose logs -f"
echo "   - Stop: docker compose down"
echo "   - Restart: docker compose restart"
echo "   - Console: docker compose exec app bin/rails console"
echo ""

echo "✅ Deployment complete! 🎉"
