package cf.dysonsphere.mass_text_flutter

import android.content.*
import android.os.BatteryManager
import android.os.Build
import android.provider.Telephony
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "mySmsHandlerChannel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // Note: this method is invoked on the main thread.
            call, result ->

            if (call.method == "get_battery_level") {
                val batteryLevel = getBatteryLevel()
                if (batteryLevel != -1) result.success(batteryLevel)
                else result.error("UNAVAILABLE", "Battery level not available.", null)

            } else if (call.method == "make_default_handler") {
                makeDefaultHandler()
                result.success(null)
            }

            else if (call.method == "check_if_default_handler") {
                result.success(isDefaultHandler())
            }
            else {
                result.notImplemented()
            }
        }
    }

    private fun isDefaultHandler(): Boolean {
        return Telephony.Sms.getDefaultSmsPackage(this) == packageName
    }

    private fun makeDefaultHandler() {
        if (isDefaultHandler()) return
        val intent = Intent(Telephony.Sms.Intents.ACTION_CHANGE_DEFAULT)
        intent.putExtra(Telephony.Sms.Intents.EXTRA_PACKAGE_NAME,
                packageName)
        startActivity(intent)
    }

    private fun getBatteryLevel(): Int {
        val batteryLevel: Int
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }

        return batteryLevel
    }




}

class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {

    }
}

class MmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {

    }
}