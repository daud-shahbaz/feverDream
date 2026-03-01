extends Node2D

var t: float = 0.0
var gulls: Array = []

func _ready():
	z_index = 15

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in 2:
		gulls.append({
			"pos": Vector2(rng.randf_range(-500, 500),rng.randf_range(-350, 350)),
			"dir": Vector2(rng.randf_range(-1, 1),rng.randf_range(-1, 1)).normalized(),
			"spd": rng.randf_range(20, 32),
			"wing_ph": rng.randf_range(0, TAU),
			"wing_spd": rng.randf_range(1.0, 1.6),
			"sz": rng.randf_range(0.9, 1.15),
			"turn_ph": rng.randf_range(0, TAU),
			"turn_spd": rng.randf_range(0.08, 0.18),
			"alt": rng.randf_range(0.6, 1.0),
		})

func _process(delta):
	t += delta
	var cam_pos := Vector2.ZERO
	var cam := get_viewport().get_camera_2d()
	if cam:
		cam_pos = cam.global_position
	for g in gulls:
		var turn := sin(t * g["turn_spd"] + g["turn_ph"]) * 0.4
		g["dir"] = (g["dir"] as Vector2).rotated(turn * delta).normalized()
		g["pos"] += g["dir"] * g["spd"] * delta
		var p : Vector2 = g["pos"]
		if p.x > cam_pos.x + 650: p.x -= 1300
		if p.x < cam_pos.x - 650: p.x += 1300
		if p.y > cam_pos.y + 650: p.y -= 1300
		if p.y < cam_pos.y - 650: p.y += 1300
		g["pos"] = p
	queue_redraw()

func _draw():
	for g in gulls:
		var pos: Vector2 = g["pos"]
		var sz: float = g["sz"]
		var wa := sin(t * g["wing_spd"] + g["wing_ph"])
		var ang := (g["dir"] as Vector2).angle()
		var fwd := Vector2(cos(ang), sin(ang))
		var side := Vector2(-sin(ang), cos(ang))
		var spread := 16.0 * sz
		var lift := wa * 4.0 * sz
		var lt := pos + side * (-spread) + fwd * (-1.0) + side * Vector2(0, lift).rotated(ang)
		var rt:= pos + side * spread + fwd* (-1.0) - side * Vector2(0, lift).rotated(ang)
		var tail := pos - fwd * 6.0 * sz * 1.2

		# shadow
		_wing(pos + Vector2(6, 10), sz * 0.85, wa * 0.7,fwd, side, Color(0.0, 0.03, 0.08, 0.07))
		# wings
		_wing(pos, sz, wa, fwd, side, Color(0.92, 0.94, 0.96, 0.85))
		_wing(pos, sz * 0.88, wa * 0.95, fwd, side, Color(1.0, 1.0, 1.0, 0.70))
		# body
		var bp : PackedVector2Array = []
		for i in 12:
			var a := (float(i) / 12) * TAU
			var local := Vector2(cos(a) * 5.5 * sz * 0.55, sin(a) * 2.2 * sz * 0.55)
			bp.append(pos + local.rotated(ang))
		draw_colored_polygon(bp, Color(1.0, 1.0, 1.0, 0.90))
		# wing tips
		var tc := Color(0.45, 0.48, 0.52, 0.55)
		draw_colored_polygon(PackedVector2Array([pos + side * (-spread * 0.65) + fwd * 0.5 * sz, lt, pos + side * (-spread * 0.55) - fwd * 1.5 * sz]), tc)
		draw_colored_polygon(PackedVector2Array([pos + side * (spread * 0.65) + fwd * 0.5 * sz, rt, pos + side * (spread * 0.55) - fwd * 1.5 * sz]), tc)

# wing shape
func _wing(pos: Vector2, sz: float, wa: float, fwd: Vector2, side: Vector2, col: Color):
	var spread := 16.0 * sz
	var lift := wa * 4.0 * sz
	var tail := pos - fwd * 6.0 * sz * 1.2
	var lt := pos + side * (-spread) + fwd * (-1.0) + side * Vector2(0, lift).rotated(fwd.angle())
	var rt := pos + side * spread + fwd * (-1.0) - side * Vector2(0, lift).rotated(fwd.angle())
	draw_colored_polygon(PackedVector2Array([pos + fwd * 2 * sz, pos + side * (-spread * 0.4) + fwd * sz, lt, pos + side * (-spread * 0.3) - fwd * 2 * sz, tail]), col)
	draw_colored_polygon(PackedVector2Array([pos + fwd * 2 * sz, pos + side * (spread * 0.4) + fwd * sz, rt, pos + side * (spread * 0.3) - fwd * 2 * sz, tail]), col)
