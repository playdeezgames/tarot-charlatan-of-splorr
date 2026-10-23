package tcos

import "core:fmt"

Suit :: enum {
	Wands,
	Cups,
	Swords,
	Pentacles,
}

Card_Kind :: enum {
	Minor,
	Major,
}

// Static description of one of the 78 cards. Index into `CARDS` is the card id.
Card_Type :: struct {
	name:   string,
	kind:   Card_Kind,
	suit:   Suit, // only meaningful for Minor
	number: int, // minor: 1 (ace)..14 (king); major: 0 (Fool)..21 (World)
}

Card :: struct {
	type:     int, // index into CARDS
	reversed: bool,
}

CARD_COUNT :: 78

MINOR_RANKS := [14]string {
	"Ace", "Two", "Three", "Four", "Five", "Six", "Seven",
	"Eight", "Nine", "Ten", "Page", "Knight", "Queen", "King",
}

MAJOR_NAMES := [22]string {
	"The Fool", "The Magician", "The High Priestess", "The Empress", "The Emperor",
	"The Hierophant", "The Lovers", "The Chariot", "Strength", "The Hermit",
	"Wheel of Fortune", "Justice", "The Hanged Man", "Death", "Temperance",
	"The Devil", "The Tower", "The Star", "The Moon", "The Sun", "Judgement", "The World",
}

MAJOR_NUMERALS := [22]string {
	"0", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X",
	"XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX", "XXI",
}

CARDS: [CARD_COUNT]Card_Type

// Builds the card table. Names are heap-allocated once and live for the whole process.
cards_init :: proc() {
	i := 0
	for suit in Suit {
		for rank in 0 ..< 14 {
			CARDS[i] = {
				name   = fmt.aprintf("%s of %v", MINOR_RANKS[rank], suit),
				kind   = .Minor,
				suit   = suit,
				number = rank + 1,
			}
			i += 1
		}
	}
	for n in 0 ..< 22 {
		CARDS[i] = {
			name   = fmt.aprintf("%s (%s)", MAJOR_NAMES[n], MAJOR_NUMERALS[n]),
			kind   = .Major,
			number = n,
		}
		i += 1
	}
}

card_display :: proc(card: Card) -> string {
	name := CARDS[card.type].name
	if card.reversed {
		return fmt.tprintf("%s (reversed)", name)
	}
	return name
}
