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
        updateViewfromModel()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.dealMoreButton.subviews.first?.contentMode = .scaleAspectFit
    }
    
    override var prefersStatusBarHidden: Bool { return false }
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    private func setUI() {
        self.dealMoreButton.setBackgroundImage(UIImage(named: "deck"), for: .normal)
        user1SetButton.layer.cornerRadius   = 15
        user2SetButton.layer.cornerRadius   = 15
        user1SetButton.layer.maskedCorners  = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        user2SetButton.layer.maskedCorners  = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
    }
    
    /// Instance of the game (our model)
    private lazy var game = Game()
    
    lazy var animator = UIDynamicAnimator(referenceView: self.gameFieldView)
    
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
    @IBOutlet weak var user1SetButton: UIButton!
    @IBOutlet weak var user2SetButton: UIButton!
    @IBOutlet weak var dealMoreButton: UIButton!

    // Array of selected CardViews on the game field
    private var selectedCardViews: [CardView] {
        return gameFieldView.cardViews.filter { $0.cardIsSelected == true }
    }
    
    // Array of matched CardViews on the game field
    private var matchedCardViews: [CardView] {
        return gameFieldView.cardViews.filter { $0.matchState == .matched }
    }
    
    // MARK: - Actions
    @objc func tapCard(recognizedBy recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let cardView = recognizer.view as? CardView {
                // Method works if only button has associated 'Card' instance
                guard let card = cardView.card else { break }
                if cardView.matchState == .notSet {
                    game.chooseCard(card)
                    updateViewfromModel()
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
        dealMoreButton.isEnabled = false
        sender.backgroundColor = Theme.setButtonColorSelected
        startGameTimer(by: sender)
    }
    
    @IBAction func user2TapSet(_ sender: UIButton) {
        guard game.selectedCards.isEmpty else { return }
        game.currentPlayer = .user2
        sender.isEnabled = false
        user1SetButton.isEnabled = false
        sender.backgroundColor = Theme.setButtonColorSelected
        startGameTimer(by: sender)
    }
    
    // Deal 3 more cards
    @IBAction func dealMoreCards(_ sender: UIButton) {
        game.deal(3)
        updateViewfromModel()
        // Shows number of cards in deck
        dealMoreButton.setTitle(game.numbederOfCardsInDeck.asString, for: .normal)
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { timer in
            let titleString = self.game.numbederOfCardsInDeck > 0 ? "Deal" : "No Cards"
            sender.setTitle(titleString, for: .normal)})
    }
    
    @objc private func deal(recognizedBy recognizer: UISwipeGestureRecognizer) {
        switch recognizer.state {
        case .ended: dealMoreCards(self.dealMoreButton)
        default: break
        }
    }
    
    @objc private func reshuffle(recognizedBy recognizer: UIRotationGestureRecognizer) {
        switch recognizer.state {
        case .ended: gameFieldView.cardViews.shuffle()
        default: break
        }
    }
    
    // Starts new game
    @IBAction func newGame(_ sender: UIButton) {
        timer?.invalidate()
        game = Game()
        gameFieldView.cardViews = []
        setUI()
        updateViewfromModel()
    }
   
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
//                    cheatButton.isEnabled = false
                    Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { timer in
                        cardView.cheatHilighted = false
//                        self.cheatButton.isEnabled = true
                        timer.invalidate()
                        self.updateViewfromModel()
                    })
                }
            }
        }
    }
    
    private var deckCenter: CGPoint {
        return view.convert(dealMoreButton.superview!.center, to: gameFieldView)
    }
    
    //    MARK: - Animation
    
    private func flyaway() {
        let cardsToAnimate = self.matchedCardViews
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.6,
                delay: 0.0,
                options: [],
                animations: { cardsToAnimate.forEach { $0.alpha = 0 } },
                completion: { position in
                    cardsToAnimate.forEach {
                        if self.game.numbederOfCardsInDeck > 0 { $0.card = nil }
                        else { self.gameFieldView.removeCardView($0) }
                        self.updateViewfromModel()
                    }
            })
        }
    
    // MARK: - The Game :-)
    private var timeBonusToOpponent = 0.0
    private weak var timer: Timer?
    
    private func startGameTimer(by sender: UIButton)
    {
        updateViewfromModel()
        let timeInterval = timeBonusToOpponent != 0 ? 10 + timeBonusToOpponent : 5
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false, block:
            { timer in
                sender.isEnabled = true
                sender.backgroundColor = Theme.buttonColor
                self.tryForMatching()
        })
    }
    
    private func tryForMatching()
    {
        timer?.invalidate()
        // Define opponent's Set button to tap if we failed to get a Set
        let nextPosibleAction: UIButton = game.currentPlayer == .user1 ? user2SetButton : user1SetButton
        // completionHandler  is needed to "tap" opponent's button by code at the end of the timer's closure.
        // We need to run the completionHandler only if 'self.game.gameMatchState == .notMatched'
        // and we will loose this context if we will be trying to send action to opponent's button
        // not using closure.
        var completionHandler: () -> Void = {}
        timeBonusToOpponent = 0.0
        dealMoreButton.isEnabled  = game.numbederOfCardsInDeck > 0
        switch game.currentPlayer {
        case .user1: user2SetButton.isEnabled  = true
        case .user2: user1SetButton.isEnabled  = true
        default: break
        }
        
        if game.gameMatchState == .notMatched {
            timeBonusToOpponent += 5
            completionHandler = { nextPosibleAction.sendActions(for: .touchUpInside) }
        } else {
            
            timeBonusToOpponent = 0
        }
        game.clearSelection()
        game.currentPlayer = .none
        updateViewfromModel()
        completionHandler()
    }
    
    //    MARK: - Update Views From Model

    private func updateViewfromModel()
    {
        if self.matchedCardViews.count == 3 {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
                self.flyaway()
                self.matchedCardViews.forEach { $0.matchState = .notSet }
            }
        } else {
            let numberOfCardViews = gameFieldView.cardViews.count
            for index in game.cardsInGame.indices {
                // Card from Model
                let card = game.cardsInGame[index]
                // Creating cardViews for newly dealt cards
                if index > numberOfCardViews - 1 {
                    let cardView = CardView()
                    addTapGestureRecognizer(for: cardView)
                    gameFieldView.cardViews.append(cardView)
                    cardView.alpha = 0.0
                    cardView.card = card
                    // Else updating cards already on the game field
                } else {
                    let cardView = gameFieldView.cardViews.first(where: { $0.card == card }) ??
                                   gameFieldView.cardViews.first(where: { $0.card == nil })
                    if let cardView = cardView {
                        if cardView.card == nil {
                            cardView.alpha = 0
                            cardView.card = card
                        }
                        updateCardView(cardView)
                    }
                }
            }
        updateUI()
        if game.gameMatchState == .matched { tryForMatching() }
        dealAnimation()
        }
    }
    
    private func updateCardView(_ cardView: CardView) {
        let card = cardView.card!
        cardView.cardIsSelected = game.selectedCards.contains(card)
        cardView.cheatHilighted = false
        // CardView.matchState
        if game.matchedCards.contains(card) { cardView.matchState = .matched }
        else if cardView.cardIsSelected && game.selectedCards.count == 3 { cardView.matchState = .notMatched }
        else { cardView.matchState = .notSet }
    }
    
    private func dealAnimation() {
        var currentCard = 0
        let timeInterval =  0.30
        let cardViews = gameFieldView.cardViews.filter { $0.alpha == 0.0 }
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { timer in
            for cardView in cardViews {
                if cardView.alpha == 0 {
                    cardView.animateApearance(from: self.deckCenter, delay: TimeInterval(currentCard) * 0.4)
                    currentCard += 1
                }
            }
        }
    }
    
    private func updateUI()
    {
        // Disable interaction with cards if no user is in the game (SET button is not pressed).
        if game.currentPlayer != .none {
            gameFieldView.cardViews.forEach { $0.isUserInteractionEnabled = true }
        } else {
            gameFieldView.cardViews.forEach { $0.isUserInteractionEnabled = false }
        }
        
        if game.currentPlayer == .none {
            user1SetButton.isEnabled = true
            user2SetButton.isEnabled = true
            user1SetButton.backgroundColor = Theme.buttonColor
            user2SetButton.backgroundColor = Theme.buttonColor
            dealMoreButton.isEnabled = game.numbederOfCardsInDeck > 0
            // Card can't be selected if there is no current user
            if !game.selectedCards.isEmpty { game.clearSelection() }
        }
        
        if game.numbederOfCardsInDeck == 0 {
            self.dealMoreButton.setBackgroundImage(nil, for: .normal)
        }
        // Enable/disable 'Deal 3 More' buttons
        dealMoreButton.isEnabled = game.numbederOfCardsInDeck > 0
        
        // shows scores of current game
//        user1ScoreDisplayLabel.text      = "\(game.matchedSets[.user1]!)"
//        user2ScoreDisplayLabel.text      = "\(game.matchedSets[.user2]!)"
        
        // Shows if set is matched or not
        switch game.gameMatchState {
        case .matched:      matchStatusLabel.text = "Matched!";
        case .notMatched:   matchStatusLabel.text = "Not Matched..."
        case .notSet:       matchStatusLabel.text = " "
        }
//        cheatButton.isEnabled = game.countOfallFoundSets > 0
//        var cheatButtonString = "\(game.countOfallFoundSets) Set"
//        if game.countOfallFoundSets > 1 { cheatButtonString.append("s") }
//        cheatButton.setTitle(cheatButtonString, for: .normal)
        
        if game.isEnded {
            user1SetButton.isEnabled = false
            user2SetButton.isEnabled = false
            if game.matchedSets[.user1]! > game.matchedSets[.user2]! {
                user1SetButton.setTitle("👤 WINNER!", for: .normal)
                user2SetButton.setTitle("LOSER! 😡", for: .normal)
            } else {
                user1SetButton.setTitle("😡 LOSER!", for: .normal)
                user2SetButton.setTitle("WINNER! 👤", for: .normal)
            }
            matchStatusLabel.text = "🏆 🏆 🏆"
            timer?.invalidate()
        } else {
            user1SetButton.setTitle("👤 SET", for: .normal)
            user2SetButton.setTitle("SET 👤", for: .normal)
        }
    }
    
    // - MARK: - Gestures
    private func addTapGestureRecognizer(for view: CardView) {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapCard(recognizedBy:)))
        tapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapRecognizer)
    }
}
