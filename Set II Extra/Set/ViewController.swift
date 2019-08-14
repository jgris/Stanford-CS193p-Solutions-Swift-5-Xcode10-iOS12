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
    }
    private lazy var oneLebel = UILabel()
    
    private func setUI() {
        cheatButton.layer.cornerRadius      = 15
        DealMoreButton.layer.cornerRadius   = 15
        user1SetButton.layer.cornerRadius   = 15
        user2SetButton.layer.cornerRadius   = 15
        user1SetButton.layer.maskedCorners  = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        user2SetButton.layer.maskedCorners  = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
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
    @IBOutlet weak var user1ScoreDisplayLabel: UILabel!
    @IBOutlet weak var user2ScoreDisplayLabel: UILabel!
    
    @IBOutlet weak var cheatButton: UIButton!
    @IBOutlet weak var user1SetButton: UIButton!
    @IBOutlet weak var user2SetButton: UIButton!
    @IBOutlet weak var DealMoreButton: UIButton!

    
    // MARK: - Actions
    @objc func tapCard(recognizedBy recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let cardView = recognizer.view as? CardView {
                // Method works if only button has associated 'Card' instance
                guard let card = cardView.card else { break }
                if cardView.matchState == .notSet {
                    game.chooseCard(card)
                    updateUIfromModel()
                }
            }
        default: break
        }
    }
    // - MARK: - Assignment III Extra Credit
    @IBAction func user1TapSet(_ sender: UIButton) {
        guard game.selectedCards.isEmpty else { return }
        game.currentPlayer = .user1
        sender.isEnabled = false
        user2SetButton.isEnabled = false
        DealMoreButton.isEnabled = false
        sender.backgroundColor = Theme.setButtonColorSelected
        startPlayTimer(by: sender)
    }
    
    @IBAction func user2TapSet(_ sender: UIButton) {
        guard game.selectedCards.isEmpty else { return }
        game.currentPlayer = .user2
        sender.isEnabled = false
        user1SetButton.isEnabled = false
        sender.backgroundColor = Theme.setButtonColorSelected
        startPlayTimer(by: sender)
    }
    
    private var timeBonusToOpponent = 0.0
    private var timer: Timer?
    
    private func startPlayTimer(by sender: UIButton) {
        updateUIfromModel()
        let timeInterval = timeBonusToOpponent != 0 ? 10 + timeBonusToOpponent : 5
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false, block:
            { timer in
                sender.isEnabled = true
                sender.backgroundColor = Theme.buttonColor
                // Define opponent's Set button to tap if we failed to get a Set
                let nextPosibleAction: UIButton = self.game.currentPlayer == .user1 ? self.user2SetButton : self.user1SetButton
                // completionHandler  is needed to "tap" opponent's button by code at the end of the timer's closure.
                // We need to run the completionHandler only if 'self.game.gameMatchState == .notMatched'
                // and we will loose this context if we will be trying to send action to opponent's button
                // not using closure.
                var completionHandler: () -> Void = {}
                self.timeBonusToOpponent = 0.0
                self.DealMoreButton.isEnabled  = true
                switch self.game.currentPlayer {
                case .user1: self.user2SetButton.isEnabled  = true
                case .user2: self.user1SetButton.isEnabled  = true
                default: break
                }
                
                if self.game.gameMatchState == .notMatched {
                    self.timeBonusToOpponent += 5
                    completionHandler = { nextPosibleAction.sendActions(for: .touchUpInside) }
                } else {
                    self.timeBonusToOpponent = 0
                }

                self.game.clearSelection()
                self.game.currentPlayer = .none
                self.updateUIfromModel()
                completionHandler()
        })
    }
    
    // Deal 3 more cards
    @IBAction func dealMoreCards(_ sender: UIButton) {
        game.deal(3)
        updateUIfromModel()
        // Shows number of cards in deck
        DealMoreButton.setTitle(game.numbederOfCardsInDeck.asString + " in Deck", for: .normal)
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { timer in
            let titleString = self.game.numbederOfCardsInDeck > 0 ? "Deal 3 More" : "No More Cards"
            sender.setTitle(titleString, for: .normal)})
    }
    
    @objc private func deal(recognizedBy recognizer: UISwipeGestureRecognizer) {
        switch recognizer.state {
        case .ended: dealMoreCards(self.DealMoreButton)
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
        timer?.invalidate()
        game = Game()
        gameFieldView.cardViews = []
        setUI()
        updateUIfromModel()
    }
   
    // Assignment II Extra Credit 3 - Cheat Button.
    /// Highlights a set of matching cards in pink for a short time.
    @IBAction func cheat(_ sender: UIButton) {
        game.cheatSet()
        let cardViews = gameFieldView.cardViews
        if !game.currentCheatSet.isEmpty {
            cardViews.forEach { cardView in
                // If 'cardView' has 'Card' and card is in 'game.currentCheatSet'
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
        
        // Disable interaction with cards if no user is in the game (SET button is not pressed).
        gameFieldView.isUserInteractionEnabled = game.currentPlayer != .none
        
        if game.currentPlayer == .none {
            user1SetButton.isEnabled = true
            user2SetButton.isEnabled = true
            user1SetButton.backgroundColor = Theme.buttonColor
            user2SetButton.backgroundColor = Theme.buttonColor
            DealMoreButton.isEnabled = true
        }
        
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
        
        // Enable/disable 'Deal 3 More' buttons
        DealMoreButton.isEnabled = game.numbederOfCardsInDeck > 0
        
        // shows scores of current game
        user1ScoreDisplayLabel.text      = "\(game.matchedSets[.user1]!)"
        user2ScoreDisplayLabel.text      = "\(game.matchedSets[.user2]!)"
        
//         if game.currentPlayer == .user1 {user1SetButton.setTitle("🤔", for: .normal)}
        
        // Shows if set is matched or not
        switch game.gameMatchState {
        case .matched:      matchStatusLabel.text = "Matched!";
        case .notMatched:   matchStatusLabel.text = "Not Matched..."
        case .notSet:       matchStatusLabel.text = " "
        }
        cheatButton.isEnabled = game.countOfallFoundSets > 0
        var cheatButtonString = "\(game.countOfallFoundSets) Set"
        if game.countOfallFoundSets > 1 { cheatButtonString.append("s") }
        cheatButton.setTitle(cheatButtonString, for: .normal)
        
        if game.isEnded {
            if game.matchedSets[.user1]! > game.matchedSets[.user2]! {
                user2SetButton.setTitle("WINNER! 👤", for: .normal)
                user1SetButton.setTitle("😡 LOSER!", for: .normal)
            } else {
                user2SetButton.setTitle("😡 LOSER!", for: .normal)
                user1SetButton.setTitle("WINNER! 👤", for: .normal)
            }
            matchStatusLabel.text = "🏆 🏆 🏆"
            timer?.invalidate()
        }
//        if game.selectedCards.isEmpty {user2Timer?.invalidate(); }
    }
    
    // - MARK: - Gestures
    private func addTapGestureRecognizer(for view: CardView) {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapCard(recognizedBy:)))
        tapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapRecognizer)
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
