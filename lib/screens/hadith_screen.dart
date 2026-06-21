import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/hadith_service.dart';
import '../theme/app_theme.dart';

/// Écran Hadiths — Sahih Bukhari et Sahih Muslim, en français.
class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});
  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  String _collection = 'bukhari';
  int _book = 1;
  List<Map<String, dynamic>> _hadiths = [];
  bool _loading = true;
  String? _error;
  int _page = 0;
  static const _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list =
          await HadithService.fetchChapter(_book, collection: _collection);
      if (mounted)
        setState(() {
          _hadiths = list;
          _loading = false;
          _page = 0;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = '$e';
        });
    }
  }

  void _switchCollection(String collection) {
    setState(() {
      _collection = collection;
      _book = 1;
    });
    _load();
  }

  Future<void> _random() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final h = await HadithService.randomHadith(collection: _collection);
    if (!mounted) return;
    if (h == null) {
      setState(() {
        _loading = false;
        _error = 'Impossible de charger un hadith.';
      });
      return;
    }
    setState(() {
      _hadiths = [h];
      _loading = false;
      _page = 0;
    });
  }

  List<Map<String, dynamic>> get _paged {
    final start = _page * _pageSize;
    final end = (start + _pageSize).clamp(0, _hadiths.length);
    return _hadiths.sublist(start, end);
  }

  int get _totalPages => (_hadiths.length / _pageSize).ceil();

  @override
  Widget build(BuildContext context) {
    final totalBooks = HadithService.totalBooks(_collection);
    final label = HadithService.label(_collection);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadiths'),
        actions: [
          IconButton(
              icon: const Icon(Icons.shuffle_rounded),
              tooltip: 'Hadith aléatoire',
              onPressed: _random),
        ],
      ),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          color: AppTheme.surfaceVariant,
          child: Row(children: [
            Expanded(
                child: _CollectionTab(
                    label: 'Sahih Bukhari',
                    selected: _collection == 'bukhari',
                    onTap: () => _switchCollection('bukhari'))),
            const SizedBox(width: 8),
            Expanded(
                child: _CollectionTab(
                    label: 'Sahih Muslim',
                    selected: _collection == 'muslim',
                    onTap: () => _switchCollection('muslim'))),
          ]),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          color: AppTheme.surfaceVariant,
          child: Row(children: [
            const Icon(Icons.menu_book_rounded,
                color: AppTheme.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
                child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _book,
                isDense: true,
                items: List.generate(
                    totalBooks,
                    (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('$label — Livre ${i + 1}',
                            style: const TextStyle(fontSize: 13)))),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _book = v);
                  _load();
                },
              ),
            )),
          ]),
        ),
        Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary))
                : _error != null
                    ? _buildError()
                    : _hadiths.isEmpty
                        ? const Center(
                            child: Text('Aucun hadith pour ce livre.'))
                        : _buildList()),
        if (!_loading && _error == null && _totalPages > 1)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: AppTheme.surface,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  color: _page > 0 ? AppTheme.primary : AppTheme.border,
                  onPressed: _page > 0 ? () => setState(() => _page--) : null),
              Text('${_page + 1} / $_totalPages',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  color: _page < _totalPages - 1
                      ? AppTheme.primary
                      : AppTheme.border,
                  onPressed: _page < _totalPages - 1
                      ? () => setState(() => _page++)
                      : null),
            ]),
          ),
      ]),
    );
  }

  Widget _buildList() => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _paged.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _HadithCard(hadith: _paged[i]),
      );

  Widget _buildError() => Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.wifi_off_rounded,
            size: 48, color: AppTheme.textSecondary),
        const SizedBox(height: 16),
        const Text('Connexion requise',
            style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Réessayer'),
            onPressed: _load),
      ]));
}

class _CollectionTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CollectionTab(
      {required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: selected ? AppTheme.primary : AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: selected ? AppTheme.primary : AppTheme.border)),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: selected ? Colors.white : AppTheme.textSecondary))));
}

class _HadithCard extends StatelessWidget {
  final Map<String, dynamic> hadith;
  const _HadithCard({required this.hadith});

  @override
  Widget build(BuildContext context) {
    final text = hadith['text'] as String? ?? '';
    final number = hadith['number'];
    final book = hadith['book'];
    final collectionLabel =
        hadith['collectionLabel'] as String? ?? 'Sahih Bukhari';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: AppTheme.primarySurface,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('$collectionLabel — Livre $book  •  N°$number',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary))),
          GestureDetector(
              onTap: () async {
                await Clipboard.setData(ClipboardData(
                    text:
                        '$text\n\n[$collectionLabel, Livre $book, N°$number]'));
                if (context.mounted)
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Hadith copié'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating));
              },
              child: const Icon(Icons.copy_rounded,
                  size: 16, color: AppTheme.textSecondary)),
        ]),
        const SizedBox(height: 12),
        Text(text,
            style: const TextStyle(
                fontSize: 14, height: 1.7, color: AppTheme.textPrimary)),
      ]),
    );
  }
}
