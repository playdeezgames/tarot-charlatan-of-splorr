package tcos

import "core:math/rand"
import "base:runtime"
import "core:testing"

// cards_init heap-allocates names for the life of the process; do it once, outside the
// test runner's leak-tracking allocator.
@(private = "file")
ensure_cards :: proc() {
	@(static) done: bool
	if done {
		return
	}
	context.allocator = runtime.heap_allocator()
	cards_init()
	done = true
}

@(private = "file")
seeded :: proc(seed: u64, state: ^rand.Default_Random_State) -> rand.Generator {
	state^ = rand.create(seed)
	return rand.default_random_generator(state)
}

@(test)
test_card_table :: proc(t: ^testing.T) {
	ensure_cards()
	seen := make(map[string]bool, CARD_COUNT, context.temp_allocator)
	majors, minors: int
	for c in CARDS {
		testing.expect(t, len(c.name) > 0)
		testing.expectf(t, !seen[c.name], "duplicate card name %q", c.name)
		seen[c.name] = true
		switch c.kind {
		case .Major:
			majors += 1
		case .Minor:
			minors += 1
		}
	}
	testing.expect_value(t, majors, 22)
	testing.expect_value(t, minors, 56)
}

@(test)
test_card_names :: proc(t: ^testing.T) {
	ensure_cards()
	testing.expect_value(t, CARDS[0].name, "Ace of Wands")
	testing.expect_value(t, CARDS[55].name, "King of Pentacles")
	testing.expect_value(t, CARDS[56].name, "The Fool (0)")
	testing.expect_value(t, CARDS[58].name, "The High Priestess (II)")
	testing.expect_value(t, CARDS[73].name, "The Star (XVII)")
	testing.expect_value(t, CARDS[74].name, "The Moon (XVIII)")
	testing.expect_value(t, CARDS[77].name, "The World (XXI)")
}

@(test)
test_deck_is_full_permutation :: proc(t: ^testing.T) {
	state: rand.Default_Random_State
	deck := deck_shuffled(seeded(1, &state), context.temp_allocator)
	testing.expect_value(t, len(deck.cards), CARD_COUNT)
	seen: [CARD_COUNT]bool
	for c in deck.cards {
		testing.expect(t, !seen[c.type])
		seen[c.type] = true
	}
}

@(test)
test_deck_seed_is_deterministic :: proc(t: ^testing.T) {
	sa, sb, sc: rand.Default_Random_State
	a := deck_shuffled(seeded(42, &sa), context.temp_allocator)
	b := deck_shuffled(seeded(42, &sb), context.temp_allocator)
	c := deck_shuffled(seeded(43, &sc), context.temp_allocator)
	same_ab, same_ac := true, true
	for i in 0 ..< CARD_COUNT {
		same_ab &&= a.cards[i] == b.cards[i]
		same_ac &&= a.cards[i] == c.cards[i]
	}
	testing.expect(t, same_ab, "same seed should give same deck")
	testing.expect(t, !same_ac, "different seed should give different deck")
}

@(test)
test_deck_reversal_is_mixed :: proc(t: ^testing.T) {
	state: rand.Default_Random_State
	deck := deck_shuffled(seeded(7, &state), context.temp_allocator)
	reversed := 0
	for c in deck.cards {
		if c.reversed {
			reversed += 1
		}
	}
	testing.expectf(t, reversed > 10 && reversed < 68, "reversed count %d implausible", reversed)
}

@(test)
test_deck_draw_exhausts :: proc(t: ^testing.T) {
	state: rand.Default_Random_State
	deck := deck_shuffled(seeded(3, &state), context.temp_allocator)
	for _ in 0 ..< CARD_COUNT {
		_, ok := deck_draw(&deck)
		testing.expect(t, ok)
	}
	_, ok := deck_draw(&deck)
	testing.expect(t, !ok, "empty deck should not yield a card")
}

@(test)
test_spreads :: proc(t: ^testing.T) {
	Expect :: struct {
		id:    string,
		count: int,
	}
	expected := [?]Expect{{"single_card", 1}, {"three_card", 3}, {"celtic_cross", 10}}
	testing.expect_value(t, len(SPREADS), len(expected))
	for e in expected {
		s, ok := find_spread(e.id)
		testing.expectf(t, ok, "missing spread %s", e.id)
		testing.expect_value(t, len(s.positions), e.count)
		id := e.id
		seen := make(map[string]bool, 16, context.temp_allocator)
		for p in s.positions {
			testing.expectf(t, !seen[p.id], "duplicate position %s in %s", p.id, id)
			seen[p.id] = true
		}
	}
	_, ok := find_spread("nope")
	testing.expect(t, !ok)
}

@(test)
test_every_spread_can_be_drawn :: proc(t: ^testing.T) {
	for s in SPREADS {
		state: rand.Default_Random_State
		deck := deck_shuffled(seeded(5, &state), context.temp_allocator)
		for _ in s.positions {
			_, ok := deck_draw(&deck)
			testing.expectf(t, ok, "ran out of cards in %s", s.id)
		}
	}
}
