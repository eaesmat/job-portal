import 'package:blog_app/features/blog/data/models/blog_model.dart';
import 'package:hive/hive.dart';

abstract interface class BlogLocaleDataSource {
  void uploadLocaleBlogs({required List<BlogModel> blogs});
  List<BlogModel> loadBlogs();
}

class BlogLocaleDataSourceImpl implements BlogLocaleDataSource {
  final Box box;
  BlogLocaleDataSourceImpl(this.box);
  @override
  List<BlogModel> loadBlogs() {
    List<BlogModel> blogs = [];
    box.read(() => {
          for (int i = 0; i < box.length; i++)
            {blogs.add(BlogModel.fromJson(box.get(i.toString())))}
        });

    return blogs;
  }

  @override
  void uploadLocaleBlogs({required List<BlogModel> blogs}) {
    box.clear();
    box.write(() {
      for (int i = 0; i < blogs.length; i++) {
        box.put(i.toString(), blogs[i].toJson());
      }
    });
  }
}
