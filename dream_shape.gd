extends Node2D

var shape_type: int = 0
var base_radius: float = 30.0

var hue: float = 0.0
var hue_speed: float = 0.05

var drift_dir: Vector2 = Vector2.RIGHT
var drift_speed: float = 20.0
var drift_angle: float = 0.0

var pulse: float = 0.0
var pulse_speed: float = 2.0
var spin_angle: float = 0.0
var spin_speed: float = 0.5

var react_scale: float = 1.0
var react_target: float = 1.0
const REACT_DIST: float = 120.0

var bounds: Rect2 = Rect2(-1500, -1500, 3000, 3000)

func setup(rng: RandomNumberGenerator) -> void:
	shape_type  = rng.randi_range(0, 3)
	base_radius = rng.randf_range(18.0, 55.0)
	hue         = rng.randf()
	hue_speed   = rng.randf_range(0.02, 0.12)
	drift_speed = rng.randf_range(12.0, 45.0)
	drift_angle = rng.randf_range(0.0, TAU)
	drift_dir   = Vector2(cos(drift_angle), sin(drift_angle))
	pulse_speed = rng.randf_range(1.5, 4.0)
	spin_speed  = rng.randf_range(-1.5, 1.5)
	pulse       = rng.randf_range(0.0, TAU)

func _process(delta: float) -> void:
	_drift(delta)
	_animate(delta)
	_check_proximity()
	queue_redraw()

func _drift(delta: float) -> void:
	drift_angle += delta * 0.3
	drift_dir = Vector2(cos(drift_angle), sin(drift_angle))
	position += drift_dir * drift_speed * delta

	if position.x > bounds.end.x:   position.x = bounds.position.x
	if position.x < bounds.position.x: position.x = bounds.end.x
	if position.y > bounds.end.y:   position.y = bounds.position.y
	if position.y < bounds.position.y: position.y = bounds.end.y

func _animate(delta: float) -> void:
	hue       = fmod(hue + hue_speed * delta, 1.0)
	pulse     = fmod(pulse + pulse_speed * delta, TAU)
	spin_angle += spin_speed * delta

	react_scale = lerp(react_scale, react_target, delta * 8.0)
	react_target = 1.0

func _check_proximity() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var dist = global_position.distance_to(player.global_position)
	if dist < REACT_DIST:
		var closeness = 1.0 - (dist / REACT_DIST)
		react_target  = 1.0 + closeness * 0.9
		hue_speed     = 0.3 + closeness * 0.8

func _draw() -> void:
	var r     = base_radius * (1.0 + sin(pulse) * 0.15) * react_scale
	var col   = Color.from_hsv(hue, 0.85, 1.0)
	var col2  = Color.from_hsv(fmod(hue + 0.5, 1.0), 0.7, 1.0, 0.3)

	draw_set_transform(Vector2.ZERO, spin_angle, Vector2.ONE)

	match shape_type:
		0:
			draw_circle(Vector2.ZERO, r, col)
			draw_circle(Vector2.ZERO, r * 0.55, col2)

		1:
			var rect = Rect2(-r, -r, r * 2, r * 2)
			draw_rect(rect, col)
			draw_rect(rect.grow(-6), col2)

		2:
			var pts = PackedVector2Array([
				Vector2(0, -r),
				Vector2(r * 0.866, r * 0.5),
				Vector2(-r * 0.866, r * 0.5)
			])
			draw_colored_polygon(pts, col)
			var pts2 = PackedVector2Array([
				Vector2(0, -r * 0.5),
				Vector2(r * 0.43, r * 0.25),
				Vector2(-r * 0.43, r * 0.25)
			])
			draw_colored_polygon(pts2, col2)

		3:
			draw_arc(Vector2.ZERO, r, 0.0, TAU, 32, col, 5.0)
			draw_arc(Vector2.ZERO, r * 0.65, 0.0, TAU, 24, col2, 3.0)

	var glow = Color.from_hsv(hue, 0.5, 1.0, 0.08 * react_scale)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_circle(Vector2.ZERO, r * 1.6, glow)
