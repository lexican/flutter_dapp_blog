import 'package:dapp_blog/src/core/services/web3_service.dart';
import 'package:dapp_blog/src/core/utils/app_utils.dart';
import 'package:dapp_blog/src/widgets/blog_item/blog_item.dart';
import 'package:flutter/material.dart';

import '../../core/models/post.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Web3Service _web3service = Web3Service();
  final TextEditingController _titleTextEditingController =
      TextEditingController();
  final TextEditingController _descriptionTextEditingController =
      TextEditingController();
  final TextEditingController _postImageUrlTextEditingController =
      TextEditingController();
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _web3service.init();
    getPosts();
  }

  Future<void> getPosts() async {
    _posts.clear();
    List<dynamic> allPosts = await _web3service.getPosts();
    List<Post> postItems = [];

    for (int i = 0; i < allPosts[0].length; i++) {
      List<dynamic> postList = allPosts[0][i];

      Post post = Post(
        postId: postList[0],
        title: postList[1],
        description: postList[2],
        imageUrl: postList[3],
        author: postList[4],
        createdAt: postList[5],
        updatedAt: postList[6],
      );

      postItems.add(post);
    }
    setState(() {
      _posts = List.from(postItems.reversed);
    });
  }

  Future<void> createPost() async {
    String title = _titleTextEditingController.text;
    String desciption = _descriptionTextEditingController.text;
    String postImageUrl = _postImageUrlTextEditingController.text;

    if (title.isNotEmpty && desciption.isNotEmpty && postImageUrl.isNotEmpty) {
      showSnackBar(
        context,
        "Creating post",
        Colors.black,
      );
      bool addPost = await _web3service.createPost(
        title: title,
        description: desciption,
        imageUrl: postImageUrl,
      );

      if (addPost) {
        clearTextFields();
        Future.delayed(
          const Duration(
            seconds: 15,
          ),
          () async {
            await getPosts();
            // ignore: use_build_context_synchronously
            showSnackBar(
              context,
              "Post created successfully",
              Colors.green,
            );
          },
        );
        // ignore: use_build_context_synchronously
      }
    }
  }

  void clearTextFields() {
    _titleTextEditingController.clear();
    _descriptionTextEditingController.clear();
    _postImageUrlTextEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          "dApp Blog",
        ),
      ),
      body: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return BlogItem(
            post: _posts[index],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCreatePostModalBottomSheet();
        },
        tooltip: 'Create Post',
        child: const Icon(Icons.add),
      ),
    );
  }

  void showCreatePostModalBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Wrap(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        hintStyle: TextStyle(color: Colors.grey[800]),
                        hintText: "Title",
                        fillColor: Colors.white70,
                      ),
                      controller: _titleTextEditingController,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: TextField(
                      maxLines: 4,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        hintStyle: TextStyle(color: Colors.grey[800]),
                        hintText: "Description",
                        fillColor: Colors.white70,
                      ),
                      controller: _descriptionTextEditingController,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        hintStyle: TextStyle(color: Colors.grey[800]),
                        hintText: "Post image url",
                        fillColor: Colors.white70,
                      ),
                      controller: _postImageUrlTextEditingController,
                    ),
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                              ),
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                            ),
                            onPressed: () async {
                              await createPost();
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Post',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _titleTextEditingController.dispose();
    _descriptionTextEditingController.dispose();
    _postImageUrlTextEditingController.dispose();
  }
}
