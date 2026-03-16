// The MIT License (MIT)
//
// Copyright (c) 2020–2022 Alexander Grebenyuk (github.com/kean).

import UIKit
import SwiftUI
import Pulse
import PulseUI

@main
final class Pulse_Demo_iOSApp: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = PulseDemoSceneDelegate.self
        return configuration
    }
}

final class PulseDemoSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: MainView(store: .mock))
        window.makeKeyAndVisible()
        self.window = window
    }
}

var task: URLSessionDataTask?

private func testProxy() {
//    Experimental.URLSessionProxy.shared.isEnabled = true
    URLSessionProxyDelegate.enableAutomaticRegistration()

    let session = URLSession(configuration: .default, delegate: MockSessionDelegate(), delegateQueue: nil)

    let task = session.downloadTask(with: URLRequest(url: URL(string: "https://github.com/kean/Nuke/archive/refs/tags/11.0.0.zip")!))
//    task = session.dataTask(with: URL(string: "https://github.com/CreateAPI/Get")!)
    task.resume()
}

private final class MockSessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDownloadDelegate {
    var completion: ((URLSessionTask, Error?) -> Void)?

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        completion?(task, error)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("here")
    }
}
