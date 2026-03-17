class_name ProfilePersistence
extends RefCounted

static func load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	if parse_error != OK or not (json.data is Dictionary):
		return {}
	return Dictionary(json.data)

static func save_json(path: String, value: Dictionary) -> bool:
	DirAccess.make_dir_recursive_absolute("user://profile")
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(value, "\t"))
	file.close()
	return true
