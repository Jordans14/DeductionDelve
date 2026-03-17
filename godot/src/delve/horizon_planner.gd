class_name DelveHorizonPlanner
extends RefCounted

static func plan(world_model: Dictionary, session_context: Dictionary) -> Dictionary:
	var social: Dictionary = Dictionary(world_model.get("social_model", {}))
	var route: Dictionary = Dictionary(world_model.get("route_model", {}))
	var ecology: Dictionary = Dictionary(world_model.get("ecology_model", {}))
	var economy: Dictionary = Dictionary(world_model.get("economy_model", {}))
	var cultural: Dictionary = Dictionary(world_model.get("cultural_model", {}))
	var epoch: Dictionary = Dictionary(world_model.get("epoch_model", {}))
	var doctrine: Dictionary = Dictionary(world_model.get("doctrine_model", {}))
	var protocol_state := str(Dictionary(world_model.get("session_model", {})).get("protocol_state", session_context.get("protocol_state", "")))
	var cookbook_fragment_pressure := int(cultural.get("cookbook_fragment_count", 0)) + int(cultural.get("cookbook_fragment_heat", 0))
	var cookbook_network_pressure := int(cultural.get("cookbook_holder_depth", 0)) + int(cultural.get("cookbook_network_pressure", 0)) + int(cultural.get("cookbook_network_rumor", 0))
	var cookbook_redirection_pressure := int(cultural.get("cookbook_redirection_pressure", 0)) + int(cultural.get("cookbook_redirection_heat", 0))
	var relay_stress := int(route.get("relay_stress", 0)) + int(cultural.get("relay_memory_pressure", 0))
	var witness_network_pressure := int(cultural.get("witness_network_pressure", 0))
	var relay_bottleneck_pressure := int(cultural.get("relay_bottleneck_pressure", 0))
	var rumor_shock_pressure := int(cultural.get("rumor_shock_pressure", 0))
	var cohort_pressure := int(cultural.get("cohort_pressure", 0))
	var epoch_phase := str(epoch.get("phase", "")).strip_edges()
	var epoch_transition_pressure := int(epoch.get("transition_pressure", 0))
	var immediate: Array[String] = []
	var run_goals: Array[String] = []
	var session_goals: Array[String] = []
	var campaign_goals: Array[String] = []
	if int(social.get("fault_recurrence", 0)) >= 3:
		immediate.append("stress social fault lines without obscuring the answer")
	if int(route.get("rescue_geometry", 0)) <= 2:
		immediate.append("restore at least one visible rescue line")
	if int(social.get("alliance_stability", 0)) >= 3:
		run_goals.append("keep loyalty and alliance readable under burden, not only betrayal suspicion")
	if int(social.get("trust_fragility", 0)) >= 2:
		session_goals.append("let trust topology strain without flattening every bond into treachery")
	if int(social.get("friendship_pressure", 0)) >= 2:
		campaign_goals.append("let friendship survive as a real history-making force")
	if int(social.get("loyalty_pressure", 0)) >= 2:
		run_goals.append("make rescue obligation and remembered loyalty shape the route")
	if int(economy.get("fallback_dependence", 0)) >= 4:
		run_goals.append("shift value away from fallback certainty")
	if int(ecology.get("presence_pressure", 0)) >= 3:
		run_goals.append("keep presence pressure legible but not dominant")
	if int(cultural.get("overfit_risk", 0)) >= 4:
		session_goals.append("break the current public overfit")
	if int(cultural.get("burial_pressure", 0)) >= 2:
		session_goals.append("respect burial pressure without freezing the artifact answer")
	if int(cultural.get("legitimacy_pressure", 0)) >= 2:
		session_goals.append("make custody obligations legible without fixing them into hard law")
	if int(cultural.get("taboo_heat", 0)) >= 2:
		run_goals.append("let taboo pressure shape hesitation without closing interpretation")
	if int(cultural.get("false_canon_pressure", 0)) >= 2:
		session_goals.append("fracture false canon without replacing it with noise")
	if int(cultural.get("semantic_drift", 0)) >= 1:
		run_goals.append("let semantic drift trouble witness confidence without making routes unreadable")
	if int(cultural.get("forgery_pressure", 0)) >= 1:
		run_goals.append("surface provenance doubt without making every artifact uninterpretable")
	if int(cultural.get("contradiction_heat", 0)) >= 2:
		session_goals.append("let rival explanations spread without forcing a single clean settlement")
	if int(cultural.get("ritual_spread", 0)) >= 1:
		run_goals.append("let ritual readings travel through action and place rather than instruction")
	if int(cultural.get("institutional_campaigns", 0)) >= 1:
		session_goals.append("keep institutional campaigns from fixing the meaning too early")
	if int(cultural.get("melancholy_heat", 0)) >= 2:
		run_goals.append("let mourning sit in the run without freezing motion")
	if int(cultural.get("punitive_heat", 0)) >= 1 or int(cultural.get("paranoia_heat", 0)) >= 1:
		session_goals.append("restore ordinary sanctioned work and resist punitive overreaction")
	if int(cultural.get("martyr_pressure", 0)) >= 1:
		run_goals.append("keep sacrifice readable without rewarding performative martyr scripts")
	if int(cultural.get("anti_martyr_pressure", 0)) >= 1:
		session_goals.append("let ordinary labor matter without requiring legend status")
	if Array(doctrine.get("stale_doctrines", [])).size() >= 1:
		session_goals.append("move off solved doctrine families")
	if int(doctrine.get("misclassification_pressure", 0)) >= 1:
		session_goals.append("keep Delve from over-reading the same human pattern")
	if protocol_state == "Exposure Protocol":
		immediate.append("reward prepared answers without losing danger")
		run_goals.append("make solitude feel intentional, not abandoned")
	elif protocol_state == "Intimate Protocol":
		run_goals.append("load pair obligation and mutual exposure")
	elif protocol_state == "Fracture Protocol":
		run_goals.append("test regroup pressure and split accountability")
	else:
		run_goals.append("heat the public answer line without collapsing deduction")
	campaign_goals.append("preserve deduction quality while resisting stale answers")
	if not str(cultural.get("current_focus", "")).strip_edges().is_empty():
		campaign_goals.append("recast the field around %s only if a cleaner answer appears" % str(cultural.get("current_focus", "")))
	if int(cultural.get("orthodoxy_strength", 0)) >= 2:
		campaign_goals.append("keep the dominant truth tradition from hardening into capture")
	if int(cultural.get("ordinary_life_pressure", 0)) >= 2:
		campaign_goals.append("keep ordinary labor socially legible, not just spectacular legend")
	if int(cultural.get("sacred_pressure", 0)) >= 1 and int(cultural.get("administrative_pressure", 0)) >= 1:
		campaign_goals.append("keep sacred and administrative order in tension without breaking practical survival")
	if int(cultural.get("practical_pressure", 0)) >= 1:
		campaign_goals.append("keep lived survival custom legible against elite interpretation")
	if int(cultural.get("counterfactual_heat", 0)) >= 2:
		session_goals.append("keep the world haunted by unchosen answers without making them decisive")
	if str(cultural.get("dominant_ontology", "")).strip_edges() == "unknowable anomaly":
		run_goals.append("let anomaly ontology sharpen caution without giving away the answer")
	if str(cultural.get("uncertainty_philosophy", "")).strip_edges() == "necessary condition of truth":
		campaign_goals.append("treat uncertainty as part of knowing, not only noise to erase")
	if int(cultural.get("silence_pressure", 0)) >= 1:
		session_goals.append("preserve silence where forced explanation would cheapen plurality")
	if int(cultural.get("unclassified_pressure", 0)) >= 1:
		run_goals.append("leave at least one zone unresolved while keeping it traversal-honest")
	if epoch_transition_pressure >= 2:
		session_goals.append("let the run feel like part of an unfolding epoch shift without turning history into a menu")
	if epoch_phase == "relay fracture":
		run_goals.append("treat relay strain like lived route pressure rather than abstract transport logic")
	elif epoch_phase == "counter-canon unrest":
		campaign_goals.append("let era-level canon fracture stay legible without exposing private forbidden doctrine")
	elif epoch_phase == "custody consolidation":
		campaign_goals.append("treat custody duty as a civilizational turn, not only a local rule")
	elif epoch_phase == "mourning turn":
		run_goals.append("let the era's mourning weather shape the run without stopping motion")
	if cookbook_fragment_pressure >= 2:
		session_goals.append("let forbidden marginalia bend interpretation without becoming a public codex")
	if cookbook_network_pressure >= 2:
		campaign_goals.append("allow hidden readers to recognize each other through anomaly residue rather than open institutions")
	if cookbook_redirection_pressure >= 1:
		run_goals.append("let some routes redirect protocol expectation without breaking traversal law")
	if relay_stress >= 2:
		session_goals.append("keep relay stress legible without turning the crawl into transport management")
	if witness_network_pressure >= 1:
		campaign_goals.append("let distributed witness networks matter without collapsing into crowd certainty")
	if relay_bottleneck_pressure >= 1:
		run_goals.append("preserve one overloaded relay bottleneck as a lived route problem")
	if rumor_shock_pressure >= 1:
		run_goals.append("let rumor shock outrun proof without making route truth unreadable")
	if cohort_pressure >= 1:
		session_goals.append("keep sub-cohort duty legible without hardening into detached faction menus")
	if int(doctrine.get("overcorrection_pressure", 0)) >= 1:
		campaign_goals.append("let Delve remember its own errors without thrashing into novelty")
	return {
		"immediate": immediate,
		"run": run_goals,
		"session": session_goals,
		"campaign": campaign_goals
	}
