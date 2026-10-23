package tcos

Position :: struct {
	id:   string, // stable machine name
	name: string, // human label
}

Spread :: struct {
	id:        string,
	name:      string,
	positions: []Position,
}

// To add a spread, append here; the MCP tool schema and listings derive from this table.
SPREADS := []Spread {
	{id = "single_card", name = "Single Card", positions = {{"single_card", "Single Card"}}},
	{
		id = "three_card",
		name = "Three Card",
		positions = {{"past", "Past"}, {"present", "Present"}, {"future", "Future"}},
	},
	{
		id = "celtic_cross",
		name = "Celtic Cross",
		positions = {
			{"present", "Present"},
			{"challenge", "Challenge"},
			{"foundation", "Foundation"},
			{"recent_past", "Recent Past"},
			{"crown", "Crown"},
			{"near_future", "Near Future"},
			{"self", "Self"},
			{"environment", "Environment"},
			{"hopes_and_fears", "Hopes and Fears"},
			{"outcome", "Outcome"},
		},
	},
}

find_spread :: proc(id: string) -> (spread: Spread, ok: bool) {
	for s in SPREADS {
		if s.id == id {
			return s, true
		}
	}
	return {}, false
}
