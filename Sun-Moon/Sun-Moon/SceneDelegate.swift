//
//  SceneDelegate.swift
//  Sun-Moon
//
//  Created by WizWI on 20.09.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // Главный метод: вызывается, когда сцена (окно) подключается к приложению
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Если вы используете Storyboard, Xcode автоматически найдет начальный экран.
        // Главное — убедиться, что тип сцены совпадает с UIWindowScene.
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}
