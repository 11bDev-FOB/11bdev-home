# 11bDev API Documentation

Welcome to the 11bDev API! This REST API provides programmatic access to blog posts and projects.

## Base URL

```
Production: https://11b.dev/api
Development: http://localhost:3000/api
```

## Authentication

**Public endpoints** (read-only) do not require authentication:
- `GET /api/posts`
- `GET /api/posts/:id`
- `GET /api/projects`
- `GET /api/projects/:id`

**Protected endpoints** (write operations) require HTTP Basic Authentication:
- `POST /api/posts`
- `PUT/PATCH /api/posts/:id`
- `DELETE /api/posts/:id`
- `POST /api/projects`
- `PUT/PATCH /api/projects/:id`
- `DELETE /api/projects/:id`

### Authentication Example

```bash
# Using curl
curl -u admin:password https://11b.dev/api/posts \
  -H "Content-Type: application/json" \
  -d '{"post": {"title": "My Post", "content": "Content here"}}'

# Using Authorization header
curl https://11b.dev/api/posts \
  -H "Authorization: Basic $(echo -n 'admin:password' | base64)" \
  -H "Content-Type: application/json" \
  -d '{"post": {"title": "My Post"}}'
```

## Response Format

All responses are in JSON format.

### Success Response

```json
{
  "id": 1,
  "title": "Example Post",
  "created_at": "2025-10-16T12:00:00Z"
}
```

### Error Response

```json
{
  "error": "Post not found"
}
```

```json
{
  "errors": [
    "Title can't be blank",
    "Content is too short"
  ]
}
```

## HTTP Status Codes

- `200 OK` - Request succeeded
- `201 Created` - Resource created successfully
- `404 Not Found` - Resource not found
- `422 Unprocessable Entity` - Validation errors
- `401 Unauthorized` - Authentication required

---

## Posts API

### List Posts

Get all published blog posts.

**Endpoint:** `GET /api/posts`

**Authentication:** Not required

**Response:**

```json
[
  {
    "id": 1,
    "title": "Welcome to 11bDev",
    "author": "Tim",
    "slug": "welcome-to-11bdev",
    "published": true,
    "published_at": "2025-10-16T12:00:00.000Z",
    "created_at": "2025-10-16T10:00:00.000Z",
    "updated_at": "2025-10-16T11:00:00.000Z",
    "tag_list": ["welcome", "introduction"]
  }
]
```

**Example:**

```bash
curl https://11b.dev/api/posts
```

---

### Get Post

Get a single post by ID or slug.

**Endpoint:** `GET /api/posts/:id`

**Authentication:** Not required

**Parameters:**
- `id` (path) - Post ID or slug

**Response:**

```json
{
  "id": 1,
  "title": "Welcome to 11bDev",
  "author": "Tim",
  "slug": "welcome-to-11bdev",
  "content": "# Welcome\n\nThis is the content...",
  "published": true,
  "published_at": "2025-10-16T12:00:00.000Z",
  "created_at": "2025-10-16T10:00:00.000Z",
  "updated_at": "2025-10-16T11:00:00.000Z",
  "tag_list": ["welcome", "introduction"]
}
```

**Example:**

```bash
# By ID
curl https://11b.dev/api/posts/1

# By slug
curl https://11b.dev/api/posts/welcome-to-11bdev
```

---

### Create Post

Create a new blog post.

**Endpoint:** `POST /api/posts`

**Authentication:** Required (HTTP Basic Auth)

**Request Body:**

```json
{
  "post": {
    "title": "My New Post",
    "content": "# Hello\n\nThis is markdown content",
    "author": "Tim",
    "published": true,
    "published_at": "2025-10-16T12:00:00Z",
    "tag_list": "rails,ruby,coding"
  }
}
```

**Parameters:**
- `title` (required) - Post title
- `content` (required) - Markdown content
- `author` (optional) - Author name (defaults to "Tim")
- `published` (optional) - Published status (boolean, default: false)
- `published_at` (optional) - Published date/time (ISO 8601 format)
- `tag_list` (optional) - Comma-separated list of tags

**Response:** `201 Created`

```json
{
  "id": 2,
  "title": "My New Post",
  "author": "Tim",
  "slug": "my-new-post",
  "content": "# Hello\n\nThis is markdown content",
  "published": true,
  "published_at": "2025-10-16T12:00:00.000Z",
  "created_at": "2025-10-16T12:00:00.000Z",
  "updated_at": "2025-10-16T12:00:00.000Z",
  "tag_list": ["rails", "ruby", "coding"]
}
```

**Example:**

```bash
curl -u admin:password https://11b.dev/api/posts \
  -H "Content-Type: application/json" \
  -d '{
    "post": {
      "title": "My New Post",
      "content": "Hello world!",
      "published": true,
      "tag_list": "rails,ruby"
    }
  }'
```

---

### Update Post

Update an existing post.

**Endpoint:** `PATCH /api/posts/:id` or `PUT /api/posts/:id`

**Authentication:** Required (HTTP Basic Auth)

**Parameters:**
- `id` (path) - Post ID or slug

**Request Body:**

```json
{
  "post": {
    "title": "Updated Title",
    "content": "Updated content",
    "published": true,
    "tag_list": "updated,tags"
  }
}
```

**Response:** `200 OK`

```json
{
  "id": 1,
  "title": "Updated Title",
  "author": "Tim",
  "slug": "updated-title",
  "content": "Updated content",
  "published": true,
  "published_at": "2025-10-16T12:00:00.000Z",
  "created_at": "2025-10-16T10:00:00.000Z",
  "updated_at": "2025-10-16T13:00:00.000Z",
  "tag_list": ["updated", "tags"]
}
```

**Example:**

```bash
curl -u admin:password -X PATCH https://11b.dev/api/posts/1 \
  -H "Content-Type: application/json" \
  -d '{"post": {"title": "Updated Title"}}'
```

---

### Delete Post

Delete a post.

**Endpoint:** `DELETE /api/posts/:id`

**Authentication:** Required (HTTP Basic Auth)

**Parameters:**
- `id` (path) - Post ID or slug

**Response:** `200 OK`

```json
{
  "success": true
}
```

**Example:**

```bash
curl -u admin:password -X DELETE https://11b.dev/api/posts/1
```

---

## Projects API

### List Projects

Get all published projects.

**Endpoint:** `GET /api/projects`

**Authentication:** Not required

**Response:**

```json
[
  {
    "id": 1,
    "title": "FragOut",
    "slug": "fragout",
    "description": "Multi-platform social media scheduler",
    "tech_stack": "Rails, Hotwire, Tailwind",
    "project_url": "https://fragout.11b.dev",
    "published": true,
    "open_source": true,
    "featured": true,
    "created_at": "2025-10-16T10:00:00.000Z",
    "updated_at": "2025-10-16T11:00:00.000Z"
  }
]
```

**Example:**

```bash
curl https://11b.dev/api/projects
```

---

### Get Project

Get a single project by ID or slug.

**Endpoint:** `GET /api/projects/:id`

**Authentication:** Not required

**Parameters:**
- `id` (path) - Project ID or slug

**Response:**

```json
{
  "id": 1,
  "title": "FragOut",
  "slug": "fragout",
  "description": "Multi-platform social media scheduler",
  "tech_stack": "Rails, Hotwire, Tailwind",
  "project_url": "https://fragout.11b.dev",
  "published": true,
  "open_source": true,
  "featured": true,
  "created_at": "2025-10-16T10:00:00.000Z",
  "updated_at": "2025-10-16T11:00:00.000Z"
}
```

**Example:**

```bash
# By ID
curl https://11b.dev/api/projects/1

# By slug
curl https://11b.dev/api/projects/fragout
```

---

### Create Project

Create a new project.

**Endpoint:** `POST /api/projects`

**Authentication:** Required (HTTP Basic Auth)

**Request Body:**

```json
{
  "project": {
    "title": "New Project",
    "description": "Project description here",
    "tech_stack": "Rails, PostgreSQL",
    "project_url": "https://example.com",
    "published": true,
    "open_source": true,
    "featured": false
  }
}
```

**Parameters:**
- `title` (required) - Project title
- `description` (required) - Project description
- `tech_stack` (optional) - Technologies used
- `project_url` (optional) - Project URL
- `published` (optional) - Published status (boolean, default: false)
- `open_source` (optional) - Open source flag (boolean, default: false)
- `featured` (optional) - Featured flag (boolean, default: false)

**Response:** `201 Created`

```json
{
  "id": 2,
  "title": "New Project",
  "slug": "new-project",
  "description": "Project description here",
  "tech_stack": "Rails, PostgreSQL",
  "project_url": "https://example.com",
  "published": true,
  "open_source": true,
  "featured": false,
  "created_at": "2025-10-16T12:00:00.000Z",
  "updated_at": "2025-10-16T12:00:00.000Z"
}
```

**Example:**

```bash
curl -u admin:password https://11b.dev/api/projects \
  -H "Content-Type: application/json" \
  -d '{
    "project": {
      "title": "New Project",
      "description": "A cool project",
      "tech_stack": "Rails",
      "published": true
    }
  }'
```

---

### Update Project

Update an existing project.

**Endpoint:** `PATCH /api/projects/:id` or `PUT /api/projects/:id`

**Authentication:** Required (HTTP Basic Auth)

**Parameters:**
- `id` (path) - Project ID or slug

**Request Body:**

```json
{
  "project": {
    "title": "Updated Project",
    "description": "Updated description",
    "featured": true
  }
}
```

**Response:** `200 OK`

```json
{
  "id": 1,
  "title": "Updated Project",
  "slug": "updated-project",
  "description": "Updated description",
  "tech_stack": "Rails, PostgreSQL",
  "project_url": "https://example.com",
  "published": true,
  "open_source": true,
  "featured": true,
  "created_at": "2025-10-16T10:00:00.000Z",
  "updated_at": "2025-10-16T13:00:00.000Z"
}
```

**Example:**

```bash
curl -u admin:password -X PATCH https://11b.dev/api/projects/1 \
  -H "Content-Type: application/json" \
  -d '{"project": {"featured": true}}'
```

---

### Delete Project

Delete a project.

**Endpoint:** `DELETE /api/projects/:id`

**Authentication:** Required (HTTP Basic Auth)

**Parameters:**
- `id` (path) - Project ID or slug

**Response:** `200 OK`

```json
{
  "success": true
}
```

**Example:**

```bash
curl -u admin:password -X DELETE https://11b.dev/api/projects/1
```

---

## Code Examples

### Python

```python
import requests
from requests.auth import HTTPBasicAuth

# List posts
response = requests.get('https://11b.dev/api/posts')
posts = response.json()

# Create post (with auth)
auth = HTTPBasicAuth('admin', 'password')
data = {
    'post': {
        'title': 'New Post',
        'content': 'Content here',
        'published': True
    }
}
response = requests.post(
    'https://11b.dev/api/posts',
    json=data,
    auth=auth
)
print(response.json())
```

### Ruby

```ruby
require 'net/http'
require 'json'

# List posts
uri = URI('https://11b.dev/api/posts')
response = Net::HTTP.get(uri)
posts = JSON.parse(response)

# Create post (with auth)
uri = URI('https://11b.dev/api/posts')
request = Net::HTTP::Post.new(uri)
request.basic_auth('admin', 'password')
request['Content-Type'] = 'application/json'
request.body = {
  post: {
    title: 'New Post',
    content: 'Content here',
    published: true
  }
}.to_json

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(request)
end

puts JSON.parse(response.body)
```

### JavaScript (Node.js)

```javascript
// Using fetch with async/await
const base64Auth = Buffer.from('admin:password').toString('base64');

// List posts
async function getPosts() {
  const response = await fetch('https://11b.dev/api/posts');
  const posts = await response.json();
  return posts;
}

// Create post (with auth)
async function createPost() {
  const response = await fetch('https://11b.dev/api/posts', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Basic ${base64Auth}`
    },
    body: JSON.stringify({
      post: {
        title: 'New Post',
        content: 'Content here',
        published: true
      }
    })
  });
  const post = await response.json();
  return post;
}
```

### cURL Examples

```bash
# List all posts
curl https://11b.dev/api/posts

# Get specific post
curl https://11b.dev/api/posts/my-post-slug

# Create post
curl -u admin:password https://11b.dev/api/posts \
  -H "Content-Type: application/json" \
  -d '{"post": {"title": "New Post", "content": "Content", "published": true}}'

# Update post
curl -u admin:password -X PATCH https://11b.dev/api/posts/1 \
  -H "Content-Type: application/json" \
  -d '{"post": {"title": "Updated Title"}}'

# Delete post
curl -u admin:password -X DELETE https://11b.dev/api/posts/1

# List all projects
curl https://11b.dev/api/projects

# Create project
curl -u admin:password https://11b.dev/api/projects \
  -H "Content-Type: application/json" \
  -d '{"project": {"title": "New Project", "description": "Description"}}'
```

---

## Rate Limiting

Currently, there are no rate limits enforced. Please be respectful and avoid excessive requests.

## CORS

CORS is not currently enabled. If you need CORS support for browser-based applications, please contact us.

## Support

- Issues: https://github.com/11bDev/11bdev-home/issues
- Website: https://11b.dev
- Email: dev@11b.dev

## Changes & Versioning

This API is currently in v1. Breaking changes will be announced via the blog at https://11b.dev/blog.

---

**Built with ❤️ by 11bDev - Adapt and overcome, one API call at a time** 💣
