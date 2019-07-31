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
        setUI()
        updateUIfromModel()
        goIphone()
    }
    
    private func setUI() {
        cheatButton.layer.cornerRadius          = 15
        cheatButton.layer.maskedCorners         = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        dealMoreCardsButton.layer.cornerRadius  = 15
        dealMoreCardsButton.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        iphoneEmoji.layer.cornerRadius          = 15
        iphoneEmoji.layer.maskedCorners         = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        userEmoji.layer.cornerRadius            = 15
        userEmoji.layer.maskedCorners           = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
    }
    
    /// Instance of the game (our model)
    private lazy var game = Game()
    
    // MARK: - Outlets
    @IBOutlet      var cardButtons: [CardButton]!
    @IBOutlet weak var matchStatusLabel: UILabel!
    @IBOutlet weak var userScoreDisplayLabel: UILabel!
    @IBOutlet weak var iphoneScoreDisplayLabel: UILabel!
    @IBOutlet weak var iphoneEmoji: UIButton!
    @IBOutlet weak var userEmoji: UIButton!
    
    
    @IBOutlet weak var dealMoreCardsButton: UIButton!
    @IBOutlet weak var cheatButton: UIButton!
    
    // MARK: - Actions
    @IBAction func touchCardButton(_ sender: CardButton) {
        // Method works if only button has associated 'Card' instance
        guard let card = sender.card else { return }
        if sender.matchState == .notSet {
//            print("button \(card.identifier)")
            game.currentPlayer = .user
            iPhoneTimer?.invalidate()
            iPhoneHighlightTimer?.invalidate()
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
        iPhoneTimer?.invalidate()
        iPhoneHighlightTimer?.invalidate()
        goIphone()
    }
    
    // Extra Credit 3 - Cheat Button.
    /// Highlights a set of matching cards in pink for a short time.
    @IBAction func cheat(_ sender: UIButton) {
        game.cheatSet()
        if !game.currentCheatSet.isEmpty {
            cardButtons.forEach { button in
                // If button has 'Card' and card is in 'game.currentCheatSet'
                // set background color to hint one set to player.
                if let card = button.card, game.currentCheatSet.contains(card) {
                    button.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
                    cheatTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { timer in
                        button.backgroundColor = Theme.cardColor
                        timer.invalidate()
                        self.updateUIfromModel()
                    })
                }
            }
        }
    }
    
    private weak var cheatTimer: Timer?
    
    private func updateUIfromModel() {
        for index in cardButtons.indices {
            let button = cardButtons[index]
            if index < game.cardsInGame.count {
                let card = game.cardsInGame[index]
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
        // TODO: - numberOfCardsInDeckLabel
//        numberOfCardsInDeckLabel.text = game.numbederOfCardsInDeck.asString + " in Deck"
        // shows scores of current game
        userScoreDisplayLabel.text        = "\(game.score[0].asString) / \(game.matchedSets[0])"
        iphoneScoreDisplayLabel.text      = "\(game.score[1].asString) / \(game.matchedSets[1])"
        
         if game.currentPlayer == .user {iphoneEmoji.setTitle("🤔", for: .normal)}
        
        // Shows if set is matched or not
        switch game.gameMatchState {
        case .matched:      matchStatusLabel.text = "Matched!"
        case .notMatched:   matchStatusLabel.text = "Not Matched..."
        case .notSet:       matchStatusLabel.text = " "
        }
        cheatButton.isEnabled = game.countOfallFoundSets > 0
        var cheatButtonString = "\(game.countOfallFoundSets) Set"
        if game.countOfallFoundSets > 1 { cheatButtonString.append("s") }
        cheatButton.setTitle(cheatButtonString, for: .normal)
        
        // iPhone will be upset if we stole his set..
        // (if at least one card from his set was in our winning set.)
        if game.gameMatchState == .matched && game.randomIphoneSet.isEmpty {
            iphoneEmoji.setTitle("🥺 No..", for: .normal)
            iPhoneTimer?.invalidate()
            iPhoneHighlightTimer?.invalidate()
        }
        if game.selectedCards.isEmpty {iPhoneTimer?.invalidate(); goIphone() }
    }
    
    // MARK: - iPhone AI :-)
    /*
     Extra Credit 4 - Play Against the iPhone.
     1. There is at least one set on table
     2. iPhone choose random set from game.allFoundSets.
     3. Random-length timer will start for iPhone.
     1. If Player pick any card, iPhone have to wait until Player will finish picking the set (pause timer).
     4. If the timer has expired and Player has not selected this set, the iPhone selects the set.
     5. If the Player has been faster than the iPhone - repeat.
     */
    private weak var iPhoneTimer: Timer?
    private weak var iPhoneHighlightTimer: Timer?
    
    private func goIphone() {
        if !game.randomIphoneSet.isEmpty && game.selectedCards.isEmpty {
            let randomTimeInterval = TimeInterval(Int.random(in: 3...5))
            iPhoneTimer = Timer.scheduledTimer(withTimeInterval: randomTimeInterval, repeats: false, block:
                { timer in
                    // Closure will work only if no cards are chosen at the moment.
                    guard self.game.selectedCards.isEmpty else { timer.invalidate(); return }
                    // Sets currentPlayer to iPhone
                    self.game.currentPlayer = .iphone
                    self.dealMoreCardsButton.isUserInteractionEnabled = false
                    self.cheatButton.isUserInteractionEnabled = false
                    self.iphoneEmoji.setTitle("😀 SET!", for: .normal)
                    // Highlights iPhone's choosen cards for us
                    // iPhone chooses cards just like we do :-)
                    self.cardButtons.forEach { button in
                        // Blocking interaction with buttons when the iPhone is the boss.
                        button.isUserInteractionEnabled = false
                        if let card = button.card, self.game.randomIphoneSet.contains(card) {
                            button.layer.borderColor = UIColor.blue.cgColor
                            button.layer.borderWidth = CGFloat(4.0)
                        }
                    }
                    self.iPhoneHighlightTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block:
                        { higlightTimer in
                            self.cardButtons.forEach { button in
                                // Unlocking interactions with buttons after the iPhone finished.
                                if let card = button.card, self.game.randomIphoneSet.contains(card) {
                                    button.layer.borderWidth = CGFloat(0.0)
                                }
                                button.isUserInteractionEnabled = true
                            }
                            self.game.randomIphoneSet.forEach { card in self.game.chooseCard(card) }
                            self.updateUIfromModel()
                            self.dealMoreCardsButton.isUserInteractionEnabled = true
                            self.cheatButton.isUserInteractionEnabled = true
                            self.iphoneEmoji.setTitle("🥳 Yes!", for: .normal)
                    })
                })
        } else {
            self.iphoneEmoji.setTitle("😡 Deal!", for: .normal)
        }
        // else { ... Wait... Should we allow the iPhone to deal 3 more cards
        // if there are no sets found? :-)
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
