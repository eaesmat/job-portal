import 'dart:io';

import 'package:blog_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_app/core/common/widget/loader.dart';
import 'package:blog_app/core/constants/constants.dart';
import 'package:blog_app/core/theme/app_palette.dart';
import 'package:blog_app/core/utils/pick_image.dart';
import 'package:blog_app/core/utils/show_snackbar.dart';
import 'package:blog_app/features/blog/presentaion/bloc/blog_bloc.dart';
import 'package:blog_app/features/blog/presentaion/pages/blog_page.dart';
import 'package:blog_app/features/blog/presentaion/widget/blog_editor.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddNewBlogPage extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const AddNewBlogPage());
  const AddNewBlogPage({super.key});

  @override
  State<AddNewBlogPage> createState() => _AddNewBlogPageState();
}

class _AddNewBlogPageState extends State<AddNewBlogPage> {
  final titleController = TextEditingController();
  final blogContextController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final List<String> selectedItems = [];
  File? image;

  void uploadBlog() {
    if (formKey.currentState!.validate() &&
        selectedItems.isNotEmpty &&
        image != null) {
      final posterId =
          (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;

      context.read<BlogBloc>().add(BlogUpload(
          title: titleController.text.trim(),
          posterId: posterId,
          content: blogContextController.text.trim(),
          image: image!,
          topics: selectedItems));
    }
  }

  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    blogContextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              uploadBlog();
            },
            icon: const Icon(Icons.done_rounded),
          ),
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            showSnackBar(context, state.message);
          } else if (state is BlogUploadSuccess) {
            Navigator.pushAndRemoveUntil(
                context, BlogPage.route(), (route) => false);
          }
        },
        builder: (context, state) {
          if (state is BlogLoading) {
            return const Loader();
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        selectImage();
                      },
                      child: image != null
                          ? SizedBox(
                              height: 150,
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  image!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : DottedBorder(
                              color: AppPalette.borderColor,
                              dashPattern: const [15, 4],
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(10),
                              strokeCap: StrokeCap.round,
                              child: const SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.folder_open,
                                      size: 45,
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      'Select Image here',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: Constants.topics
                            .map(
                              (e) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    if (selectedItems.contains(e)) {
                                      selectedItems.remove(e);
                                    } else {
                                      selectedItems.add(e);
                                    }

                                    setState(() {});
                                  },
                                  child: Chip(
                                    side: selectedItems.contains(e)
                                        ? null
                                        : const BorderSide(
                                            color: AppPalette.borderColor,
                                          ),
                                    label: Text(e),
                                    color: selectedItems.contains(e)
                                        ? const MaterialStatePropertyAll(
                                            AppPalette.gradient1)
                                        : null,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 5),
                    BlogEditor(
                        controller: titleController, labelText: 'Blog Title'),
                    const SizedBox(
                      height: 10,
                    ),
                    BlogEditor(
                        controller: blogContextController,
                        labelText: 'Blog Content'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
