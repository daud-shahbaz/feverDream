extends Node2D
@onready var bg: ColorRect = $ColorRect
var bg_hue:float = 0.6

func _process(delta: float) -> void:
	bg_hue = fmod(bg_hue + delta * 0.04, 1.0)
	bg.color = Color.from_hsv(bg_hue, 0.6, 0.08)
