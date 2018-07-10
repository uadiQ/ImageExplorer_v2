//
//  Result.swift
//  ImageExplorer
//
//  Created by Vadim Shoshin on 14.06.2018.
//  Copyright © 2018 Vadim Shoshin. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case fail(Error)
}
