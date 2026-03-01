extends Area2D

var hue: float = 0.0
var pulse: float = 0.0
var spin: float = 0.0
var activated: bool = false
var activate_scale: float = 1.0

var burst_particles: CPUParticles2D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	monitoring = true

	_create_burst_particles()

func _create_burst_particles() -> void:
	burst_particles = CPUParticles2D.new()
	add_child(burst_particles)

	burst_particles.emitting          = false
	burst_particles.one_shot          = true
	burst_particles.explosiveness     = 0.95    # all at once
	burst_particles.amount            = 80
	burst_particles.lifetime          = 1.8

	burst_particles.spread            = 180.0
	burst_particles.initial_velocity_min = 80.0
	burst_particles.initial_velocity_max = 280.0
	burst_particles.gravity           = Vector2.ZERO
	burst_particles.damping_min       = 40.0
	burst_particles.damping_max       = 90.0

	burst_particles.scale_amount_min  = 3.0
	burst_particles.scale_amount_max  = 8.0

	var grad = Gradient.new()
	grad.set_color(0, Color(1, 1, 1, 1.0))
	grad.set_color(1, Color(1, 1, 1, 0.0))
	burst_particles.color_ramp = grad

func _on_body_entered(body: Node2D) -> void:
	if activated:
		return
	if body.is_in_group("player"):
		_activate()

func _activate() -> void:
	activated = true

	burst_particles.emitting = true

	get_tree().call_group("world", "trigger_flash")

	var tween = create_tween()
	tween.tween_property(self, "activate_scale", 3.5, 0.4)\
		 .set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "activate_scale", 0.0, 0.6)\
		 .set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(queue_free)   # portal disappears after burst

func _process(delta: float) -> void:
	hue   = fmod(hue + delta * 0.4, 1.0)
	pulse = fmod(pulse + delta * 3.5, TAU)
	spin  = fmod(spin  + delta * 1.2, TAU)
	queue_redraw()

func _draw() -> void:
	if activated:
		return

	var r    = 55.0 * (1.0 + sin(pulse) * 0.12) * activate_scale
	var col  = Color.from_hsv(hue, 0.7, 1.0)
	var col2 = Color.from_hsv(fmod(hue + 0.25, 1.0), 0.9, 1.0)
	var col3 = Color.from_hsv(fmod(hue + 0.5,  1.0), 0.6, 1.0, 0.12)

	draw_set_transform(Vector2.ZERO, spin, Vector2.ONE)

	draw_circle(Vector2.ZERO, r * 1.9, col3)

	for i in 8:
		var angle = (TAU / 8.0) * i
		var from  = Vector2(cos(angle), sin(angle)) * r * 0.4
		var to    = Vector2(cos(angle), sin(angle)) * r
		draw_line(from, to, col2, 2.5)

	draw_arc(Vector2.ZERO, r,        0.0, TAU, 48, col,  4.0)
	draw_arc(Vector2.ZERO, r * 0.6,  0.0, TAU, 32, col2, 2.5)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	draw_circle(Vector2.ZERO, r * 0.25, Color.WHITE)
	draw_circle(Vector2.ZERO, r * 0.15, col)
