import UIKit
import Flutter
import Firebase // Firebase के लिए
import workmanager // Workmanager के लिए

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Firebase को इनिशियलाइज़ करें (अगर आप Flutter कोड से नहीं कर रहे हैं)
    // FirebaseApp.configure() 
    
    GeneratedPluginRegistrant.register(with: self)
    
    // Workmanager टास्क रजिस्टर करें
    WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "com.fixsathi.fixsathi.backgroundTask")
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
