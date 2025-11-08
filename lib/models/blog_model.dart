class BlogPostModel {
  final String id;
  final String title;
  final String slug;
  final String summary;
  final String? image;
  final String content;
  final String authorId;
  final String category;
  final String status;
  final List<String> tags;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  BlogPostModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.summary,
    this.image,
    required this.content,
    required this.authorId,
    required this.category,
    required this.status,
    required this.tags,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BlogPostModel.fromJson(Map<String, dynamic> json) {
    return BlogPostModel(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      summary: json['summary'] as String,
      image: json['image'] as String?,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      category: json['category'] as String,
      status: json['status'] as String? ?? 'draft',
      tags: List<String>.from(json['tags'] as List? ?? []),
      publishedAt: json['publishedAt'] != null 
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'summary': summary,
      'image': image,
      'content': content,
      'authorId': authorId,
      'category': category,
      'status': status,
      'tags': tags,
      'publishedAt': publishedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isPublished => status == 'published';
}

