//
//  AppDelegate.swift
//  MyFirstApp
//
//  Created by Takashi Nakano on 2020/04/21.
//  Copyright © 2020 Takashi Nakano. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    // バックグラウンド用
    var backgroundTaskID: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
    var oldBackgroundTaskID: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
    var timer: Timer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
            backgroundTaskID = application.beginBackgroundTask {
                [weak self] in
                application.endBackgroundTask((self?.backgroundTaskID)!)
                self?.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
            }

            timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { _ in
                self.oldBackgroundTaskID = self.backgroundTaskID

                // 新しいタスクを登録
                self.backgroundTaskID = application.beginBackgroundTask() { [weak self] in
                    application.endBackgroundTask((self?.backgroundTaskID)!)
                    self?.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
                }
                // 前のタスクを削除
                application.endBackgroundTask(self.oldBackgroundTaskID)
            })
        }

    // フォアグラウンドになった時の処理
    func applicationDidBecomeActive(_ application: UIApplication) {
        timer?.invalidate()
        application.endBackgroundTask(backgroundTaskID)
    }

}
