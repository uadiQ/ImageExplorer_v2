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
    
    private var recentPosts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        DataManager.instance.fetchRecentPhotos()
        HUD.show(.progress, onView: view)
        title = "Explore"
        navigationController?.navigationBar.tintColor = .black
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
    
    private func setupTableView() {
        tableView.delaysContentTouches = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PostTableViewCell.nib, forCellReuseIdentifier: PostTableViewCell.reuseID)
        tableView.isUserInteractionEnabled = true
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
        guard let destVC = segue.destination as? DetailsViewController else { return }
        destVC.post = sender as? Post
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
        let alertMessage = UIAlertController(title: "Error", message: "New posts request failed", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertMessage.addAction(okAction)
        self.present(alertMessage, animated: true, completion: nil)
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
        let mealToPresent = recentPosts[indexPath.row]
        performSegue(withIdentifier: Constants.showDetails, sender: mealToPresent)
    }
}

extension BrowseViewController: PostSharing {
    func share(urlToShare: URL) {
        let activityViewController = UIActivityViewController(activityItems: [urlToShare], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = tableView
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension BrowseViewController: FavouriteAdding {
    func processAddition(of post: Post) {
        HUD.flash(.labeledSuccess(title: "Meal added to Favorites!", subtitle: nil))
        DataManager.instance.addToFavourites(post: post)
    }
}
