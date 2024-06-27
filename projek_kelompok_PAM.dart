import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(PetPalsApp());
}

class PetPalsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetPals',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FlutterLogo(
              size: 64,
              style: FlutterLogoStyle.stacked,
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Email',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: TextField(
                controller: passController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Password',
                ),
                obscureText: true,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final email = 'user';
                    final password = '123';
                    if (emailController.text == email &&
                        passController.text == password) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Login Gagal'),
                        ),
                      );
                    }
                  },
                  child: Text('Login'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? postsString = prefs.getString('posts');
    if (postsString != null) {
      List<dynamic> postsJson = jsonDecode(postsString);
      setState(() {
        posts = postsJson.map((json) => Post.fromJson(json)).toList();
      });
    }
  }

  Future<void> _savePosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> postsJson = posts.map((post) => jsonEncode(post.toJson())).toList();
    prefs.setString('posts', jsonEncode(postsJson));
  }

  void _addPost(Post post) {
    setState(() {
      posts.add(post);
    });
    _savePosts();
  }

  void _editPost(Post post, int index) {
    setState(() {
      posts[index] = post;
    });
    _savePosts();
  }

  void _deletePost(int index) {
    setState(() {
      posts.removeAt(index);
    });
    _savePosts();
  }

  void _likePost(Post post) {
    setState(() {
      post.likes += 1;
    });
    _savePosts();
  }

  void _addComment(Post post, String comment) {
    setState(() {
      post.comments.add(comment);
    });
    _savePosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PetPals'),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostWidget(
            post: posts[index],
            onLike: () => _likePost(posts[index]),
            onAddComment: (comment) => _addComment(posts[index], comment),
            onEdit: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditPostPage(
                    post: posts[index],
                    onEditPost: (updatedPost) => _editPost(updatedPost, index),
                  ),
                ),
              );
            },
            onDelete: () => _deletePost(index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddPostPage(
                onAddPost: _addPost,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class Post {
  final String user;
  final String description;
  final String date;
  final String image;
  final String label;
  final List<String> comments;
  int likes;

  Post({
    required this.user,
    required this.description,
    required this.date,
    required this.image,
    required this.label,
    required this.comments,
    required this.likes,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      user: json['user'],
      description: json['description'],
      date: json['date'],
      image: json['image'],
      label: json['label'],
      comments: List<String>.from(json['comments']),
      likes: json['likes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user,
        'description': description,
        'date': date,
        'image': image,
        'label': label,
        'comments': comments,
        'likes': likes,
      };
}

class PostWidget extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final ValueChanged<String> onAddComment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  PostWidget({
    required this.post,
    required this.onLike,
    required this.onAddComment,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController commentController = TextEditingController();

    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(post.user),
            subtitle: Text(post.date),
            trailing: PopupMenuButton<String>(
              onSelected: (String result) {
                if (result == 'edit') {
                  onEdit();
                } else if (result == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ),
          Image.network(post.image),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(post.description),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up),
                  onPressed: onLike,
                ),
                Text('${post.likes} likes'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Comments:'),
          ),
          ...post.comments.map((comment) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(comment),
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: 'Add a comment',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    onAddComment(commentController.text);
                    commentController.clear();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddPostPage extends StatefulWidget {
  final ValueChanged<Post> onAddPost;

  AddPostPage({required this.onAddPost});

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();
  String _label = 'newpost';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _userController,
                decoration: InputDecoration(labelText: 'User'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a user name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageController,
                decoration: InputDecoration(labelText: 'Image URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _label,
                decoration: InputDecoration(labelText: 'Label'),
                items: ['newpost', 'dijual', 'tips perawatan']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _label = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newPost = Post(
                      user: _userController.text,
                      description: _descriptionController.text,
                      date: DateTime.now().toString().split(' ')[0],
                      image: _imageController.text,
                      label: _label,
                      comments: [],
                      likes: 0,
                    );
                    widget.onAddPost(newPost);
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Add Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditPostPage extends StatefulWidget {
  final Post post;
  final ValueChanged<Post> onEditPost;

  EditPostPage({required this.post, required this.onEditPost});

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _userController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageController;
  late String _label;

  @override
  void initState() {
    super.initState();
    _userController = TextEditingController(text: widget.post.user);
    _descriptionController = TextEditingController(text: widget.post.description);
    _imageController = TextEditingController(text: widget.post.image);
    _label = widget.post.label;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _userController,
                decoration: InputDecoration(labelText: 'User'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a user name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageController,
                decoration: InputDecoration(labelText: 'Image URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _label,
                decoration: InputDecoration(labelText: 'Label'),
                items: ['newpost', 'dijual', 'tips perawatan']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _label = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final updatedPost = Post(
                      user: _userController.text,
                      description: _descriptionController.text,
                      date: widget.post.date,
                      image: _imageController.text,
                      label: _label,
                      comments: widget.post.comments,
                      likes: widget.post.likes,
                    );
                    widget.onEditPost(updatedPost);
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Update Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}