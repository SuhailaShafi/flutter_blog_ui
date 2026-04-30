class BlogModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? categoryId;
  final String authorId;
  final DateTime createdAt;

  // Joined fields (optional, populated via query)
  final String? categoryName;
  final String? authorName;

  const BlogModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.categoryId,
    required this.authorId,
    required this.createdAt,
    this.categoryName,
    this.authorName,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) => BlogModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        imageUrl: json['image_url'] as String?,
        categoryId: json['category_id'] as String?,
        authorId: json['author_id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        categoryName: json['categories']?['name'] as String?,
        authorName: json['profiles']?['username'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'category_id': categoryId,
        'author_id': authorId,
      };

  BlogModel copyWith({
    String? title,
    String? description,
    String? imageUrl,
    String? categoryId,
  }) =>
      BlogModel(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        categoryId: categoryId ?? this.categoryId,
        authorId: authorId,
        createdAt: createdAt,
        categoryName: categoryName,
        authorName: authorName,
      );
}
