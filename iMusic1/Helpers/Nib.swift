//
//  Nib.swift
//  iMusic1
//
//  Created by Тимур Мусаханов on 8/17/20.
//  Copyright © 2020 Тимур Мусаханов. All rights reserved.
//

import UIKit

extension UIView {
    
    static func loadFromNib<T: UIView>() -> T {
        let name = String(describing: T.self)
        guard let trackDetailsView = Bundle.main.loadNibNamed(name,
                                                              owner: nil,
                                                              options: nil)?.first as? T else { return T() }
        return trackDetailsView
    }
}
