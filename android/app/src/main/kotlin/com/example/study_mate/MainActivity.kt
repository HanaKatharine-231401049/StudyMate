package com.example.study_mate   // <-- make sure this matches your project!

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "focus_dnd"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            try {
                val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

                when (call.method) {
                    "hasPermission" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            result.success(nm.isNotificationPolicyAccessGranted)
                        } else {
                            // DND API not supported on < 23
                            result.success(false)
                        }
                    }

                    "enableDnd" -> {
                        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
                            result.error(
                                "UNSUPPORTED",
                                "Do Not Disturb is not supported on this Android version",
                                null
                            )
                            return@setMethodCallHandler
                        }

                        if (!nm.isNotificationPolicyAccessGranted) {
                            // Open settings so user can grant permission
                            startActivity(
                                Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
                                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            )
                            result.error("NO_PERMISSION", "Permission required", null)
                        } else {
                            nm.setInterruptionFilter(
                                NotificationManager.INTERRUPTION_FILTER_NONE
                            )
                            result.success(true)
                        }
                    }

                    "disableDnd" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            nm.setInterruptionFilter(
                                NotificationManager.INTERRUPTION_FILTER_ALL
                            )
                            result.success(true)
                        } else {
                            // On old devices, just say "ok" but do nothing
                            result.success(true)
                        }
                    }

                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                e.printStackTrace()
                result.error("ERROR", e.message, null)
            }
        }
    }
}