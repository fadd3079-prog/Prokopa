package com.prokopa.prokopa

import android.os.Bundle
import android.view.WindowManager
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
        )
    }
}
