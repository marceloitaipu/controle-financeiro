// lib/features/attachments/presentation/widgets/attachment_list_field.dart

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../pages/attachment_viewer_page.dart';

/// Widget que exibe e gerencia a lista de anexos de uma transação no formulário.
///
/// Gerencia dois tipos de item:
/// - [existingUrls]: URLs já salvas no Firebase Storage (modo edição)
/// - [pendingFiles]: Arquivos locais a serem enviados ao salvar
///
/// Callbacks:
/// - [onAddFiles]: chamado ao selecionar novos arquivos
/// - [onRemoveUrl]: chamado ao remover uma URL existente
/// - [onRemoveFile]: chamado ao remover um arquivo pendente
class AttachmentListField extends StatelessWidget {
  const AttachmentListField({
    super.key,
    required this.existingUrls,
    required this.pendingFiles,
    required this.onAddFiles,
    required this.onRemoveUrl,
    required this.onRemoveFile,
    this.enabled = true,
  });

  final List<String> existingUrls;
  final List<XFile> pendingFiles;
  final void Function(List<XFile> files) onAddFiles;
  final void Function(String url) onRemoveUrl;
  final void Function(XFile file) onRemoveFile;
  final bool enabled;

  static bool _isImage(String pathOrUrl) {
    final ext = pathOrUrl.toLowerCase().split('.').last.split('?').first;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = existingUrls.isNotEmpty || pendingFiles.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasItems)
          SizedBox(
            height: 84,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // URLs existentes
                for (final url in existingUrls)
                  _AttachmentThumbnail(
                    key: ValueKey(url),
                    label: _filenameFromUrl(url),
                    isImage: _isImage(url),
                    imageUrl: _isImage(url) ? url : null,
                    onTap: () => _openViewer(context, url),
                    onRemove: enabled ? () => onRemoveUrl(url) : null,
                  ),
                // Arquivos pendentes (ainda não enviados)
                for (final file in pendingFiles)
                  _AttachmentThumbnail(
                    key: ValueKey(file.path),
                    label: file.name,
                    isImage: _isImage(file.name),
                    localFile:
                        _isImage(file.name) ? File(file.path) : null,
                    onTap: () {
                      if (_isImage(file.name)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AttachmentViewerPage(
                              localFile: File(file.path),
                              fileName: file.name,
                            ),
                          ),
                        );
                      }
                    },
                    onRemove: enabled ? () => onRemoveFile(file) : null,
                    isPending: true,
                  ),
              ],
            ),
          ),
        if (enabled)
          Padding(
            padding: EdgeInsets.only(top: hasItems ? AppSpacing.sm : 0),
            child: OutlinedButton.icon(
              onPressed: () => _showPickerSheet(context),
              icon: const Icon(Icons.attach_file_rounded, size: 18),
              label: const Text('Adicionar comprovante'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _openViewer(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttachmentViewerPage(
          url: url,
          fileName: _filenameFromUrl(url),
        ),
      ),
    );
  }

  void _showPickerSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.sheetRadius,
      ),
      builder: (_) => _AttachmentPickerSheet(
        onPickFiles: (files) {
          Navigator.pop(context);
          if (files.isNotEmpty) onAddFiles(files);
        },
      ),
    );
  }

  /// Extrai nome legível de uma URL do Firebase Storage.
  static String _filenameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final raw = Uri.decodeComponent(segments.last);
        // Remove o prefixo de timestamp (ex: "1714000000000_nome.jpg")
        return raw.replaceFirst(RegExp(r'^\d+_'), '');
      }
    } catch (_) {}
    return 'anexo';
  }
}

// ── Thumbnail ─────────────────────────────────────────────────────────────────

class _AttachmentThumbnail extends StatelessWidget {
  const _AttachmentThumbnail({
    super.key,
    required this.label,
    required this.isImage,
    this.imageUrl,
    this.localFile,
    required this.onTap,
    this.onRemove,
    this.isPending = false,
  });

  final String label;
  final bool isImage;
  final String? imageUrl;
  final File? localFile;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Stack(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: AppRadius.cardRadius,
            child: Container(
              width: 72,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: AppRadius.cardRadius,
                border: Border.all(
                  color: isPending
                      ? colorScheme.primary.withValues(alpha: 0.5)
                      : colorScheme.outlineVariant,
                ),
              ),
              child: ClipRRect(
                borderRadius: AppRadius.cardRadius,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isImage && imageUrl != null)
                      Expanded(
                        child: CachedNetworkImage(
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (_, __) => const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.broken_image_outlined,
                            size: 28,
                          ),
                        ),
                      )
                    else if (isImage && localFile != null)
                      Expanded(
                        child: Image.file(
                          localFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image_outlined,
                            size: 28,
                          ),
                        ),
                      )
                    else
                      Icon(
                        _fileIcon(label),
                        size: 28,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    const SizedBox(height: AppSpacing.xs),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs),
                      child: Text(
                        label,
                        style: theme.textTheme.labelSmall,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Botão de remover
          if (onRemove != null)
            Positioned(
              top: 2,
              right: 2,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          // Badge "pendente"
          if (isPending)
            Positioned(
              bottom: 2,
              left: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'novo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _fileIcon(String name) {
    final ext = name.toLowerCase().split('.').last;
    return switch (ext) {
      'pdf' => Icons.picture_as_pdf_outlined,
      'doc' || 'docx' => Icons.description_outlined,
      'xls' || 'xlsx' => Icons.table_chart_outlined,
      _ => Icons.insert_drive_file_outlined,
    };
  }
}

// ── Picker sheet ──────────────────────────────────────────────────────────────

class _AttachmentPickerSheet extends StatelessWidget {
  const _AttachmentPickerSheet({required this.onPickFiles});

  final void Function(List<XFile> files) onPickFiles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.xl2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Adicionar comprovante',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _PickerOption(
              icon: Icons.photo_library_outlined,
              label: 'Galeria de fotos',
              onTap: () => _pickFromGallery(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            _PickerOption(
              icon: Icons.camera_alt_outlined,
              label: 'Câmera',
              onTap: () => _pickFromCamera(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            _PickerOption(
              icon: Icons.folder_outlined,
              label: 'Arquivos (PDF, DOC…)',
              onTap: () => _pickFile(context),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 85);
    onPickFiles(files);
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (file != null) onPickFiles([file]);
  }

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'png', 'jpg'],
    );
    if (result == null) return;
    final xFiles = result.files
        .where((f) => f.path != null)
        .map((f) => XFile(f.path!, name: f.name))
        .toList();
    onPickFiles(xFiles);
  }
}

class _PickerOption extends StatelessWidget {
  const _PickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.inputRadius,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: AppRadius.inputRadius,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.md),
            Text(label),
          ],
        ),
      ),
    );
  }
}
