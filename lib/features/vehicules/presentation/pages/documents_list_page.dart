import 'package:flutter/material.dart';
import 'package:gestion_driver/core/theme/app_colors.dart';
import 'package:gestion_driver/features/vehicules/models/vehicule.dart';
import 'package:gestion_driver/features/vehicules/models/vehicule_document_draft.dart';
import 'package:gestion_driver/features/vehicules/utils/document_utils.dart';

class DocumentsListPage extends StatefulWidget {
  final Vehicule vehicule;
  final List<VehiculeDocument> documents;
  final void Function(int index) onDocumentTap;
  final VoidCallback onAddTap;
  final VoidCallback? onDocumentsChanged;

  const DocumentsListPage({
    super.key,
    required this.vehicule,
    required this.documents,
    required this.onDocumentTap,
    required this.onAddTap,
    this.onDocumentsChanged,
  });

  @override
  State<DocumentsListPage> createState() => _DocumentsListPageState();
}

class _DocumentsListPageState extends State<DocumentsListPage> {
  DocumentStatusOption? _filtreActif;
  // late List<VehiculeDocument> docs;

  // @override
  // void initState() {
  //   super.initState();
  //   docs = widget.documents;
  // }

  // @override
  // void didUpdateWidget(DocumentsListPage oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (oldWidget.documents != widget.documents) {
  //     setState(() => docs = widget.documents);
  //   }
  // }

  List<VehiculeDocument> get _filtered {
    if (_filtreActif == null) return widget.documents;
    return widget.documents.where((d) => _statusOf(d) == _filtreActif).toList();
  }

  DocumentStatusOption _statusOf(VehiculeDocument doc) =>
      statusFromDate(doc.dateExpiration);

  List<VehiculeDocument> get _urgents => _filtered.where((d) {
    print('les documents qui on expirée');
    final s = _statusOf(d);
    return s == DocumentStatusOption.expire ||
        s == DocumentStatusOption.bientotExpire;
  }).toList();

  List<VehiculeDocument> get _autres => _filtered.where((d) {
    final s = _statusOf(d);
    return s != DocumentStatusOption.expire &&
        s != DocumentStatusOption.bientotExpire;
  }).toList();

  int _count(DocumentStatusOption s) =>
      widget.documents.where((d) => _statusOf(d) == s).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _buildAppBar(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildSummaryRow()),
          SliverToBoxAdapter(child: _buildFilterRow()),
          if (_urgents.isNotEmpty) ...[
            _buildSectionHeader('Attention requise'),
            _buildList(_urgents, urgent: true),
            if (_autres.isNotEmpty)
              const SliverToBoxAdapter(
                child: Divider(height: 1, indent: 16, endIndent: 16),
              ),
          ],
          if (_autres.isNotEmpty) ...[
            if (_filtreActif == null && _urgents.isNotEmpty)
              _buildSectionHeader('Autres documents'),
            _buildList(_autres),
          ],
          if (_filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.folder_open_outlined,
                      size: 48,
                      color: AppColors.secondary.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Aucun document dans cette catégorie',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onAddTap,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.primary,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          const Text(
            'Véhicules',
            style: TextStyle(color: AppColors.secondary, fontSize: 13),
          ),
          const Icon(Icons.chevron_right, color: AppColors.secondary, size: 16),
          Text(
            widget.vehicule.plaque,
            style: const TextStyle(color: AppColors.secondary, fontSize: 13),
          ),
          const Icon(Icons.chevron_right, color: AppColors.secondary, size: 16),
          const Text(
            'Documents',
            style: TextStyle(color: AppColors.primary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          _StatCard(
            count: _count(DocumentStatusOption.expire),
            label: 'Expiré',
            color: const Color(0xFFA32D2D),
            bgColor: const Color(0xFFFCEBEB),
            active: _filtreActif == DocumentStatusOption.expire,
            onTap: () => setState(
              () => _filtreActif = _filtreActif == DocumentStatusOption.expire
                  ? null
                  : DocumentStatusOption.expire,
            ),
          ),
          const SizedBox(width: 8),
          _StatCard(
            count: _count(DocumentStatusOption.bientotExpire),
            label: 'À renouveler',
            color: const Color(0xFF854F0B),
            bgColor: const Color(0xFFFAEEDA),
            active: _filtreActif == DocumentStatusOption.bientotExpire,
            onTap: () => setState(
              () => _filtreActif =
                  _filtreActif == DocumentStatusOption.bientotExpire
                  ? null
                  : DocumentStatusOption.bientotExpire,
            ),
          ),
          const SizedBox(width: 8),
          _StatCard(
            count: _count(DocumentStatusOption.valide),
            label: 'Valides',
            color: const Color(0xFF0F6E56),
            bgColor: const Color(0xFFE1F5EE),
            active: _filtreActif == DocumentStatusOption.valide,
            onTap: () => setState(
              () => _filtreActif = _filtreActif == DocumentStatusOption.valide
                  ? null
                  : DocumentStatusOption.valide,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final filtres = [
      (label: 'Tous', value: null),
      (label: 'Expirés', value: DocumentStatusOption.expire),
      (label: 'À renouveler', value: DocumentStatusOption.bientotExpire),
      (label: 'Valides', value: DocumentStatusOption.valide),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: filtres.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final f = filtres[i];
          final isActive = _filtreActif == f.value;
          return GestureDetector(
            onTap: () => setState(() => _filtreActif = f.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.secondary.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: Text(
                f.label,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.white : AppColors.secondary,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  SliverToBoxAdapter _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  SliverPadding _buildList(
    List<VehiculeDocument> items, {
    bool urgent = false,
  }) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final doc = items[index];
          final globalIndex = widget.documents.indexOf(doc);
          final statut = _statusOf(doc);
          final jours = _joursRestants(doc);

          final Color borderLeftColor = statut == DocumentStatusOption.expire
              ? const Color(0xFFA32D2D)
              : const Color(0xFF854F0B);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                if (globalIndex != -1) widget.onDocumentTap(globalIndex);
              },
              child: urgent
                  ? Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.black12,
                              width: 0.5,
                            ),
                          ),
                          child: _buildListTile(doc, statut, jours),
                        ),
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 4,
                            decoration: BoxDecoration(
                              color: borderLeftColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12, width: 0.5),
                      ),
                      child: _buildListTile(doc, statut, jours),
                    ),
            ),
          );
        }, childCount: items.length),
      ),
    );
  }

  Widget _buildListTile(
    VehiculeDocument doc,
    DocumentStatusOption statut,
    int? jours,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(doc.icon, size: 20, color: AppColors.primary),
      ),
      title: Text(
        doc.title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
      subtitle: Text(
        _buildMeta(doc, jours),
        style: const TextStyle(fontSize: 12, color: AppColors.secondary),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBadge(statut, jours),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.secondary),
        ],
      ),
    );
  }

  String _buildMeta(VehiculeDocument doc, int? jours) {
    final parts = <String>[];
    if (doc.subtitle.isNotEmpty && doc.subtitle != 'Ajout manuel') {
      parts.add(doc.subtitle);
    }
    if (doc.dateExpiration != null) {
      parts.add('Expire le ${_formatDate(doc.dateExpiration!)}');
    } else if (doc.extra.isNotEmpty) {
      parts.add('Expire le ${doc.extra}');
    }
    if (jours != null) {
      if (jours < 0) {
        parts.add('Expiré il y a ${jours.abs()} j');
      } else {
        parts.add('Expire dans $jours j');
      }
    }
    return parts.join(' · ');
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Widget _buildBadge(DocumentStatusOption statut, int? jours) {
    final (label, color, bg) = switch (statut) {
      DocumentStatusOption.expire => (
        'Expiré',
        const Color(0xFFA32D2D),
        const Color(0xFFFCEBEB),
      ),
      DocumentStatusOption.bientotExpire => (
        jours != null ? 'J-$jours' : 'Bientôt',
        const Color(0xFF854F0B),
        const Color(0xFFFAEEDA),
      ),
      DocumentStatusOption.valide => (
        'Valide',
        const Color(0xFF0F6E56),
        const Color(0xFFE1F5EE),
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  int? _joursRestants(VehiculeDocument doc) =>
      joursRestantsFromDate(doc.dateExpiration);
  //{
  //   if (extra.trim().isEmpty) return null;
  //   final parts = extra.trim().split('/');
  //   if (parts.length != 3) return null;
  //   final day = int.tryParse(parts[0]);
  //   final month = int.tryParse(parts[1]);
  //   final year = int.tryParse(parts[2]);
  //   if (day == null || month == null || year == null) return null;
  //   try {
  //     final expiry = DateTime(year, month, day);
  //     final now = DateTime.now();
  //     final e = DateTime(expiry.year, expiry.month, expiry.day);
  //     final n = DateTime(now.year, now.month, now.day);
  //     return e.difference(n).inDays;
  //   } catch (_) {
  //     return null;
  //   }
  // }
}

// ── Widgets internes ──────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.count,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.active,
    required this.onTap,
  });

  final int count;
  final String label;
  final Color color;
  final Color bgColor;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? bgColor : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? color.withValues(alpha: 0.4) : Colors.black12,
              width: active ? 1.5 : 0.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
