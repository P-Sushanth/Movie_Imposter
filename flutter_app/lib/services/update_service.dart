import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

const String kCurrentAppVersion = '1.0.3';
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

class UpdateService {
  /// Silently checks GitHub for a newer release.
  /// Returns null if offline or no update is found.
  static Future<UpdateInfo?> checkForUpdate() async {
    HttpClient? client;
    try {
      client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 3);

      final request = await client.getUrl(Uri.parse(kGithubReleasesApiUrl));
      request.headers.set('User-Agent', 'MovieImposterApp');
      request.headers.set('Accept', 'application/vnd.github.v3+json');

      final response = await request.close().timeout(const Duration(seconds: 4));
      if (response.statusCode != 200) return null;

      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;

      final tagName = json['tag_name'] as String?;
      if (tagName == null) return null;

      if (!isVersionNewer(tagName, kCurrentAppVersion)) {
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

      return UpdateInfo(
        version: tagName,
        downloadUrl: downloadUrl,
        releaseNotes: json['body'] as String?,
      );
    } catch (_) {
      // Always fail silently to ensure completely offline-safe gameplay
      return null;
    } finally {
      client?.close();
    }
  }

  /// Checks and presents an update dialog if an update exists.
  static Future<void> checkAndShowUpdateDialog(BuildContext context) async {
    final update = await checkForUpdate();
    if (update == null || !context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.system_update_rounded, color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            Text(
              'Update Available!',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A new version (${update.version}) of Movie Imposter is available.',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            if (update.releaseNotes != null && update.releaseNotes!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Text(
                  update.releaseNotes!.trim(),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Later',
              style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                const channel = MethodChannel('com.imposterwho.game/updater');
                await channel.invokeMethod('launchUrl', {'url': update.downloadUrl});
              } catch (_) {}
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }
}
