
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)

        let splashVC = SplashViewController()

        splashVC.onFinish = { [weak self] in
            guard let self, let window = self.window else { return }

            let mainVC = MainTabBarController()

            UIView.transition(
                with: window,
                duration: 0.35,
                options: .transitionCrossDissolve,
                animations: {
                    window.rootViewController = mainVC
                }
            )
        }

        window.rootViewController = splashVC
        window.makeKeyAndVisible()

        self.window = window
    }
}
