package tcos

import "core:math/rand"

Deck :: struct {
	cards: [dynamic]Card,
}

// Fresh 78-card deck, shuffled, each card independently reversed with 50% probability.
// Pass a seeded generator for reproducible readings.
deck_shuffled :: proc(gen: rand.Generator, allocator := context.allocator) -> Deck {
	context.random_generator = gen
	deck := Deck{cards = make([dynamic]Card, 0, CARD_COUNT, allocator)}
	for i in 0 ..< CARD_COUNT {
		append(&deck.cards, Card{type = i})
	}
	rand.shuffle(deck.cards[:])
	for &c in deck.cards {
		c.reversed = rand.int_max(2) == 1
	}
	return deck
}

deck_draw :: proc(deck: ^Deck) -> (card: Card, ok: bool) {
	if len(deck.cards) == 0 {
		return {}, false
	}
	card = deck.cards[0]
	ordered_remove(&deck.cards, 0)
	return card, true
}
