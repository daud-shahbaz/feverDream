extends CharacterBody2D

const SPEED = 180.0

var hue: float = 0.0
var pulse: float = 0.0
var trail_points: Array = []
const TRAIL_LENGTH = 25

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_update_visuals(delta)
	_update_trail()
	move_and_slide()

func _handle_movement(_delta: float) -> void:
	var dir = Vector2.ZERO
	if Input.is_action_pressed("ui_right"): dir.x += 1
	if Input.is_action_pressed("ui_left"):  dir.x -= 1
	if Input.is_action_pressed("ui_down"):  dir.y += 1
	if Input.is_action_pressed("ui_up"):    dir.y -= 1

	if dir.length() > 0:
		dir = dir.normalized()

	velocity = dir * SPEED

func _update_visuals(delta: float) -> void:
	hue   = fmod(hue + delta * 0.3, 1.0)
	pulse = fmod(pulse + delta * 3.0, TAU)

func _update_trail() -> void:
	trail_points.insert(0, global_position)
	if trail_points.size() > TRAIL_LENGTH:
		trail_points.resize(TRAIL_LENGTH)
	queue_redraw()   # triggers _draw every frame

func _draw() -> void:
	for i in trail_points.size():
		var t       = 1.0 - float(i) / TRAIL_LENGTH
		var radius  = lerp(4.0, 14.0, t)
		var alpha   = lerp(0.0, 0.5, t)
		var trail_hue = fmod(hue + i * 0.03, 1.0)
		var col     = Color.from_hsv(trail_hue, 0.9, 1.0, alpha)
		var local_pos = trail_points[i] - global_position
		draw_circle(local_pos, radius, col)

	var body_radius = 14.0 + sin(pulse) * 4.0
	var body_color  = Color.from_hsv(hue, 0.8, 1.0)
	draw_circle(Vector2.ZERO, body_radius, body_color)

	draw_circle(Vector2.ZERO, 5.0, Color.WHITE)

	var glow_col = Color.from_hsv(hue, 0.6, 1.0, 0.15)
	draw_circle(Vector2.ZERO, body_radius + 12.0, glow_col)

func _ready() -> void:
	add_to_group("player")
