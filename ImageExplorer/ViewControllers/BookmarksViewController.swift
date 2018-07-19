//
//  BookmarksViewController.swift
//  ImageExplorer
//
//  Created by Vadim Shoshin on 14.06.2018.
//  Copyright © 2018 Vadim Shoshin. All rights reserved.
//

import UIKit
import SwifterSwift

class BookmarksViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        title = "Favourites"
        setupTableView()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.barTintColor = .cyan
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(color: .cyan, size: CGSize(width: 1, height: 1)), for: .default)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PostTableViewCell.nib, forCellReuseIdentifier: PostTableViewCell.reuseID)
        tableView.isUserInteractionEnabled = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destVC = segue.destination as? DetailsViewController else { return }
        destVC.post = sender as? Post
    }
}


// MARK: - TableViewDelegate, TableViewDataSource
extension BookmarksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.instance.favourites.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PostTableViewCell.height
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.reuseID, for: indexPath) as? PostTableViewCell else {
            fatalError("Cell with wrong id")
        }
        let postToPresent = DataManager.instance.favourites[indexPath.row]
        cell.update(with: postToPresent)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postToPresent = DataManager.instance.favourites[indexPath.row]
        performSegue(withIdentifier: Constants.Navigation.showDetails, sender: postToPresent)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard editingStyle == .delete else { return }
        let deletingItem = DataManager.instance.favourites[indexPath.row]
        DataManager.instance.deleteFromFavourites(post: deletingItem)
        
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}

extension BookmarksViewController: PostSharing {
    func share(urlToShare: URL) {
        let activityViewController = UIActivityViewController(activityItems: [urlToShare], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = tableView
        self.present(activityViewController, animated: true, completion: nil)
    }
}
