//
//  UIViewController+Extension.swift
//  ImageExplorer
//
//  Created by swstation on 7/18/18.
//  Copyright © 2018 Vadim Shoshin. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlertWithOk(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}
