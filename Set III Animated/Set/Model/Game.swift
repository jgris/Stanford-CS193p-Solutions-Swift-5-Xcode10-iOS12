//
//  Game.swift
//  Set
//
//  Created by J. Grishin on 7/13/19.
//  Copyright © 2019 J. Grishin. All rights reserved.
//

import Foundation

struct Game
{
    private var deck: Deck
    var currentPlayer: Player = .none
    
    //     MARK: - Initialisations
    /// Creates instance of Deck and
    init() {
        self.deck = Deck()
        self.cardsInGame = takeCardsFromDeck(amount: 12)
        findSets()
        // Initial point in time
        lastActionTime = Date()
    }
    
    //    MARK: - Public API
    
    /// Number of cards in deck.
    var numbederOfCardsInDeck:  Int { return deck.count }
    
    /// Number of all visible sets
    var countOfallFoundSets:    Int { return allFoundSets.count }
    
    private(set) var currentCheatSet = [Card]()
    
    // When the property is set, looking for all Sets of cards in the game
    // We have to call findSets() every time we set 'cardsInGame',
    // because matching combinations with new cards in the game will be different.
    /// Cards currently in the game
    private(set) var cardsInGame = [Card]() { didSet { findSets() } }
    
    /// Cards been selected for matching
    private(set) var selectedCards = [Card]()
    
    /// Cards from last matched set
    private(set) var matchedCards = [Card]()
    
    // Counter of successful matches
    private(set) var matchedSets: [Player: Int] = [.user1: 0, .user2: 0]
    // Scores of the current game
    private(set) var score: [Player: Int] = [.user1: 0, .user2: 0]
    
    // Returns true if it's impossible to find at least one set and there are no cards in the deck.
    var isEnded: Bool {
        return allFoundSets.isEmpty && numbederOfCardsInDeck == 0
    }

    /// Toggle card selection
    mutating func chooseCard(_ card: Card) {
        if !selectedCards.contains(card) {
            selectCard(card)
        } else {
            deselectCard(card)
        }
    }
    
    /// Puts taken [Card] from the deck to 'cardsInGame'
    mutating func deal(_ amount: Int) {
        if gameMatchState == .matched {
            cleanAfterMatching()
        } else {
            // Extra Credit 2 - penalize pressing Deal if at least 1 Set is visible.
            if !allFoundSets.isEmpty { setScore(for: .dealIfSets) }
            let cards = takeCardsFromDeck(amount: amount)
            cardsInGame += cards
        }
    }
    
    // Reshuffle cards in game
    mutating func resuffleCards() {
        cardsInGame.shuffle()
    }
    
    /// Returns one of the visible sets;
    /// Removes its from 'allFoundSets'
    /// - Returns: Array [Card]
    mutating func cheatSet(){
        guard !allFoundSets.isEmpty else { return }
        currentCheatSet = allFoundSets.removeFirst()
    }
    
    mutating func clearSelection() {
        guard 1...3 ~= selectedCards.count else { return }
            cleanAfterMatching()
    }
    
    // MARK: - Internal Implementation
    
    // Extra Credit 1 - "speed of play"
    /// Here we set a point in time in order to track player speed
    private var lastActionTime: Date?
    
    /// Array with all found Sets
    private var allFoundSets = [[Card]]()
    
    /// Can have one of three states of type 'MatchState':
    /// .matched, .notMatched, .notSet
    private(set) var gameMatchState: MatchState = .notSet
    
    ///  Returns '[Card]' by removing 'number' of 'Card's in 'deck'
    ///  if 'deck' has that number of 'Card's.
    private mutating func takeCardsFromDeck(amount: Int) -> [Card] {
        assert(deck.count > 0, "There are no cards in the deck.")
        var cards = [Card]()
        for _ in 1...amount {
            cards.append(deck.cards.removeFirst())
        }
        return cards
    }
    
    private mutating func selectCard(_ card: Card) {
        if selectedCards.count       < 2 { selectedCards.append(card) }
        else if selectedCards.count == 2 { selectedCards.append(card); matchCards() }
        else if selectedCards.count == 3 { cleanAfterMatching(); selectedCards.append(card) }
    }
    
    private mutating func deselectCard(_ card: Card) {
        assert(selectedCards.contains(card), "There is no such 'Card' in 'selectedCards'")
        if let cardIndex = selectedCards.firstIndex(of: card) {
            selectedCards.remove(at: cardIndex)
            setScore(for: .deselected)
        }
    }
    
    /// Find all matched sets of cards in the game and stores it in 'allFoundSets' of the game.
    /// Add random set to iphoneRandomSet.
    mutating func findSets() {
        guard cardsInGame.count > 2 else { return }
        if !allFoundSets.isEmpty { allFoundSets.removeAll() }
        for i in 0..<cardsInGame.count {
            for j in (i+1)..<cardsInGame.count {
                for k in (j+1)..<cardsInGame.count {
                    let cards = [cardsInGame[i], cardsInGame[j], cardsInGame[k]]
                    // Testing cards for matching using method 'isSet()' of our extension of Array<Card>
                    if cards.isSet { allFoundSets.append(cards) }
                }
            }
        }
    }
    
    /// Tests selected cards for matching
    private mutating func matchCards() {
        guard selectedCards.count == 3 else { return }
        // Testing cards for matching using method 'isSet()' of our extension of Array<Card>
        if selectedCards.isSet {
            // Populate 'matchedCards' with contents of 'selectedCard'
            matchedCards += selectedCards
            matchedSets[currentPlayer]? += 1
            gameMatchState = .matched
            setScore(for: .matched)
            
           /* If there is matched set on table, remove sets containing matched cards out of the allFoundSets.
             We do it because if we tap on Cheat button while matched set is displayed on the table,
             we don't want to see highlited cheats with cards that already matched and will be removed
             from the table in a second. */
//            print(randomIphoneSet.map {"card \($0.identifier)"}, "-" ) // test
            for card in matchedCards {
                allFoundSets.forEach { set in
                    if set.contains(card) { allFoundSets.removeElements([set]) }
                }
            }
            
        } else {
            gameMatchState = .notMatched
            setScore(for: .mismatched)
        }
    }

    private mutating func cleanAfterMatching() {
        // remove contents of 'selectedCards'
        selectedCards.removeAll()
        // Doing the rest only if set is matched
        guard gameMatchState == .matched else { gameMatchState = .notSet; return }
        // If set is matched, take new 3 cards from the deck;
        // Replace matched cards in 'cardsInGame' with new ones;
        // or remove matched cards if no cards in the deck
        if numbederOfCardsInDeck > 0 {
            let newCards = takeCardsFromDeck(amount: 3)
            cardsInGame.replaceElements(matchedCards, to: newCards)
        } else {
            cardsInGame.removeElements(matchedCards)
        }
        gameMatchState = .notSet
        // remove contents of 'matchedCards'
        matchedCards.removeAll()
        lastActionTime = Date()
    }
    
    /// Sets 'score' of the game for player's action:
    /// Set matched: +3 points, mismatched: -3, card was deselected: -1 point.
    /// - Parameters:
    ///     - action: type 'Points'
    private mutating func setScore(for action: Points) {
        if action == .matched {
            let timePenalty = min(-Int(lastActionTime?.timeIntervalSinceNow ?? 0), 4)
            score[currentPlayer]? += action.score - timePenalty
        } else {
            score[currentPlayer]? += action.score
        }
    }
    
    // Points for player's actions
    private enum Points: Int {
        case matched
        case mismatched
        case deselected
        case dealIfSets
        
        var score: Int {
            switch self {
            case .matched: return 5
            case .mismatched: return -3
            case .deselected, .dealIfSets: return -1
            }
        }
    }
    
    enum MatchState {
        case matched, notMatched, notSet
    }
    
    enum Player {
        case user1
        case user2
        case none
    }

}

extension Int {
    var asString: String {
        return String(self)
    }
}

extension Array where Element: Equatable {
    /// Replaces elements at specified positions with new ones
    /// - Parameters:
    ///     - oldElements: Array with Elements to replace, if found in 'self'
    ///     - newElements: New elements
    mutating func replaceElements(_ oldElements: [Element], to newElements: [Element]) {
        guard oldElements.count == newElements.count else { return }
        for count in 0..<oldElements.count {
            if let destinationIndex = self.firstIndex(of: oldElements[count]) {
                self[destinationIndex] = newElements[count]
            }
        }
    }
    
    mutating func removeElements(_ elements: [Element]) {
        self = self.filter { !elements.contains($0) }
    }
}
// It might be more convenient to use an Array extension to match 3 cards in Array.
extension Array where Element == Card {
    /// Returns 'true' if cards in 'self' is matched.
    var isSet: Bool {
        guard self.count == 3 else { return false }
        return self.reduce(0, { $0 + $1.number }) % 3 == 0 &&
               self.reduce(0, { $0 + $1.shape }) % 3 == 0 &&
               self.reduce(0, { $0 + $1.color }) % 3 == 0 &&
               self.reduce(0, { $0 + $1.fill }) % 3 == 0
    }
}
