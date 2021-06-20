//
//  ProfileViewController.swift
//  Navigation
//
//  Created by v.milchakova on 15.11.2020.
//  Copyright © 2020 Artem Novichkov. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class ProfileViewController: UIViewController {
    
    private let screenRect = UIScreen.main.bounds
    private lazy var screenWidth = screenRect.size.width
    private lazy var screenHeight = screenRect.size.height
    private var selectedPost: StoragePost!
    private var addedPostTitles = [String]()
    private var favorites: Bool = false
    private var titleText = ""
    private var tapped = false
    private let table = UITableView(frame: .zero, style: .grouped)
    private var coreDataManager: CoreDataStack!
    private var tableFavoritesPredicate: NSPredicate?
    
    private var reuseId: String {
        String(describing: PostTableViewCell.self)
    }
    
    private lazy var header = ProfileTableHederView()
    private lazy var photos = ProfilePhotoStackView()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        print(type(of: self), #function)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(withCoreData: Bool = false, title: String, manager: CoreDataStack) {
        super.init(nibName: nil, bundle: nil)
        titleText = title
        favorites = withCoreData
        coreDataManager = manager
        reloadTable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadTable()
    }
    
    func reloadTable() {
        print("Перезагружаем таблицу постов")
        Storage.favoritePosts = self.convertCoreDataPostsToStoragePost(posts: coreDataManager.fetchData(for: Post.self, predicate: favorites ? tableFavoritesPredicate : nil))
        table.reloadData()
    }
    
    func convertCoreDataPostsToStoragePost(posts: [Post]) -> [StoragePost] {
        var favoritePosts = [StoragePost]()
        for post in posts {
            guard let author = post.author, let title = post.title, let image = post.image, let data = UIImage(data: image) else {
                return favoritePosts
            }
            let pst = StoragePost(author: author, title: title, image: data,
                                  likes: post.likes, views: post.views)
            favoritePosts.append(pst)
        }
        return favoritePosts
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = titleText
        view.addSubview(table)
        table.addSubview(avatarButton)
        
        self.navigationController?.navigationBar.isHidden = true
        
        tableSetup()
        setupLayout()
        gestureRecognizerSetup()
        
        if favorites {
            let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
            
            view.addSubview(navBar)

            let navItem = UINavigationItem()
            let doneItem = UIBarButtonItem(title: "Find", style: .plain, target: nil, action: #selector(showFilterAlert))
            let photoItem = UIBarButtonItem(title: "Clear filter", style: .plain, target: nil, action: #selector(clearFilterButtonClicked))

            navItem.rightBarButtonItem = doneItem
            navItem.leftBarButtonItem = photoItem

            navBar.setItems([navItem], animated: false)
        }
    }
    
    @objc func showFilterAlert() {
        let ac = UIAlertController(title: "Enter author name", message: nil, preferredStyle: .alert)
        ac.addTextField()

        let submitAction = UIAlertAction(title: "OK", style: .default) { [self, unowned ac] _ in
            guard let field = ac.textFields else { return }
            let answer = field[0]
            guard let text = answer.text else { return }
            showAuthor(name: text)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    func showAuthor(name: String) {
        print("Показываем посты с определенным автором")
        tableFavoritesPredicate = NSPredicate(format: "author = %s", argumentArray: [name])
        reloadTable()
    }
    
    @objc func clearFilterButtonClicked() {
        print("Очищаем фильтр по автору")
        tableFavoritesPredicate = nil
        reloadTable()
    }
    
    func tableSetup() {
        table.toAutoLayout()
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 250
        table.register(PostTableViewCell.self, forCellReuseIdentifier: reuseId)
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .white
    }
    
    func setupLayout() {
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: view.topAnchor),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            avatarButton.heightAnchor.constraint(equalToConstant: 50),
            avatarButton.widthAnchor.constraint(equalToConstant: 50),
            avatarButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            avatarButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
    
    func gestureRecognizerSetup() {
        let tapAvatarGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapAvatar))
        header.avatarImage.addGestureRecognizer(tapAvatarGestureRecognizer)
        header.avatarImage.isUserInteractionEnabled = true
        
        let tapTableGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapTable))
        tapTableGestureRecognizer.numberOfTapsRequired = 2
        table.addGestureRecognizer(tapTableGestureRecognizer)
        table.isUserInteractionEnabled = true
    }
    
    @objc func tapTable() {
        print("Тапнули ячейку")
        
        guard let post = selectedPost else {
            print("Нет сохраненного поста")
            return
        }

        guard let pst = coreDataManager.create(from: Post.self, title: post.title) else {
            return
        }

        pst.author = post.author
        pst.title = post.title
        pst.image = post.image.pngData()
        pst.views = post.views
        pst.likes = post.likes
        
        coreDataManager.save()
        print("Пост \(post.author) добавлен в Избранное: favorites \(coreDataManager.fetchData(for: Post.self, predicate: favorites ? tableFavoritesPredicate : nil).count)")
    }
    
    @objc func tapAvatar() {
        table.addSubview(avatarView)
        table.addSubview(header.avatarImage)
        table.addSubview(avatarButton)
        
        UIView.animateKeyframes(withDuration: 0.8, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                self.avatarView.backgroundColor = .white
                self.avatarView.alpha = 0.5
            }

            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                self.header.avatarImage.translatesAutoresizingMaskIntoConstraints = true
                self.header.avatarImage.layer.borderWidth = 0
                self.header.avatarImage.clipsToBounds = false
                
                self.header.avatarImage.frame.size.width = self.screenWidth
                self.header.avatarImage.frame.size.height = self.screenHeight / 2
                self.header.avatarImage.center.x = self.screenWidth / 2
                self.header.avatarImage.center.y = self.screenHeight / 2
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.3) {
                self.avatarButton.alpha = 1
                self.avatarButton.isEnabled = true
                self.avatarButton.addTarget(self, action: #selector(self.avatarButtonPressed), for: .touchUpInside)
            }
        }) { (_) in
            self.table.isScrollEnabled = false
        }
    }
    
    @objc func avatarButtonPressed(sender: UIButton){
        print("Нажали на аватарку")
        view.layer.removeAllAnimations()
        
        UIView.animateKeyframes(withDuration: 0.8, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                self.avatarView.backgroundColor = .none
            }

            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                self.header.avatarImage.frame.size.width = 100
                self.header.avatarImage.frame.size.height = 100
                self.header.avatarImage.center.x = 66
                self.header.avatarImage.center.y = 66

                self.header.avatarImage.contentMode = .scaleAspectFill
                self.header.avatarImage.tintColor = .white
                self.header.avatarImage.layer.borderWidth = 3
                self.header.avatarImage.layer.cornerRadius = 50
                self.header.avatarImage.layer.borderColor = UIColor.white.cgColor
                self.header.avatarImage.clipsToBounds = true
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.3) {
                self.avatarButton.alpha = 0
                self.avatarButton.isEnabled = false
            }
        }) { (_) in

        self.header.avatarImage.toAutoLayout()

        NSLayoutConstraint.activate([
            self.header.avatarImage.topAnchor.constraint(equalTo: self.header.topAnchor, constant: 16),
            self.header.avatarImage.leadingAnchor.constraint(equalTo: self.header.leadingAnchor, constant: 16),
            self.header.avatarImage.widthAnchor.constraint(equalToConstant: 100),
            self.header.avatarImage.heightAnchor.constraint(equalToConstant: 100),
        ])}
        table.sendSubviewToBack(avatarView)
        table.isScrollEnabled = true
        header.addSubview(header.avatarImage)
    }
    
    public lazy var avatarView: UIView = {
        let view = UIView()
        view.toAutoLayout()
        view.backgroundColor = .none
        view.frame.size.width = screenWidth
        view.frame.size.height = screenHeight
        return view
    }()
    
    private lazy var avatarButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.backgroundColor = .none
        button.isEnabled = false
        button.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        button.alpha = 0
        return button
    }()
    
    private lazy var findAuthorButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.backgroundColor = .none
        button.isEnabled = false
        button.setTitle("Find", for: .normal)
        button.alpha = 0
        return button
    }()
    
    private lazy var clearFilterButton: UIButton = {
        let button = UIButton()
        button.toAutoLayout()
        button.backgroundColor = .none
        button.isEnabled = false
        button.setTitle("Clear filter", for: .normal)
        button.alpha = 0
        return button
    }()
}


@available(iOS 13.0, *)
extension ProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else {
            if favorites {
                let count = coreDataManager.fetchData(for: Post.self, predicate: favorites ? tableFavoritesPredicate : nil).count
                print("Количество постов в favorites: \(count)")
                return count
            } else {
                return Storage.posts.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PostTableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as! PostTableViewCell
        if favorites {
            let post = coreDataManager.fetchData(for: Post.self, predicate: favorites ? tableFavoritesPredicate : nil)[indexPath.row]
            cell.configureViaCoreData(post: post)
        } else {
            let post = Storage.posts[indexPath.row]
            cell.configureViaStorage(post: post)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 220 }
        if section == 1 { return 140 }
        return .zero
    }
}

@available(iOS 13.0, *)
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return header
        }
        if section == 1 {
            return photos
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if favorites {
            return UISwipeActionsConfiguration(actions: [
                makeDeleteContextualAction(forRowAt: indexPath)
            ])
        } else { return nil }
    }

    //MARK: - Contextual Actions
    private func makeDeleteContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        return UIContextualAction(style: .destructive, title: "Delete") { (action, swipeButtonView, completion) in
            print("Свайпнули удалить")
            let post = self.coreDataManager.fetchData(for: Post.self, predicate: self.favorites ? self.tableFavoritesPredicate : nil)[indexPath.row]

            self.coreDataManager.delete(object: post)
            print("Пост \(post.author ?? "Неизвестный") добавлен в Избранное: favorites \(self.coreDataManager.fetchData(for: Post.self, predicate: self.favorites ? self.tableFavoritesPredicate : nil).count)")
            completion(true)
            self.table.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PostTableViewCell
        
        guard let name = cell.nameLabel.text, let title = cell.descriptionLabel.text, let image = cell.postImage.image, let likes = cell.likesLabel.text, let views = cell.viewsLabel.text else {
            return
        }
        
        let post = StoragePost(author: name, title: title, image: image, likes: getInt(text: likes), views: getInt(text: views))
        selectedPost = post
    }
    
    private func getInt(text: String) -> Int64 {
        guard let number = Int64(text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) else {
            fatalError()
        }
        return number
    }
}
