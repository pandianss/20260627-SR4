import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Add observers for screen capture/recording and screenshots
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenCaptureChanged),
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(userDidTakeScreenshot),
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil
    )
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  @objc private func screenCaptureChanged() {
    // Hide content or show a warning overlay when screen recording starts
    if UIScreen.main.isCaptured {
      let alert = UIAlertController(
        title: "Screen Recording Detected",
        message: "To protect proprietary material, content visibility is restricted during screen recording.",
        preferredStyle: .alert
      )
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
  }

  @objc private func userDidTakeScreenshot() {
    let alert = UIAlertController(
      title: "Screenshot Detected",
      message: "Please note that capturing screenshots of study materials is discouraged to protect intellectual property.",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    self.window?.rootViewController?.present(alert, animated: true, completion: nil)
  }
}
