import Flutter
import UIKit
import FirebaseMessaging
import Workmanager // 'W' को कैपिटल (बड़ा) होना अनिवार्य है!

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // 1. Flutter के सभी प्लगइन्स को रजिस्टर करें
    GeneratedPluginRegistrant.register(with: self)
    
    // 2. Workmanager के बैकग्राउंड टास्क को सही तरीके से रजिस्टर करें
    // ध्यान दें: जो ID आपने Info.plist में डाली है, वही यहाँ होनी चाहिए
    WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "com.fixsathi.fixsathi.backgroundTask")
    
    // 3. iOS 10+ के लिए पुश नोटिफिकेशन की परमिशन और डेलीगेट सेट करें
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }

    application.registerForRemoteNotifications()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}