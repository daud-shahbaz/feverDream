extends Node2D

@export var count: int = 80
@export var world_radius: float = 1500.0

var t: float = 0.0
var parts: Array = []

func _ready():
	z_index = 3
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in count:
		parts.append({
			"pos": Vector2(rng.randf_range(-world_radius, world_radius), rng.randf_range(-world_radius, world_radius)),
			"sz": rng.randf_range(0.8, 3.0),
			"drift": Vector2(rng.randf_range(-8, 8), rng.randf_range(-12, -3)),
			"ph": rng.randf_range(0, TAU),
			"pulse": rng.randf_range(0.5, 2.0),
		})

func _process(delta):
	t += delta
	queue_redraw()

func _draw():
	for p in parts:
		var pos: Vector2 = p["pos"]
		var sz: float = p["sz"]
		var ph : float = p["ph"]
		var ps: float = p["pulse"]
		var drift: Vector2 = p["drift"]
		var ap := pos + drift * t + Vector2(sin(t * 0.4 + ph) * 15, cos(t * 0.3 + ph) * 10)
		ap.x = fmod(ap.x + world_radius, world_radius * 2) - world_radius
		ap.y = fmod(ap.y + world_radius, world_radius * 2) - world_radius
		var depth := clampf(ap.length() / world_radius, 0.0, 1.0)
		var alpha := lerpf(0.5, 0.12, depth) * (0.5 + sin(t * ps + ph) * 0.5)
		var col := Color(1.0, 0.98, 0.9, alpha) if depth < 0.4 else Color(0.7, 0.88, 1.0, alpha)
		draw_circle(ap, sz, col)
		draw_circle(ap + Vector2(-0.3, -0.3), sz * 0.3, Color(1.0, 1.0, 1.0, alpha * 0.5))
