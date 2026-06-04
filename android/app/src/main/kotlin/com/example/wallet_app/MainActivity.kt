package com.example.wallet_app

import android.database.Cursor
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "sms_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "getSMS") {
                result.success(getSMS())
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getSMS(): List<Map<String, Any>> {

        val smsList = mutableListOf<Map<String, Any>>()

        val uri = Uri.parse("content://sms/inbox")

        val cursor: Cursor? =
            contentResolver.query(uri, null, null, null, "date DESC")

        if (cursor != null) {

            val addressIndex = cursor.getColumnIndex("address")
            val bodyIndex = cursor.getColumnIndex("body")
            val dateIndex = cursor.getColumnIndex("date")

            while (cursor.moveToNext()) {

                val message = cursor.getString(bodyIndex)

                smsList.add(
                    mapOf(
                        "message" to message,
                        "address" to cursor.getString(addressIndex),
                        "date" to cursor.getLong(dateIndex)
                    )
                )
            }

            cursor.close()
        }

        return smsList
    }
}