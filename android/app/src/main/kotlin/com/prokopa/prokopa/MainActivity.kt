package com.prokopa.prokopa

<<<<<<< HEAD
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
=======
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE,
        )
    }
}
>>>>>>> ae41a87e6beda91e9f6606e3b2f76b10d3024898
