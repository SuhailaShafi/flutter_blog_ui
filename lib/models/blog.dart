class Blog {
  final String title;
  final String description;
  final String imageUrl;
  final String authorName;
  final String date;
  final String category;

  const Blog({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.authorName,
    required this.date,
    required this.category,
  });
}

const List<Blog> sampleBlogs = [
  Blog(
    title: 'Getting Started with Flutter in 2026',
    description:
        'Flutter has become one of the most popular cross-platform frameworks. In this post, we explore the latest features and best practices to kickstart your Flutter journey.',
    imageUrl: 'https://picsum.photos/seed/flutter/800/400',
    authorName: 'Alice Johnson',
    date: 'Apr 20, 2026',
    category: 'Tech',
  ),
  Blog(
    title: 'Mastering Clean Architecture in Dart',
    description:
        'Clean architecture separates concerns and makes your codebase maintainable. Learn how to apply it effectively in your Dart and Flutter projects.',
    imageUrl: 'https://picsum.photos/seed/dart/800/400',
    authorName: 'Bob Smith',
    date: 'Apr 18, 2026',
    category: 'Dev',
  ),
  Blog(
    title: 'Top 10 Lifestyle Habits for Developers',
    description:
        'Staying healthy as a developer is crucial. From ergonomic setups to mindful breaks, discover habits that boost productivity and well-being.',
    imageUrl: 'https://picsum.photos/seed/lifestyle/800/400',
    authorName: 'Clara Lee',
    date: 'Apr 15, 2026',
    category: 'Lifestyle',
  ),
  Blog(
    title: 'Designing Beautiful UIs with Material 3',
    description:
        'Material 3 brings expressive theming and dynamic color to your apps. This guide walks through the key components and how to use them in Flutter.',
    imageUrl: 'https://picsum.photos/seed/material/800/400',
    authorName: 'David Park',
    date: 'Apr 12, 2026',
    category: 'Design',
  ),
  Blog(
    title: 'State Management Showdown: Riverpod vs Bloc',
    description:
        'Choosing the right state management solution can make or break your app. We compare Riverpod and Bloc with real-world examples to help you decide.',
    imageUrl: 'https://picsum.photos/seed/state/800/400',
    authorName: 'Eva Martinez',
    date: 'Apr 10, 2026',
    category: 'Tech',
  ),
  Blog(
    title: 'Travel Diaries: Coding from Bali',
    description:
        'Remote work opens up the world. Follow along as I share my experience working as a developer from the beaches of Bali, including tips and lessons learned.',
    imageUrl: 'https://picsum.photos/seed/bali/800/400',
    authorName: 'Frank Chen',
    date: 'Apr 7, 2026',
    category: 'Travel',
  ),
];
