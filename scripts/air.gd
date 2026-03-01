extends Node2D

@export var max_r: float= 80.0
@export var ring_count: int = 4
@export var duration: float = 7.0
@export var thickness: float = 1.6

var elapsed: float = 0.0
var depth_t: float = 0.0
var ring_scales: Array[float] = []
var ring_delays : Array[float] = []

func _ready():
	z_index = 6
	depth_t = clampf(global_position.length() / 1500.0, 0.0, 1.0)
	ring_count = randi_range(3, 6)
	duration = randf_range(6.0, 12.0)
	thickness = randf_range(1.2, 2.2)
	for i in ring_count:
		ring_scales.append(randf_range(0.75, 1.0))
		ring_delays.append(randf_range(0.0, 0.4))

func _process(delta):
	elapsed += delta
	if elapsed > duration + 2.0:
		queue_free()
	queue_redraw()

# expanding rings
func _draw():
	for i in ring_count:
		var base_delay := float(i) * (duration * 0.22) / ring_count
		var rd := base_delay + ring_delays[i]
		var rt := elapsed - rd
		if rt < 0:
			continue
		var f:= clampf(rt / duration, 0.0, 1.0)
		var eased := 1.0 - pow(1.0 - f, 3.0)
		var r:= max_r * ring_scales[i] * eased
		var alpha := (1.0- f) * 0.35
		var col: Color
		if depth_t < 0.4:
			col = Color(0.6, 0.92, 0.95, alpha)
		elif depth_t < 0.7:
			col = Color(0.45, 0.75, 0.88, alpha)
		else:
			col = Color(0.35, 0.55, 0.75, alpha * 0.7)
		var w := thickness * (1.0 - f * 0.4)
		_ring(Vector2.ZERO, r, col, w)
		if f < 0.3:
			var ga := (0.3 - f) * 0.08
			_filled(Vector2.ZERO, r * 0.2 * (1.0 - f), Color(0.8, 0.95, 1.0, ga))

func _ring(c: Vector2, r: float, col: Color, w: float):
	for i in 48:
		var a0 := (float(i) / 48) * TAU
		var a1 := (float(i + 1) / 48) * TAU
		draw_line(c + Vector2(cos(a0), sin(a0)) * r, c + Vector2(cos(a1), sin(a1)) * r, col, w, true)

func _filled(c: Vector2, r: float, col: Color):
	var pts: PackedVector2Array = []
	for i in 20:
		var a:= (float(i) / 20) * TAU
		pts.append(c + Vector2(cos(a), sin(a)) * r)
	if pts.size() >= 3:
		draw_colored_polygon(pts, col)
