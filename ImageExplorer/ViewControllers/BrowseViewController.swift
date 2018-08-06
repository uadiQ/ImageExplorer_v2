//
//  BrowseViewController.swift
//  ImageExplorer
//
//  Created by Vadim Shoshin on 14.06.2018.
//  Copyright © 2018 Vadim Shoshin. All rights reserved.
//

import UIKit
import PKHUD
import SwifterSwift

class BrowseViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var recentPosts: [Post] = []
    private var searchedCategory: String?
    private var paginationInfo: String = ""
    
    var isPaginating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addGestures()
        HUD.show(.progress, onView: tableView)
        fetchRecents()
        DataManager.instance.deletingDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        setObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        removeObservers()
    }
    
    //MARK: - Viewcontroller setup methods
    private func setupUI() {
        title = "Recent"
        setupSearchBar()
        setupNavigationBar()
        setupTableView()
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.tintColor = .black
        searchBar.shadowOpacity = 1
        searchBar.shadowColor = .clear
        searchBar.setBackgroundImage(UIImage(color: .cyan, size: CGSize(width: 1, height: 1)), for: .any, barMetrics: .default)
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.barTintColor = .cyan
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(color: .cyan, size: CGSize(width: 1, height: 1)), for: .default)
    }
    
    private func addGestures() {
        let upSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(hideKeyboardGestureRecognized))
        upSwipeGestureRecognizer.direction = .up
        
        let downSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(hideKeyboardGestureRecognized))
        downSwipeGestureRecognizer.direction = .down
        
        for recognizer in [upSwipeGestureRecognizer, downSwipeGestureRecognizer] {
            view.addGestureRecognizer(recognizer)
        }
    }
    
    private func setupTableView() {
        tableView.delaysContentTouches = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PostTableViewCell.nib, forCellReuseIdentifier: PostTableViewCell.reuseID)
        tableView.register(PaginateTableViewCell.nib, forCellReuseIdentifier: PaginateTableViewCell.reuseID)
        tableView.isUserInteractionEnabled = true
        tableView.keyboardDismissMode = .onDrag
    }
    
    private func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(processFailedRequest), name: .RequestFailed, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? DetailsViewController {
            destVC.post = sender as? Post
        } else if let destVC = segue.destination as? SearchResultsViewController, let sendedString = sender as? String {
            destVC.searchingCategory = sendedString
        } else {
            return
        }
    }
    
    //MARK: - App logic methods
    
    private func fetchRecents() {
        DataManager.instance.fetchRecentPhotos { [weak self] paginationString in
            self?.recentPosts = DataManager.instance.recents
            self?.paginationInfo = paginationString
            HUD.hide()
            self?.tableView.reloadData()
        }
    }
    
    @objc private func fetchNextPage() {
        isPaginating = true
        tableView.reloadSections(IndexSet(integer: 1), with: .bottom)
        let offset = tableView.contentOffset
        tableView.setContentOffset(offset, animated: false)
        guard let paginatingURL = URL(string: paginationInfo) else {
            print("Wrong pagination URL")
            return
        }
        
        DataManager.instance.paginateRecents(with: paginatingURL) { [weak self] paginationString in
            
            let difference = DataManager.instance.recents.count - (self?.recentPosts.count ?? 0)
            let startingIndex = IndexPath(row: self!.recentPosts.count - 1, section: 0)
            var indexes: [IndexPath] = []
            for i in 1...difference {
                let newIndexPath = IndexPath(row: startingIndex.row + i, section: 0)
                indexes.append(newIndexPath)
            }
            self?.recentPosts = DataManager.instance.recents
            
            self?.tableView.beginUpdates()
            self?.tableView.insertRows(at: indexes, with: UITableViewRowAnimation.none)
            self?.tableView.endUpdates()
            
            self?.paginationInfo = paginationString
            self?.isPaginating = false
            self?.tableView.reloadSections(IndexSet(integer: 1), with: .bottom)
            // scrolling to the next post
            self?.tableView.safeScrollToRow(at: IndexPath(row: indexes[0].row - 1, section: 0), at: UITableViewScrollPosition.top, animated: true)
        }
    }
    
}

// MARK: - Notification
extension BrowseViewController {
    
    @objc func processFailedRequest() {
        HUD.hide()
        showAlertWithOk(title: "Error", message: "New posts request failed")
    }
}

// MARK: - TableViewDelegate, TableViewDataSource
extension BrowseViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return recentPosts.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return ((tableView.frame.width - 30) / recentPosts[indexPath.row].ratio) + 80
        }
        else {
            return 44
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.section == 0 {
            guard let postCell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.reuseID, for: indexPath) as? PostTableViewCell else {
                fatalError("Cell with wrong id")
            }
            let postToPresent = recentPosts[indexPath.row]
            postCell.update(with: postToPresent)
            postCell.delegate = self
            postCell.favouriteAddingDelegate = self
            cell = postCell
        } else  {
            guard let paginationCell = tableView.dequeueReusableCell(withIdentifier: PaginateTableViewCell.reuseID, for: indexPath) as? PaginateTableViewCell else {
                fatalError("Cell with wrong id")
            }
            cell = paginationCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postToPresent = recentPosts[indexPath.row]
        performSegue(withIdentifier: Constants.Navigation.showDetails, sender: postToPresent)
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && !isPaginating && paginationInfo != "" {
            fetchNextPage()
        }
    }
}

// MARK: - Postsharing protocol
extension BrowseViewController: PostSharing {
    func share(urlToShare: URL) {
        let activityViewController = UIActivityViewController(activityItems: [urlToShare], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = tableView
        self.present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - FavouriteAddding protocol
extension BrowseViewController: FavouriteAdding {
    func processAddition(of post: Post) {
        HUD.flash(.labeledSuccess(title: "Post added to Favorites!", subtitle: nil))
        DataManager.instance.addToFavourites(post: post)
    }
}

// MARK: - SearchBar Delegate Methods
extension BrowseViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        guard let searchingText = searchBar.text, !searchingText.isEmpty else {
            showAlertWithOk(title: "Error", message: "Search field can't be empty")
            return
        }
        performSegue(withIdentifier: Constants.Navigation.showSearchResults, sender: searchingText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        view.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
}

// MARK: - Hide Keyboard Gestures

extension BrowseViewController {
    @objc func hideKeyboardGestureRecognized() {
        self.view.endEditing(true)
    }
}

// MARK: -
extension BrowseViewController: BrowseScreenRefreshing {
    func refreshCell(with postID: String) {
        var deletingIndex: Int?
        for (index, post) in recentPosts.enumerated() {
            if post.id == postID {
                deletingIndex = index
            }
        }
        if let indexToDelete = deletingIndex {
            let indexPath = IndexPath(row: indexToDelete, section: 0)
            tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
}
