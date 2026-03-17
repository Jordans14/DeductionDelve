class_name ProfileShellBuilders
extends RefCounted

static func build_home_momentum_line(profile: Dictionary, next_track_preview: String, active_crawl_lines: Array[String], relationship_preview: Array[String]) -> String:
	var active_crawl: Dictionary = Dictionary(profile.get("active_crawl", {}))
	if not active_crawl.is_empty():
		var momentum := _first_string(_string_array(active_crawl.get("momentum_history", [])), "").replace("_", " ")
		var identity := _first_string(_string_array(active_crawl.get("crawl_identity", [])), "")
		var challenge := str(active_crawl.get("public_challenge", "")).strip_edges()
		var promise := str(active_crawl.get("promise_pressure", "")).strip_edges()
		var belief := _first_string(_string_array(active_crawl.get("belief_pressure", [])), "")
		var model := _first_string(_string_array(active_crawl.get("model_memory", [])), "")
		var fault := _first_string(_string_array(active_crawl.get("fault_memory", [])), "")
		var memorial := _first_string(_string_array(active_crawl.get("memorial_residue", [])), "")
		if not momentum.is_empty():
			if not challenge.is_empty():
				return "%s | %s | %s" % [momentum.capitalize(), challenge, next_track_preview]
			if not promise.is_empty():
				return "%s | %s | %s" % [momentum.capitalize(), promise, next_track_preview]
			if not belief.is_empty():
				return "%s | %s | %s" % [momentum.capitalize(), belief, next_track_preview]
			if not model.is_empty():
				return "%s | %s | %s" % [momentum.capitalize(), model, next_track_preview]
			if not fault.is_empty():
				return "%s | %s | %s" % [momentum.capitalize(), fault, next_track_preview]
			if not memorial.is_empty():
				return "%s | %s | %s" % [momentum.capitalize(), memorial, next_track_preview]
			if not identity.is_empty():
				return "%s | %s | %s" % [momentum.capitalize(), identity, next_track_preview]
			return "%s | %s" % [momentum.capitalize(), next_track_preview]
	if not active_crawl_lines.is_empty():
		return "%s | %s" % [active_crawl_lines[0], next_track_preview]
	if not relationship_preview.is_empty():
		return "%s | %s" % [relationship_preview[0], next_track_preview]
	return next_track_preview

static func build_party_continuity_line(profile: Dictionary, session_overview: Dictionary) -> String:
	var active_crawl: Dictionary = Dictionary(profile.get("active_crawl", {}))
	var fabric: Dictionary = Dictionary(profile.get("relationship_fabric", {}))
	var world_memory: Dictionary = Dictionary(profile.get("world_memory", {}))
	var connected := bool(session_overview.get("connected", false))
	if connected and not active_crawl.is_empty():
		var public_challenge := str(active_crawl.get("public_challenge", "")).strip_edges()
		var promise_pressure := str(active_crawl.get("promise_pressure", "")).strip_edges()
		if not public_challenge.is_empty():
			return "continue with the current lobby | %s" % public_challenge
		if not promise_pressure.is_empty():
			return "continue with the current lobby | %s" % promise_pressure
		return "continue with the current lobby"
	if connected:
		return "continue with the current lobby"
	var recent_pairs := _string_array(fabric.get("recent_pairs", []))
	if not recent_pairs.is_empty():
		var pair_entry: Dictionary = Dictionary(Dictionary(fabric.get("pairs", {})).get(recent_pairs[0], {}))
		var pair_pull := _first_string(_string_array(pair_entry.get("obligations", [])), str(pair_entry.get("public_reputation", "")))
		if not pair_pull.is_empty():
			return pair_pull
	var recent_crews := _string_array(fabric.get("recent_crews", []))
	if not recent_crews.is_empty():
		var crew_entry: Dictionary = Dictionary(Dictionary(fabric.get("crews", {})).get(recent_crews[0], {}))
		var crew_pull := _first_string(_string_array(crew_entry.get("obligations", [])), str(crew_entry.get("public_reputation", "")))
		if not crew_pull.is_empty():
			return crew_pull
	var world_focus := str(Dictionary(world_memory.get("fascination", {})).get("current_focus", "")).strip_edges()
	var world_pressure := str(Dictionary(world_memory.get("fascination", {})).get("pressure", "")).strip_edges()
	if not world_focus.is_empty():
		if not world_pressure.is_empty():
			return world_pressure
		return "the world is still watching %s" % world_focus.to_lower()
	var last_run: Dictionary = Dictionary(profile.get("last_run", {}))
	var frame: Dictionary = Dictionary(last_run.get("frame", {}))
	var world_pull := str(frame.get("world_pull", "")).strip_edges()
	if not world_pull.is_empty():
		return world_pull
	return "review the last run and carry the pressure forward"

static func build_relationship_preview_lines(profile: Dictionary) -> Array[String]:
	var fabric: Dictionary = Dictionary(profile.get("relationship_fabric", {}))
	var players: Dictionary = Dictionary(fabric.get("players", {}))
	var pairs: Dictionary = Dictionary(fabric.get("pairs", {}))
	var crews: Dictionary = Dictionary(fabric.get("crews", {}))
	var recent_players := _string_array(players.keys())
	recent_players.sort()
	var recent_pairs := _string_array(fabric.get("recent_pairs", []))
	var recent_crews := _string_array(fabric.get("recent_crews", []))
	var lines: Array[String] = []
	if not recent_players.is_empty():
		var player_entry: Dictionary = Dictionary(players.get(recent_players[0], {}))
		var player_line := "Delver echo: %s" % str(player_entry.get("title", "Remembered delver"))
		var player_expectation := _first_string(_string_array(player_entry.get("obligations", [])), "")
		if not player_expectation.is_empty():
			player_line += " | %s" % player_expectation
		var player_read := str(player_entry.get("public_reputation", "")).strip_edges()
		if not player_read.is_empty():
			player_line += " | %s" % player_read
		var player_burden := str(player_entry.get("status_burden", "")).strip_edges()
		if not player_burden.is_empty():
			player_line += " | %s" % player_burden
		if int(player_entry.get("near_misses", 0)) >= 2:
			player_line += " | unfinished pressure still follows"
		lines.append(player_line)
	if not recent_pairs.is_empty():
		var pair: Dictionary = Dictionary(pairs.get(recent_pairs[0], {}))
		var pair_line := "Pair echo: %s" % str(pair.get("title", "Recurring pair"))
		var obligation := _first_string(_string_array(pair.get("obligations", [])), "")
		if not obligation.is_empty():
			pair_line += " | %s" % obligation
		var status_burden := str(pair.get("status_burden", "")).strip_edges()
		if not status_burden.is_empty():
			pair_line += " | %s" % status_burden
		var pair_reputation := str(pair.get("public_reputation", "")).strip_edges()
		if not pair_reputation.is_empty():
			pair_line += " | %s" % pair_reputation
		var pair_belief := _first_string(_string_array(pair.get("signals", [])), "")
		if not pair_belief.is_empty() and pair_line.find(pair_belief) == -1:
			pair_line += " | %s" % pair_belief
		if int(pair.get("near_misses", 0)) >= 2:
			pair_line += " | almost still hangs over it"
		lines.append(pair_line)
	if not recent_crews.is_empty():
		var crew: Dictionary = Dictionary(crews.get(recent_crews[0], {}))
		var crew_line := "Crew echo: %s" % str(crew.get("title", "Recurring crew"))
		var burden := str(crew.get("status_burden", "")).strip_edges()
		if not burden.is_empty():
			crew_line += " | %s" % burden
		var obligation := _first_string(_string_array(crew.get("obligations", [])), "")
		if not obligation.is_empty():
			crew_line += " | %s" % obligation
		var crew_reputation := str(crew.get("public_reputation", "")).strip_edges()
		if not crew_reputation.is_empty():
			crew_line += " | %s" % crew_reputation
		var crew_signal := _first_string(_string_array(crew.get("signals", [])), "")
		if not crew_signal.is_empty() and crew_line.find(crew_signal) == -1:
			crew_line += " | %s" % crew_signal
		if int(crew.get("collapse_moments", 0)) >= 2:
			crew_line += " | collapse history still colors the read"
		lines.append(crew_line)
	return lines

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result

static func _first_string(values: Array[String], fallback: String) -> String:
	for value in values:
		var text := str(value).strip_edges()
		if not text.is_empty():
			return text
	return fallback
