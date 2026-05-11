import Flutter
import UIKit
import UserNotifications
import FirebaseCore
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    // FCM swizzles the APNs delegate methods automatically (see
    // FirebaseAppDelegateProxyEnabled in Info.plist — left at the default
    // value of YES). All we need to do here is:
    //   1. Become the UNUserNotificationCenter delegate so foreground
    //      banners surface (FlutterAppDelegate already conforms).
    //   2. Ask iOS for an APNs device token. firebase_messaging picks it
    //      up and exchanges it for the FCM token that Dart reads via
    //      FirebaseMessaging.getToken().
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
