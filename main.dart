import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const LiyoApp());
}

class LiyoApp extends StatelessWidget {
  const LiyoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LIYO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LiyoHome(),
    );
  }
}

class LiyoHome extends StatefulWidget {
  const LiyoHome({super.key});

  @override
  State<LiyoHome> createState() => _LiyoHomeState();
}

class _LiyoHomeState extends State<LiyoHome> {
  int tab = 0;
  final posts = <Map<String, dynamic>>[
    {
      'name': 'LIYO User',
      'text': 'Welcome to LIYO! Share your video, photo, audio or idea.',
      'likes': 12,
      'comments': 3,
    },
  ];

  Future<void> createPost() async {
    final picker = ImagePicker();
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(leading: const Icon(Icons.edit), title: const Text('Idea / Text'), onTap: () => Navigator.pop(context, 'text')),
          ListTile(leading: const Icon(Icons.photo), title: const Text('Photo'), onTap: () => Navigator.pop(context, 'photo')),
          ListTile(leading: const Icon(Icons.videocam), title: const Text('Video'), onTap: () => Navigator.pop(context, 'video')),
        ]),
      ),
    );

    if (choice == 'text') {
      final controller = TextEditingController();
      final text = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Share an idea'),
          content: TextField(controller: controller, maxLines: 5, decoration: const InputDecoration(hintText: 'Write something...')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Post')),
          ],
        ),
      );
      if (text != null && text.isNotEmpty) {
        setState(() => posts.insert(0, {'name': 'You', 'text': text, 'likes': 0, 'comments': 0}));
      }
    } else if (choice == 'photo') {
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() => posts.insert(0, {'name': 'You', 'text': 'New photo shared on LIYO', 'image': file.path, 'likes': 0, 'comments': 0}));
      }
    } else if (choice == 'video') {
      final file = await picker.pickVideo(source: ImageSource.gallery);
      if (file != null) {
        setState(() => posts.insert(0, {'name': 'You', 'text': 'New video shared on LIYO', 'video': file.path, 'likes': 0, 'comments': 0}));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      Feed(posts: posts, onLike: (i) => setState(() => posts[i]['likes']++)),
      const Center(child: Text('Search\n\nFind people, videos and ideas', textAlign: TextAlign.center, style: TextStyle(fontSize: 20))),
      const Center(child: Text('Notifications', style: TextStyle(fontSize: 22))),
      const Center(child: Text('Profile\n\n@liyo_user', textAlign: TextAlign.center, style: TextStyle(fontSize: 22))),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('LIYO', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
        centerTitle: false,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
        ],
      ),
      body: pages[tab],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: createPost,
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.notifications_none), selectedIcon: Icon(Icons.notifications), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class Feed extends StatelessWidget {
  final List<Map<String, dynamic>> posts;
  final void Function(int) onLike;
  const Feed({super.key, required this.posts, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100, top: 8),
      itemCount: posts.length,
      itemBuilder: (_, i) {
        final p = posts[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 10),
                Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
              ]),
              const SizedBox(height: 10),
              Text(p['text'] ?? ''),
              if (p['image'] != null)
                Padding(padding: const EdgeInsets.only(top: 10), child: Image.file(File(p['image']), fit: BoxFit.cover)),
              if (p['video'] != null)
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  height: 180,
                  width: double.infinity,
                  color: Colors.black12,
                  child: const Center(child: Icon(Icons.play_circle_fill, size: 64)),
                ),
              const Divider(),
              Row(children: [
                IconButton(onPressed: () => onLike(i), icon: const Icon(Icons.favorite_border)),
                Text('${p['likes']}'),
                const SizedBox(width: 12),
                IconButton(onPressed: () {}, icon: const Icon(Icons.comment_outlined)),
                Text('${p['comments']}'),
                const Spacer(),
                IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
              ]),
            ]),
          ),
        );
      },
    );
  }
}

