extends Node2D

@export var text: String = ""
@export var color: Color = Color.WHITE
@export var font_size: int = 16

var _font: Font = null

func _ready() -> void:
	_font = ThemeDB.fallback_font

func _draw() -> void:
	if _font == null:
		return
	draw_string(_font, Vector2.ZERO, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)