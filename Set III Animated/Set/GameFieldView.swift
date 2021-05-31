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
        for cardView in cardViews { cardView.removeFromSuperview() }
    }
    
    private func addSubviews() {
        for cardView in cardViews { addSubview(cardView) }
    }
    
    func removeCardView(_ cardView: CardView) {
        if let index = cardViews.firstIndex(of: cardView) {
            cardViews.remove(at: index)
            cardView.removeFromSuperview()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        setNeedsDisplay()
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        var grid = Grid(aspectRatio: Constant.cellAspectRatio, frame: bounds)
        grid.cellCount = cardViews.count
        
        for index in cardViews.indices {
            let cardView = cardViews[index]
            
            let cardViewFrame = grid[index]!.insetBy(dx: Constant.space, dy: Constant.space)

            if !cardView.frame.isEmpty && cardView.frame != cardViewFrame {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: Constant.animationDuration,
                    delay: Constant.animationDelay,
                    options: [.curveEaseInOut],
                    animations: {
                        cardView.frame = cardViewFrame
                })
            } else {
                cardView.frame = cardViewFrame
            }
        }
    }
    
    struct Constant {
        static let cellAspectRatio: CGFloat = 0.7
        static let space: CGFloat           = 2.0
        
        static let animationDuration: TimeInterval  = 0.4
        static let animationDelay: TimeInterval     = 0.1
    }
}
