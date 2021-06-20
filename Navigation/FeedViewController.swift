//
//  ViewController.swift
//  Navigation
//
//  Created by Artem Novichkov on 12.09.2020.
//  Copyright © 2020 Artem Novichkov. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
final class FeedViewController: UIViewController {
    var date = Date()
    var calendar = Calendar.current
    var hour = 0
    var minutes = 0
    var second = 0
    
    private lazy var postButton: UIButton = {
        let postButton = UIButton(type: .system)
        postButton.setTitle("Open post", for: .normal)
        postButton.setTitleColor(.white, for: .normal)
        postButton.addTarget(self, action: #selector(buttonPressed), for:.touchUpInside)
        postButton.toAutoLayout()
        return postButton
    }()
    
    @objc func buttonPressed() {
        let vc = PostViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        print(type(of: self), #function)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print(type(of: self), #function)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        date = Date()
        calendar = Calendar.current
        hour = calendar.component(.hour, from: date)
        minutes = calendar.component(.minute, from: date)
        second = calendar.component(.second, from: date)
        
        print("viewDidLoad: \(hour) \(minutes) \(second)")
        
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { (notification) in
            self.date = Date()
            self.calendar = Calendar.current
            self.hour = self.calendar.component(.hour, from: self.date)
            self.minutes = self.calendar.component(.minute, from: self.date)
            self.second = self.calendar.component(.second, from: self.date)
            print("Активирован бекграунд режим \(self.hour) \(self.minutes) \(self.second)")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        view.addSubview(postButton)
        view.backgroundColor = .blue
        print(type(of: self), #function)
        title = "Feed"
        
        NSLayoutConstraint.activate([
            postButton.heightAnchor.constraint(equalToConstant: 50),
            postButton.widthAnchor.constraint(equalToConstant: 100),
            postButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            postButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        date = Date()
        calendar = Calendar.current
        hour = calendar.component(.hour, from: date)
        minutes = calendar.component(.minute, from: date)
        second = calendar.component(.second, from: date)
        print("Приложение активировано \(hour) \(minutes) \(second)")
    }
}
