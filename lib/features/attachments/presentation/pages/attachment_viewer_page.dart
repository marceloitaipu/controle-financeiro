// lib/features/attachments/presentation/pages/attachment_viewer_page.dart

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Tela de visualização de um único anexo.
///
/// Suporta:
/// - Imagens remotas (via [url]) → visualização em tela cheia com zoom
/// - Imagens locais (via [localFile]) → para pré-visualização antes do upload
/// - Outros formatos (PDF, DOC…) → exibe ícone e nome do arquivo
class AttachmentViewerPage extends StatelessWidget {
  const AttachmentViewerPage({
    super.key,
    this.url,
    this.localFile,
    this.fileName,
  }) : assert(
          url != null || localFile != null,
          'Forneça url ou localFile.',
        );

  /// URL de download do Firebase Storage (para arquivos já salvos).
  final String? url;

  /// Arquivo local (para pré-visualização antes do upload).
  final File? localFile;

  /// Nome do arquivo — exibido na AppBar.
  final String? fileName;

  static bool _isImage(String? name) {
    if (name == null) return false;
    final ext = name.toLowerCase().split('.').last.split('?').first;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  @override
  Widget build(BuildContext context) {
    final name = fileName ?? (url != null ? _nameFromUrl(url!) : 'anexo');
    final isImg = _isImage(name);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          name,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (url != null)
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded),
              tooltip: 'Abrir URL',
              onPressed: () => _showUrlDialog(context),
            ),
        ],
      ),
      body: isImg ? _buildImageViewer(context) : _buildFilePreview(context, name),
    );
  }

  Widget _buildImageViewer(BuildContext context) {
    Widget image;

    if (localFile != null) {
      image = Image.file(
        localFile!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildError(context),
      );
    } else {
      image = CachedNetworkImage(
        imageUrl: url!,
        fit: BoxFit.contain,
        placeholder: (_, __) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        errorWidget: (_, __, ___) => _buildError(context),
      );
    }

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 5.0,
      child: Center(child: image),
    );
  }

  Widget _buildFilePreview(BuildContext context, String name) {
    final ext = name.toLowerCase().split('.').last;
    final icon = switch (ext) {
      'pdf' => Icons.picture_as_pdf_rounded,
      'doc' || 'docx' => Icons.description_rounded,
      'xls' || 'xlsx' => Icons.table_chart_rounded,
      _ => Icons.insert_drive_file_rounded,
    };

    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: Colors.white70),
            const SizedBox(height: AppSpacing.lg),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Visualização não disponível para este formato.\nUse um app externo para abrir o arquivo.',
              style: TextStyle(color: Colors.white54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_outlined,
                size: 64, color: AppColors.danger),
            SizedBox(height: AppSpacing.md),
            Text(
              'Não foi possível carregar a imagem.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );

  void _showUrlDialog(BuildContext context) {
    if (url == null) return;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('URL do arquivo'),
        content: SelectableText(
          url!,
          style: const TextStyle(fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  static String _nameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final raw = Uri.decodeComponent(uri.pathSegments.last);
      return raw.replaceFirst(RegExp(r'^\d+_'), '');
    } catch (_) {
      return 'anexo';
    }
  }
}
