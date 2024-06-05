import UIKit
import Flutter
import GoogleMaps
import Firebase
import UserNotifications
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
    GeneratedPluginRegistrant.register(with: self)
    // TODO: Add your Google Maps API key
    GMSServices.provideAPIKey("AIzaSyCipXndU8JMDHKlBhHt380NMl1ilC-tB4o")
      
    // FCM Notification
    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate

    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]

    UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: {_, _ in }

    )

    // For iOS 10 display notification (sent via APNS)
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate

    // For iOS 10 data message (sent via FCM)
    Messaging.messaging().delegate = self as? MessagingDelegate

    } else {
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
    }
      
     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
