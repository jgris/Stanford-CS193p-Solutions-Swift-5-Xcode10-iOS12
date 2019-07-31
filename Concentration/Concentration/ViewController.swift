//
//  ViewController.swift
//  Concentration
//
//  Created by J. Grishin on 6/1/19.
//  Copyright © 2019 J. Grishin. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        theme = .getRandomTheme()
    }
    
    private lazy var game = Concentration(numberOfPairOfCards: numberOfPairOfCards)
    
    var numberOfPairOfCards: Int {
            return (cardButtons.count + 1) / 2
    }
    
    private(set) var flipCount = 0 {
        didSet{
            let attributes: [NSAttributedString.Key: Any] = [
                .strokeWidth : 5.0,
                .strokeColor : #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1),
            ]
            let attributedString = NSAttributedString(string: "Flips: \(flipCount)", attributes: attributes)
            flipCountLabel.attributedText = attributedString
        }
    }
    
    private var theme = Theme.getRandomTheme() {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet      var cardButtons: [UIButton]!
    @IBOutlet weak var themeNameLabel: UILabel!
    @IBOutlet weak var flipCountLabel: UILabel!
    @IBOutlet weak var scoreCountLabel: UILabel!
    
    @IBAction func touchCard(_ sender: UIButton) {
        if let cardNumber = cardButtons.firstIndex(of: sender) {
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
        } else {
            print("Chosen card is not in cardButtons")
        }
    }
    
    @IBAction func newGame(_ sender: UIButton) {
        game.reset()
        theme = .getRandomTheme()
    }
    
    // Updates UI when starting new game
    private func updateUI() {
        themeNameLabel.text = theme.name
        emojiChoices = theme.emojis
        view.backgroundColor = theme.backgroundColor
        emoji = [Card:String]()
        updateViewFromModel()
    }

   private func updateViewFromModel() {
        for index in cardButtons.indices {
            let button = cardButtons[index]
            let card = game.cards[index]
            if card.isFaceUp {
                button.backgroundColor = .white
                button.setTitle(emoji(for: card), for: .normal)
            } else {
                button.backgroundColor = card.isMatched ?  #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 0) : theme.cardBackColor
                button.setTitle("", for: .normal)
            }
        }
        flipCount = game.flipCount
        scoreCountLabel.text = "Score: \(game.scoreCount)"
    }
    
    private var emoji = [Card:String]()
    private var emojiChoices = ""
    
    private func emoji(for card: Card) -> String {
        if emoji[card] == nil, emojiChoices.count > 0 {
            let randomStringIndex = emojiChoices.index(emojiChoices.startIndex, offsetBy: emojiChoices.count.randomIndex)
            emoji[card] = String(emojiChoices.remove(at: randomStringIndex))
        }
        return emoji[card] ?? "?"
    }
    
}

extension Int {
    var randomIndex: Int {
        if self > 0 {
        return Int.random(in: 1..<self)
        } else {
             if self < 0 {
                return -Int.random(in: 1..<abs(self))
             } else {
                return 0
            }
        }
    }
}
