//
//  MyTabBarController.swift
//  Navigation
//
//  Created by v.milchakova on 11.01.2021.
//  Copyright © 2021 Artem Novichkov. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class MyTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private let coreDataManager = CoreDataStack(modelName: "PostModel")
    
    private lazy var updateLabel: UILabel = {
        let label = UILabel()
        label.toAutoLayout()
        label.textColor = .darkGray
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        view.addSubview(updateLabel)
        setupLayout()
        view.backgroundColor = .systemGray5
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            tabBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            tabBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            updateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            updateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let item1 = FeedViewController()
        let item2 = ProfileViewController(title: "Profile", manager: coreDataManager)
        let item3 = UINavigationController(rootViewController: ProfileViewController(withCoreData: true, title: "Favorites", manager: coreDataManager))
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemBlue], for: .selected)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .normal)

        let controllers = [item1, item2, item3]
        self.viewControllers = controllers
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("Выбранная вкладка: \(viewController.title ?? "")")
        return true;
    }
    
    private var time: Date?

    private lazy var dateFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateStyle = .short
      formatter.timeStyle = .long
      return formatter
    }()

    func fetch(_ completion: () -> Void) {
      time = Date()
      completion()
    }

    func updateUI() {

      if let time = time {
        updateLabel.text = dateFormatter.string(from: time)
      } else {
        updateLabel.text = "Not yet updated"
      }
    }
}
