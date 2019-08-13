//
//  GameFieldView.swift
//  Set
//
//  Created by J. Grishin on 8/9/19.
//  Copyright © 2019 J. Grishin. All rights reserved.
//

import UIKit

class GameFieldView: UIView {
    // cards in game
    var cardViews = [CardView]() {
        willSet { removeSubviews() }
        didSet { addSubviews(); setNeedsLayout() }
    }
    
    private func removeSubviews() {
        for card in cardViews { card.removeFromSuperview() }
    }
    
    private func addSubviews() {
        for card in cardViews { addSubview(card) }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var grid = Grid(aspectRatio: Constant.cellAspectRatio, frame: bounds)
        grid.cellCount = cardViews.count
        for index in cardViews.indices {
            let cardView = cardViews[index]
            cardView.frame = grid[index]!.insetBy(dx: Constant.space, dy: Constant.space)
        }
    }
    
    struct Constant {
        static let cellAspectRatio: CGFloat = 0.7
        static let space: CGFloat           = 2.0
    }
}
