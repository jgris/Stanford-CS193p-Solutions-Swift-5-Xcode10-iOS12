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
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        updateUIfromModel()
        goIphone()
    }
    
    private func setUI() {
        cheatButton.layer.cornerRadius          = 15
        dealMoreCardsButton.layer.cornerRadius  = 15
        iphoneEmoji.layer.cornerRadius          = 15
        userEmoji.layer.cornerRadius            = 15
        iphoneEmoji.layer.maskedCorners         = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        userEmoji.layer.maskedCorners           = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
    }
    
    /// Instance of the game (our model)
    private lazy var game = Game()
    
    // MARK: - Outlets
    
    @IBOutlet weak var gameFieldView: GameFieldView! {
        didSet {
            let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(deal(recognizedBy:)))
            swipeRecognizer.direction = .down
            self.gameFieldView.addGestureRecognizer(swipeRecognizer)
            let rotationRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(reshuffle(recognizedBy:)))
            self.gameFieldView.addGestureRecognizer(rotationRecognizer)
        }
    }
    
    @IBOutlet weak var matchStatusLabel: UILabel!
    @IBOutlet weak var userScoreDisplayLabel: UILabel!
    @IBOutlet weak var iphoneScoreDisplayLabel: UILabel!
    @IBOutlet weak var iphoneEmoji: UIButton!
    @IBOutlet weak var userEmoji: UIButton!
    
    @IBOutlet weak var dealMoreCardsButton: UIButton!
    @IBOutlet weak var cheatButton: UIButton!
    
    // MARK: - Actions
    @objc func tapCard(recognizedBy recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let cardView = recognizer.view as? CardView {
                // Method works if only button has associated 'Card' instance
                guard let card = cardView.card else { break }
                if cardView.matchState == .notSet {
                    game.currentPlayer = .user
                    iPhoneTimer?.invalidate()
                    game.chooseCard(card)
                    updateUIfromModel()
                }
            }
        default: break
        }
    }
    // Deal 3 more cards
    @IBAction func dealMoreCards(_ sender: UIButton) {
        game.deal(3)
        updateUIfromModel()
        // Shows number of cards in deck
        dealMoreCardsButton.setTitle(game.numbederOfCardsInDeck.asString + " in Deck", for: .normal)
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { timer in
            let titleString = self.game.numbederOfCardsInDeck > 0 ? "Deal 3 More" : "No More Cards"
            self.dealMoreCardsButton.setTitle(titleString, for: .normal)})
    }
    
    @objc private func deal(recognizedBy recognizer: UISwipeGestureRecognizer) {
        switch recognizer.state {
        case .ended: dealMoreCards(self.dealMoreCardsButton)
        default: break
        }
    }
    
    @objc private func reshuffle(recognizedBy recognizer: UIRotationGestureRecognizer) {
        switch recognizer.state {
        case .ended: game.resuffleCards(); updateUIfromModel()
        default: break
        }
    }
    
    // Starts new game
    @IBAction func newGame(_ sender: UIButton) {
        game = Game()
        gameFieldView.cardViews = []
        updateUIfromModel()
        iPhoneTimer?.invalidate()
        goIphone()
    }
   
    // Extra Credit 3 - Cheat Button.
    /// Highlights a set of matching cards in pink for a short time.
    @IBAction func cheat(_ sender: UIButton) {
        game.cheatSet()
        let cardViews = gameFieldView.cardViews
        if !game.currentCheatSet.isEmpty {
            cardViews.forEach { cardView in
                // If button has 'Card' and card is in 'game.currentCheatSet'
                // set background color to hint one set to player.
                if let card = cardView.card, game.currentCheatSet.contains(card) {
                    cardView.cheatHilighted = true
                    cheatTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { timer in
                        cardView.cheatHilighted = false
                        timer.invalidate()
                        self.updateUIfromModel()
                    })
                }
            }
        }
    }
    
    private weak var cheatTimer: Timer?
    
    private func updateUIfromModel() {
        gameFieldView.cardViews = []
        let numberOfCardViews = gameFieldView.cardViews.count
        for index in game.cardsInGame.indices {
            let card = game.cardsInGame[index]
            if index > numberOfCardViews - 1 {
                let cardView = CardView()
                cardView.card = card
                addTapGestureRecognizer(for: cardView)
                gameFieldView.cardViews.append(cardView)
            }
        }
        
        for cardView in gameFieldView.cardViews {
            guard let card = cardView.card else { return }
            cardView.cardIsSelected = game.selectedCards.contains(card)
            if game.matchedCards.contains(card) { cardView.matchState = .matched }
            else if cardView.cardIsSelected && game.selectedCards.count == 3 { cardView.matchState = .notMatched }
            else { cardView.matchState = .notSet }
        }
        
        // Enable/disable 'Deal 3 More' button
        dealMoreCardsButton.isEnabled = game.numbederOfCardsInDeck > 0
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
        }
        if game.isEnded {
            if game.matchedSets[0] > game.matchedSets[1] {
                userEmoji.setTitle("WINNER! 👤", for: .normal)
                iphoneEmoji.setTitle("😡 LOSER!", for: .normal)
            } else {
                userEmoji.setTitle("😡 LOSER!", for: .normal)
                iphoneEmoji.setTitle("WINNER! 👤", for: .normal)
            }
            matchStatusLabel.text = "🏆 🏆 🏆"
            iPhoneTimer?.invalidate()
        }
        if game.selectedCards.isEmpty {iPhoneTimer?.invalidate(); goIphone() }
    }
    
    // - MARK: - Gestures
    private func addTapGestureRecognizer(for view: CardView) {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapCard(recognizedBy:)))
        tapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapRecognizer)
    }
    
    // MARK: - iPhone AI :-)
    /*
     Assignment II Extra Credit 4 - Play Against the iPhone.
     1. There is at least one set on table
     2. iPhone choose random set from game.allFoundSets.
     3. Random-length timer will start for iPhone.
     1. If Player pick any card, iPhone have to wait until Player will finish picking the set (pause timer).
     4. If the timer has expired and Player has not selected this set, the iPhone selects the set.
     5. If the Player has been faster than the iPhone - repeat.
     */
    private weak var iPhoneTimer: Timer?
    
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
                    self.gameFieldView.cardViews.forEach { cardView in
                        // Blocking interaction with buttons when the iPhone is the boss.
                        cardView.isUserInteractionEnabled = false
                        if let card = cardView.card, self.game.randomIphoneSet.contains(card) {
                            cardView.cardIsSelectedByIphone = true
                        }
                    }
                    Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block:
                        { higlightTimer in
                            self.gameFieldView.cardViews.forEach { cardView in
                                // Unlocking interactions with buttons after the iPhone finished.
                                if let card = cardView.card, self.game.randomIphoneSet.contains(card) {
                                    cardView.cardIsSelectedByIphone = false
                                }
                                cardView.isUserInteractionEnabled = true
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
extension UIButton {
    open override var isEnabled: Bool {
        didSet {
            self.backgroundColor = self.isEnabled ? Theme.buttonColor : Theme.buttonColorDisabled
        }
    }
}
