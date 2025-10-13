import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging
import AVFoundation
import FamilyControls
import DeviceActivity
import ManagedSettings
import Combine
import SwiftUI

class FamilyActivitySelectionObserver: ObservableObject {
  @Published var selection = FamilyActivitySelection()
  
  var applicationTokens: Set<ApplicationToken> {
    if #available(iOS 15.0, *) {
      return selection.applicationTokens
    }
    return []
  }
}

struct FamilyActivityPickerWrapper: View {
    @Environment(\.presentationMode) var presentationMode
    let selectionBinding: Binding<FamilyActivitySelection>

    var body: some View {
        NavigationView {
            FamilyActivityPicker(selection: selectionBinding)
                .navigationBarItems(trailing: Button("Save") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
    }
}

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
  private var selectionObserver = FamilyActivitySelectionObserver()
  private var subscriptions = Set<AnyCancellable>()
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Firebase
    FirebaseApp.configure()
    
    // Set messaging delegate
    Messaging.messaging().delegate = self
    
    // Set notification delegate
    UNUserNotificationCenter.current().delegate = self
    
    // Request authorization for notifications
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: { _, _ in }
    )
    
    // Register for remote notifications
    application.registerForRemoteNotifications()
    
    GeneratedPluginRegistrant.register(with: self)
    
    // Set up the audio MethodChannel
    if let controller = window?.rootViewController as? FlutterViewController {
      let audioChannel = FlutterMethodChannel(name: "com.yourcompany/audio", binaryMessenger: controller.binaryMessenger)
      audioChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
        guard let self = self else { return }
        switch call.method {
        case "switchToSpeaker":
          self.switchToSpeaker(result: result)
        case "switchToReceiver":
          self.switchToReceiver(result: result)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
      
      // Set up the Screen Time MethodChannel
      let screenTimeChannel = FlutterMethodChannel(name: "com.yourcompany/screentime", binaryMessenger: controller.binaryMessenger)
      screenTimeChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
        guard let self = self else { return }
        switch call.method {
        case "showFamilyActivityPicker":
          self.showFamilyActivityPicker(result: result)
        case "blockWebsites":
          if let arguments = call.arguments as? [String: Any],
             let websites = arguments["websites"] as? [String] {
            self.blockWebsites(websites: websites, result: result)
          } else {
            result(FlutterError(code: "INVALID_ARGUMENTS", 
                              message: "Expected websites array", 
                              details: nil))
          }
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - Firebase Messaging Methods

  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("Firebase registration token: \(String(describing: fcmToken))")
    
    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
  }

  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }
  
  // MARK: - Audio Routing Methods

  private func switchToSpeaker(result: @escaping FlutterResult) {
    let session = AVAudioSession.sharedInstance()
    do {
      // Remove the .defaultToSpeaker option and use .voiceChat mode for clearer routing
      try session.setCategory(.playAndRecord, mode: .voiceChat, options: [])
      try session.setActive(true)
      try session.overrideOutputAudioPort(.speaker)
      // Delay briefly to ensure the change is fully committed
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        result(true)
      }
    } catch {
      result(FlutterError(code: "AVAudioSessionError",
                          message: error.localizedDescription,
                          details: nil))
    }
  }
  
  private func switchToReceiver(result: @escaping FlutterResult) {
    let session = AVAudioSession.sharedInstance()
    do {
      // Set category back without forcing speaker, allowing default receiver routing
      try session.setCategory(.playAndRecord, mode: .default, options: [])
      try session.setActive(true)
      try session.overrideOutputAudioPort(.none)
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        result(true)
      }
    } catch {
      result(FlutterError(code: "AVAudioSessionError",
                          message: error.localizedDescription,
                          details: nil))
    }
  }
  
  // MARK: - Screen Time Methods
  
  private func showFamilyActivityPicker(result: @escaping FlutterResult) {
    // Check if running on iOS 15 or later
    if #available(iOS 15.0, *) {
      // Request authorization
      let authorizationCenter = AuthorizationCenter.shared
      
      Task {
        do {
          try await authorizationCenter.requestAuthorization(for: .individual)
          
          // Set up observer for selection changes
          self.selectionObserver.$selection
            .dropFirst() // Skip initial value
            .sink { [weak self] selection in
              guard let self = self else { return }
              self.setupAppRestrictions(for: selection.applicationTokens)
            }
            .store(in: &self.subscriptions)
          
          // Create and present the Family Activity picker
          DispatchQueue.main.async {
            // Create a SwiftUI view with the picker
            let binding = Binding<FamilyActivitySelection>(
              get: { self.selectionObserver.selection },
              set: { self.selectionObserver.selection = $0 }
            )
            
            let familyPickerView = FamilyActivityPickerWrapper(selectionBinding: binding)
            
            // Create a SwiftUI hosting controller
            let hostingController = UIHostingController(rootView: familyPickerView)
            
            if let controller = self.window?.rootViewController {
              // Present the hosting controller
              controller.present(hostingController, animated: true) {
                result(true)
              }
            } else {
              result(FlutterError(code: "NO_CONTROLLER", 
                                message: "Could not get root view controller", 
                                details: nil))
            }
          }
        } catch {
          result(FlutterError(code: "AUTHORIZATION_ERROR", 
                            message: error.localizedDescription, 
                            details: nil))
        }
      }
    } else {
      result(FlutterError(code: "UNSUPPORTED_VERSION", 
                        message: "Screen Time API requires iOS 15 or later", 
                        details: nil))
    }
  }
  
  private func setupAppRestrictions(for apps: Set<ApplicationToken>) {
    if #available(iOS 15.0, *) {
      let store = ManagedSettingsStore()
      store.shield.applications = apps.isEmpty ? nil : apps
    }
  }
  
  private func blockWebsites(websites: [String], result: @escaping FlutterResult) {
    if #available(iOS 15.0, *) {
      // Request authorization
      let authorizationCenter = AuthorizationCenter.shared
      
      Task {
        do {
          try await authorizationCenter.requestAuthorization(for: .individual)
          
          // Create the store for applying restrictions
          let store = ManagedSettingsStore()
          
          // Create WebDomain objects for the blocked websites
          let webDomains: Set<WebDomain> = Set(websites.map { WebDomain(domain: $0) })
          
          // Apply the restrictions using ManagedSettingsStore
          store.webContent.blockedByFilter = .specific(webDomains)
          
          DispatchQueue.main.async {
            result(true)
          }
        } catch {
          DispatchQueue.main.async {
            result(FlutterError(code: "AUTHORIZATION_ERROR", 
                              message: error.localizedDescription, 
                              details: nil))
          }
        }
      }
    } else {
      result(FlutterError(code: "UNSUPPORTED_VERSION", 
                        message: "Screen Time API requires iOS 15 or later", 
                        details: nil))
    }
  }
}
