# Flutter Admin App Development Prompt

## Project Overview

Create a cross-platform Flutter application (desktop and mobile) that provides an admin interface for managing the 11bDev blog and projects via the REST API. The app should replicate the web admin functionality with a clean, military-themed UI.

## Application Requirements

### Platform Support
- **Primary**: Desktop (Linux, Windows)
- **Secondary**: Mobile (Android)
- Single codebase with responsive layouts for all platforms

### Core Features
1. **Authentication**
   - HTTP Basic Auth login screen
   - Secure credential storage (flutter_secure_storage)
   - Remember credentials option
   - Auto-logout on 401 responses

2. **Posts Management**
   - List all posts (published and drafts)
   - Create new posts
   - Edit existing posts
   - Delete posts
   - Markdown editor with live preview
   - Tag management (comma-separated)
   - Published date picker
   - Publish/unpublish toggle
   - Search and filter posts

3. **Projects Management**
   - List all projects
   - Create new projects
   - Edit existing projects
   - Delete projects
   - Featured/Open Source toggles
   - Tech stack input
   - Project URL field
   - Search and filter projects

### Technical Stack

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HTTP & API
  http: ^1.1.0
  dio: ^5.4.0  # Alternative with better features
  
  # State Management
  provider: ^6.1.0  # or riverpod: ^2.4.0
  
  # Secure Storage
  flutter_secure_storage: ^9.0.0
  
  # Markdown
  flutter_markdown: ^0.6.18
  markdown: ^7.1.1
  
  # UI Components
  flutter_form_builder: ^9.1.1
  intl: ^0.18.1  # Date formatting
  
  # Utils
  logger: ^2.0.2
  url_launcher: ^6.2.1
```

## API Integration

### Base Configuration

```dart
class ApiConfig {
  static const String baseUrl = 'https://11b.dev/api';
  static const String devUrl = 'http://localhost:3000/api';
  
  // Use environment variables or secure storage
  static String get apiUrl => 
    const String.fromEnvironment('API_URL', defaultValue: devUrl);
}
```

### Authentication

```dart
class AuthService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  
  Future<void> saveCredentials(String username, String password) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }
  
  Future<Map<String, String>?> getCredentials() async {
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    
    if (username != null && password != null) {
      return {'username': username, 'password': password};
    }
    return null;
  }
  
  String getBasicAuthHeader(String username, String password) {
    final credentials = base64Encode(utf8.encode('$username:$password'));
    return 'Basic $credentials';
  }
  
  Future<void> logout() async {
    await _storage.deleteAll();
  }
}
```

### API Service Layer

```dart
class ApiService {
  final Dio _dio;
  final AuthService _authService;
  
  ApiService(this._authService) : _dio = Dio() {
    _dio.options.baseUrl = ApiConfig.apiUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
    
    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final creds = await _authService.getCredentials();
        if (creds != null) {
          options.headers['Authorization'] = 
            _authService.getBasicAuthHeader(
              creds['username']!, 
              creds['password']!
            );
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Handle unauthorized - logout user
          _authService.logout();
        }
        handler.next(error);
      },
    ));
  }
  
  // Posts API
  Future<List<Post>> getPosts() async {
    final response = await _dio.get('/posts');
    return (response.data as List)
      .map((json) => Post.fromJson(json))
      .toList();
  }
  
  Future<Post> getPost(String id) async {
    final response = await _dio.get('/posts/$id');
    return Post.fromJson(response.data);
  }
  
  Future<Post> createPost(Map<String, dynamic> data) async {
    final response = await _dio.post('/posts', data: {'post': data});
    return Post.fromJson(response.data);
  }
  
  Future<Post> updatePost(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/posts/$id', data: {'post': data});
    return Post.fromJson(response.data);
  }
  
  Future<void> deletePost(String id) async {
    await _dio.delete('/posts/$id');
  }
  
  // Projects API (similar pattern)
  Future<List<Project>> getProjects() async {
    final response = await _dio.get('/projects');
    return (response.data as List)
      .map((json) => Project.fromJson(json))
      .toList();
  }
  
  Future<Project> createProject(Map<String, dynamic> data) async {
    final response = await _dio.post('/projects', data: {'project': data});
    return Project.fromJson(response.data);
  }
  
  Future<Project> updateProject(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/projects/$id', data: {'project': data});
    return Project.fromJson(response.data);
  }
  
  Future<void> deleteProject(String id) async {
    await _dio.delete('/projects/$id');
  }
}
```

## Data Models

### Post Model

```dart
class Post {
  final int id;
  final String title;
  final String author;
  final String slug;
  final String content;
  final bool published;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tagList;
  
  Post({
    required this.id,
    required this.title,
    required this.author,
    required this.slug,
    required this.content,
    required this.published,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.tagList,
  });
  
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      slug: json['slug'],
      content: json['content'] ?? '',
      published: json['published'] ?? false,
      publishedAt: json['published_at'] != null 
        ? DateTime.parse(json['published_at']) 
        : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      tagList: List<String>.from(json['tag_list'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'content': content,
      'published': published,
      'published_at': publishedAt?.toIso8601String(),
      'tag_list': tagList.join(','),
    };
  }
}
```

### Project Model

```dart
class Project {
  final int id;
  final String title;
  final String slug;
  final String description;
  final String techStack;
  final String? projectUrl;
  final bool published;
  final bool openSource;
  final bool featured;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Project({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.techStack,
    this.projectUrl,
    required this.published,
    required this.openSource,
    required this.featured,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      description: json['description'],
      techStack: json['tech_stack'] ?? '',
      projectUrl: json['project_url'],
      published: json['published'] ?? false,
      openSource: json['open_source'] ?? false,
      featured: json['featured'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'tech_stack': techStack,
      'project_url': projectUrl,
      'published': published,
      'open_source': openSource,
      'featured': featured,
    };
  }
}
```

## UI Implementation

### Theme Configuration

```dart
class AppTheme {
  static const Color oliveGreen = Color(0xFF4B5E40);
  static const Color darkOlive = Color(0xFF3D4A43);
  static const Color tan = Color(0xFFD2B48C);
  static const Color vintageCream = Color(0xFFF5F5DC);
  static const Color lightTan = Color(0xFFE8DCC4);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: oliveGreen,
        secondary: tan,
        surface: vintageCream,
        background: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkOlive,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: oliveGreen,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
```

### Login Screen

```dart
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Card(
            margin: EdgeInsets.all(20),
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '11bDev Admin',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 32),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter username';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    CheckboxListTile(
                      title: Text('Remember me'),
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                          ? CircularProgressIndicator()
                          : Text('LOGIN'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authService = context.read<AuthService>();
      final apiService = context.read<ApiService>();
      
      if (_rememberMe) {
        await authService.saveCredentials(
          _usernameController.text,
          _passwordController.text,
        );
      }
      
      // Test authentication by fetching posts
      await apiService.getPosts();
      
      // Navigate to dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DashboardScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
```

### Dashboard Screen

```dart
class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    PostsListScreen(),
    ProjectsListScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('11bDev Admin'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.article_outlined),
                selectedIcon: Icon(Icons.article),
                label: Text('Posts'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.work_outline),
                selectedIcon: Icon(Icons.work),
                label: Text('Projects'),
              ),
            ],
          ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
  
  Future<void> _handleLogout() async {
    final authService = context.read<AuthService>();
    await authService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }
}
```

### Posts List Screen

```dart
class PostsListScreen extends StatefulWidget {
  @override
  _PostsListScreenState createState() => _PostsListScreenState();
}

class _PostsListScreenState extends State<PostsListScreen> {
  late Future<List<Post>> _postsFuture;
  
  @override
  void initState() {
    super.initState();
    _loadPosts();
  }
  
  void _loadPosts() {
    setState(() {
      _postsFuture = context.read<ApiService>().getPosts();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Blog Posts',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('New Post'),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostEditorScreen(),
                      ),
                    );
                    _loadPosts();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Post>>(
              future: _postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final posts = snapshot.data ?? [];
                
                if (posts.isEmpty) {
                  return Center(child: Text('No posts yet'));
                }
                
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return ListTile(
                      title: Text(post.title),
                      subtitle: Text(
                        'By ${post.author} • ${_formatDate(post.updatedAt)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (post.published)
                            Chip(
                              label: Text('Published'),
                              backgroundColor: Colors.green[100],
                            )
                          else
                            Chip(
                              label: Text('Draft'),
                              backgroundColor: Colors.orange[100],
                            ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PostEditorScreen(post: post),
                                ),
                              );
                              _loadPosts();
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _confirmDelete(post),
                          ),
                        ],
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostEditorScreen(post: post),
                          ),
                        );
                        _loadPosts();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  Future<void> _confirmDelete(Post post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Post'),
        content: Text('Are you sure you want to delete "${post.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('DELETE'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await context.read<ApiService>().deletePost(post.id.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post deleted')),
        );
        _loadPosts();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting post: $e')),
        );
      }
    }
  }
}
```

### Post Editor Screen

```dart
class PostEditorScreen extends StatefulWidget {
  final Post? post;
  
  PostEditorScreen({this.post});
  
  @override
  _PostEditorScreenState createState() => _PostEditorScreenState();
}

class _PostEditorScreenState extends State<PostEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  bool _published = false;
  DateTime? _publishedAt;
  bool _showPreview = false;
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _contentController = TextEditingController(text: widget.post?.content ?? '');
    _tagsController = TextEditingController(
      text: widget.post?.tagList.join(', ') ?? ''
    );
    _published = widget.post?.published ?? false;
    _publishedAt = widget.post?.publishedAt;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post == null ? 'New Post' : 'Edit Post'),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: Text('SAVE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        TextButton.icon(
                          icon: Icon(Icons.edit),
                          label: Text('Write'),
                          onPressed: () => setState(() => _showPreview = false),
                          style: TextButton.styleFrom(
                            backgroundColor: !_showPreview 
                              ? AppTheme.lightTan 
                              : null,
                          ),
                        ),
                        SizedBox(width: 8),
                        TextButton.icon(
                          icon: Icon(Icons.visibility),
                          label: Text('Preview'),
                          onPressed: () => setState(() => _showPreview = true),
                          style: TextButton.styleFrom(
                            backgroundColor: _showPreview 
                              ? AppTheme.lightTan 
                              : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    if (!_showPreview)
                      TextFormField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          labelText: 'Content (Markdown)',
                          border: OutlineInputBorder(),
                          hintText: '# Your content here...',
                        ),
                        maxLines: 20,
                        style: TextStyle(fontFamily: 'monospace'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter content';
                          }
                          return null;
                        },
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: EdgeInsets.all(16),
                        child: MarkdownBody(
                          data: _contentController.text,
                        ),
                      ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _tagsController,
                      decoration: InputDecoration(
                        labelText: 'Tags (comma-separated)',
                        border: OutlineInputBorder(),
                        hintText: 'rails, flutter, coding',
                      ),
                    ),
                    SizedBox(height: 16),
                    SwitchListTile(
                      title: Text('Published'),
                      value: _published,
                      onChanged: (value) => setState(() => _published = value),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      title: Text('Published Date'),
                      subtitle: Text(
                        _publishedAt != null 
                          ? _formatDateTime(_publishedAt!) 
                          : 'Not set'
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: _selectPublishedDate,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _selectPublishedDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _publishedAt ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_publishedAt ?? DateTime.now()),
      );
      
      if (time != null) {
        setState(() {
          _publishedAt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
           '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      final data = {
        'title': _titleController.text,
        'content': _contentController.text,
        'published': _published,
        'tag_list': _tagsController.text,
        if (_publishedAt != null)
          'published_at': _publishedAt!.toIso8601String(),
      };
      
      final apiService = context.read<ApiService>();
      
      if (widget.post == null) {
        await apiService.createPost(data);
      } else {
        await apiService.updatePost(widget.post!.id.toString(), data);
      }
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving post: $e')),
      );
    }
  }
}
```

## Project Structure

```
lib/
├── main.dart
├── config/
│   └── api_config.dart
├── models/
│   ├── post.dart
│   └── project.dart
├── services/
│   ├── auth_service.dart
│   └── api_service.dart
├── screens/
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── posts/
│   │   ├── posts_list_screen.dart
│   │   └── post_editor_screen.dart
│   └── projects/
│       ├── projects_list_screen.dart
│       └── project_editor_screen.dart
├── widgets/
│   └── markdown_editor.dart
└── theme/
    └── app_theme.dart
```

## Main Entry Point

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
        ProxyProvider<AuthService, ApiService>(
          update: (_, auth, __) => ApiService(auth),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '11bDev Admin',
      theme: AppTheme.lightTheme,
      home: FutureBuilder<Map<String, String>?>(
        future: context.read<AuthService>().getCredentials(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.data != null) {
            return DashboardScreen();
          }
          
          return LoginScreen();
        },
      ),
    );
  }
}
```

## Testing

Create integration tests for API interactions:

```dart
void main() {
  group('API Service Tests', () {
    test('Login and fetch posts', () async {
      final authService = AuthService();
      await authService.saveCredentials('admin', 'password');
      
      final apiService = ApiService(authService);
      final posts = await apiService.getPosts();
      
      expect(posts, isNotEmpty);
    });
    
    test('Create and delete post', () async {
      final authService = AuthService();
      final apiService = ApiService(authService);
      
      final post = await apiService.createPost({
        'title': 'Test Post',
        'content': 'Test content',
        'published': false,
      });
      
      expect(post.title, 'Test Post');
      
      await apiService.deletePost(post.id.toString());
    });
  });
}
```

## Deployment

### Desktop (Linux)

```bash
flutter build linux --release
```

### Desktop (macOS)

```bash
flutter build macos --release
```

### Desktop (Windows)

```bash
flutter build windows --release
```

### Mobile (Android)

```bash
flutter build apk --release
```

### Mobile (iOS)

```bash
flutter build ios --release
```

## Additional Features to Consider

1. **Offline Mode**: Cache posts/projects locally with SQLite
2. **Image Upload**: Support for featured images (would require multipart/form-data)
3. **Bulk Operations**: Select and delete multiple items
4. **Advanced Search**: Filter by tags, date range, published status
5. **Statistics Dashboard**: Show post counts, project counts, etc.
6. **Dark Mode**: Toggle between light and dark themes
7. **Keyboard Shortcuts**: For power users on desktop
8. **Auto-save**: Periodic saving of draft content

## Security Considerations

1. Store credentials securely using flutter_secure_storage
2. Clear credentials on logout
3. Handle 401 responses by forcing re-login
4. Validate SSL certificates (don't allow self-signed in production)
5. Don't log sensitive data
6. Use HTTPS only in production

## API Reference

See the full API documentation at:
`https://github.com/11bDev/11bdev-home/blob/main/API_DOCUMENTATION.md`

---

**Built with discipline, crafted with soul** 🎖️
