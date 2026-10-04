//
//  AppDelegate.swift
//  Sun-Moon
//
//  Created by WizWI on 20.09.2026.
//

import UIKit

@main // Этот атрибут указывает Xcode, что файл является точкой входа в приложение
class AppDelegate: UIResponder, UIApplicationDelegate {

    // Вызывается при запуске приложения. Здесь настраиваются глобальные библиотеки.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle
    // Эти методы необходимы, если в проекте используется SceneDelegate (по умолчанию для iOS 13+)
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

