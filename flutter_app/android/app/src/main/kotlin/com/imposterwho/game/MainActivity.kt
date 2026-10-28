package com.imposterwho.game

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.imposterwho.game/updater"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAppVersion" -> {
                    try {
                        @Suppress("DEPRECATION")
                        val pInfo = context.packageManager.getPackageInfo(context.packageName, 0)
                        result.success(pInfo.versionName)
                    } catch (e: Exception) {
                        result.error("VERSION_ERROR", e.message, null)
                    }
                }
                "getAppCacheDir" -> {
                    try {
                        val cacheDir = context.cacheDir.absolutePath
                        result.success(cacheDir)
                    } catch (e: Exception) {
                        result.error("CACHE_ERROR", e.message, null)
                    }
                }
                "installApk" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath != null) {
                        try {
                            val file = File(filePath)
                            if (!file.exists()) {
                                result.error("FILE_NOT_FOUND", "APK file does not exist at $filePath", null)
                                return@setMethodCallHandler
                            }

                            val apkUri: Uri = FileProvider.getUriForFile(
                                this,
                                "${applicationContext.packageName}.fileprovider",
                                file
                            )

                            val intent = Intent(Intent.ACTION_VIEW).apply {
                                setDataAndType(apkUri, "application/vnd.android.package-archive")
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("INSTALL_ERROR", e.message, null)
                        }
                    } else {
                        result.error("INVALID_PATH", "filePath was null", null)
                    }
                }
                "launchUrl" -> {
                    val url = call.argument<String>("url")
                    if (url != null) {
                        try {
                            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("UNAVAILABLE", e.message, null)
                        }
                    } else {
                        result.error("INVALID_URL", "URL was null", null)
                    }
                }
                "vibrateAlert" -> {
                    try {
                        val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                            vibratorManager.defaultVibrator
                        } else {
                            @Suppress("DEPRECATION")
                            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                        }

                        if (vibrator.hasVibrator()) {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                // High-intensity repeating pulse pattern for times-up alert:
                                // 0ms delay, 500ms buzz, 150ms pause, 500ms buzz, 150ms pause, 800ms buzz
                                // Amplitude 255 = maximum hardware motor strength
                                val timings = longArrayOf(0, 500, 150, 500, 150, 800)
                                val amplitudes = intArrayOf(0, 255, 0, 255, 0, 255)
                                val effect = VibrationEffect.createWaveform(timings, amplitudes, -1)
                                vibrator.vibrate(effect)
                            } else {
                                @Suppress("DEPRECATION")
                                val pattern = longArrayOf(0, 500, 150, 500, 150, 800)
                                @Suppress("DEPRECATION")
                                vibrator.vibrate(pattern, -1)
                            }
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("VIBRATION_ERROR", e.message, null)
                    }
                }
                "cancelVibration" -> {
                    try {
                        val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                            vibratorManager.defaultVibrator
                        } else {
                            @Suppress("DEPRECATION")
                            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                        }
                        vibrator.cancel()
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
