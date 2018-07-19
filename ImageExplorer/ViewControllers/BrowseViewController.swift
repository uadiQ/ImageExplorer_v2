//
//  BrowseViewController.swift
//  ImageExplorer
//
//  Created by Vadim Shoshin on 14.06.2018.
//  Copyright © 2018 Vadim Shoshin. All rights reserved.
//

import UIKit
import PKHUD

class BrowseViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var recentPosts: [Post] = []
    private var searchedCategory: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        searchBar.delegate = self
        searchBar.tintColor = .black
        
        addGestures()
        DataManager.instance.fetchRecentPhotos()
        HUD.show(.progress, onView: view)
        title = "Recent"
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData() // To setup favourite button correctly every time, after favourite is deleted
        setObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        removeObservers()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.barTintColor = .cyan
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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
        tableView.isUserInteractionEnabled = true
        tableView.keyboardDismissMode = .onDrag
    }
    
    private func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(processFetchedRecents), name: .RecentsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(processLoadedImage), name: .ImageLoaded, object: nil)
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
    
}

// MARK: - Notification
extension BrowseViewController {
    @objc func processFetchedRecents() {
        recentPosts = DataManager.instance.recents
        HUD.hide()
        
        tableView.reloadData()
    }
    
    @objc func processLoadedImage() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @objc func processFailedRequest() {
        HUD.hide()
        showAlertWithOk(title: "Error", message: "New posts request failed")
    }
}

// MARK: - TableViewDelegate, TableViewDataSource
extension BrowseViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentPosts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PostTableViewCell.height
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.reuseID, for: indexPath) as? PostTableViewCell else {
            fatalError("Cell with wrong id")
        }
        let postToPresent = recentPosts[indexPath.row]
        cell.update(with: postToPresent)
        cell.delegate = self
        cell.favouriteAddingDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postToPresent = recentPosts[indexPath.row]
        performSegue(withIdentifier: Constants.Navigation.showDetails, sender: postToPresent)
        self.view.endEditing(true)
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
    
    
}

// MARK: - Hide Keyboard Gestures

extension BrowseViewController {
    @objc func hideKeyboardGestureRecognized() {
        self.view.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
    }
}
