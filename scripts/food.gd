extends Area2D

@export var lifetime: float = 18.0
@export var drift_speed: float = 8.0

var t: float = 0.0
var age: float = 0.0
var ph: float = 0.0
var col: Color = Color(0.92, 0.58, 0.22)
var r : float = 3.0
var drift_dir := Vector2.DOWN
var eaten := false

var eat_t: float = 0.0

func _ready():
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	ph = rng.randf_range(0, TAU)
	r = rng.randf_range(2.2, 3.8)
	drift_dir = Vector2(rng.randf_range(-0.3, 0.3), 1.0).normalized()
	var palette := [
		Color(0.92, 0.58, 0.22), Color(0.88, 0.42, 0.18),
		Color(0.85, 0.65, 0.30), Color(0.78, 0.38, 0.15), Color(0.90, 0.72, 0.35),
	]
	col = palette[rng.randi_range(0, palette.size() - 1)]
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = r + 6.0
	shape.shape = circle
	add_child(shape)
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_value(2, true)
	set_collision_mask_value(1, true)
	body_entered.connect(_on_body)
	monitoring = true
	monitorable = true

func _process(delta):
	t += delta
	age += delta
	# eaten animation
	if eaten:
		eat_t += delta * 4.0
		if eat_t >= 1.0:
			queue_free()
			return
		queue_redraw()
		return
	position += drift_dir * drift_speed * delta
	position.x += cos(t * 0.8 + ph) * 0.3
	if age >= lifetime:
		queue_free()
		return
	queue_redraw()

func _draw():
	if eaten:
		var f := eat_t
		var sr := r * (1.0 - f)
		var a := 1.0 - f
		draw_circle(Vector2.ZERO, sr + 4.0 * f, Color(1.0, 0.95, 0.7, a * 0.3))
		draw_circle(Vector2.ZERO, sr, Color(col, a))
		return
	var fade := 1.0
	if age > lifetime - 3.0:
		fade = (lifetime - age) / 3.0
	draw_circle(Vector2.ZERO, r * 2.5, Color(1.0, 0.9, 0.6, 0.08 * fade * (0.7 + sin(t * 2.0 + ph) * 0.3)))
	draw_circle(Vector2(1.5, 2.0), r * 0.9, Color(0.0, 0.02, 0.08, 0.12 * fade))
	var pulse := 1.0 + sin(t * 3.0 + ph) * 0.06
	draw_circle(Vector2.ZERO, r * pulse, Color(col, 0.9 * fade))
	draw_circle(Vector2(-r * 0.25, -r * 0.3), r * 0.5, Color(minf(col.r + 0.15, 1.0), minf(col.g + 0.12, 1.0), minf(col.b + 0.08, 1.0), 0.6 * fade))

func _on_body(body: Node2D):
	if body.is_in_group("player") and not eaten:
		eaten = true
		if body.has_method("feed"):
			body.feed(20.0)
		set_deferred("monitoring", false)
