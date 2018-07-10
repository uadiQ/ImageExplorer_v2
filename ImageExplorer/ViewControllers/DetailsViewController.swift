//
//  DetailsViewController.swift
//  ImageExplorer
//
//  Created by Vadim Shoshin on 14.06.2018.
//  Copyright © 2018 Vadim Shoshin. All rights reserved.
//

import UIKit
import SDWebImage
import SafariServices

class DetailsViewController: UIViewController {
    @IBOutlet private weak var photoImage: UIImageView!
    @IBOutlet private weak var authorName: UILabel!
    
    var post: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        if let image = post.fullPhotoImage {
            photoImage.image = image
        } else {
            guard let regularUrl = URL(string: post.urls.regular) else { print( "wrong url")
                return
            }
            photoImage.sd_setImage(with: regularUrl)
        }
        authorName.text = "Author: \(post.user.name)"
    }
    
    @IBAction func seeProfilePushed(_ sender: Any) {
        let url = Constants.Networking.baseWeb.appendingPathComponent(post.user.username)
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true)
    }
    
}
