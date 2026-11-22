package com.musnote.vocalNoteMonitor

import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.musnote.vocalNoteMonitor/downloads",
        ).setMethodCallHandler { call, result ->
            if (call.method != "save") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            if (Build.VERSION.SDK_INT < 29) {
                result.error("old", "Downloads needs Android 10", null)
                return@setMethodCallHandler
            }
            val path = call.argument<String>("path")
            val name = call.argument<String>("name")
            val mime = call.argument<String>("mime") ?: "application/octet-stream"
            if (path.isNullOrEmpty() || name.isNullOrEmpty()) {
                result.error("args", "path and name are required", null)
                return@setMethodCallHandler
            }
            try {
                val values = android.content.ContentValues().apply {
                    put(MediaStore.Downloads.DISPLAY_NAME, name)
                    put(MediaStore.Downloads.MIME_TYPE, mime)
                    put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
                    put(MediaStore.Downloads.IS_PENDING, 1)
                }
                val uri = contentResolver.insert(
                    MediaStore.Downloads.EXTERNAL_CONTENT_URI,
                    values,
                ) ?: throw IllegalStateException("insert failed")
                contentResolver.openOutputStream(uri).use { out ->
                    File(path).inputStream().use { input -> input.copyTo(out!!) }
                }
                values.clear()
                values.put(MediaStore.Downloads.IS_PENDING, 0)
                contentResolver.update(uri, values, null, null)
                val stored = contentResolver.query(
                    uri,
                    arrayOf(MediaStore.Downloads.DISPLAY_NAME),
                    null,
                    null,
                    null,
                )?.use { cursor ->
                    if (cursor.moveToFirst()) cursor.getString(0) else name
                } ?: name
                result.success(stored)
            } catch (error: Exception) {
                result.error("save", error.message, null)
            }
        }
    }
}
