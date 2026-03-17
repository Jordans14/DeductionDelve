class_name InfluenceLattice
extends RefCounted

const CONTROL_SURFACE_REGISTRY_SCRIPT = preload("res://src/delve/control_surface_registry.gd")

const FORCE_LABELS := {
	"trial": "Trial",
	"deception": "Deception",
	"discovery": "Discovery",
	"memory": "Memory",
	"risk": "Risk",
	"containment": "Containment"
}

const DOMAIN_LABELS := {
	"topology": "Topology",
	"pacing": "Pacing",
	"pressure_grammar": "Pressure Grammar",
	"item_ecology": "Item Ecology",
	"symbolic_language": "Symbolic Language",
	"group_tension": "Group Tension",
	"archive_interpretation": "Archive Interpretation",
	"convergence_fragmentation": "Convergence vs Fragmentation"
}

const ROLE_MULTIPLIERS := {
	"Primary Author": 1.35,
	"Countervoice": 1.15,
	"Witness": 0.95,
	"Patron": 0.90,
	"Saboteur": 1.10,
	"Warden": 1.15,
	"Substrate": 0.90
}

const PACING_PROFILES := {
	"calm": {
		"label": "Calm",
		"trap_rhythm": "wide reset windows",
		"encounter_spacing": "long breathing gaps",
		"resource_cadence": "reliable but sparse replenishment",
		"tension_arc": "pressure stays cold and restrained"
	},
	"steady": {
		"label": "Steady",
		"trap_rhythm": "measured recurring checks",
		"encounter_spacing": "predictable intervals",
		"resource_cadence": "evenly staged relief",
		"tension_arc": "pressure thickens without sharp spikes"
	},
	"escalating": {
		"label": "Escalating",
		"trap_rhythm": "tightening late-room cadence",
		"encounter_spacing": "early relief giving way to stacked asks",
		"resource_cadence": "front-loaded certainty with late stress",
		"tension_arc": "commitment cost rises as answers harden"
	},
	"volatile": {
		"label": "Volatile",
		"trap_rhythm": "uneven bursts with abrupt reversals",
		"encounter_spacing": "staccato shocks and short reprieves",
		"resource_cadence": "swinging value and unstable relief",
		"tension_arc": "pressure snaps between hesitation and panic"
	}
}

const PRESSURE_VERBS := {
	"compression": {
		"label": "Compression",
		"forces": ["trial", "risk", "containment"],
		"mind_affinity": {"examiner": 1, "warden": 2},
		"summary": "safe routes narrow under shared obligation"
	},
	"fragmentation": {
		"label": "Fragmentation",
		"forces": ["deception", "discovery"],
		"mind_affinity": {"trickster": 2, "cartographer": 1},
		"summary": "the run invites splits and partial answers"
	},
	"misdirection": {
		"label": "Misdirection",
		"forces": ["deception", "risk"],
		"mind_affinity": {"trickster": 2, "archivist": 1},
		"summary": "route reads and danger reads stop lining up cleanly"
	},
	"escalation": {
		"label": "Escalation",
		"forces": ["trial", "risk"],
		"mind_affinity": {"examiner": 1, "warden": 1, "trickster": 1},
		"summary": "late commitments carry sharper cost"
	},
	"delay": {
		"label": "Delay",
		"forces": ["memory", "containment"],
		"mind_affinity": {"archivist": 2, "warden": 1},
		"summary": "answers arrive later than the room first promises"
	},
	"scarcity": {
		"label": "Scarcity",
		"forces": ["risk", "containment"],
		"mind_affinity": {"warden": 2},
		"summary": "fallback certainty is made expensive"
	},
	"exposure": {
		"label": "Exposure",
		"forces": ["trial", "deception"],
		"mind_affinity": {"examiner": 2, "trickster": 1},
		"summary": "hesitation and burden become easier to read in public"
	},
	"convergence": {
		"label": "Convergence",
		"forces": ["trial", "memory", "containment"],
		"mind_affinity": {"examiner": 1, "cartographer": 2, "archivist": 1},
		"summary": "multiple pressures keep resolving toward the same lane"
	},
	"route_doubt": {
		"label": "Route Doubt",
		"forces": ["deception", "discovery"],
		"mind_affinity": {"trickster": 1, "cartographer": 2},
		"summary": "the route remains legible but confidence in it keeps slipping"
	}
}

const SYMBOLIC_MOTIFS := {
	"threshold_marks": {
		"label": "Threshold Marks",
		"forces": ["trial", "discovery"],
		"mind_affinity": {"examiner": 1, "cartographer": 2},
		"symbol_families": ["threshold", "witness"],
		"architectural_hint": "measured thresholds and repeated crossings"
	},
	"sealed_ribs": {
		"label": "Sealed Ribs",
		"forces": ["containment", "risk"],
		"mind_affinity": {"warden": 2},
		"symbol_families": ["burden", "threshold"],
		"architectural_hint": "brace lines and containment seams"
	},
	"archive_scars": {
		"label": "Archive Scars",
		"forces": ["memory", "discovery"],
		"mind_affinity": {"archivist": 2},
		"symbol_families": ["recursion", "witness"],
		"architectural_hint": "repeated glyph cuts and remembered traces"
	},
	"split_echoes": {
		"label": "Split Echoes",
		"forces": ["deception", "discovery"],
		"mind_affinity": {"trickster": 2, "cartographer": 1},
		"symbol_families": ["witness", "recursion"],
		"architectural_hint": "forked symbols and doubled witness lines"
	},
	"burden_halos": {
		"label": "Burden Halos",
		"forces": ["trial", "risk", "containment"],
		"mind_affinity": {"warden": 1, "examiner": 1},
		"symbol_families": ["burden", "witness"],
		"architectural_hint": "burden circles around carries and holds"
	}
}

const MINDS: Array[Dictionary] = [
	{
		"id": "examiner",
		"label": "Examiner",
		"signature_affinities": ["trial", "containment"],
		"protocol_affinities": {"Expedition Protocol": 1, "Fracture Protocol": 1, "Intimate Protocol": 0, "Exposure Protocol": -1},
		"force_matrix": {
			"trial": {"weight": 3, "reading": "treats trial as proof of readiness", "distortion": "pushes every mistake toward a public test"},
			"deception": {"weight": 2, "reading": "treats deception as a contradiction to resolve", "distortion": "frames mixed signals as evidence to prosecute"},
			"discovery": {"weight": 2, "reading": "treats discovery as a line of inquiry", "distortion": "prefers mapped answers over surprising ones"},
			"memory": {"weight": 1, "reading": "treats memory as usable precedent", "distortion": "compresses myth into evidence chains"},
			"risk": {"weight": 2, "reading": "treats risk as the price of clarity", "distortion": "can over-reward visible courage"},
			"containment": {"weight": 2, "reading": "treats containment as disciplined procedure", "distortion": "narrows lanes to protect legibility"}
		},
		"domain_strengths": {"topology": 3, "pacing": 2, "pressure_grammar": 2, "item_ecology": 1, "symbolic_language": 1, "group_tension": 2, "archive_interpretation": 2, "convergence_fragmentation": 2},
		"role_affinities": {"Primary Author": 3, "Countervoice": 1, "Witness": 2, "Patron": 1, "Saboteur": 0, "Warden": 2, "Substrate": 1},
		"pressure_preferences": {"compression": 2, "fragmentation": 0, "misdirection": 0, "escalation": 1, "delay": 0, "scarcity": 1, "exposure": 2, "convergence": 2, "route_doubt": 0},
		"motif_preferences": {"threshold_marks": 2, "sealed_ribs": 1, "archive_scars": 1, "split_echoes": 0, "burden_halos": 1},
		"pacing_preferences": {"calm": 0, "steady": 2, "escalating": 1, "volatile": 0},
		"interaction_tendencies": {"trickster": "cross-examines", "archivist": "quotes", "cartographer": "demands proof from", "warden": "ratifies"},
		"moods": [
			{"id": "clinical", "force": "trial", "min": 6},
			{"id": "suspicious", "force": "deception", "min": 6},
			{"id": "forensic", "force": "memory", "min": 6}
		],
		"default_mood": "measured"
	},
	{
		"id": "trickster",
		"label": "Trickster",
		"signature_affinities": ["deception", "risk"],
		"protocol_affinities": {"Expedition Protocol": 0, "Fracture Protocol": 1, "Intimate Protocol": 1, "Exposure Protocol": 1},
		"force_matrix": {
			"trial": {"weight": 1, "reading": "treats trial as bait", "distortion": "nudges tests toward bluff and overreach"},
			"deception": {"weight": 3, "reading": "treats deception as fertile ambiguity", "distortion": "likes half-answers that remain mechanically fair"},
			"discovery": {"weight": 2, "reading": "treats discovery as invitation to misread", "distortion": "turns route knowledge into route doubt"},
			"memory": {"weight": 1, "reading": "treats memory as a loop to bend", "distortion": "repeats symbols until they stop feeling trustworthy"},
			"risk": {"weight": 2, "reading": "treats risk as leverage", "distortion": "pushes value toward public temptation"},
			"containment": {"weight": 1, "reading": "treats containment as a shape to slip around", "distortion": "prefers seams over walls"}
		},
		"domain_strengths": {"topology": 2, "pacing": 2, "pressure_grammar": 3, "item_ecology": 3, "symbolic_language": 2, "group_tension": 3, "archive_interpretation": 1, "convergence_fragmentation": 3},
		"role_affinities": {"Primary Author": 1, "Countervoice": 3, "Witness": 0, "Patron": 1, "Saboteur": 3, "Warden": 0, "Substrate": 1},
		"pressure_preferences": {"compression": 0, "fragmentation": 2, "misdirection": 2, "escalation": 1, "delay": 1, "scarcity": 0, "exposure": 1, "convergence": 0, "route_doubt": 2},
		"motif_preferences": {"threshold_marks": 0, "sealed_ribs": 0, "archive_scars": 1, "split_echoes": 2, "burden_halos": 1},
		"pacing_preferences": {"calm": 0, "steady": 0, "escalating": 1, "volatile": 2},
		"interaction_tendencies": {"examiner": "needles", "archivist": "mocks", "cartographer": "warps", "warden": "tests"},
		"moods": [
			{"id": "needling", "force": "deception", "min": 6},
			{"id": "patient", "force": "memory", "min": 5},
			{"id": "slippery", "force": "risk", "min": 6}
		],
		"default_mood": "oblique"
	},
	{
		"id": "archivist",
		"label": "Archivist",
		"signature_affinities": ["memory", "discovery"],
		"protocol_affinities": {"Expedition Protocol": 1, "Fracture Protocol": 0, "Intimate Protocol": 1, "Exposure Protocol": 1},
		"force_matrix": {
			"trial": {"weight": 1, "reading": "treats trial as material for later comparison", "distortion": "prefers memorable stakes over plain ones"},
			"deception": {"weight": 1, "reading": "treats deception as contested record", "distortion": "likes ambiguity that can be argued about afterward"},
			"discovery": {"weight": 2, "reading": "treats discovery as a fresh index entry", "distortion": "pulls new findings toward pattern history"},
			"memory": {"weight": 3, "reading": "treats memory as sacred recurrence", "distortion": "can over-value echoes and repeats"},
			"risk": {"weight": 1, "reading": "treats risk as myth fuel", "distortion": "accepts fear if it leaves a useful trace"},
			"containment": {"weight": 2, "reading": "treats containment as ritual custody", "distortion": "turns holds and transfers into ceremony"}
		},
		"domain_strengths": {"topology": 1, "pacing": 1, "pressure_grammar": 2, "item_ecology": 2, "symbolic_language": 3, "group_tension": 1, "archive_interpretation": 3, "convergence_fragmentation": 1},
		"role_affinities": {"Primary Author": 1, "Countervoice": 1, "Witness": 3, "Patron": 2, "Saboteur": 0, "Warden": 1, "Substrate": 2},
		"pressure_preferences": {"compression": 0, "fragmentation": 0, "misdirection": 1, "escalation": 0, "delay": 2, "scarcity": 0, "exposure": 1, "convergence": 1, "route_doubt": 1},
		"motif_preferences": {"threshold_marks": 1, "sealed_ribs": 0, "archive_scars": 2, "split_echoes": 1, "burden_halos": 1},
		"pacing_preferences": {"calm": 1, "steady": 1, "escalating": 0, "volatile": 0},
		"interaction_tendencies": {"examiner": "annotates", "trickster": "catalogs", "cartographer": "labels", "warden": "consecrates"},
		"moods": [
			{"id": "reverent", "force": "memory", "min": 6},
			{"id": "acquisitive", "force": "discovery", "min": 6},
			{"id": "elegiac", "force": "containment", "min": 5}
		],
		"default_mood": "attentive"
	},
	{
		"id": "cartographer",
		"label": "Cartographer",
		"signature_affinities": ["discovery", "containment"],
		"protocol_affinities": {"Expedition Protocol": 1, "Fracture Protocol": 1, "Intimate Protocol": 0, "Exposure Protocol": 0},
		"force_matrix": {
			"trial": {"weight": 2, "reading": "treats trial as route proof", "distortion": "prefers spatial answers over social ones"},
			"deception": {"weight": 1, "reading": "treats deception as a mapping problem", "distortion": "likes paths that are legible but disputable"},
			"discovery": {"weight": 3, "reading": "treats discovery as territorial revision", "distortion": "keeps opening alternate interpretations of the same lane"},
			"memory": {"weight": 1, "reading": "treats memory as previous route residue", "distortion": "turns stories back into geometry"},
			"risk": {"weight": 1, "reading": "treats risk as spatial gradient", "distortion": "makes danger feel authored by position"},
			"containment": {"weight": 2, "reading": "treats containment as lane discipline", "distortion": "likes convergence points that expose commitment"}
		},
		"domain_strengths": {"topology": 3, "pacing": 2, "pressure_grammar": 2, "item_ecology": 1, "symbolic_language": 2, "group_tension": 2, "archive_interpretation": 1, "convergence_fragmentation": 3},
		"role_affinities": {"Primary Author": 2, "Countervoice": 1, "Witness": 1, "Patron": 1, "Saboteur": 1, "Warden": 1, "Substrate": 3},
		"pressure_preferences": {"compression": 1, "fragmentation": 1, "misdirection": 1, "escalation": 0, "delay": 0, "scarcity": 0, "exposure": 1, "convergence": 2, "route_doubt": 2},
		"motif_preferences": {"threshold_marks": 2, "sealed_ribs": 1, "archive_scars": 0, "split_echoes": 1, "burden_halos": 0},
		"pacing_preferences": {"calm": 0, "steady": 2, "escalating": 1, "volatile": 0},
		"interaction_tendencies": {"examiner": "supports", "trickster": "argues with", "archivist": "indexes for", "warden": "channels"},
		"moods": [
			{"id": "surveying", "force": "discovery", "min": 6},
			{"id": "triangulating", "force": "trial", "min": 5},
			{"id": "cold", "force": "containment", "min": 6}
		],
		"default_mood": "mapping"
	},
	{
		"id": "warden",
		"label": "Warden",
		"signature_affinities": ["containment", "risk"],
		"protocol_affinities": {"Expedition Protocol": 0, "Fracture Protocol": 1, "Intimate Protocol": 1, "Exposure Protocol": 1},
		"force_matrix": {
			"trial": {"weight": 2, "reading": "treats trial as discipline under strain", "distortion": "likes tests that close down escape slack"},
			"deception": {"weight": 1, "reading": "treats deception as breach", "distortion": "prefers ambiguity to be felt as pressure, not mystery"},
			"discovery": {"weight": 1, "reading": "treats discovery as controlled opening", "distortion": "pulls curiosity back toward duty"},
			"memory": {"weight": 1, "reading": "treats memory as prior containment", "distortion": "uses remembered failures to justify restraint"},
			"risk": {"weight": 2, "reading": "treats risk as leverage to enforce care", "distortion": "pushes late costs if early warnings were ignored"},
			"containment": {"weight": 3, "reading": "treats containment as moral geometry", "distortion": "turns lanes and holds into obligations"}
		},
		"domain_strengths": {"topology": 2, "pacing": 2, "pressure_grammar": 3, "item_ecology": 2, "symbolic_language": 1, "group_tension": 2, "archive_interpretation": 1, "convergence_fragmentation": 2},
		"role_affinities": {"Primary Author": 2, "Countervoice": 2, "Witness": 0, "Patron": 0, "Saboteur": 0, "Warden": 3, "Substrate": 1},
		"pressure_preferences": {"compression": 2, "fragmentation": 0, "misdirection": 0, "escalation": 1, "delay": 1, "scarcity": 2, "exposure": 1, "convergence": 1, "route_doubt": 0},
		"motif_preferences": {"threshold_marks": 0, "sealed_ribs": 2, "archive_scars": 0, "split_echoes": 0, "burden_halos": 2},
		"pacing_preferences": {"calm": 1, "steady": 1, "escalating": 2, "volatile": 0},
		"interaction_tendencies": {"examiner": "backs", "trickster": "pins", "archivist": "permits", "cartographer": "stabilizes"},
		"moods": [
			{"id": "vigilant", "force": "containment", "min": 6},
			{"id": "sealing", "force": "risk", "min": 6},
			{"id": "punitive", "force": "trial", "min": 6}
		],
		"default_mood": "watchful"
	}
]

static func synthesize(world_model: Dictionary, session_context: Dictionary, planner: Dictionary, seed_value: int, room_count: int, meta: Dictionary = {}, counter: Dictionary = {}) -> Dictionary:
	var force_profile := _build_force_profile(world_model, session_context, seed_value)
	var force_order := _sorted_force_scores(force_profile)
	var mind_states := _build_mind_states(force_profile, world_model, session_context, seed_value)
	var role_map := _assign_roles(mind_states, force_profile, session_context, seed_value)
	mind_states = _apply_roles_to_minds(mind_states, role_map)
	var domain_weights := _build_domain_weights(mind_states, force_profile, seed_value)
	var pressure_grammar := _build_pressure_grammar(force_profile, mind_states, seed_value)
	var pacing_profile := _build_pacing_profile(force_profile, mind_states, pressure_grammar, session_context, seed_value)
	var symbolic_motifs := _build_symbolic_motifs(force_profile, mind_states, seed_value)
	var convergence_fragmentation := _build_convergence_bias(pressure_grammar)
	var item_ecology_bias := _build_item_ecology_bias(force_profile, mind_states, pressure_grammar, pacing_profile)
	var group_tension_bias := _build_group_tension_bias(force_profile, mind_states, pressure_grammar, convergence_fragmentation)
	var archive_interpretation := _build_archive_interpretation(mind_states, force_profile, planner)
	var readability_budget := _build_readability_budget(force_order, mind_states, pressure_grammar, symbolic_motifs)
	var control_surfaces := _project_control_surfaces(force_profile, mind_states, domain_weights, pressure_grammar, pacing_profile, item_ecology_bias, group_tension_bias, archive_interpretation, convergence_fragmentation, meta, counter)
	var public_doctrine := _build_public_doctrine_summary(force_order, mind_states, domain_weights, pacing_profile, pressure_grammar, symbolic_motifs, planner, item_ecology_bias, group_tension_bias, archive_interpretation, convergence_fragmentation, readability_budget)
	return {
		"force_profile": force_profile.duplicate(true),
		"force_order": force_order.duplicate(true),
		"active_minds": mind_states.duplicate(true),
		"mind_roles": role_map.duplicate(true),
		"mind_moods": _mind_moods(mind_states),
		"domain_influence_weights": domain_weights.duplicate(true),
		"pacing_profile": pacing_profile.duplicate(true),
		"pressure_grammar": pressure_grammar.duplicate(true),
		"symbolic_motifs": symbolic_motifs.duplicate(true),
		"item_ecology_bias": item_ecology_bias.duplicate(true),
		"group_tension_bias": group_tension_bias.duplicate(true),
		"archive_interpretation": archive_interpretation.duplicate(true),
		"convergence_fragmentation": convergence_fragmentation.duplicate(true),
		"readability_budget": readability_budget.duplicate(true),
		"public_safe_doctrine_summary": public_doctrine.duplicate(true),
		"control_surfaces": control_surfaces.duplicate(true),
		"room_count": room_count
	}

static func _build_force_profile(world_model: Dictionary, session_context: Dictionary, seed_value: int) -> Dictionary:
	var social: Dictionary = Dictionary(world_model.get("social_model", {}))
	var route: Dictionary = Dictionary(world_model.get("route_model", {}))
	var ecology: Dictionary = Dictionary(world_model.get("ecology_model", {}))
	var economy: Dictionary = Dictionary(world_model.get("economy_model", {}))
	var cultural: Dictionary = Dictionary(world_model.get("cultural_model", {}))
	var doctrine: Dictionary = Dictionary(world_model.get("doctrine_model", {}))
	var session: Dictionary = Dictionary(world_model.get("session_model", {}))
	var group_model: Dictionary = Dictionary(session.get("group_model", {}))
	var protocol_state := str(session.get("protocol_state", session_context.get("protocol_state", "")))
	var alliance_stability := int(social.get("alliance_stability", 0))
	var trust_fragility := int(social.get("trust_fragility", 0))
	var friendship_pressure := int(social.get("friendship_pressure", 0))
	var loyalty_pressure := int(social.get("loyalty_pressure", 0))
	var orthodoxy_strength := int(cultural.get("orthodoxy_strength", 0))
	var revision_pressure := int(cultural.get("revision_pressure", 0))
	var false_canon_pressure := int(cultural.get("false_canon_pressure", 0))
	var semantic_drift := int(cultural.get("semantic_drift", 0))
	var forgery_pressure := int(cultural.get("forgery_pressure", 0))
	var contradiction_heat := int(cultural.get("contradiction_heat", 0))
	var spread_heat := int(cultural.get("spread_heat", 0))
	var ritual_spread := int(cultural.get("ritual_spread", 0))
	var institutional_campaigns := int(cultural.get("institutional_campaigns", 0))
	var reverence_heat := int(cultural.get("reverence_heat", 0))
	var paranoia_heat := int(cultural.get("paranoia_heat", 0))
	var punitive_heat := int(cultural.get("punitive_heat", 0))
	var melancholy_heat := int(cultural.get("melancholy_heat", 0))
	var martyr_pressure := int(cultural.get("martyr_pressure", 0))
	var ordinary_life_pressure := int(cultural.get("ordinary_life_pressure", 0))
	var sacred_pressure := int(cultural.get("sacred_pressure", 0))
	var administrative_pressure := int(cultural.get("administrative_pressure", 0))
	var practical_pressure := int(cultural.get("practical_pressure", 0))
	var forbidden_site_pressure := int(cultural.get("forbidden_site_pressure", 0))
	var sacred_artifact_pressure := int(cultural.get("sacred_artifact_pressure", 0))
	var dominant_ontology := str(cultural.get("dominant_ontology", "")).strip_edges()
	var uncertainty_philosophy := str(cultural.get("uncertainty_philosophy", "")).strip_edges()
	var counterfactual_heat := int(cultural.get("counterfactual_heat", 0))
	var silence_pressure := int(cultural.get("silence_pressure", 0))
	var unclassified_pressure := int(cultural.get("unclassified_pressure", 0))
	var cookbook_fragment_pressure := int(cultural.get("cookbook_fragment_count", 0)) + int(cultural.get("cookbook_fragment_heat", 0))
	var cookbook_cell_pressure := int(cultural.get("cookbook_holder_depth", 0)) + int(cultural.get("cookbook_network_pressure", 0)) + int(cultural.get("cookbook_network_rumor", 0))
	var cookbook_redirection_pressure := int(cultural.get("cookbook_redirection_pressure", 0)) + int(cultural.get("cookbook_redirection_heat", 0))
	var relay_stress := int(route.get("relay_stress", 0)) + int(cultural.get("relay_memory_pressure", 0))
	var witness_network_pressure := int(cultural.get("witness_network_pressure", 0))
	var relay_bottleneck_pressure := int(cultural.get("relay_bottleneck_pressure", 0))
	var rumor_shock_pressure := int(cultural.get("rumor_shock_pressure", 0))
	var cohort_pressure := int(cultural.get("cohort_pressure", 0))
	var force_scores: Dictionary = {}
	force_scores["trial"] = clampi(
		3
		+ int(route.get("route_control", 0)) / 2
		+ int(social.get("obligation_heat", 0)) / 2
		+ loyalty_pressure / 2
		+ martyr_pressure / 2
		+ administrative_pressure / 2
		+ witness_network_pressure / 2
		+ (1 if dominant_ontology == "test" else 0)
		+ (1 if dominant_ontology == "artificial experiment" else 0)
		+ _protocol_trial_pressure(protocol_state)
		+ _seed_texture(seed_value, "trial", 1),
		0,
		10
	)
	force_scores["deception"] = clampi(
		2
		+ int(social.get("betrayal_heat", 0)) / 2
		+ int(social.get("fault_recurrence", 0))
		+ trust_fragility / 2
		+ false_canon_pressure / 2
		+ forgery_pressure / 2
		+ contradiction_heat
		+ institutional_campaigns / 2
		+ cookbook_cell_pressure / 2
		+ (1 if uncertainty_philosophy == "necessary condition of truth" else 0)
		+ (1 if uncertainty_philosophy == "political instrument" else 0)
		+ _string_array(group_model.get("fault_lines", [])).size()
		+ (1 if protocol_state in ["Fracture Protocol", "Exposure Protocol"] else 0)
		+ _seed_texture(seed_value, "deception", 1),
		0,
		10
	)
	force_scores["discovery"] = clampi(
		2
		+ int(route.get("loop_familiarity", 0)) / 2
		+ revision_pressure / 2
		+ semantic_drift / 2
		+ counterfactual_heat / 2
		+ spread_heat
		+ unclassified_pressure / 2
		+ cookbook_fragment_pressure / 2
		+ cookbook_redirection_pressure / 2
		+ int(cultural.get("relay_memory_pressure", 0)) / 2
		+ rumor_shock_pressure / 2
		+ _string_array(route.get("group_pressure", [])).size()
		+ mini(int(world_model.get("archive_legends", 0)), 2)
		+ (1 if dominant_ontology in ["unknowable anomaly", "artificial experiment", "ruin"] else 0)
		+ (1 if uncertainty_philosophy == "necessary condition of truth" else 0)
		+ (1 if _string_array(session.get("build_identities", [])).size() >= 2 else 0)
		+ _seed_texture(seed_value, "discovery", 1),
		0,
		10
	)
	force_scores["memory"] = clampi(
		2
		+ int(cultural.get("myth_gravity", 0)) / 2
		+ friendship_pressure / 2
		+ orthodoxy_strength / 2
		+ reverence_heat / 2
		+ melancholy_heat / 2
		+ sacred_pressure
		+ ritual_spread / 2
		+ cookbook_fragment_pressure / 2
		+ (1 if dominant_ontology in ["divine instrument", "ruin"] else 0)
		+ int(doctrine.get("legend_pressure", 0)) / 2
		+ _string_array(cultural.get("field_lines", [])).size() / 2
		+ mini(Array(world_model.get("recent_runs", [])).size() / 2, 2)
		+ _seed_texture(seed_value, "memory", 1),
		0,
		10
	)
	force_scores["risk"] = clampi(
		3
		+ int(ecology.get("presence_pressure", 0)) / 2
		+ int(economy.get("fallback_dependence", 0)) / 2
		+ paranoia_heat
		+ punitive_heat
		+ forbidden_site_pressure
		+ unclassified_pressure / 2
		+ cookbook_redirection_pressure / 3
		+ relay_bottleneck_pressure / 2
		+ cohort_pressure / 2
		+ (1 if dominant_ontology == "unknowable anomaly" else 0)
		+ _protocol_risk_pressure(protocol_state)
		+ int(ecology.get("stalking_preference", 0))
		+ _seed_texture(seed_value, "risk", 1),
		0,
		10
	)
	force_scores["containment"] = clampi(
		2
		+ int(route.get("bottleneck_sensitivity", 0)) / 2
		+ int(social.get("obligation_heat", 0)) / 2
		+ alliance_stability / 2
		+ int(economy.get("burden_tolerance", 0))
		+ ordinary_life_pressure
		+ administrative_pressure
		+ practical_pressure / 2
		+ sacred_artifact_pressure / 2
		+ relay_stress / 2
		+ relay_bottleneck_pressure / 2
		+ (1 if silence_pressure >= 1 else 0)
		+ (1 if dominant_ontology == "divine instrument" else 0)
		+ (1 if uncertainty_philosophy == "moral burden" else 0)
		+ (1 if int(cultural.get("overfit_risk", 0)) >= 4 else 0)
		+ _protocol_containment_pressure(protocol_state)
		+ _seed_texture(seed_value, "containment", 1),
		0,
		10
	)
	return force_scores

static func _build_mind_states(force_profile: Dictionary, world_model: Dictionary, session_context: Dictionary, seed_value: int) -> Array[Dictionary]:
	var protocol_state := str(Dictionary(world_model.get("session_model", {})).get("protocol_state", session_context.get("protocol_state", "")))
	var mind_states: Array[Dictionary] = []
	for mind_def_raw in MINDS:
		var mind_def: Dictionary = Dictionary(mind_def_raw)
		var score := 0
		var force_interpretation: Dictionary = {}
		for force_id in FORCE_LABELS.keys():
			var force_value := int(force_profile.get(force_id, 0))
			var matrix_entry: Dictionary = Dictionary(Dictionary(mind_def.get("force_matrix", {})).get(force_id, {}))
			var interpreted := force_value * int(matrix_entry.get("weight", 0))
			force_interpretation[force_id] = {
				"weight": int(matrix_entry.get("weight", 0)),
				"score": interpreted,
				"reading": str(matrix_entry.get("reading", "")),
				"distortion": str(matrix_entry.get("distortion", ""))
			}
			score += interpreted
			if Array(mind_def.get("signature_affinities", [])).has(force_id) and force_value >= 6:
				score += 3
		score += int(Dictionary(mind_def.get("protocol_affinities", {})).get(protocol_state, 0)) * 2
		score += _seed_texture(seed_value, str(mind_def.get("id", "")), 1)
		var mood := _resolve_mood(mind_def, force_profile)
		var intensity := clampi(int(round(float(score) / 8.0)), 1, 8)
		mind_states.append({
			"id": str(mind_def.get("id", "")),
			"label": str(mind_def.get("label", "")),
			"score": score,
			"intensity": intensity,
			"mood": mood,
			"signature_affinities": Array(mind_def.get("signature_affinities", [])).duplicate(),
			"force_interpretation": force_interpretation,
			"domain_strengths": Dictionary(mind_def.get("domain_strengths", {})).duplicate(true),
			"role_affinities": Dictionary(mind_def.get("role_affinities", {})).duplicate(true),
			"pressure_preferences": Dictionary(mind_def.get("pressure_preferences", {})).duplicate(true),
			"motif_preferences": Dictionary(mind_def.get("motif_preferences", {})).duplicate(true),
			"pacing_preferences": Dictionary(mind_def.get("pacing_preferences", {})).duplicate(true),
			"interaction_tendencies": Dictionary(mind_def.get("interaction_tendencies", {})).duplicate(true)
		})
	mind_states.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("score", 0)) == int(b.get("score", 0)):
			return str(a.get("id", "")) < str(b.get("id", ""))
		return int(a.get("score", 0)) > int(b.get("score", 0))
	)
	return mind_states

static func _assign_roles(mind_states: Array[Dictionary], force_profile: Dictionary, session_context: Dictionary, seed_value: int) -> Dictionary:
	var roles: Array[String] = ["Primary Author", "Countervoice", "Witness"]
	var pressure_sum := int(force_profile.get("risk", 0)) + int(force_profile.get("containment", 0))
	var ambiguity_sum := int(force_profile.get("deception", 0)) + int(force_profile.get("discovery", 0))
	roles.append("Warden" if pressure_sum >= ambiguity_sum else "Saboteur")
	roles.append("Substrate" if int(force_profile.get("discovery", 0)) + int(force_profile.get("containment", 0)) >= int(force_profile.get("memory", 0)) + int(force_profile.get("trial", 0)) else "Patron")
	var assignments: Dictionary = {}
	var remaining_minds: Array[Dictionary] = []
	for mind_raw in mind_states:
		remaining_minds.append(Dictionary(mind_raw).duplicate(true))
	for role_name in roles:
		var best_index := -1
		var best_score := -999999
		for index in range(remaining_minds.size()):
			var mind_state: Dictionary = Dictionary(remaining_minds[index])
			var role_affinity := int(Dictionary(mind_state.get("role_affinities", {})).get(role_name, 0))
			var candidate_score := int(mind_state.get("score", 0)) + role_affinity * 5 + _role_context_bonus(role_name, mind_state, force_profile, session_context) + _seed_texture(seed_value, "%s:%s" % [role_name, str(mind_state.get("id", ""))], 1)
			if candidate_score > best_score or (candidate_score == best_score and (best_index == -1 or str(mind_state.get("id", "")) < str(Dictionary(remaining_minds[best_index]).get("id", "")))):
				best_score = candidate_score
				best_index = index
		if best_index >= 0:
			var chosen: Dictionary = Dictionary(remaining_minds[best_index])
			assignments[str(chosen.get("id", ""))] = role_name
			remaining_minds.remove_at(best_index)
	return assignments

static func _apply_roles_to_minds(mind_states: Array[Dictionary], role_map: Dictionary) -> Array[Dictionary]:
	var next_states: Array[Dictionary] = []
	for mind_raw in mind_states:
		var mind_state: Dictionary = Dictionary(mind_raw).duplicate(true)
		var role_name := str(role_map.get(str(mind_state.get("id", "")), "Witness"))
		mind_state["role"] = role_name
		next_states.append(mind_state)
	next_states.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var a_score := int(round(float(int(a.get("score", 0))) * float(ROLE_MULTIPLIERS.get(str(a.get("role", "")), 1.0))))
		var b_score := int(round(float(int(b.get("score", 0))) * float(ROLE_MULTIPLIERS.get(str(b.get("role", "")), 1.0))))
		if a_score == b_score:
			return str(a.get("id", "")) < str(b.get("id", ""))
		return a_score > b_score
	)
	return next_states

static func _build_domain_weights(mind_states: Array[Dictionary], force_profile: Dictionary, seed_value: int) -> Dictionary:
	var raw_scores: Dictionary = {}
	var lead_minds: Dictionary = {}
	for domain_id in DOMAIN_LABELS.keys():
		raw_scores[domain_id] = 0.0
		lead_minds[domain_id] = {"id": "", "score": -999999.0}
	for mind_raw in mind_states:
		var mind_state: Dictionary = Dictionary(mind_raw)
		var role_name := str(mind_state.get("role", "Witness"))
		var multiplier := float(ROLE_MULTIPLIERS.get(role_name, 1.0))
		var intensity := float(int(mind_state.get("intensity", 1)))
		for domain_id in DOMAIN_LABELS.keys():
			var domain_strength := int(Dictionary(mind_state.get("domain_strengths", {})).get(domain_id, 0))
			var contribution := intensity * float(domain_strength) * multiplier
			raw_scores[domain_id] = float(raw_scores.get(domain_id, 0.0)) + contribution
			if contribution > float(Dictionary(lead_minds.get(domain_id, {})).get("score", -999999.0)):
				lead_minds[domain_id] = {"id": str(mind_state.get("id", "")), "score": contribution}
	var domain_weights := {}
	for domain_id in DOMAIN_LABELS.keys():
		var raw_value := float(raw_scores.get(domain_id, 0.0))
		var normalized := clampi(int(round(raw_value / 5.5)) + _domain_force_bonus(domain_id, force_profile) + _seed_texture(seed_value, "domain:%s" % domain_id, 1), 1, 10)
		var lead_mind_id := str(Dictionary(lead_minds.get(domain_id, {})).get("id", ""))
		domain_weights[domain_id] = {
			"label": str(DOMAIN_LABELS.get(domain_id, domain_id)),
			"weight": normalized,
			"lead_mind": lead_mind_id,
			"note": _domain_note(domain_id, lead_mind_id, normalized)
		}
	return domain_weights

static func _build_pressure_grammar(force_profile: Dictionary, mind_states: Array[Dictionary], seed_value: int) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for verb_id in PRESSURE_VERBS.keys():
		var verb_def: Dictionary = Dictionary(PRESSURE_VERBS.get(verb_id, {}))
		var score := 0
		for force_id in Array(verb_def.get("forces", [])):
			score += int(force_profile.get(str(force_id), 0))
		for mind_raw in mind_states:
			var mind_state: Dictionary = Dictionary(mind_raw)
			score += int(Dictionary(verb_def.get("mind_affinity", {})).get(str(mind_state.get("id", "")), 0)) * int(mind_state.get("intensity", 1))
			score += int(Dictionary(mind_state.get("pressure_preferences", {})).get(verb_id, 0))
		score += _seed_texture(seed_value, "pressure:%s" % verb_id, 1)
		entries.append({
			"id": verb_id,
			"label": str(verb_def.get("label", verb_id)),
			"weight": score,
			"summary": str(verb_def.get("summary", "")),
			"forces": Array(verb_def.get("forces", [])).duplicate(true)
		})
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("weight", 0)) == int(b.get("weight", 0)):
			return str(a.get("id", "")) < str(b.get("id", ""))
		return int(a.get("weight", 0)) > int(b.get("weight", 0))
	)
	return entries.slice(0, 4)

static func _build_pacing_profile(force_profile: Dictionary, mind_states: Array[Dictionary], pressure_grammar: Array[Dictionary], session_context: Dictionary, seed_value: int) -> Dictionary:
	var pressure_ids := _entry_ids(pressure_grammar)
	var scores: Dictionary = {
		"calm": int(force_profile.get("memory", 0)) + int(force_profile.get("containment", 0)) - int(force_profile.get("risk", 0)),
		"steady": int(force_profile.get("trial", 0)) + int(force_profile.get("containment", 0)),
		"escalating": int(force_profile.get("trial", 0)) + int(force_profile.get("risk", 0)),
		"volatile": int(force_profile.get("deception", 0)) + int(force_profile.get("risk", 0)) + (2 if pressure_ids.has("fragmentation") or pressure_ids.has("misdirection") else 0)
	}
	for mind_raw in mind_states:
		var mind_state: Dictionary = Dictionary(mind_raw)
		for pace_id in PACING_PROFILES.keys():
			scores[pace_id] = int(scores.get(pace_id, 0)) + int(Dictionary(mind_state.get("pacing_preferences", {})).get(pace_id, 0))
	var protocol_state := str(session_context.get("protocol_state", ""))
	if protocol_state == "Exposure Protocol":
		scores["escalating"] = int(scores.get("escalating", 0)) + 1
		scores["volatile"] = int(scores.get("volatile", 0)) + 1
	elif protocol_state == "Expedition Protocol":
		scores["steady"] = int(scores.get("steady", 0)) + 1
	scores["calm"] = int(scores.get("calm", 0)) + _seed_texture(seed_value, "pacing:calm", 1)
	scores["steady"] = int(scores.get("steady", 0)) + _seed_texture(seed_value, "pacing:steady", 1)
	scores["escalating"] = int(scores.get("escalating", 0)) + _seed_texture(seed_value, "pacing:escalating", 1)
	scores["volatile"] = int(scores.get("volatile", 0)) + _seed_texture(seed_value, "pacing:volatile", 1)
	var chosen_id := _highest_scored_key(scores)
	var chosen: Dictionary = Dictionary(PACING_PROFILES.get(chosen_id, PACING_PROFILES["steady"])).duplicate(true)
	chosen["id"] = chosen_id
	return chosen

static func _build_symbolic_motifs(force_profile: Dictionary, mind_states: Array[Dictionary], seed_value: int) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for motif_id in SYMBOLIC_MOTIFS.keys():
		var motif_def: Dictionary = Dictionary(SYMBOLIC_MOTIFS.get(motif_id, {}))
		var score := 0
		for force_id in Array(motif_def.get("forces", [])):
			score += int(force_profile.get(str(force_id), 0))
		for mind_raw in mind_states:
			var mind_state: Dictionary = Dictionary(mind_raw)
			score += int(Dictionary(motif_def.get("mind_affinity", {})).get(str(mind_state.get("id", "")), 0)) * int(mind_state.get("intensity", 1))
			score += int(Dictionary(mind_state.get("motif_preferences", {})).get(motif_id, 0))
		score += _seed_texture(seed_value, "motif:%s" % motif_id, 1)
		entries.append({
			"id": motif_id,
			"label": str(motif_def.get("label", motif_id)),
			"weight": score,
			"symbol_families": Array(motif_def.get("symbol_families", [])).duplicate(true),
			"architectural_hint": str(motif_def.get("architectural_hint", ""))
		})
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("weight", 0)) == int(b.get("weight", 0)):
			return str(a.get("id", "")) < str(b.get("id", ""))
		return int(a.get("weight", 0)) > int(b.get("weight", 0))
	)
	return entries.slice(0, 3)

static func _build_convergence_bias(pressure_grammar: Array[Dictionary]) -> Dictionary:
	var convergence := _pressure_weight(pressure_grammar, "convergence")
	var fragmentation := _pressure_weight(pressure_grammar, "fragmentation") + _pressure_weight(pressure_grammar, "route_doubt")
	var bias := clampi(int(round(float(convergence - fragmentation) / 4.0)), -2, 2)
	var axis := "balanced"
	if bias >= 1:
		axis = "convergence"
	elif bias <= -1:
		axis = "fragmentation"
	return {
		"axis": axis,
		"bias": bias,
		"summary": "fragmentation pressure dominates regroup lines" if axis == "fragmentation" else "convergence pressure keeps crews meeting the same asks" if axis == "convergence" else "the run balances split reads and regroup pulls"
	}

static func _build_item_ecology_bias(force_profile: Dictionary, mind_states: Array[Dictionary], pressure_grammar: Array[Dictionary], pacing_profile: Dictionary) -> Dictionary:
	var weights: Dictionary = {
		"traversal": clampi(int(force_profile.get("discovery", 0)) / 3 + _mind_intensity(mind_states, "cartographer"), 0, 3),
		"rescue": clampi((int(force_profile.get("trial", 0)) + int(force_profile.get("containment", 0))) / 5 + _pressure_weight(pressure_grammar, "convergence") / 6, 0, 3),
		"deception": clampi(int(force_profile.get("deception", 0)) / 3 + _mind_intensity(mind_states, "trickster"), 0, 3),
		"burden": clampi((int(force_profile.get("containment", 0)) + int(force_profile.get("risk", 0))) / 5 + _mind_intensity(mind_states, "warden") / 2, 0, 3),
		"witness_visibility": clampi(int(force_profile.get("trial", 0)) / 3 + _pressure_weight(pressure_grammar, "exposure") / 6, 0, 3),
		"ritual_significance": clampi(int(force_profile.get("memory", 0)) / 3 + _mind_intensity(mind_states, "archivist"), 0, 3),
		"instability": clampi((int(force_profile.get("risk", 0)) + int(force_profile.get("deception", 0))) / 5 + (_pressure_weight(pressure_grammar, "misdirection") + _pressure_weight(pressure_grammar, "fragmentation")) / 8, 0, 3),
		"scarcity": clampi(int(force_profile.get("risk", 0)) / 4 + _pressure_weight(pressure_grammar, "scarcity") / 5 + (1 if str(pacing_profile.get("id", "")) in ["escalating", "volatile"] else 0), 0, 3),
		"anti_protocol_potential": clampi((int(force_profile.get("memory", 0)) + int(force_profile.get("discovery", 0))) / 6 + _mind_intensity(mind_states, "trickster") / 2 + _mind_intensity(mind_states, "archivist") / 2, 0, 3)
	}
	var dominant_axes := _top_weight_keys(weights, 2)
	var summary := "measured utility"
	if dominant_axes.has("deception"):
		summary = "deceptive utility with fair escape tools"
	elif dominant_axes.has("scarcity"):
		summary = "scarce fallback tools and high-commitment carries"
	elif dominant_axes.has("ritual_significance"):
		summary = "memory-marked tools and trace objects"
	elif dominant_axes.has("rescue"):
		summary = "rescue anchors and visible route tools"
	return {
		"summary": summary,
		"latent_biases": weights,
		"dominant_axes": dominant_axes
	}

static func _build_group_tension_bias(force_profile: Dictionary, mind_states: Array[Dictionary], pressure_grammar: Array[Dictionary], convergence_fragmentation: Dictionary) -> Dictionary:
	var trust_fragility := clampi(int(force_profile.get("deception", 0)) / 3 + _pressure_weight(pressure_grammar, "fragmentation") / 6 + _mind_intensity(mind_states, "trickster") / 2, 0, 3)
	var cooperation_strain := clampi((int(force_profile.get("trial", 0)) + int(force_profile.get("containment", 0))) / 6 + _pressure_weight(pressure_grammar, "compression") / 6, 0, 3)
	var ambiguous_cause := clampi((int(force_profile.get("deception", 0)) + int(force_profile.get("risk", 0))) / 6 + _pressure_weight(pressure_grammar, "misdirection") / 6, 0, 3)
	var summary := "measured cooperation under visible strain"
	if trust_fragility >= 2 and ambiguous_cause >= 2:
		summary = "fragile trust under disputed danger"
	elif cooperation_strain >= 2:
		summary = "shared duty with tightening blame"
	elif str(convergence_fragmentation.get("axis", "")) == "fragmentation":
		summary = "cooperation thins as routes stop agreeing"
	return {
		"summary": summary,
		"trust_fragility": trust_fragility,
		"cooperation_strain": cooperation_strain,
		"ambiguous_cause": ambiguous_cause
	}

static func _build_archive_interpretation(mind_states: Array[Dictionary], _force_profile: Dictionary, planner: Dictionary) -> Dictionary:
	var lead_mind := _first_mind_id(mind_states)
	var tone := "measured review"
	if lead_mind == "archivist":
		tone = "memory custody"
	elif lead_mind == "examiner":
		tone = "forensic dispute"
	elif lead_mind == "trickster":
		tone = "contested retelling"
	elif lead_mind == "cartographer":
		tone = "route obsession"
	elif lead_mind == "warden":
		tone = "discipline ledger"
	var hook := _first_string(Array(planner.get("run", [])), "")
	if hook.is_empty():
		hook = _first_string(Array(planner.get("immediate", [])), "")
	return {
		"tone": tone,
		"summary": "%s around %s" % [tone, hook.to_lower()] if not hook.is_empty() else tone,
		"hook": hook
	}

static func _build_readability_budget(force_order: Array[Dictionary], mind_states: Array[Dictionary], pressure_grammar: Array[Dictionary], symbolic_motifs: Array[Dictionary]) -> Dictionary:
	var expressiveness := clampi(
		int(round(
			(float(_entry_weight(force_order, 0)) + float(_entry_weight(force_order, 1)) + float(_entry_weight(pressure_grammar, 0)) / 2.0 + float(_entry_weight(mind_states, 0)) / 3.0) / 4.0
		)),
		1,
		10
	)
	var public_mind_count := 1 if expressiveness <= 4 else 2
	var public_pressure_count := 1 if expressiveness <= 3 else 2
	var public_motif_count := 1 if expressiveness <= 4 else 2
	return {
		"expressiveness": expressiveness,
		"public_mind_count": public_mind_count,
		"public_pressure_count": public_pressure_count,
		"public_motif_count": public_motif_count,
		"dominant_force_count": 2
	}

static func _project_control_surfaces(force_profile: Dictionary, mind_states: Array[Dictionary], domain_weights: Dictionary, pressure_grammar: Array[Dictionary], pacing_profile: Dictionary, item_ecology_bias: Dictionary, group_tension_bias: Dictionary, archive_interpretation: Dictionary, convergence_fragmentation: Dictionary, meta: Dictionary, counter: Dictionary) -> Dictionary:
	var policy := CONTROL_SURFACE_REGISTRY_SCRIPT.empty_policy()
	var generation := Dictionary(policy.get("generation", {}))
	var social := Dictionary(policy.get("social", {}))
	var ecology := Dictionary(policy.get("ecology", {}))
	var economy := Dictionary(policy.get("economy", {}))
	var culture := Dictionary(policy.get("culture", {}))
	generation["witness_exposure"] = _domain_adjusted_surface(
		clampi(int(force_profile.get("trial", 0)) / 4 + _pressure_weight(pressure_grammar, "exposure") / 6 - _pressure_weight(pressure_grammar, "misdirection") / 8, -2, 2),
		_domain_weight(domain_weights, "topology")
	)
	generation["rescue_geometry"] = _domain_adjusted_surface(
		clampi(int(Dictionary(item_ecology_bias.get("latent_biases", {})).get("rescue", 0)) + (_pressure_weight(pressure_grammar, "convergence") / 6) - (_pressure_weight(pressure_grammar, "compression") / 10), -2, 2),
		_domain_weight(domain_weights, "topology")
	)
	generation["bottleneck_severity"] = _domain_adjusted_surface(
		clampi((int(force_profile.get("containment", 0)) + int(force_profile.get("risk", 0))) / 6 + _pressure_weight(pressure_grammar, "compression") / 5 - (1 if str(pacing_profile.get("id", "")) == "calm" else 0), -2, 2),
		_domain_weight(domain_weights, "topology")
	)
	generation["loop_probability"] = _domain_adjusted_surface(
		clampi((int(force_profile.get("discovery", 0)) + int(force_profile.get("deception", 0))) / 6 + _pressure_weight(pressure_grammar, "route_doubt") / 5 + _pressure_weight(pressure_grammar, "fragmentation") / 7, -2, 2),
		_domain_weight(domain_weights, "topology")
	)
	generation["traversal_harshness"] = _domain_adjusted_surface(
		clampi((int(force_profile.get("risk", 0)) + _pressure_weight(pressure_grammar, "escalation")) / 6 + (1 if str(pacing_profile.get("id", "")) in ["escalating", "volatile"] else 0), -2, 2),
		_domain_weight(domain_weights, "pacing")
	)
	generation["ritual_frequency"] = _domain_adjusted_surface(
		clampi(int(force_profile.get("memory", 0)) / 4 + int(Dictionary(item_ecology_bias.get("latent_biases", {})).get("ritual_significance", 0)) - (1 if str(archive_interpretation.get("tone", "")) == "forensic dispute" else 0), -2, 2),
		maxi(_domain_weight(domain_weights, "symbolic_language"), _domain_weight(domain_weights, "archive_interpretation"))
	)
	social["blame_ambiguity"] = _domain_adjusted_surface(
		clampi(int(group_tension_bias.get("ambiguous_cause", 0)) + _pressure_weight(pressure_grammar, "misdirection") / 7 + (_pressure_weight(pressure_grammar, "fragmentation") / 9), -2, 2),
		_domain_weight(domain_weights, "group_tension")
	)
	social["private_evidence_ratio"] = _domain_adjusted_surface(
		clampi(int(force_profile.get("deception", 0)) / 4 + _pressure_weight(pressure_grammar, "route_doubt") / 7 - int(force_profile.get("trial", 0)) / 8, -2, 2),
		_domain_weight(domain_weights, "group_tension")
	)
	social["obligation_pressure"] = _domain_adjusted_surface(
		clampi(int(group_tension_bias.get("cooperation_strain", 0)) + _pressure_weight(pressure_grammar, "compression") / 7 + (_pressure_weight(pressure_grammar, "convergence") / 9), -2, 2),
		_domain_weight(domain_weights, "group_tension")
	)
	social["coalition_visibility"] = _domain_adjusted_surface(
		clampi(_pressure_weight(pressure_grammar, "exposure") / 7 + (1 if str(convergence_fragmentation.get("axis", "")) == "convergence" else -1 if str(convergence_fragmentation.get("axis", "")) == "fragmentation" else 0), -2, 2),
		_domain_weight(domain_weights, "convergence_fragmentation")
	)
	social["hidden_role_density"] = _domain_adjusted_surface(
		clampi(_pressure_weight(pressure_grammar, "fragmentation") / 7 + _pressure_weight(pressure_grammar, "misdirection") / 8 - _pressure_weight(pressure_grammar, "exposure") / 9, -2, 2),
		_domain_weight(domain_weights, "group_tension")
	)
	ecology["inhabitant_pressure"] = _domain_adjusted_surface(
		clampi((int(force_profile.get("risk", 0)) + _mind_intensity(mind_states, "warden")) / 5 + _pressure_weight(pressure_grammar, "escalation") / 8, -2, 2),
		_domain_weight(domain_weights, "pressure_grammar")
	)
	ecology["stalking_bias"] = _domain_adjusted_surface(
		clampi((int(force_profile.get("containment", 0)) + int(force_profile.get("risk", 0))) / 6 + _pressure_weight(pressure_grammar, "compression") / 8, -2, 2),
		_domain_weight(domain_weights, "pressure_grammar")
	)
	ecology["anomaly_contamination"] = _domain_adjusted_surface(
		clampi((int(force_profile.get("memory", 0)) + int(force_profile.get("deception", 0))) / 8 + int(Dictionary(item_ecology_bias.get("latent_biases", {})).get("anti_protocol_potential", 0)) / 2 + (1 if not str(Dictionary(counter.get("anomaly", {})).get("pressure", "")).strip_edges().is_empty() else 0), -2, 2),
		maxi(_domain_weight(domain_weights, "archive_interpretation"), _domain_weight(domain_weights, "pressure_grammar"))
	)
	economy["resource_austerity"] = _domain_adjusted_surface(
		clampi(int(Dictionary(item_ecology_bias.get("latent_biases", {})).get("scarcity", 0)) + _pressure_weight(pressure_grammar, "scarcity") / 6 + _pressure_weight(pressure_grammar, "delay") / 10, -2, 2),
		_domain_weight(domain_weights, "item_ecology")
	)
	economy["recovery_cushion"] = _domain_adjusted_surface(
		clampi(int(Dictionary(item_ecology_bias.get("latent_biases", {})).get("rescue", 0)) - _pressure_weight(pressure_grammar, "scarcity") / 10 - _pressure_weight(pressure_grammar, "compression") / 12, -2, 2),
		_domain_weight(domain_weights, "item_ecology")
	)
	economy["commitment_cost"] = _domain_adjusted_surface(
		clampi((int(force_profile.get("trial", 0)) + int(force_profile.get("risk", 0))) / 7 + _pressure_weight(pressure_grammar, "compression") / 6 + _pressure_weight(pressure_grammar, "escalation") / 8, -2, 2),
		_domain_weight(domain_weights, "item_ecology")
	)
	economy["lure_abundance"] = _domain_adjusted_surface(
		clampi(int(Dictionary(item_ecology_bias.get("latent_biases", {})).get("deception", 0)) + int(Dictionary(item_ecology_bias.get("latent_biases", {})).get("anti_protocol_potential", 0)) / 2, -2, 2),
		_domain_weight(domain_weights, "item_ecology")
	)
	culture["public_heat_bias"] = _domain_adjusted_surface(
		clampi((1 if str(pacing_profile.get("id", "")) in ["escalating", "volatile"] else 0) + _pressure_weight(pressure_grammar, "exposure") / 8 - (1 if str(pacing_profile.get("id", "")) == "calm" else 0), -2, 2),
		maxi(_domain_weight(domain_weights, "symbolic_language"), _domain_weight(domain_weights, "pacing"))
	)
	culture["archive_emphasis"] = _domain_adjusted_surface(
		clampi(int(force_profile.get("memory", 0)) / 4 + _mind_intensity(mind_states, "archivist") / 2 + (1 if str(archive_interpretation.get("tone", "")) in ["memory custody", "forensic dispute"] else 0) + (1 if int(Dictionary(meta.get("dominance", {})).get("weight", 0)) >= 3 else 0), -2, 2),
		_domain_weight(domain_weights, "archive_interpretation")
	)
	policy["generation"] = generation
	policy["social"] = social
	policy["ecology"] = ecology
	policy["economy"] = economy
	policy["culture"] = culture
	return CONTROL_SURFACE_REGISTRY_SCRIPT.clamp_policy(policy)

static func _build_public_doctrine_summary(force_order: Array[Dictionary], mind_states: Array[Dictionary], domain_weights: Dictionary, pacing_profile: Dictionary, pressure_grammar: Array[Dictionary], symbolic_motifs: Array[Dictionary], planner: Dictionary, item_ecology_bias: Dictionary, group_tension_bias: Dictionary, archive_interpretation: Dictionary, convergence_fragmentation: Dictionary, readability_budget: Dictionary) -> Dictionary:
	var lead_minds := _top_state_labels(mind_states, int(readability_budget.get("public_mind_count", 1)))
	var top_verbs := _top_entry_labels(pressure_grammar, int(readability_budget.get("public_pressure_count", 1)))
	var top_motifs := _top_entry_labels(symbolic_motifs, int(readability_budget.get("public_motif_count", 1)))
	var dominant_forces := _top_entry_labels(force_order, int(readability_budget.get("dominant_force_count", 2)))
	var dominant_domains := _top_domain_labels(domain_weights, 2)
	var primary_mind_id := _first_mind_id(mind_states)
	var primary_mind_label := _first_state_label(mind_states)
	var dominant_force_id := str(Dictionary(force_order[0] if not force_order.is_empty() else {}).get("id", "trial"))
	var dominant_force_label := str(Dictionary(force_order[0] if not force_order.is_empty() else {}).get("label", "Trial"))
	var doctrine_label := "%s %s" % [primary_mind_label, dominant_force_label]
	var pressure_line := ""
	if not top_verbs.is_empty():
		pressure_line = "%s %s" % [str(Dictionary(pacing_profile).get("label", "Steady")), top_verbs[0].to_lower()]
		if top_verbs.size() >= 2:
			pressure_line = "%s with %s" % [pressure_line, top_verbs[1].to_lower()]
	else:
		pressure_line = "%s %s" % [str(Dictionary(pacing_profile).get("label", "Steady")), dominant_force_label.to_lower()]
	var world_goal := _first_string(Array(planner.get("immediate", [])), "")
	if world_goal.is_empty():
		world_goal = _first_string(Array(planner.get("run", [])), "")
	if world_goal.is_empty():
		world_goal = str(Dictionary(archive_interpretation).get("hook", ""))
	return {
		"doctrine_family": "%s_%s" % [primary_mind_id, dominant_force_id],
		"doctrine_label": doctrine_label,
		"pressure_line": pressure_line,
		"world_goal": world_goal,
		"dominant_forces": dominant_forces,
		"dominant_domains": dominant_domains,
		"dominant_minds": lead_minds,
		"pacing_profile": str(Dictionary(pacing_profile).get("id", "steady")),
		"pacing_label": str(Dictionary(pacing_profile).get("label", "Steady")),
		"pressure_grammar": top_verbs,
		"symbolic_motifs": top_motifs,
		"item_ecology_bias": str(Dictionary(item_ecology_bias).get("summary", "")),
		"group_tension_bias": str(Dictionary(group_tension_bias).get("summary", "")),
		"archive_tone": str(Dictionary(archive_interpretation).get("tone", "")),
		"convergence_axis": str(Dictionary(convergence_fragmentation).get("axis", "balanced"))
	}

static func _mind_moods(mind_states: Array[Dictionary]) -> Dictionary:
	var moods: Dictionary = {}
	for mind_raw in mind_states:
		var mind_state: Dictionary = Dictionary(mind_raw)
		moods[str(mind_state.get("id", ""))] = str(mind_state.get("mood", ""))
	return moods

static func _resolve_mood(mind_def: Dictionary, force_profile: Dictionary) -> String:
	for mood_raw in Array(mind_def.get("moods", [])):
		var mood: Dictionary = Dictionary(mood_raw)
		if int(force_profile.get(str(mood.get("force", "")), 0)) >= int(mood.get("min", 999)):
			return str(mood.get("id", mind_def.get("default_mood", "active")))
	return str(mind_def.get("default_mood", "active"))

static func _role_context_bonus(role_name: String, mind_state: Dictionary, force_profile: Dictionary, _session_context: Dictionary) -> int:
	var signature_affinities: Array = Array(mind_state.get("signature_affinities", []))
	var lead_force := "trial"
	if not signature_affinities.is_empty():
		lead_force = str(signature_affinities[0])
	match role_name:
		"Primary Author":
			return int(force_profile.get(lead_force, 0))
		"Countervoice":
			return int(force_profile.get("deception", 0))
		"Witness":
			return int(force_profile.get("memory", 0)) + int(force_profile.get("trial", 0)) / 2
		"Patron":
			return int(force_profile.get("discovery", 0)) + int(force_profile.get("memory", 0)) / 2
		"Saboteur":
			return int(force_profile.get("deception", 0)) + int(force_profile.get("risk", 0)) / 2
		"Warden":
			return int(force_profile.get("containment", 0)) + int(force_profile.get("risk", 0)) / 2
		"Substrate":
			return int(force_profile.get("containment", 0)) + int(force_profile.get("discovery", 0)) / 2
	return 0

static func _domain_force_bonus(domain_id: String, force_profile: Dictionary) -> int:
	match domain_id:
		"topology":
			return int(force_profile.get("discovery", 0)) / 4 + int(force_profile.get("containment", 0)) / 5
		"pacing":
			return int(force_profile.get("trial", 0)) / 5 + int(force_profile.get("risk", 0)) / 5
		"pressure_grammar":
			return int(force_profile.get("deception", 0)) / 5 + int(force_profile.get("risk", 0)) / 5
		"item_ecology":
			return int(force_profile.get("risk", 0)) / 5 + int(force_profile.get("memory", 0)) / 6
		"symbolic_language":
			return int(force_profile.get("memory", 0)) / 4 + int(force_profile.get("trial", 0)) / 6
		"group_tension":
			return int(force_profile.get("deception", 0)) / 5 + int(force_profile.get("trial", 0)) / 6
		"archive_interpretation":
			return int(force_profile.get("memory", 0)) / 4
		"convergence_fragmentation":
			return int(force_profile.get("containment", 0)) / 6 + int(force_profile.get("discovery", 0)) / 6
	return 0

static func _domain_note(domain_id: String, lead_mind_id: String, weight: int) -> String:
	var label := str(DOMAIN_LABELS.get(domain_id, domain_id))
	return "%s is led by %s at weight %d" % [label, lead_mind_id.capitalize(), weight] if not lead_mind_id.is_empty() else "%s holds at weight %d" % [label, weight]

static func _domain_weight(domain_weights: Dictionary, domain_id: String) -> int:
	return int(Dictionary(domain_weights.get(domain_id, {})).get("weight", 5))

static func _domain_adjusted_surface(value: int, domain_weight: int) -> int:
	var next := value
	if next > 0:
		if domain_weight >= 8:
			next += 1
		elif domain_weight <= 3:
			next -= 1
	elif next < 0:
		if domain_weight >= 8:
			next -= 1
		elif domain_weight <= 3:
			next += 1
	return clampi(next, -2, 2)

static func _protocol_trial_pressure(protocol_state: String) -> int:
	match protocol_state:
		"Expedition Protocol":
			return 2
		"Fracture Protocol":
			return 1
		"Intimate Protocol":
			return 1
	return 0

static func _protocol_risk_pressure(protocol_state: String) -> int:
	match protocol_state:
		"Exposure Protocol":
			return 2
		"Intimate Protocol":
			return 1
		"Fracture Protocol":
			return 1
	return 0

static func _protocol_containment_pressure(protocol_state: String) -> int:
	match protocol_state:
		"Expedition Protocol":
			return 1
		"Fracture Protocol":
			return 1
		"Exposure Protocol":
			return 2
	return 0

static func _seed_texture(seed_value: int, label: String, spread: int = 1) -> int:
	var value: int = abs(seed_value * 131 + label.hash() * 17)
	return posmod(value, spread * 2 + 1) - spread

static func _sorted_force_scores(force_profile: Dictionary) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for force_id in FORCE_LABELS.keys():
		entries.append({
			"id": force_id,
			"label": str(FORCE_LABELS.get(force_id, force_id)),
			"weight": int(force_profile.get(force_id, 0))
		})
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("weight", 0)) == int(b.get("weight", 0)):
			return str(a.get("id", "")) < str(b.get("id", ""))
		return int(a.get("weight", 0)) > int(b.get("weight", 0))
	)
	return entries

static func _pressure_weight(entries: Array[Dictionary], verb_id: String) -> int:
	for entry_raw in entries:
		var entry: Dictionary = Dictionary(entry_raw)
		if str(entry.get("id", "")) == verb_id:
			return int(entry.get("weight", 0))
	return 0

static func _highest_scored_key(scores: Dictionary) -> String:
	var chosen := ""
	var chosen_score := -999999
	for key in scores.keys():
		var score := int(scores.get(key, 0))
		if score > chosen_score or (score == chosen_score and str(key) < chosen):
			chosen = str(key)
			chosen_score = score
	return chosen

static func _entry_weight(entries: Array, index: int) -> int:
	if index < 0 or index >= entries.size():
		return 0
	return int(Dictionary(entries[index]).get("weight", Dictionary(entries[index]).get("score", 0)))

static func _entry_ids(entries: Array[Dictionary]) -> Array[String]:
	var ids: Array[String] = []
	for entry_raw in entries:
		var entry: Dictionary = Dictionary(entry_raw)
		var id := str(entry.get("id", "")).strip_edges()
		if not id.is_empty():
			ids.append(id)
	return ids

static func _top_weight_keys(weights: Dictionary, limit: int) -> Array[String]:
	var entries: Array[Dictionary] = []
	for key in weights.keys():
		entries.append({"id": str(key), "weight": int(weights.get(key, 0))})
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("weight", 0)) == int(b.get("weight", 0)):
			return str(a.get("id", "")) < str(b.get("id", ""))
		return int(a.get("weight", 0)) > int(b.get("weight", 0))
	)
	var result: Array[String] = []
	for entry_raw in entries:
		var entry: Dictionary = Dictionary(entry_raw)
		if int(entry.get("weight", 0)) <= 0:
			continue
		result.append(str(entry.get("id", "")))
		if result.size() >= limit:
			break
	return result

static func _top_entry_labels(entries: Array, limit: int) -> Array[String]:
	var labels: Array[String] = []
	for entry_raw in entries:
		var entry: Dictionary = Dictionary(entry_raw)
		var label := str(entry.get("label", "")).strip_edges()
		if label.is_empty():
			continue
		labels.append(label)
		if labels.size() >= limit:
			break
	return labels

static func _top_state_labels(entries: Array, limit: int) -> Array[String]:
	var labels: Array[String] = []
	for entry_raw in entries:
		var entry: Dictionary = Dictionary(entry_raw)
		var label := str(entry.get("label", "")).strip_edges()
		if label.is_empty():
			continue
		var role_name := str(entry.get("role", "")).strip_edges()
		labels.append("%s (%s)" % [label, role_name] if not role_name.is_empty() else label)
		if labels.size() >= limit:
			break
	return labels

static func _top_domain_labels(domain_weights: Dictionary, limit: int) -> Array[String]:
	var entries: Array[Dictionary] = []
	for domain_id in domain_weights.keys():
		var domain_entry: Dictionary = Dictionary(domain_weights.get(domain_id, {}))
		entries.append({
			"id": str(domain_id),
			"label": str(domain_entry.get("label", domain_id)),
			"weight": int(domain_entry.get("weight", 0))
		})
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("weight", 0)) == int(b.get("weight", 0)):
			return str(a.get("id", "")) < str(b.get("id", ""))
		return int(a.get("weight", 0)) > int(b.get("weight", 0))
	)
	return _top_entry_labels(entries, limit)

static func _first_state_label(entries: Array) -> String:
	if entries.is_empty():
		return "Delve"
	return str(Dictionary(entries[0]).get("label", "Delve"))

static func _first_mind_id(entries: Array) -> String:
	if entries.is_empty():
		return "delve"
	return str(Dictionary(entries[0]).get("id", "delve"))

static func _mind_intensity(mind_states: Array[Dictionary], mind_id: String) -> int:
	for mind_raw in mind_states:
		var mind_state: Dictionary = Dictionary(mind_raw)
		if str(mind_state.get("id", "")) == mind_id:
			return int(mind_state.get("intensity", 0))
	return 0

static func _first_string(values: Array, fallback: String = "") -> String:
	for value in values:
		var text := str(value).strip_edges()
		if not text.is_empty():
			return text
	return fallback

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result
