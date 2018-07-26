//
//  DetailsTwoViewController.swift
//  ImageExplorer
//
//  Created by swstation on 7/26/18.
//  Copyright © 2018 Vadim Shoshin. All rights reserved.
//

import UIKit
import PKHUD

class DetailsTwoViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    
    var post: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        if let image = post.fullPhotoImage {
            imageView.image = image
        } else {
            setImage(with: post.urls.regular)
        }
        authorLabel.text = "Author: \(post.user.name)"
    }
    
    private func setImage(with url: String) {
        HUD.show(.progress, onView: self.imageView)
        guard let targetUrl = URL(string: url) else {
            showAlertWithOk(title: nil, message: "Wrong url format")
            return
        }
        DataManager.instance.downloadImage(with: targetUrl) { result in
            DispatchQueue.main.async {
                HUD.hide()
                switch result {
                case .success(let image):
                    self.imageView.image = image
                case .fail:
                    self.showAlertWithOk(title: "Error", message: "Image loading failed, try again later")
                }
            }
        }
    }

}
