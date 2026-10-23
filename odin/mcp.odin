#+feature dynamic-literals
package tcos

import "core:bufio"
import "core:encoding/json"
import "core:fmt"
import "core:io"
import "core:math/rand"
import "core:os"
import "core:strings"
import "core:time"

SERVER_NAME :: "tarot-charlatan-of-splorr"
SERVER_VERSION :: "0.1.0"
DEFAULT_PROTOCOL :: "2025-03-26"

// JSON-RPC error codes
PARSE_ERROR :: -32700
INVALID_REQUEST :: -32600
METHOD_NOT_FOUND :: -32601
INVALID_PARAMS :: -32602

// stdio transport: one JSON-RPC message per line on stdin, replies one per line on stdout.
// stdout is reserved for protocol traffic; diagnostics go to stderr.
serve :: proc() {
	reader: bufio.Reader
	bufio.reader_init(&reader, os.to_stream(os.stdin))
	defer bufio.reader_destroy(&reader)

	for {
		line, err := bufio.reader_read_string(&reader, '\n')
		if len(line) > 0 {
			context.allocator = context.temp_allocator // dynamic literals allocate; freed per message
			handle_line(strings.trim_space(line))
		}
		free_all(context.temp_allocator)
		if err != nil {
			return
		}
	}
}

handle_line :: proc(line: string) {
	if len(line) == 0 {
		return
	}
	value, perr := json.parse(transmute([]u8)line, parse_integers = true, allocator = context.temp_allocator)
	if perr != nil {
		send_error(nil, PARSE_ERROR, "parse error")
		return
	}
	req, is_obj := value.(json.Object)
	if !is_obj {
		send_error(nil, INVALID_REQUEST, "request must be an object")
		return
	}
	id, has_id := req["id"]
	method, _ := req["method"].(json.String)
	if len(method) == 0 {
		if has_id {
			send_error(id, INVALID_REQUEST, "missing method")
		}
		return
	}
	params, _ := req["params"].(json.Object)

	// Notifications (no id) get no reply.
	if !has_id {
		return
	}

	switch method {
	case "initialize":
		proto: json.Value = DEFAULT_PROTOCOL
		if p, ok := params["protocolVersion"].(json.String); ok {
			proto = p
		}
		send_result(id, obj({
			{"protocolVersion", proto},
			{"capabilities", obj({{"tools", obj({})}})},
			{"serverInfo", obj({{"name", SERVER_NAME}, {"version", SERVER_VERSION}})},
		}))
	case "ping":
		send_result(id, obj({}))
	case "tools/list":
		send_result(id, obj({{"tools", tool_definitions()}}))
	case "tools/call":
		name, _ := params["name"].(json.String)
		args, _ := params["arguments"].(json.Object)
		call_tool(id, name, args)
	case:
		send_error(id, METHOD_NOT_FOUND, fmt.tprintf("unknown method: %s", method))
	}
}

tool_definitions :: proc() -> json.Value {
	spread_ids := make(json.Array, 0, len(SPREADS), context.temp_allocator)
	for s in SPREADS {
		append(&spread_ids, s.id)
	}
	return json.Array {
		obj({
			{"name", "list_spreads"},
			{"description", "List the available tarot spreads and the named card positions each one has."},
			{"inputSchema", obj({{"type", "object"}, {"properties", obj({})}})},
		}),
		obj({
			{"name", "draw_reading"},
			{
				"description",
				"Shuffle a fresh 78-card deck and draw a tarot reading for a spread. Each card is independently upright or reversed. Returns the cards by position; interpreting them is up to the caller.",
			},
			{
				"inputSchema",
				obj({
					{"type", "object"},
					{
						"properties",
						obj({
							{"question", obj({{"type", "string"}, {"description", "The question or concern put to the oracle."}})},
							{"spread", obj({{"type", "string"}, {"enum", spread_ids}, {"description", "Which spread to lay out."}})},
							{"seed", obj({{"type", "integer"}, {"description", "Optional RNG seed for a reproducible draw."}})},
						}),
					},
					{"required", json.Array{"question", "spread"}},
				}),
			},
		}),
	}
}

call_tool :: proc(id: json.Value, name: string, args: json.Object) {
	switch name {
	case "list_spreads":
		out := make(json.Array, 0, len(SPREADS), context.temp_allocator)
		for s in SPREADS {
			positions := make(json.Array, 0, len(s.positions), context.temp_allocator)
			for p in s.positions {
				append(&positions, obj({{"id", p.id}, {"name", p.name}}))
			}
			append(&out, obj({{"id", s.id}, {"name", s.name}, {"positions", positions}}))
		}
		send_tool_json(id, obj({{"spreads", out}}))

	case "draw_reading":
		question, q_ok := args["question"].(json.String)
		spread_id, s_ok := args["spread"].(json.String)
		if !q_ok || !s_ok || len(strings.trim_space(question)) == 0 {
			send_tool_error(id, "draw_reading requires non-empty string arguments 'question' and 'spread'")
			return
		}
		spread, found := find_spread(spread_id)
		if !found {
			send_tool_error(id, fmt.tprintf("unknown spread '%s'; use list_spreads", spread_id))
			return
		}

		seed: u64
		switch s in args["seed"] {
		case json.Integer:
			seed = u64(s)
		case json.Float:
			seed = u64(s)
		case nil, json.Null, json.Boolean, json.String, json.Array, json.Object:
			seed = u64(time.now()._nsec)
		}
		state := rand.create(seed)
		deck := deck_shuffled(rand.default_random_generator(&state), context.temp_allocator)

		cards := make(json.Array, 0, len(spread.positions), context.temp_allocator)
		for pos in spread.positions {
			card, _ := deck_draw(&deck)
			append(&cards, obj({
				{"position", pos.id},
				{"position_name", pos.name},
				{"card", CARDS[card.type].name},
				{"arcana", card.type >= 56 ? "major" : "minor"},
				{"reversed", card.reversed},
			}))
		}
		send_tool_json(id, obj({
			{"question", question},
			{"spread", spread.id},
			{"cards", cards},
		}))

	case:
		send_error(id, INVALID_PARAMS, fmt.tprintf("unknown tool: %s", name))
	}
}

// --- JSON helpers -----------------------------------------------------------

Field :: struct {
	key: string,
	val: json.Value,
}

obj :: proc(fields: []Field) -> json.Object {
	o := make(json.Object, len(fields), context.temp_allocator)
	for f in fields {
		o[f.key] = f.val
	}
	return o
}

send_message :: proc(m: json.Object) {
	data, err := json.marshal(m, {}, context.temp_allocator)
	if err != nil {
		fmt.eprintln("marshal failed:", err)
		return
	}
	out := os.to_stream(os.stdout)
	io.write(out, data)
	io.write_byte(out, '\n')
}

send_result :: proc(id: json.Value, result: json.Value) {
	send_message(obj({{"jsonrpc", "2.0"}, {"id", id}, {"result", result}}))
}

send_error :: proc(id: json.Value, code: int, message: string) {
	send_message(obj({
		{"jsonrpc", "2.0"},
		{"id", id},
		{"error", obj({{"code", json.Integer(code)}, {"message", message}})},
	}))
}

send_tool_text :: proc(id: json.Value, text: string, is_error: bool) {
	send_result(id, obj({
		{"content", json.Array{obj({{"type", "text"}, {"text", text}})}},
		{"isError", is_error},
	}))
}

send_tool_json :: proc(id: json.Value, payload: json.Value) {
	text, err := json.marshal(payload, {pretty = true}, context.temp_allocator)
	if err != nil {
		send_tool_error(id, "failed to encode result")
		return
	}
	send_tool_text(id, string(text), false)
}

send_tool_error :: proc(id: json.Value, message: string) {
	send_tool_text(id, message, true)
}
