//
//  CardButton.swift
//  Set
//
//  Created by J. Grishin on 7/17/19.
//  Copyright © 2019 J. Grishin. All rights reserved.
//

import UIKit

class CardButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    /// Card, assigned to button
    var card: Card? {
        didSet {
            self.updateState()
        }
    }
    
    /// Returns 'true' if card is selected
    var cardIsSelected: Bool   = false
    
    /// Returns  of type 'MatchState';
    /// Can be in one of three states:
    /// .matched, if card is matched;
    /// .notMatched, if not;
    /// .notSet, if no cards to test for matching
    var matchState: Game.MatchState = .notSet {
        didSet {
            switch matchState {
            case .matched:
                self.layer.borderColor = UIColor.green.cgColor
                self.layer.borderWidth = CGFloat(3.0)
            case .notMatched:
                self.layer.borderColor = UIColor.red.cgColor
                self.layer.borderWidth = CGFloat(3.0)
            case .notSet:
                self.layer.borderWidth = CGFloat(0.0)
            }
        }
    }
    
    func updateState() {
        if let card = self.card {
            self.isEnabled = true
            
            let shape       = cardShapes[card.shape]
            let shapesArray = Array(repeating: shape, count: card.number)
            let color       = cardColors[card.color]
            let fill        = cardFills[card.fill]
            let font        = UIFont.systemFont(ofSize: 23.0)
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font           : font,
                .strokeWidth    : -10.0,
                .strokeColor    : color,
                .foregroundColor: color.withAlphaComponent(fill)
            ]
            let attributedString = NSAttributedString(string: shapesArray.joined(separator: "\n"), attributes: attributes)
            setAttributedTitle(attributedString, for: .normal)
            self.backgroundColor   = cardIsSelected ? Theme.cardColorSelected : Theme.cardColor
        } else {
            self.isEnabled         = false
            self.cardIsSelected    = false
            self.matchState        = .notSet
            self.backgroundColor   = Theme.backgroundColor
            self.setAttributedTitle(nil, for: .normal)
            self.setTitle(nil, for: .normal)
            
        }
        
    }
    
    func configure() {
        updateState()
        layer.cornerRadius = Theme.cardButtonCornerRadius
    }
    
    private let cardShapes            = ["▲", "●", "■"]
    private let cardColors: [UIColor] = [#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1), #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)]
    private let cardFills : [CGFloat] = [1.0, 0.6, 0.1]
    
}


extension Array {
    subscript(_ value: Card.Value) -> Element {
        return self[(value.rawValue - 1)]
    }
}
