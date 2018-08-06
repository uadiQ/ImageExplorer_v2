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
    var isPaginating = false
    var searchResults: [Post] = []
    var paginationInfo = ""
    
    override func viewDidLoad() {
        HUD.show(.progress)
        super.viewDidLoad()
        title = searchingCategory
        setupTableView()
        loadSearchedPosts(for: searchingCategory)
        
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PostTableViewCell.nib, forCellReuseIdentifier: PostTableViewCell.reuseID)
        tableView.register(PaginateTableViewCell.nib, forCellReuseIdentifier: PaginateTableViewCell.reuseID)
    }
    
    private func loadSearchedPosts(for category: String) {
        DataManager.instance.performSearch(for: searchingCategory) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let postsArray):
                    HUD.hide()
                    self.searchResults = postsArray
                    self.tableView.reloadData()
                case .fail:
                    print("Failed search for keyword \(String(describing: self.searchingCategory))")
                    self.showAlertWithOk(title: "Error", message: "No posts for your request, try something else!")
                }
            }
        }
    }
    
    private func fetchNextPage() {
        #warning("Implement fetching next page")
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
           return searchResults.count
        } else {
           return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
        return PostTableViewCell.height
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if indexPath.section == 0 {
        guard let postCell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.reuseID, for: indexPath) as? PostTableViewCell else {
            fatalError("Cell with wrong ID")
        }
        
        let postToPresent = searchResults[indexPath.row]
        postCell.update(with: postToPresent)
        postCell.delegate = self
        postCell.favouriteAddingDelegate = self
        cell = postCell
        } else {
            guard let paginatingCell = tableView.dequeueReusableCell(withIdentifier: PaginateTableViewCell.reuseID, for: indexPath) as? PaginateTableViewCell else {
                fatalError("Cell with wrong ID")
            }
            cell = paginatingCell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postToPresent = searchResults[indexPath.row]
        performSegue(withIdentifier: Constants.Navigation.showDetails, sender: postToPresent)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && !isPaginating && paginationInfo != "" {
            fetchNextPage()
        }
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
