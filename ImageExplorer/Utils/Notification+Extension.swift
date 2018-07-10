//
//  Notification+Extension.swift
//  ImageExplorer
//
//  Created by Vadim Shoshin on 14.06.2018.
//  Copyright © 2018 Vadim Shoshin. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let RecentsUpdated = Notification.Name("RecentsUpdated")
    static let ImageLoaded = Notification.Name("ImageLoaded")
    static let FavouritesChanged = Notification.Name("FavouritesChanged")
    static let RequestFailed = Notification.Name("RequestFailed")
}
