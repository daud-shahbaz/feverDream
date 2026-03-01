extends Node2D

@export var world_radius: float = 1500.0

const SHALLOW   := Color(0.40, 0.88, 0.72)
const SHALLOW_B := Color(0.34, 0.82, 0.78)
const MID       := Color(0.18, 0.52, 0.62)
const MID_DEEP  := Color(0.10, 0.30, 0.48)
const DEEP      := Color(0.05, 0.14, 0.30)
const ABYSS     := Color(0.03, 0.06, 0.14)

var t: float = 0.0
var caustics: Array = []
var rays : Array = []
var rocks: Array = []
var corals : Array = []
var ripples: Array = []
var streaks : Array = []
var debris: Array = []
var lily_pads: Array = []

func _ready():
	z_index = -10
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	_gen_caustics(rng, 25)
	_gen_rays(rng, 4)
	_gen_rocks(rng, 10)
	_gen_corals(rng, 18)
	_gen_ripples(rng, 22)
	_gen_streaks(rng, 30)
	_gen_debris(rng, 25)
	_gen_lily_pads(rng, 8)

func _process(delta):
	t += delta
	queue_redraw()

func _gen_caustics(rng: RandomNumberGenerator, count: int):
	for i in count:
		caustics.append({
			"pos": Vector2(rng.randf_range(-world_radius, world_radius), rng.randf_range(-world_radius, world_radius)),
			"size": rng.randf_range(25, 80),
			"spd": rng.randf_range(0.3, 1.0),
			"ph": rng.randf_range(0, TAU),
		})

func _gen_rays(rng: RandomNumberGenerator, count : int):
	for i in count:
		rays.append({
			"x": rng.randf_range(-world_radius * 0.7, world_radius * 0.7),
			"w": rng.randf_range(50, 140),
			"a": rng.randf_range(0.015, 0.05),
			"spd": rng.randf_range(0.08, 0.35),
			"ph": rng.randf_range(0, TAU),
		})

func _gen_rocks(rng: RandomNumberGenerator, count: int):
	for i in count:
		var sc := rng.randi_range(1, 3)
		var cp := Vector2(rng.randf_range(-world_radius * 0.75, world_radius * 0.75), rng.randf_range(-world_radius * 0.75, world_radius * 0.75))
		var stones : Array = []
		for j in sc:
			stones.append({
				"off": Vector2(rng.randf_range(-14, 14), rng.randf_range(-12, 12)),
				"rx": rng.randf_range(6, 16),
				"ry": rng.randf_range(5, 12),
				"shade": rng.randf_range(0.0, 0.15),
			})
		rocks.append({"pos": cp, "stones": stones})
	_add_rock_colliders()

func _add_rock_colliders():
	for cluster in rocks:
		var bp: Vector2 = cluster["pos"]
		for stone in cluster["stones"]:
			var pos : Vector2 = bp + stone["off"]
			var rx : float = stone["rx"]
			var ry : float = stone["ry"]
			var body := StaticBody2D.new()
			body.position = pos
			var shape := CollisionShape2D.new()
			var cap := CapsuleShape2D.new()
			cap.radius = minf(rx, ry)
			cap.height = maxf(rx, ry) * 2.0
			if rx > ry:
				shape.rotation = PI / 2.0
			shape.shape = cap
			body.add_child(shape)
			add_child(body)

func _gen_corals(rng : RandomNumberGenerator, count: int):
	for i in count:
		corals.append({
			"pos": Vector2(rng.randf_range(-world_radius * 0.85, world_radius * 0.85), rng.randf_range(-world_radius * 0.85, world_radius * 0.85)),
			"type": rng.randi_range(0, 2),
			"size": rng.randf_range(8, 22),
			"hue": rng.randf_range(-0.08, 0.08),
			"ph": rng.randf_range(0, TAU),
			"branches": rng.randi_range(3, 6),
		})

func _gen_ripples(rng: RandomNumberGenerator, count : int):
	for i in count:
		ripples.append({
			"pos": Vector2(rng.randf_range(-world_radius, world_radius), rng.randf_range(-world_radius, world_radius)),
			"len": rng.randf_range(40, 130),
			"ang": rng.randf_range(-0.3, 0.3),
			"spd": rng.randf_range(0.3, 0.8),
			"ph": rng.randf_range(0, TAU),
			"drift": rng.randf_range(5, 20),
		})

func _gen_streaks(rng: RandomNumberGenerator, count: int):
	for i in count:
		streaks.append({
			"pos": Vector2(rng.randf_range(-world_radius * 0.9, world_radius * 0.9), rng.randf_range(-world_radius * 0.9, world_radius * 0.9)),
			"len": rng.randf_range(60, 200),
			"ang": rng.randf_range(-0.5, 0.5),
			"spd": rng.randf_range(0.15, 0.5),
			"ph": rng.randf_range(0, TAU),
			"w": rng.randf_range(1.0, 2.5),
		})

func _gen_debris(rng : RandomNumberGenerator, count: int):
	for i in count:
		debris.append({
			"pos": Vector2(rng.randf_range(-world_radius * 0.8, world_radius * 0.8), rng.randf_range(-world_radius * 0.8, world_radius * 0.8)),
			"size": rng.randf_range(1.5, 4.0),
			"drift_spd": rng.randf_range(3.0, 12.0),
			"drift_ang": rng.randf_range(0, TAU),
			"ph": rng.randf_range(0, TAU),
		})

func _gen_lily_pads(rng: RandomNumberGenerator, count: int):
	for i in count:
		lily_pads.append({
			"pos": Vector2(rng.randf_range(-world_radius * 0.6, world_radius * 0.6), rng.randf_range(-world_radius * 0.6, world_radius * 0.6)),
			"radius": rng.randf_range(14, 28),
			"rotation": rng.randf_range(0, TAU),
			"notch": rng.randf_range(0, TAU),
			"hue": rng.randf_range(-0.04, 0.04),
			"drift_ph": rng.randf_range(0, TAU),
		})

func _draw():
	_draw_gradient()
	_draw_streaks()
	_draw_rays()
	_draw_caustics()
	_draw_ripples()
	_draw_debris()
	_draw_rocks()
	_draw_corals()

# ocean gradient
func _draw_gradient():
	var ext := world_radius + 300
	draw_rect(Rect2(-ext, -ext, ext * 2, ext * 2), ABYSS)
	for i in range(80, -1, -1):
		var f := float(i) / 80.0
		var r := world_radius * f + 50
		var col : Color
		if f < 0.15:
			col = SHALLOW.lerp(SHALLOW_B, f / 0.15)
		elif f < 0.30:
			col = SHALLOW_B.lerp(MID, (f - 0.15) / 0.15)
		elif f < 0.50:
			col = MID.lerp(MID_DEEP, (f - 0.30) / 0.20)
		elif f < 0.72:
			col = MID_DEEP.lerp(DEEP, (f - 0.50) / 0.22)
		else:
			col = DEEP.lerp(ABYSS, (f - 0.72) / 0.28)
		_disc(Vector2.ZERO, r, col, 48)

func _draw_rays():
	for ray in rays:
		var drift := sin(t * ray["spd"] + ray["ph"]) * 35
		var x : float = ray["x"] + drift
		var w : float = ray["w"]
		var a : float = ray["a"] * (0.7 + sin(t * 0.4 + ray["ph"]) * 0.3)
		draw_colored_polygon(PackedVector2Array([
			Vector2(x - w * 0.25, -world_radius),
			Vector2(x + w * 0.25, -world_radius),
			Vector2(x + w, world_radius),
			Vector2(x - w, world_radius),
		]), Color(0.80, 0.95, 1.0, a))

func _draw_caustics():
	for s in caustics:
		var pos: Vector2 = s["pos"]
		var sz: float = s["size"]
		var spd: float = s["spd"]
		var ph : float = s["ph"]
		var depth := clampf(pos.length() / world_radius, 0.0, 1.0)
		var alpha := lerpf(0.14, 0.02, depth) * (0.5 + sin(t * spd * 0.7 + ph) * 0.5)
		sz += sin(t * spd + ph) * sz * 0.3
		var col := Color(0.70, 0.98, 0.90, alpha) if depth < 0.35 else Color(0.60, 0.85, 1.0, alpha)
		_oval(pos, sz, sz * 0.65, col)

func _draw_ripples():
	for rip in ripples:
		var pos: Vector2 = rip["pos"]
		var l : float = rip["len"]
		var ang: float = rip["ang"]
		var spd: float = rip["spd"]
		var ph: float = rip["ph"]
		var d : float = rip["drift"]
		var cx := pos.x + sin(t * spd * 0.3 + ph) * d
		var cy := pos.y + cos(t * spd * 0.2 + ph * 1.3) * d * 0.5
		var depth := clampf(Vector2(cx, cy).length() / world_radius, 0.0, 1.0)
		var alpha := lerpf(0.07, 0.015, depth) * (0.5 + sin(t * spd + ph) * 0.5)
		if alpha < 0.004:
			continue
		var col := Color(0.75, 0.95, 1.0, alpha)
		var prev := Vector2.ZERO
		for i in range(13):
			var f := float(i) / 12.0 - 0.5
			var x := cx + cos(ang) * f * l
			var y := cy + sin(ang) * f * l + sin(f * 7.0 + t * spd * 1.8 + ph) * 2.5
			var pt := Vector2(x, y)
			if i > 0:
				draw_line(prev, pt, col, 1.2, true)
			prev = pt

# seabed rocks
func _draw_rocks():
	for cluster in rocks:
		var bp: Vector2 = cluster["pos"]
		var depth := clampf(bp.length() / world_radius, 0.0, 1.0)
		for stone in cluster["stones"]:
			var pos : Vector2 = bp + stone["off"]
			var rx : float = stone["rx"]
			var ry : float = stone["ry"]
			var sh : float = stone["shade"]
			var bv := lerpf(0.52, 0.30, depth)
			var rc := Color(bv + sh, bv + sh - 0.02, bv + sh + 0.02, 1.0)
			_oval(pos + Vector2(3, 4), rx + 3, ry + 2, Color(0.0, 0.02, 0.06, 0.25))
			_rock_shape(pos, rx, ry, rc)
			_oval(pos + Vector2(-rx * 0.22, -ry * 0.18), rx * 0.5, ry * 0.4, Color(bv + 0.18, bv + 0.16, bv + 0.14, 0.6))

func _rock_shape(c: Vector2, rx: float, ry: float, col: Color):
	var pts : PackedVector2Array = []
	for i in 20:
		var a := (float(i) / 20) * TAU
		var n := sin(a * 3.0 + c.x * 0.1) * 1.8 + cos(a * 2.0 + c.y * 0.1) * 1.2
		pts.append(c + Vector2(cos(a) * (rx + n), sin(a) * (ry + n * 0.6)))
	draw_colored_polygon(pts, col)

func _draw_corals():
	for c in corals:
		var pos : Vector2 = c["pos"]
		var sz : float = c["size"]
		var hue : float = c["hue"]
		var ph : float = c["ph"]
		var depth := clampf(pos.length() / world_radius, 0.0, 1.0)
		var vis := lerpf(0.8, 0.2, depth)
		if vis < 0.1:
			continue
		match c["type"]:
			0: _brain_coral(pos, sz, hue, vis, ph)
			1: _branch_coral(pos, sz, hue, vis, ph, c["branches"])
			2: _fan_coral(pos, sz, hue, vis, ph)

func _brain_coral(pos: Vector2, sz: float, hue: float, vis: float, ph: float):
	_oval(pos + Vector2(2, 3), sz + 2, sz * 0.8 + 1, Color(0.0, 0.02, 0.05, vis * 0.15))
	_oval(pos, sz, sz * 0.8, Color(0.85 + hue, 0.45 + hue * 0.5, 0.55, vis))
	var sway := sin(t * 0.5 + ph) * 1.5
	for i in range(3):
		var yo := (float(i) - 1.0) * sz * 0.35
		var rc := Color(0.75 + hue, 0.35, 0.45, vis * 0.4)
		var prev := Vector2.ZERO
		for j in range(9):
			var f := float(j) / 8.0 - 0.5
			var pt := Vector2(pos.x + f * sz * 1.6, pos.y + yo + sin(f * 6.0 + ph + i + sway) * 2.0)
			if j > 0:
				draw_line(prev, pt, rc, 0.8, true)
			prev = pt
	_oval(pos + Vector2(-sz * 0.15, -sz * 0.12), sz * 0.45, sz * 0.35, Color(0.95 + hue, 0.60, 0.65, vis * 0.5))

func _branch_coral(pos : Vector2, sz: float, hue: float, vis : float, ph: float, branches: int):
	var sway := sin(t * 0.6 + ph) * 2.0
	for i in branches:
		var ang := (float(i) / branches) * TAU + ph
		var bl := sz * (0.7 + 0.3 * sin(ph + i * 1.5))
		var tip := Vector2(pos.x + cos(ang) * bl + sway * 0.5, pos.y + sin(ang) * bl)
		var perp := Vector2(-sin(ang), cos(ang))
		draw_colored_polygon(PackedVector2Array([
			pos + perp * 3.0, tip + perp * 1.2, tip - perp * 1.2, pos - perp * 3.0,
		]), Color(0.90 + hue, 0.40 + hue * 0.3, 0.30, vis * 0.75))
		_oval(tip, 2.7, 2.2, Color(0.95 + hue, 0.55, 0.40, vis * 0.35))
	_oval(pos, 4.0, 3.5, Color(0.80 + hue, 0.35, 0.25, vis * 0.85))

func _fan_coral(pos: Vector2, sz : float, hue: float, vis: float, ph : float):
	var sway := sin(t * 0.4 + ph) * 1.0
	_oval(pos + Vector2(2, 3), sz * 1.1, sz * 0.55, Color(0.0, 0.02, 0.05, vis * 0.12))
	_oval(pos + Vector2(0, sway), sz, sz * 0.5, Color(0.65 + hue, 0.35, 0.70 + hue, vis * 0.65))
	var edge := Color(0.75 + hue, 0.45, 0.80 + hue, vis * 0.40)
	for i in 5:
		var a := (float(i) / 5.0 - 0.5) * PI * 0.7 + ph * 0.5
		draw_line(pos, Vector2(pos.x + cos(a) * sz * 0.9, pos.y + sin(a) * sz * 0.4 + sway), edge, 0.7, true)
	_oval(pos + Vector2(-sz * 0.1, -sz * 0.08 + sway), sz * 0.4, sz * 0.2, Color(0.80 + hue, 0.55, 0.85 + hue, vis * 0.3))

func _draw_streaks():
	for s in streaks:
		var pos: Vector2 = s["pos"]
		var l: float = s["len"]
		var ang : float = s["ang"]
		var spd: float = s["spd"]
		var ph: float = s["ph"]
		var w : float = s["w"]
		var depth := clampf(pos.length() / world_radius, 0.0, 1.0)
		var flow := t * spd * 20.0
		var cx := fmod(pos.x + cos(ang) * flow + world_radius, world_radius * 2.0) - world_radius
		var cy := fmod(pos.y + sin(ang) * flow + world_radius, world_radius * 2.0) - world_radius
		var alpha := lerpf(0.06, 0.015, depth) * (0.4 + sin(t * spd * 2.0 + ph) * 0.6)
		if alpha < 0.003:
			continue
		var col := Color(0.55, 0.95, 0.80, alpha) if depth < 0.35 else Color(0.40, 0.70, 0.90, alpha)
		var px := -sin(ang)
		var py := cos(ang)
		var prev := Vector2.ZERO
		for i in range(11):
			var f := float(i) / 10.0 - 0.5
			var wave := sin(f * 5.0 + t * spd * 3.0 + ph) * 4.0
			var pt := Vector2(cx + cos(ang) * f * l + px * wave, cy + sin(ang) * f * l + py * wave)
			if i > 0:
				draw_line(prev, pt, col, w, true)
			prev = pt

func _draw_debris():
	for d in debris:
		var pos: Vector2 = d["pos"]
		var sz: float = d["size"]
		var spd : float = d["drift_spd"]
		var ang: float = d["drift_ang"]
		var ph: float = d["ph"]
		var dx := cos(ang) * spd * t + sin(t * 0.3 + ph) * 8.0
		var dy := sin(ang) * spd * t + cos(t * 0.2 + ph) * 5.0
		var fx := fmod(pos.x + dx + world_radius, world_radius * 2.0) - world_radius
		var fy := fmod(pos.y + dy + world_radius, world_radius * 2.0) - world_radius
		var fp := Vector2(fx, fy)
		var depth := clampf(fp.length() / world_radius, 0.0, 1.0)
		var alpha := lerpf(0.25, 0.06, depth)
		var col := Color(0.85, 0.92, 0.80, alpha) if depth < 0.4 else Color(0.7, 0.88, 1.0, alpha)
		draw_circle(fp, sz, col)

func _oval(c: Vector2, rx: float, ry: float, col: Color, segs: int = 16):
	var pts : PackedVector2Array = []
	for i in segs:
		var a := (float(i) / segs) * TAU
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, col)

func _disc(c: Vector2, r: float, col: Color, segs: int = 32):
	var pts : PackedVector2Array = []
	for i in segs:
		var a := (float(i) / segs) * TAU
		pts.append(c + Vector2(cos(a), sin(a)) * r)
	draw_colored_polygon(pts, col)
