// lib/features/onboarding/presentation/pages/onboarding_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';

/// Fluxo de onboarding em um [PageView] animado com 3 steps:
/// Step 0 → Boas-vindas
/// Step 1 → Perfil (nome + moeda)
/// Step 2 → Categorias padrão (preview)
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();

  int _currentPage = 0;
  String _selectedCurrency = 'BRL';

  static const _currencies = [
    (code: 'BRL', label: 'Real Brasileiro (R\$)'),
    (code: 'USD', label: 'Dólar Americano (\$)'),
    (code: 'EUR', label: 'Euro (€)'),
    (code: 'GBP', label: 'Libra Esterlina (£)'),
    (code: 'ARS', label: 'Peso Argentino (\$)'),
    (code: 'PYG', label: 'Guarani Paraguaio (₲)'),
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      _nameController.text = user.displayName!;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage = page);
  }

  Future<void> _handleNext() async {
    if (_currentPage == 1) {
      if (!_formKey.currentState!.validate()) return;
      FocusScope.of(context).unfocus();
      await ref.read(onboardingNotifierProvider.notifier).savePartialProgress(
            displayName: _nameController.text.trim(),
            preferredCurrency: _selectedCurrency,
          );
    }
    if (_currentPage < 2) {
      _goToPage(_currentPage + 1);
    } else {
      await _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    await ref.read(onboardingNotifierProvider.notifier).completeOnboarding(
          displayName: _nameController.text.trim(),
          preferredCurrency: _selectedCurrency,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(onboardingNotifierProvider, (prev, next) {
      next.whenOrNull(
        error: (e, _) => AppSnackBar.error(
          context,
          e is Failure ? e.message : 'Erro ao finalizar configuração.',
        ),
      );
    });

    final isLoading = ref.watch(onboardingNotifierProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _OnboardingProgressBar(
              currentPage: _currentPage,
              totalPages: 3,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const _WelcomePage(),
                  _ProfilePage(
                    formKey: _formKey,
                    nameController: _nameController,
                    nameFocusNode: _nameFocusNode,
                    selectedCurrency: _selectedCurrency,
                    currencies: _currencies,
                    onCurrencyChanged: (value) =>
                        setState(() => _selectedCurrency = value),
                  ),
                  const _CategoriesPreviewPage(),
                ],
              ),
            ),
            _OnboardingNavBar(
              currentPage: _currentPage,
              totalPages: 3,
              isLoading: isLoading,
              onBack:
                  _currentPage > 0 ? () => _goToPage(_currentPage - 1) : null,
              onNext: _handleNext,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 0: Boas-vindas ────────────────────────────────────────────────────

class _WelcomePage extends ConsumerWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final user = ref.watch(currentUserProvider);
    final firstName =
        user?.displayName?.split(' ').first ?? 'por aqui';

    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSpacing.vXl4,
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 52,
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
          AppSpacing.vXl3,
          Text(
            'Olá, $firstName! 👋',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vMd,
          Text(
            'Vamos configurar seu Controle Financeiro em poucos passos.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vXl3,
          const _FeatureRow(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Gerencie suas contas',
            subtitle: 'Corrente, poupança, carteira e muito mais.',
          ),
          AppSpacing.vLg,
          const _FeatureRow(
            icon: Icons.receipt_long_outlined,
            title: 'Controle seus gastos',
            subtitle: 'Lançamentos simples e rápidos no dia a dia.',
          ),
          AppSpacing.vLg,
          const _FeatureRow(
            icon: Icons.insights_outlined,
            title: 'Visualize seu progresso',
            subtitle:
                'Relatórios e gráficos para tomar melhores decisões.',
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 22, color: cs.onPrimaryContainer),
        ),
        AppSpacing.hMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              AppSpacing.vXs,
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Step 1: Perfil ─────────────────────────────────────────────────────────

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({
    required this.formKey,
    required this.nameController,
    required this.nameFocusNode,
    required this.selectedCurrency,
    required this.currencies,
    required this.onCurrencyChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final FocusNode nameFocusNode;
  final String selectedCurrency;
  final List<({String code, String label})> currencies;
  final void Function(String) onCurrencyChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSpacing.vXl3,
            Text(
              'Personalize seu perfil',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSm,
            Text(
              'Essas informações tornam sua experiência mais pessoal.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vXl3,
            AppTextField(
              label: 'Seu nome',
              controller: nameController,
              focusNode: nameFocusNode,
              prefixIcon: Icons.person_outline_rounded,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.name],
              validator: Validators.name,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            AppSpacing.vXl2,
            Text(
              'Moeda principal',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
            AppSpacing.vSm,
            ...currencies.map(
              (c) => _CurrencyOption(
                code: c.code,
                label: c.label,
                isSelected: selectedCurrency == c.code,
                onTap: () => onCurrencyChanged(c.code),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyOption extends StatelessWidget {
  const _CurrencyOption({
    required this.code,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String code;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? cs.primary : cs.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? cs.primaryContainer.withValues(alpha: 0.3)
                : cs.surfaceContainerLowest,
          ),
          child: Row(
            children: [
              Text(
                code,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? cs.primary : cs.onSurface,
                    ),
              ),
              AppSpacing.hMd,
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? cs.onPrimaryContainer
                            : cs.onSurfaceVariant,
                      ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: cs.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step 2: Preview de categorias ─────────────────────────────────────────

class _CategoriesPreviewPage extends StatelessWidget {
  const _CategoriesPreviewPage();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    const incomeNames = ['Salário', 'Freelance', 'Investimentos', 'Outros'];
    const expenseNames = [
      'Alimentação',
      'Transporte',
      'Moradia',
      'Saúde',
      'Educação',
      'Lazer',
      'Supermercado',
      'Assinaturas',
    ];

    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSpacing.vXl3,
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.category_rounded,
                size: 38,
                color: cs.onSecondaryContainer,
              ),
            ),
          ),
          AppSpacing.vXl2,
          Text(
            'Categorias prontas para usar',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vSm,
          Text(
            'Criaremos automaticamente '
            '${incomeNames.length + expenseNames.length} categorias padrão. '
            'Você pode personalizar depois.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.vXl2,
          const _CategoryGroupPreview(
            title: 'Receitas',
            color: Color(0xFF2E7D32),
            icon: Icons.trending_up_rounded,
            names: incomeNames,
          ),
          AppSpacing.vLg,
          const _CategoryGroupPreview(
            title: 'Despesas',
            color: Color(0xFFE53935),
            icon: Icons.trending_down_rounded,
            names: expenseNames,
          ),
          AppSpacing.vXl2,
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.primaryContainer),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: cs.primary, size: 20),
                AppSpacing.hMd,
                Expanded(
                  child: Text(
                    'Categorias podem ser editadas, adicionadas ou '
                    'removidas a qualquer momento.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onPrimaryContainer,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryGroupPreview extends StatelessWidget {
  const _CategoryGroupPreview({
    required this.title,
    required this.color,
    required this.icon,
    required this.names,
  });

  final String title;
  final Color color;
  final IconData icon;
  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            AppSpacing.hSm,
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        AppSpacing.vSm,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: names
              .map(
                (name) => Chip(
                  label: Text(name),
                  side: BorderSide(color: color.withValues(alpha: 0.3)),
                  backgroundColor: color.withValues(alpha: 0.08),
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ── Barra de progresso ─────────────────────────────────────────────────────

class _OnboardingProgressBar extends StatelessWidget {
  const _OnboardingProgressBar({
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = (currentPage + 1) / totalPages;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: cs.surfaceContainerHighest,
                color: cs.primary,
              ),
            ),
          ),
          AppSpacing.hMd,
          Text(
            '${currentPage + 1} / $totalPages',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Barra de navegação ─────────────────────────────────────────────────────

class _OnboardingNavBar extends StatelessWidget {
  const _OnboardingNavBar({
    required this.currentPage,
    required this.totalPages,
    required this.isLoading,
    required this.onNext,
    this.onBack,
  });

  final int currentPage;
  final int totalPages;
  final bool isLoading;
  final VoidCallback? onBack;
  final VoidCallback onNext;

  bool get _isLastPage => currentPage == totalPages - 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xl2,
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: isLoading ? null : onBack,
                child: const Text('Voltar'),
              ),
            ),
            AppSpacing.hMd,
          ],
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: isLoading ? null : onNext,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(_isLastPage ? 'Começar agora!' : 'Continuar'),
            ),
          ),
        ],
      ),
    );
  }
}
