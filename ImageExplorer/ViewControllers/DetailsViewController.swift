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
            downloadImage(with: post.urls.full)
        }
        authorName.text = "Author: \(post.user.name)"
    }
    private func downloadImage(with url: String) {
        HUD.show(.progress, onView: self.photoImage)
        guard let targetUrl = URL(string: url) else {
            showAlertWithOk(title: nil, message: "Wrong url format")
            return
        }
        DataManager.instance.downloadImage(with: targetUrl) { result in
            HUD.hide()
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self.photoImage.image = image
                case .fail:
                    self.showAlertWithOk(title: "Error", message: "Image loading failed, try again later")
                }
            }
        }
    }
    
    @IBAction func seeProfilePushed(_ sender: Any) {
        let url = Constants.Networking.baseWeb.appendingPathComponent(post.user.username)
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true)
    }
    
    @IBAction func saveToCameraRollPushed(_ sender: Any) {
        HUD.show(.progress)
        guard let imageToSave = photoImage.image else { return }
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
