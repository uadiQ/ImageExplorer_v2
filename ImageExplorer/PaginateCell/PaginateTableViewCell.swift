//
//  PaginateTableViewCell.swift
//  ImageExplorer
//
//  Created by swstation on 8/6/18.
//  Copyright © 2018 Vadim Shoshin. All rights reserved.
//

import UIKit

class PaginateTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var paginateIndicator: UIActivityIndicatorView!
    
    static let reuseID = String(describing: PaginateTableViewCell.self)
    static let nib = UINib(nibName: String(describing: PaginateTableViewCell.self), bundle: nil)

    override func awakeFromNib() {
        super.awakeFromNib()
        paginateIndicator.startAnimating()
    }

    override func prepareForReuse() {
        paginateIndicator.startAnimating()
    }
    
}
