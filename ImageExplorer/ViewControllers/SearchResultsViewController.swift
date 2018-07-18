//
//  SearchResultsViewController.swift
//  ImageExplorer
//
//  Created by swstation on 7/18/18.
//  Copyright © 2018 Vadim Shoshin. All rights reserved.
//

import UIKit
import PKHUD

class SearchResultsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var searchingCategory: String!
    
    var searchResults: [Post] = []
    
    override func viewDidLoad() {
        HUD.show(.progress)
        super.viewDidLoad()
        title = searchingCategory
        setupTableView()
        loadSearchedPosts(for: searchingCategory)
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PostTableViewCell.nib, forCellReuseIdentifier: PostTableViewCell.reuseID)
    }
    
    func loadSearchedPosts(for category: String) {
        DataManager.instance.performSearch(for: searchingCategory) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let postsArray):
                    HUD.hide()
                    self.searchResults = postsArray
                    self.tableView.reloadData()
                case .fail:
                    print("Failed search for keyword \(self.searchingCategory)")
                    self.showAlertWithOk(title: "Error", message: "No posts for your request, try something else!")
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destVC = segue.destination as? DetailsViewController else {
            return
        }
        destVC.post = sender as? Post
    }
}

// MARK: - TableViewDelegate, TableViewDataSource
extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PostTableViewCell.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.reuseID, for: indexPath) as? PostTableViewCell else {
            fatalError("Cell with wrong ID")
        }
        
        let postToPresent = searchResults[indexPath.row]
        cell.update(with: postToPresent)
        cell.delegate = self
        cell.favouriteAddingDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postToPresent = searchResults[indexPath.row]
        performSegue(withIdentifier: Constants.Navigation.showDetails, sender: postToPresent)
    }
}

// MARK: - Postsharing protocol
extension SearchResultsViewController: PostSharing {
    func share(urlToShare: URL) {
        let activityViewController = UIActivityViewController(activityItems: [urlToShare], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = tableView
        self.present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - FavouriteAddding protocol
extension SearchResultsViewController: FavouriteAdding {
    func processAddition(of post: Post) {
        HUD.flash(.labeledSuccess(title: "Post added to Favorites!", subtitle: nil))
        DataManager.instance.addToFavourites(post: post)
    }
}
