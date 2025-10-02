import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Load API key from GoogleMapsConfig.plist
    guard let path = Bundle.main.path(forResource: "GoogleMapsConfig", ofType: "plist"),
          let plist = NSDictionary(contentsOfFile: path),
          let apiKey = plist["GOOGLE_MAPS_API_KEY"] as? String else {
        fatalError("GoogleMapsConfig.plist not found or GOOGLE_MAPS_API_KEY not set")
    }
    GMSServices.provideAPIKey(apiKey)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
