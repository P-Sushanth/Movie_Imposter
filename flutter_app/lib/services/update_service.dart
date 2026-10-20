import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

const String kCurrentAppVersion = '1.1.2';
const String kGithubReleasesApiUrl =
    'https://api.github.com/repos/P-Sushanth/Movie_Imposter/releases/latest';

class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String? releaseNotes;

  const UpdateInfo({
    required this.version,
    required this.downloadUrl,
    this.releaseNotes,
  });
}

/// Compares two semver strings (e.g. "1.0.1" vs "1.0.0").
/// Returns true if [latest] is strictly newer than [current].
bool isVersionNewer(String latest, String current) {
  final cleanLatest = latest.replaceFirst(RegExp(r'^[vV]'), '').trim();
  final cleanCurrent = current.replaceFirst(RegExp(r'^[vV]'), '').trim();

  final latestParts = cleanLatest.split('.').map((p) => int.tryParse(p) ?? 0).toList();
  final currentParts = cleanCurrent.split('.').map((p) => int.tryParse(p) ?? 0).toList();

  final maxLen = latestParts.length > currentParts.length ? latestParts.length : currentParts.length;

  for (int i = 0; i < maxLen; i++) {
    final l = i < latestParts.length ? latestParts[i] : 0;
    final c = i < currentParts.length ? currentParts[i] : 0;
    if (l > c) return true;
    if (l < c) return false;
  }

  return false;
}

/// Parses GitHub release notes into a clean list of feature highlights.
List<String> parseReleaseFeatures(String? notes) {
  if (notes == null || notes.trim().isEmpty) {
    return const [
      'Performance enhancements and stability fixes',
      'Smoother game experience and UI refinements',
    ];
  }

  final lines = notes.split(RegExp(r'\r?\n'));
  final features = <String>[];

  for (final rawLine in lines) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;
    // Skip markdown headers (# Header, ## Subheader)
    if (line.startsWith('#')) continue;
    // Skip horizontal divider lines
    if (line.startsWith('---') || line.startsWith('***')) continue;

    // Remove leading bullet characters: -, *, +, •, or numbers like 1.
    var cleaned = line.replaceFirst(RegExp(r'^[-*+•\d\.)\s]+'), '').trim();

    // Remove markdown bold/italic tags
    cleaned = cleaned.replaceAll('**', '').replaceAll('__', '');

    if (cleaned.isNotEmpty) {
      features.add(cleaned);
    }
  }

  if (features.isEmpty) {
    return const [
      'New improvements and bug fixes',
    ];
  }

  return features;
}

class UpdateService {
  /// Notifier tracking the latest update info found, if any.
  static final ValueNotifier<UpdateInfo?> availableUpdateNotifier =
      ValueNotifier<UpdateInfo?>(null);

  /// Guard to prevent multiple update dialogs from stacking.
  static bool _isDialogShowing = false;

  /// Timestamp of the last check to prevent spamming GitHub API.
  static DateTime? _lastCheckTime;

  /// Silently checks GitHub for a newer release.
  /// Returns null if offline or no update is found.
  static Future<UpdateInfo?> checkForUpdate() async {
    HttpClient? client;
    try {
      client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);

      final request = await client.getUrl(Uri.parse(kGithubReleasesApiUrl));
      request.headers.set('User-Agent', 'MovieImposterApp');
      request.headers.set('Accept', 'application/vnd.github.v3+json');

      final response = await request.close().timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return null;

      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;

      final tagName = json['tag_name'] as String?;
      if (tagName == null) return null;

      if (!isVersionNewer(tagName, kCurrentAppVersion)) {
        availableUpdateNotifier.value = null;
        return null; // Already on latest or newer version
      }

      // Look for .apk asset in release
      String? downloadUrl;
      final assets = json['assets'] as List<dynamic>?;
      if (assets != null) {
        for (final asset in assets) {
          final name = (asset['name'] as String?)?.toLowerCase() ?? '';
          if (name.endsWith('.apk')) {
            downloadUrl = asset['browser_download_url'] as String?;
            break;
          }
        }
      }

      // Fallback to release page if no direct APK asset found
      downloadUrl ??= json['html_url'] as String?;
      if (downloadUrl == null) return null;

      final update = UpdateInfo(
        version: tagName,
        downloadUrl: downloadUrl,
        releaseNotes: json['body'] as String?,
      );

      availableUpdateNotifier.value = update;
      return update;
    } catch (_) {
      // Always fail silently to ensure completely offline-safe gameplay
      return null;
    } finally {
      client?.close();
    }
  }

  /// Checks and presents an update dialog if an update exists.
  static Future<void> checkAndShowUpdateDialog(
    BuildContext context, {
    bool showNoUpdateMessage = false,
  }) async {
    if (_isDialogShowing) return;

    final now = DateTime.now();
    if (!showNoUpdateMessage && _lastCheckTime != null) {
      if (now.difference(_lastCheckTime!) < const Duration(seconds: 30)) {
        if (availableUpdateNotifier.value != null && context.mounted) {
          showUpdateDialog(context, availableUpdateNotifier.value!);
        }
        return;
      }
    }
    _lastCheckTime = now;

    final update = await checkForUpdate();
    if (!context.mounted) return;

    if (update == null) {
      if (showNoUpdateMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are on the latest version!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    showUpdateDialog(context, update);
  }

  /// Explicitly presents the update dialog for an [UpdateInfo].
  static Future<void> showUpdateDialog(
    BuildContext context,
    UpdateInfo update,
  ) async {
    if (_isDialogShowing || !context.mounted) return;
    _isDialogShowing = true;

    try {
      await showDialog(
        context: context,
        builder: (ctx) => _UpdateAvailableDialog(update: update),
      );
    } finally {
      _isDialogShowing = false;
    }
  }
}

class _UpdateAvailableDialog extends StatelessWidget {
  final UpdateInfo update;

  const _UpdateAvailableDialog({required this.update});

  @override
  Widget build(BuildContext context) {
    final features = parseReleaseFeatures(update.releaseNotes);

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
      titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New Update Available!',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Text(
                        'v$kCurrentAppVersion  ➔  ${update.version}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Update now for these features:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 220),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: features.map((feat) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2, right: 8),
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 15,
                            color: AppColors.success,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            feat,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Later',
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dlCtx) => _UpdateDownloadDialog(update: update),
            );
          },
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text(
            'Update Now',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}

class _UpdateDownloadDialog extends StatefulWidget {
  final UpdateInfo update;

  const _UpdateDownloadDialog({required this.update});

  @override
  State<_UpdateDownloadDialog> createState() => _UpdateDownloadDialogState();
}

class _UpdateDownloadDialogState extends State<_UpdateDownloadDialog> {
  static const _channel = MethodChannel('com.imposterwho.game/updater');

  double _progress = 0.0;
  int _receivedBytes = 0;
  int _totalBytes = 0;
  String _status = 'Connecting...';
  bool _isDownloading = true;
  String? _errorMessage;
  HttpClient? _client;
  IOSink? _fileSink;
  File? _downloadFile;
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  @override
  void dispose() {
    _cancelled = true;
    _cleanup();
    super.dispose();
  }

  void _cleanup() {
    try {
      _fileSink?.close();
      _client?.close(force: true);
    } catch (_) {}
  }

  Future<void> _startDownload() async {
    try {
      String? cachePath;
      try {
        cachePath = await _channel.invokeMethod<String>('getAppCacheDir');
      } catch (_) {}

      final Directory saveDir = cachePath != null
          ? Directory(cachePath)
          : Directory.systemTemp;

      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }

      final file = File('${saveDir.path}/movie_imposter_update.apk');
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
      _downloadFile = file;

      _client = HttpClient();
      _client!.connectionTimeout = const Duration(seconds: 15);
      final request = await _client!.getUrl(Uri.parse(widget.update.downloadUrl));
      request.followRedirects = true;

      final response = await request.close();
      if (response.statusCode != 200) {
        throw Exception('Download server returned HTTP ${response.statusCode}');
      }

      _totalBytes = response.contentLength;
      _fileSink = file.openWrite();

      if (mounted) {
        setState(() {
          _status = 'Downloading update...';
        });
      }

      await for (final chunk in response) {
        if (_cancelled) return;
        _fileSink!.add(chunk);
        _receivedBytes += chunk.length;
        if (mounted) {
          setState(() {
            if (_totalBytes > 0) {
              _progress = (_receivedBytes / _totalBytes).clamp(0.0, 1.0);
            }
          });
        }
      }

      await _fileSink!.flush();
      await _fileSink!.close();
      _fileSink = null;

      if (_cancelled) return;

      if (mounted) {
        setState(() {
          _progress = 1.0;
          _status = 'Launching installer...';
          _isDownloading = false;
        });
      }

      await Future.delayed(const Duration(milliseconds: 300));

      try {
        await _channel.invokeMethod('installApk', {'filePath': file.path});
      } on MissingPluginException {
        // Fallback for older binary without installApk method
        await _channel.invokeMethod('launchUrl', {'url': widget.update.downloadUrl});
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (_cancelled) return;
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _status = 'Download failed';
        });
      }
    }
  }

  void _cancelDownload() {
    _cancelled = true;
    _cleanup();
    try {
      _downloadFile?.deleteSync();
    } catch (_) {}
    Navigator.of(context).pop();
  }

  Future<void> _fallbackBrowser() async {
    Navigator.of(context).pop();
    try {
      await _channel.invokeMethod('launchUrl', {'url': widget.update.downloadUrl});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final downloadedMb = (_receivedBytes / (1024 * 1024)).toStringAsFixed(1);
    final totalMb = _totalBytes > 0
        ? (_totalBytes / (1024 * 1024)).toStringAsFixed(1)
        : '?';

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            _errorMessage != null ? Icons.error_outline : Icons.downloading_rounded,
            color: _errorMessage != null ? AppColors.danger : AppColors.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage != null ? 'Update Failed' : 'Updating Movie Imposter',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Version ${widget.update.version}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress > 0 ? _progress : null,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: AlwaysStoppedAnimation<Color>(
                _errorMessage != null ? AppColors.danger : AppColors.primary,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _status,
                style: TextStyle(
                  fontSize: 13,
                  color: _errorMessage != null ? AppColors.danger : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_isDownloading && _totalBytes > 0)
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          if (_isDownloading && _totalBytes > 0) ...[
            const SizedBox(height: 4),
            Text(
              '$downloadedMb MB of $totalMb MB',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
      actions: [
        if (_errorMessage != null) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Dismiss', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: _fallbackBrowser,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Open in Browser'),
          ),
        ] else if (_isDownloading) ...[
          TextButton(
            onPressed: _cancelDownload,
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ],
    );
  }
}
