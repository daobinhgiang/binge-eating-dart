import Flutter
import UIKit
import flutter_local_notifications
import FirebaseCore
import FamilyControls
import DeviceActivity
import ManagedSettings
import Combine
import SwiftUI

@available(iOS 15.0, *)
class FamilyActivitySelectionObserver: ObservableObject {
  @Published var selection = FamilyActivitySelection()
  
  var applicationTokens: Set<ApplicationToken> {
    return selection.applicationTokens
  }
}

@available(iOS 15.0, *)
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
@objc class AppDelegate: FlutterAppDelegate {
  private var selectionObserver: Any?
  private var subscriptions = Set<AnyCancellable>()
  
  override init() {
    super.init()
    if #available(iOS 15.0, *) {
      selectionObserver = FamilyActivitySelectionObserver()
    }
  }
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      // Initialize Firebase before any plugins
      FirebaseApp.configure()
      
      FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
      }

      if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
      }
      
    GeneratedPluginRegistrant.register(with: self)
    
    // Set up the Screen Time MethodChannel
    if let controller = window?.rootViewController as? FlutterViewController {
      let screenTimeChannel = FlutterMethodChannel(name: "com.bingeeating/screentime", binaryMessenger: controller.binaryMessenger)
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
  
  // MARK: - Screen Time Methods
  
  private func showFamilyActivityPicker(result: @escaping FlutterResult) {
    // Check if running on iOS 16 or later (required for requestAuthorization)
    if #available(iOS 16.0, *) {
      guard let observer = self.selectionObserver as? FamilyActivitySelectionObserver else {
        result(FlutterError(code: "INITIALIZATION_ERROR",
                          message: "Family Activity observer not initialized",
                          details: nil))
        return
      }
      
      // Request authorization
      let authorizationCenter = AuthorizationCenter.shared
      
      Task {
        do {
          try await authorizationCenter.requestAuthorization(for: .individual)
          
          // Set up observer for selection changes
          observer.$selection
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
              get: { observer.selection },
              set: { observer.selection = $0 }
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
                        message: "Screen Time API requires iOS 16 or later", 
                        details: nil))
    }
  }
  
  @available(iOS 15.0, *)
  private func setupAppRestrictions(for apps: Set<ApplicationToken>) {
    let store = ManagedSettingsStore()
    store.shield.applications = apps.isEmpty ? nil : apps
  }
  
  private func blockWebsites(websites: [String], result: @escaping FlutterResult) {
    if #available(iOS 16.0, *) {
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
                        message: "Screen Time API requires iOS 16 or later", 
                        details: nil))
    }
  }
}