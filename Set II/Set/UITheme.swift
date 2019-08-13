//
//  UITheme.swift
//  Set
//
//  Created by J. Grishin on 7/17/19.
//  Copyright © 2019 J. Grishin. All rights reserved.
//

import UIKit

struct Theme {
    static let backgroundColor:                 UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
    static let cardColor:                       UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let cardColorSelected:               UIColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    static let cardColorHilighted:              UIColor = #colorLiteral(red: 0.8783014417, green: 0.7225192189, blue: 0.6207069159, alpha: 1)
    
    static let cardStrokeColorMatched:          UIColor = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
    static let cardStrokeColorNotMatched:       UIColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
    
    static let cardStrokeColorIphoneSelected:   UIColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
    
    static let buttonCornerRadius:              CGFloat = 12
    static let cardButtonCornerRadius:          CGFloat = 12
    
    static let buttonColor:                     UIColor = #colorLiteral(red: 0.6198394299, green: 0.5399842858, blue: 0, alpha: 1)
    static let buttonColorDisabled:             UIColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
}
