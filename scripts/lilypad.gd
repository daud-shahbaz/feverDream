extends Node2D

var ocean_bg: Node2D

func _ready():
	z_index = 15

func _process(_d):
	queue_redraw()

func _draw():
	if not ocean_bg:
		return
	var t: float = ocean_bg.t
	for pad in ocean_bg.lily_pads:
		var pos: Vector2 = pad["pos"]
		var r: float = pad["radius"]
		var rot: float = pad["rotation"]
		var notch: float = pad["notch"]
		var hue: float = pad["hue"]
		var dph: float = pad["drift_ph"]
		pos += Vector2(sin(t * 0.15 + dph) * 4, cos(t * 0.12 + dph) * 3)
		_shadow(pos, r)
		_pad(pos, r, rot, notch, hue)
		_edge(pos, r, rot, notch)
		_center(pos, r)

func _shadow(pos: Vector2, r: float):
	var pts: PackedVector2Array = []
	for i in 32:
		var a := (float(i) / 32) * TAU
		pts.append(pos + Vector2(3, 4) + Vector2(cos(a) * r * 1.05, sin(a) * r * 0.85))
	if pts.size() >= 3:
		draw_colored_polygon(pts, Color(0.0, 0.03, 0.06, 0.09))

func _pad(pos: Vector2, r: float, rot: float, notch: float, hue: float):
	var segs:= 64
	var pts: PackedVector2Array = []
	var nw:= 0.22
	for i in segs:
		var a := (float(i) / segs) * TAU
		var diff := fmod(a - notch + PI, TAU) - PI
		if absf(diff) < nw:
			var edge := nw - absf(diff)
			var cut := 1.0 - (edge / nw) * 0.65
			pts.append(pos + Vector2(cos(a + rot), sin(a + rot)) * r * cut)
		else:
			pts.append(pos + Vector2(cos(a + rot), sin(a + rot)) * r)
	if pts.size() >= 3:
		var g := clampf(0.28 + hue, 0.0, 1.0)
		draw_colored_polygon(pts, Color(0.18, g, 0.12, 0.85))
		draw_colored_polygon(pts, Color(0.22, g + 0.05, 0.14, 0.35))

func _edge(pos: Vector2, r: float, rot: float, notch: float):
	var segs := 64
	var nw := 0.22
	var prev := Vector2.ZERO
	for i in segs + 1:
		var a := (float(i % segs) / segs) * TAU
		var diff := fmod(a - notch + PI, TAU) - PI
		var cr := r
		if absf(diff) < nw:
			cr = r * (1.0 - ((nw - absf(diff)) / nw) * 0.65)
		var pt := pos + Vector2(cos(a + rot), sin(a + rot)) * cr
		if i > 0:
			draw_line(prev, pt, Color(0.12, 0.22, 0.08, 0.3), 0.8, true)
		prev = pt

func _center(pos: Vector2, r: float):
	var pts: PackedVector2Array = []
	for i in 12:
		var a := (float(i) / 12) * TAU
		pts.append(pos + Vector2(cos(a) * r * 0.08, sin(a) * r * 0.08))
	if pts.size() >= 3:
		draw_colored_polygon(pts, Color(0.30, 0.42, 0.20, 0.35))
