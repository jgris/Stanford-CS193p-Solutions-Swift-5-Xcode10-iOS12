//
//  ViewController.swift
//  Set
//
//  Created by J. Grishin on 7/13/19.
//  Copyright © 2019 J. Grishin. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    // MARK: Initialisations
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateUIfromModel()
    }
    /// Instance of the game (our model)
    private lazy var game = Game()
    
    // MARK: Outlets
    @IBOutlet      var cardButtons: [CardButton]!
    @IBOutlet weak var matchStatusLabel: UILabel!
    @IBOutlet weak var scoreDisplayLabel: UILabel!
    @IBOutlet weak var numberOfCardsInDeckLabel: UILabel!
    @IBOutlet weak var dealMoreCardsButton: UIButton!
    @IBOutlet weak var cheatButton: UIButton!
    
    // MARK: Actions
    @IBAction func touchCardButton(_ sender: CardButton) {
        // Method works if only button has associated 'Card' instance
        guard let card = sender.card else { return }
        if sender.matchState == .notSet {
            game.chooseCard(card)
            updateUIfromModel()
        }
    }
    // Deal 3 more cards
    @IBAction func dealMoreCards(_ sender: UIButton) {
        game.deal(3)
        updateUIfromModel()
    }
    // Starts new game
    @IBAction func newGame(_ sender: UIButton) {
        game = Game()
        updateUIfromModel()
    }

    @IBAction func cheat(_ sender: UIButton) {
    }
    
    private func updateUIfromModel() {
        for index in cardButtons.indices {
            let button = cardButtons[index]
            if index < game.cardsInGame.count {
                guard let card = game.cardsInGame[index] else { return }
                button.cardIsSelected = game.selectedCards.contains(card) ? true : false
                if      game.matchedCards.contains(card) { button.matchState = .matched }
                else if button.cardIsSelected && game.selectedCards.count == 3 { button.matchState = .notMatched }
                else { button.matchState = .notSet }
                button.card = card
            } else {
                button.card = nil
            }
        }
        // Enable/disable 'Deal 3 More' button
        dealMoreCardsButton.isEnabled = !UIIsFull &&
                                        game.numbederOfCardsInDeck > 0 ||
                                        (UIIsFull && game.gameMatchState == .matched)
        // Shows number of cards in deck
        numberOfCardsInDeckLabel.text = game.numbederOfCardsInDeck.asString + " in Deck"
        // shows scores of current game
        scoreDisplayLabel.text        = "Score: " + game.score.asString
        // Shows if set is matched or not
        switch game.gameMatchState {
        case .matched:      matchStatusLabel.text = "Matched!"
        case .notMatched:   matchStatusLabel.text = "Not Matched..."
        case .notSet:       matchStatusLabel.text = " "
        }
        // Cheat button is disabled. Reserved for next update with Extra Credit Implementation
        cheatButton.isEnabled = false
    }
}

// MARK: - Extensions
extension ViewController {
    /// - Returns: true if there is no room for new cards in UI.
    var UIIsFull: Bool {
        return self.cardButtons.filter { $0.card != nil }.count == 24
    }
}
extension UIButton {
    open override var isEnabled: Bool {
        didSet {
            self.backgroundColor = self.isEnabled ? Theme.buttonColor : Theme.buttonColorDisabled
        }
    }
}
