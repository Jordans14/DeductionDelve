class_name MultimodalContractService
extends RefCounted

const DEFAULT_MODALITIES := ["voice_policy", "gesture_summary", "camera_summary"]
const DEFAULT_ALLOWED_OUTPUTS := ["policy_state", "archive_summary", "shell_summary"]
const DEFAULT_FORBIDDEN_OUTPUTS := ["guilt_score", "role_truth", "artifact_truth", "runtime_targeting"]

static func default_state() -> Dictionary:
	return {
		"schema_version": 1,
		"opt_in_only": true,
		"runtime_authority": false,
		"retention": "session_only",
		"modalities": {
			"voice_policy": {"enabled": false, "consented": false},
			"gesture_summary": {"enabled": false, "consented": false},
			"camera_summary": {"enabled": false, "consented": false}
		},
		"allowed_outputs": DEFAULT_ALLOWED_OUTPUTS.duplicate(true),
		"forbidden_outputs": DEFAULT_FORBIDDEN_OUTPUTS.duplicate(true)
	}

static func normalize(state: Dictionary) -> Dictionary:
	var normalized := default_state()
	for key in state.keys():
		normalized[key] = state.get(key)
	normalized["schema_version"] = 1
	normalized["opt_in_only"] = true
	normalized["runtime_authority"] = false
	var modalities: Dictionary = Dictionary(normalized.get("modalities", {}))
	for modality_id in DEFAULT_MODALITIES:
		var modality_state: Dictionary = Dictionary(modalities.get(modality_id, {}))
		modalities[modality_id] = {
			"enabled": bool(modality_state.get("enabled", false)),
			"consented": bool(modality_state.get("consented", false))
		}
	normalized["modalities"] = modalities
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
