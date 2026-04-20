import 'package:flutter/material.dart';

import '../core/cbt_learn/cbt_learn_content.dart';

class LearnCbtScreen extends StatefulWidget {
  const LearnCbtScreen({super.key});

  @override
  State<LearnCbtScreen> createState() => _LearnCbtScreenState();
}

class _LearnCbtScreenState extends State<LearnCbtScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = CbtLearnContent.articles.where((a) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return a.title.toLowerCase().contains(q) ||
          a.summary.toLowerCase().contains(q) ||
          a.categoryId.toLowerCase().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'CBT Concepts',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Understand your thoughts. Reduce emotional stress.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey.shade300),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value.trim()),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search topics...',
          ),
        ),
        const SizedBox(height: 16),
        ...CbtLearnContent.categories.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CategoryCard(
              category: c,
              onOpen: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CbtLearnCategoryScreen(category: c)),
                );
              },
            ),
          ),
        ),
        if (_query.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text('Search results', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ...filtered.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ArticleCard(
                article: a,
                onOpen: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CbtLearnArticleScreen(article: a)),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class CbtLearnCategoryScreen extends StatefulWidget {
  final CbtLearnCategory category;
  const CbtLearnCategoryScreen({super.key, required this.category});

  @override
  State<CbtLearnCategoryScreen> createState() => _CbtLearnCategoryScreenState();
}

class _CbtLearnCategoryScreenState extends State<CbtLearnCategoryScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final all = CbtLearnContent.byCategory(widget.category.id);
    final filtered = all.where((a) {
      if (_filter == 'All') return true;
      if (_filter == 'Beginner') return a.difficulty == 'Beginner';
      if (_filter == '3 min') return a.readMinutes <= 3;
      if (_filter == '5 min') return a.readMinutes >= 5;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.category.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.category.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey.shade300),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['All', 'Beginner', '3 min', '5 min'].map((f) {
              return ChoiceChip(
                label: Text(f),
                selected: _filter == f,
                onSelected: (_) => setState(() => _filter = f),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          ...filtered.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ArticleCard(
                article: a,
                onOpen: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CbtLearnArticleScreen(article: a)),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CbtLearnArticleScreen extends StatelessWidget {
  final CbtLearnArticle article;
  const CbtLearnArticleScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CBT Concepts')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            article.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '${article.readMinutes} min read ? ${article.difficulty}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blueGrey.shade300),
          ),
          const SizedBox(height: 14),
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF1A1A1A),
            ),
            alignment: Alignment.center,
            child: const Text('CBT', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 16),
          ...article.sections.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _SectionBlock(title: s.heading, body: s.body),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Practice this in Journal'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Save for later'),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CbtLearnCategory category;
  final VoidCallback onOpen;
  const _CategoryCard({required this.category, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1A1A1A),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    category.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blueGrey.shade300,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final CbtLearnArticle article;
  final VoidCallback onOpen;
  const _ArticleCard({required this.article, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: const Icon(Icons.menu_book_outlined),
        title: Text(article.title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${article.summary}\n${article.readMinutes} min ? ${article.difficulty}',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: TextButton(onPressed: onOpen, child: const Text('Open')),
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  final String title;
  final String body;
  const _SectionBlock({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1A1A1A),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
