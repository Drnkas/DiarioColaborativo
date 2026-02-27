import 'package:diario_colaborativo/core/theme/app_theme.dart';
import 'package:diario_colaborativo/features/home/pages/home/widgets/home_header_section.dart';
import 'package:diario_colaborativo/features/home/pages/home/widgets/home_post_card.dart';
import 'package:diario_colaborativo/features/home/pages/home/widgets/home_prompt_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.watch<AppTheme>();

    // Dados mockados apenas para compor o layout inicial,
    // depois podem ser substituídos por dados reais da API / Firestore.
    final mockPosts = <HomePostCardData>[
      HomePostCardData(
        authorName: 'Maria',
        category: 'Reflexão',
        timeAgo: '2h',
        content:
            'Hoje percebi como é importante celebrar as pequenas vitórias. '
            'Consegui acordar mais cedo e fazer uma caminhada. Às vezes são '
            'esses momentos simples que fazem toda a diferença no nosso dia. ✨',
        likes: 12,
        comments: 3,
      ),
      HomePostCardData(
        authorName: 'Ana',
        category: 'Momento',
        timeAgo: '4h',
        content:
            'Meu café da manhã especial de domingo 🌸 Tentei fazer panquecas '
            'em formato de coração e ficaram meio tortas, mas o sabor estava perfeito!',
        likes: 19,
        comments: 5,
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.kAppGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const HomeHeaderSection(),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const HomePromptCard();
                    }

                    final post = mockPosts[index - 1];
                    return HomePostCard(data: post);
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemCount: mockPosts.length + 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
