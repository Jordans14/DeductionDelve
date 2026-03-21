class_name MultimodalContractService
extends RefCounted

const DEFAULT_MODALITIES := ["voice_policy", "gesture_summary", "camera_summary"]
const DEFAULT_ALLOWED_OUTPUTS := ["policy_state", "archive_summary", "shell_summary"]
const DEFAULT_FORBIDDEN_OUTPUTS := ["guilt_score", "role_truth", "artifact_truth", "runtime_targeting"]
const DEFAULT_ALLOWED_OUTPUT_LAYERS := ["compile_bias", "persistence_learning", "report_safe_summary", "operator_review"]
const DEFAULT_FORBIDDEN_RUNTIME_FIELDS := [
	"peer_ids",
	"runtime_state",
	"event_log",
	"physics_override",
	"legality_override",
	"artifact_truth_override",
	"runtime_ai_arbitration"
]
const DEFAULT_ALLOWED_SUBJECT_DOMAINS := ["experiment", "theory", "world_state", "observation"]
const DEFAULT_OBSERVATION_STATUS_DOMAIN := ["public_safe_summary", "traceable_archive_only", "pressure_trace", "constitution_trace"]

static func default_state() -> Dictionary:
	return {
		"schema_version": 1,
		"opt_in_only": true,
		"runtime_authority": false,
		"hidden_targeting_authority": false,
		"moral_classification_allowed": false,
		"player_essence_typing_allowed": false,
		"bounded_inference_required": true,
		"contextual_non_final_observation_required": true,
		"persistence_report_safe_only": true,
		"uncertainty_preservation_required": true,
		"bias_mitigation_required": true,
		"retention": "session_only",
		"modalities": {
			"voice_policy": {"enabled": false, "consented": false},
			"gesture_summary": {"enabled": false, "consented": false},
			"camera_summary": {"enabled": false, "consented": false}
		},
		"allowed_output_layers": DEFAULT_ALLOWED_OUTPUT_LAYERS.duplicate(true),
		"forbidden_runtime_fields": DEFAULT_FORBIDDEN_RUNTIME_FIELDS.duplicate(true),
		"allowed_subject_domains": DEFAULT_ALLOWED_SUBJECT_DOMAINS.duplicate(true),
		"observation_status_domain": DEFAULT_OBSERVATION_STATUS_DOMAIN.duplicate(true),
		"public_lines_max": 6,
		"operator_lines_max": 6,
		"allowed_outputs": DEFAULT_ALLOWED_OUTPUTS.duplicate(true),
		"forbidden_outputs": DEFAULT_FORBIDDEN_OUTPUTS.duplicate(true),
		"failure_codes": [
			"runtime_authority_forbidden",
			"hidden_targeting_forbidden",
			"moral_typing_forbidden",
			"essence_typing_forbidden",
			"forbidden_output_requested"
		]
	}

static func normalize(state: Dictionary) -> Dictionary:
	var normalized := default_state()
	for key in state.keys():
		normalized[key] = state.get(key)
	normalized["schema_version"] = 1
	normalized["opt_in_only"] = true
	normalized["runtime_authority"] = false
	normalized["hidden_targeting_authority"] = false
	normalized["moral_classification_allowed"] = false
	normalized["player_essence_typing_allowed"] = false
	normalized["bounded_inference_required"] = true
	normalized["contextual_non_final_observation_required"] = true
	normalized["persistence_report_safe_only"] = true
	normalized["uncertainty_preservation_required"] = true
	normalized["bias_mitigation_required"] = true
	var modalities: Dictionary = Dictionary(normalized.get("modalities", {}))
	for modality_id in DEFAULT_MODALITIES:
		var modality_state: Dictionary = Dictionary(modalities.get(modality_id, {}))
		modalities[modality_id] = {
			"enabled": bool(modality_state.get("enabled", false)),
			"consented": bool(modality_state.get("consented", false))
		}
	normalized["modalities"] = modalities
	normalized["allowed_output_layers"] = DEFAULT_ALLOWED_OUTPUT_LAYERS.duplicate(true)
	normalized["forbidden_runtime_fields"] = DEFAULT_FORBIDDEN_RUNTIME_FIELDS.duplicate(true)
	normalized["allowed_subject_domains"] = DEFAULT_ALLOWED_SUBJECT_DOMAINS.duplicate(true)
	normalized["observation_status_domain"] = DEFAULT_OBSERVATION_STATUS_DOMAIN.duplicate(true)
	normalized["public_lines_max"] = 6
	normalized["operator_lines_max"] = 6
	var requested_allowed := _string_array(normalized.get("allowed_outputs", DEFAULT_ALLOWED_OUTPUTS))
	var safe_allowed: Array[String] = []
	for output_kind in DEFAULT_ALLOWED_OUTPUTS:
		if requested_allowed.has(output_kind) and not safe_allowed.has(output_kind):
			safe_allowed.append(output_kind)
	if safe_allowed.is_empty():
		safe_allowed = DEFAULT_ALLOWED_OUTPUTS.duplicate(true)
	var forbidden_outputs := DEFAULT_FORBIDDEN_OUTPUTS.duplicate(true)
	for output_kind in _string_array(normalized.get("forbidden_outputs", DEFAULT_FORBIDDEN_OUTPUTS)):
		if not forbidden_outputs.has(output_kind):
			forbidden_outputs.append(output_kind)
	normalized["allowed_outputs"] = safe_allowed
	normalized["forbidden_outputs"] = forbidden_outputs
	normalized["failure_codes"] = _string_array(normalized.get("failure_codes", default_state().get("failure_codes", [])))
	return normalized

static func set_modality_consent(state: Dictionary, modality_id: String, enabled: bool) -> Dictionary:
	var normalized := normalize(state)
	if not DEFAULT_MODALITIES.has(modality_id):
		return normalized
	var modalities: Dictionary = Dictionary(normalized.get("modalities", {}))
	modalities[modality_id] = {
		"enabled": enabled,
		"consented": enabled
	}
	normalized["modalities"] = modalities
	return normalized

static func modality_enabled(state: Dictionary, modality_id: String) -> bool:
	var normalized := normalize(state)
	var modality_state: Dictionary = Dictionary(Dictionary(normalized.get("modalities", {})).get(modality_id, {}))
	return bool(modality_state.get("enabled", false)) and bool(modality_state.get("consented", false))

static func can_emit_summary(state: Dictionary, modality_id: String, output_kind: String) -> bool:
	var normalized := normalize(state)
	if not modality_enabled(normalized, modality_id):
		return false
	if _string_array(normalized.get("forbidden_outputs", [])).has(output_kind):
		return false
	return _string_array(normalized.get("allowed_outputs", [])).has(output_kind)

static func build_archive_summary(state: Dictionary, modality_id: String, summary_text: String) -> Dictionary:
	if not can_emit_summary(state, modality_id, "archive_summary"):
		return {}
	var bounded_text := summary_text.strip_edges()
	if bounded_text.length() > 280:
		bounded_text = bounded_text.substr(0, 280).strip_edges()
	return {
		"modality_id": modality_id,
		"summary_text": bounded_text,
		"output_kind": "archive_summary",
		"runtime_authority": false,
		"retention": str(normalize(state).get("retention", "session_only"))
	}

static func contract_lines(state: Dictionary) -> Array[String]:
	var normalized := normalize(state)
	var lines: Array[String] = [
		"Multimodal: opt-in only",
		"Runtime authority: disabled",
		"Retention: %s" % str(normalized.get("retention", "session_only"))
	]
	for modality_id in DEFAULT_MODALITIES:
		var enabled := modality_enabled(normalized, modality_id)
		lines.append("%s: %s" % [modality_id, "enabled" if enabled else "disabled"])
	return lines

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text := str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result
