import UIKit
import Flutter
import GoogleMaps  // need this import

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // TODO: Add your Google Maps API key
    GMSServices.provideAPIKey("AIzaSyCkAe_gsj2tjp-VDFnlJCl2EFNNZdXg7D0")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}