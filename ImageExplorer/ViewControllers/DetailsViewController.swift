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
    @IBOutlet private weak var photoImageHeight: NSLayoutConstraint!
    
    var post: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        if let image = post.fullPhotoImage {
            photoImage.image = image
        } else {
            setImage(with: post.urls.regular)
        }
        authorName.text = "Author: \(post.user.name)"
        photoImageHeight.constant = self.view.bounds.width / post.ratio
        view.layoutIfNeeded()
        tabBarController?.tabBar.isHidden = true
    }
    
    private func setImage(with url: String) {
        HUD.show(.progress, onView: self.photoImage)
        guard let targetUrl = URL(string: url) else {
            showAlertWithOk(title: nil, message: "Wrong url format")
            return
        }
        DataManager.instance.downloadImage(with: targetUrl) { result in
            DispatchQueue.main.async {
                HUD.hide()
                switch result {
                case .success(let image):
                    self.photoImage.image = image
                case .fail:
                    self.showAlertWithOk(title: "Error", message: "Image loading failed, try again later")
                }
            }
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let destVC = segue.destination as? DetailsTwoViewController {
//            destVC.post = self.post
//        }
//    }
    
    private func downloadFullSizeImage(with url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let targetUrl = URL(string: url) else {
            return
        }
        DataManager.instance.downloadImage(with: targetUrl, completion: completion)
    }
    
    @IBAction func seeProfilePushed(_ sender: Any) {
        let url = Constants.Networking.baseWeb.appendingPathComponent(post.user.username)
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true)
    }
    
    @IBAction func saveToCameraRollPushed(_ sender: Any) {
        HUD.show(.progress)
        downloadFullSizeImage(with: post.urls.full) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let loadedImage):
                    UIImageWriteToSavedPhotosAlbum(loadedImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                case .fail:
                    self.showAlertWithOk(title: "Error", message: "Image loading failed, try again later")
                }
            }
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        HUD.hide()
        if let error = error {
            showAlertWithOk(title: "Saving error", message: error.localizedDescription)
        } else {
            HUD.flash(.labeledSuccess(title: nil, subtitle: "Image was saved to your camera roll"), delay: 1)
        }
    }
}
