# 11b Dev Portfolio Site 🎸⚡

> **Military-grade code with hippie soul** - A Rails portfolio showcasing battle-tested development with creative flair.

![Rails Version](https://img.shields.io/badge/Rails-8.0.3-red.svg)
![Ruby Version](https://img.shields.io/badge/Ruby-3.4.6-red.svg)
![Tailwind CSS](https://img.shields.io/badge/TailwindCSS-4.1.13-blue.svg)

## 🚀 About

11b Dev combines military discipline with creative freedom. This portfolio site represents the intersection of structured engineering and artistic expression - like a Grateful Dead concert organized by Infantry NCOs.

### 🎨 Design Philosophy
- **Military Precision**: Clean, organized code structure
- **Hippie Soul**: Creative, flowing design with tie-dye gradients
- **Battle-tested**: Robust, reliable functionality
- **Accessible**: Works for everyone, everywhere

## ✨ Features

- **🎨 Military/Hippie Theme**: Custom olive & desert color palette with subtle tie-dye elements
- **📱 Fully Responsive**: Mobile-first design that works on all devices
- **📝 Blog System**: Markdown-powered blog with GFM support and tagging
- **⚡ Modern Stack**: Rails 8.0.3 with Hotwire, Tailwind CSS, and SQLite
- **🎯 Project Showcase**: Dynamic project gallery with featured items
- **� REST API**: Full-featured API for posts and projects (read-only public, write with auth)
- **🔒 Admin Panel**: Secure admin interface with HTTP Basic Authentication
- **🐳 Docker Ready**: Complete Docker setup with Caddy reverse proxy
- **💬 Contact**: Letterbird embedded form

## 🛠️ Tech Stack

- **Backend**: Ruby on Rails 8.0.3
- **Frontend**: Tailwind CSS 4.x, Hotwire (Turbo + Stimulus)
- **Database**: SQLite (development), PostgreSQL ready
- **Deployment**: Docker, Kamal, Railway/Heroku compatible
- **Testing**: Rails testing framework with system tests

## 🏃 Quick Start

```bash
# Clone the repository
git clone https://github.com/11bDev/11bdev-home.git
cd 11bdev-home

# Install dependencies
bundle install

# Setup database
rails db:create db:migrate db:seed

# Start the server
rails server
```

Visit `http://localhost:3000` to see the site in action!

## � API Access

The site includes a full REST API for programmatic access to posts and projects.

**Public endpoints** (no auth required):
- `GET /api/posts` - List all published posts
- `GET /api/posts/:id` - Get a single post
- `GET /api/projects` - List all published projects
- `GET /api/projects/:id` - Get a single project

**Protected endpoints** (HTTP Basic Auth required):
- `POST /api/posts` - Create a post
- `PATCH /api/posts/:id` - Update a post
- `DELETE /api/posts/:id` - Delete a post
- `POST /api/projects` - Create a project
- `PATCH /api/projects/:id` - Update a project
- `DELETE /api/projects/:id` - Delete a project

📚 **Full API documentation**: See [API_DOCUMENTATION.md](API_DOCUMENTATION.md)

## �📁 Project Structure

```
app/
├── controllers/
│   ├── admin/           # Admin panel controllers
│   ├── api/             # REST API controllers
│   └── pages_controller.rb
├── models/              # Data models (Post, Project)
├── views/               # HTML templates with ERB
└── assets/              # Stylesheets and images

config/
├── routes.rb            # URL routing
└── database.yml         # Database configuration
```

## 🎯 Projects Featured

- **Hayduke**: Clean indie blogging service (tribute to Edward Abbey)
- **Yall**: Multi-platform social media scheduler
- **Squared Away**: Military transition platform

## 🌟 Customization

The site uses CSS custom properties for easy theming:

```css
:root {
  --olive-green: #4B5E40;
  --desert-tan: #D2B48C;
  --tie-dye-purple: #8A4FFF;
  --tie-dye-orange: #FF6B35;
}
```

## 🚀 Deployment

### Docker (Recommended)

The easiest way to deploy is using Docker with Caddy:

```bash
# Quick deploy
./deploy.sh

# Or manually
docker compose up -d
docker compose exec app bin/rails db:migrate
```

See [DOCKER_DEPLOYMENT.md](DOCKER_DEPLOYMENT.md) for comprehensive Docker deployment guide.

### Railway
```bash
# Connect to Railway
railway login
railway init
railway up
```

### Kamal (included)
```bash
# Configure deploy.yml and deploy
kamal setup
kamal deploy
```

## 🐳 Docker Setup

The application includes a complete Docker setup with:
- **App Container**: Rails 8 application with SQLite
- **Caddy Container**: Reverse proxy with automatic SSL
- **Volumes**: Persistent storage for database, uploads, and logs
- **Health Checks**: Automatic monitoring and recovery

Quick start:
```bash
# 1. Configure environment
cp .env.example .env
nano .env  # Set RAILS_MASTER_KEY and credentials

# 2. Deploy
./deploy.sh

# 3. Access
open http://localhost
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/awesome-feature`)
3. Commit your changes (`git commit -m 'Add awesome feature'`)
4. Push to the branch (`git push origin feature/awesome-feature`)
5. Open a Pull Request

## 📜 License

This project is open source and available under the [MIT License](LICENSE).

## 🎸 The Story

Born from the fusion of military precision and countercultural creativity, 11b Dev represents the unique perspective of veterans in tech. We build applications with the same attention to detail learned in the Infantry, but with the creative freedom of a Dead show.

**"Code like your life depends on it, deploy like you're following the music."**

---

### 📞 Contact

- **Website**: [11b.dev](https://11b.dev)
- **GitHub**: [@11bDev](https://github.com/11bDev)
- **Email**: dev@11b.dev

*Built with ❤️ by veterans, for everyone*
