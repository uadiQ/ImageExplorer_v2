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
import PKHUD

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
    
    @IBAction func saveToCameraRollPushed(_ sender: Any) {
        HUD.show(.progress)
        var imageToSave: UIImage
        if let image = post.fullPhotoImage {
            imageToSave = image
        } else {
            guard let urlToDownload = URL(string: post.urls.full),
            let imageData = try? Data(contentsOf: urlToDownload),
                let image = UIImage(data: imageData) else { return }
            imageToSave = image
        }
        
        UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        HUD.hide()
        if let error = error {
            showAlertWithOk(title: "Saving error", message: error.localizedDescription)
        } else {
            showAlertWithOk(title: "Success", message: "Image was saved to your camera roll")
        }
    }
}
