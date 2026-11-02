import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let dashboard = DashboardViewController()
        let dashboardNavigation = UINavigationController(rootViewController: dashboard)
        dashboardNavigation.tabBarItem = UITabBarItem(
            title: "Overview",
            image: UIImage(systemName: "square.grid.2x2"),
            selectedImage: UIImage(systemName: "square.grid.2x2.fill")
        )
        dashboard.onBrowseDirectory = { [weak self] in
            self?.selectedIndex = 1
        }

        let directory = EmployeeDirectoryViewController()
        let directoryNavigation = UINavigationController(rootViewController: directory)
        directoryNavigation.tabBarItem = UITabBarItem(
            title: "People",
            image: UIImage(systemName: "person.2"),
            selectedImage: UIImage(systemName: "person.2.fill")
        )

        viewControllers = [dashboardNavigation, directoryNavigation]
        selectedIndex = 0
        tabBar.tintColor = .systemBlue
        tabBar.backgroundColor = .systemBackground
    }
}
