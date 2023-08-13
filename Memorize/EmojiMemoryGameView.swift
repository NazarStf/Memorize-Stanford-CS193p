//
//  EmojiMemoryGameView.swift
//  Memorize
//
//  Created by NazarStf on 07.08.2023.
//

import SwiftUI

// MARK: - EmojiMemoryGameView Struct
struct EmojiMemoryGameView: View {
	
	// MARK: - Dealing Functions
	@Namespace private var dealingNamespace
	
	@State private var dealt = Set<Int>()
	
	private func deal(_ card: EmojiMemoryGame.Card) {
		dealt.insert(card.id)
	}
	
	private func isUndealt(_ card: EmojiMemoryGame.Card) -> Bool {
		!dealt.contains(card.id)
	}
	
	// MARK: - Observed Game Object
	@ObservedObject var game: EmojiMemoryGame
	
	// MARK: - View Body
	var body: some View {
		VStack {
			gameBody
			deckBody
			shuffle
		}
		.padding()
	}
	
	// MARK: - Game Body
	var gameBody: some View {
		AspectVGrid(items: game.cards, aspectRatio: 2/3) { card in
			if isUndealt(card) || (card.isMatched && !card.isFaceUp) {
				Color.clear
			} else {
				CardView(card)
					.matchedGeometryEffect(id: card.id, in: dealingNamespace)
					.padding(4)
					.transition(AnyTransition.asymmetric(insertion: .identity, removal: .scale))
					.onTapGesture {
						withAnimation(.easeInOut(duration: 0.5)) {
							game.choose(card)
						}
					}
			}
		}
		.foregroundColor(CardConstants.color)
	}
	
	// MARK: - Deck Body
	var deckBody: some View {
		ZStack {
			ForEach(game.cards.filter(isUndealt)) { card in
				CardView(card)
					.matchedGeometryEffect(id: card.id, in: dealingNamespace)
					.transition(AnyTransition.asymmetric(insertion: .opacity, removal: .identity))
			}
		}
		.frame(width: CardConstants.undealtWidth, height: CardConstants.undealtHeight)
		.foregroundColor(CardConstants.color)
		.onTapGesture {
			// "deal" cards
			withAnimation(.easeInOut(duration: 5)) {
				for card in game.cards {
					deal(card)
				}
			}
		}
	}
	
	// MARK: - Shuffle Button
	var shuffle: some View {
		Button("Shuffle") {
			withAnimation {
				game.shuffle()
			}
		}
	}
	
	// MARK: - Card Constants
	private struct CardConstants {
		static let color = Color.red
		static let aspectRatio: CGFloat = 2/3
		static let dealDuration: Double = 0.5
		static let totalDealDuration: Double = 2
		static let undealtHeight: CGFloat = 90
		static let undealtWidth = undealtHeight * aspectRatio
	}
}

// MARK: - Preview Provider
struct EmojiMemoryGameView_Previews: PreviewProvider {
	static var previews: some View {
		let game = EmojiMemoryGame()
		
		EmojiMemoryGameView(game: game)
			.preferredColorScheme(.light)
		EmojiMemoryGameView(game: game)
			.preferredColorScheme(.dark)
	}
}
