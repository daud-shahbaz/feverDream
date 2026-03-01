extends CharacterBody2D

@export var speed: float = 90.0
@export var rot_speed: float = 3.5
@export var damping: float = 0.92
@export var max_hp: float = 100.0

var hp: float = 100.0
var move_drain : float = 2.5
var idle_drain: float = 0.25
var dead := false
var death_t: float = 0.0
var t : float = 0.0

var tail_ph: float = 0.0
var fin_ph : float = 0.0
var breath: float = 0.0
var idle_t : float = 0.0
var undulate : float = 0.0
var dir := Vector2.RIGHT
var moving := false

var trail : Array[Vector2] = []

signal health_changed(current: float, maximum: float)
func _ready():
	add_to_group("player")
	z_index = 10

func _physics_process(delta):
	t += delta
	if dead:
		death_t += delta
		if death_t >= 2.5:
			_respawn()
		queue_redraw()
		return
	_handle_input(delta)
	_drain(delta)
	_animate(delta)
	move_and_slide()
	trail.insert(0, global_position)
	if trail.size() > 22:
		trail.resize(22)
	queue_redraw()

# hunger drain
func _drain(delta):
	var effort := velocity.length() / maxf(speed, 1.0)
	var rate := lerpf(idle_drain, move_drain, effort)
	hp = maxf(hp - rate * delta, 0.0)
	health_changed.emit(hp, max_hp)
	if hp <= 0.0:
		dead = true
		death_t = 0.0
		velocity = Vector2.ZERO

func feed(amount: float):
	hp = minf(hp + amount, max_hp)
	health_changed.emit(hp, max_hp)

func _respawn():
	dead = false
	hp = max_hp * 0.6
	global_position = Vector2.ZERO
	velocity = Vector2.ZERO
	trail.clear()
	health_changed.emit(hp, max_hp)

func _handle_input(delta):
	var inp := Vector2.ZERO
	if Input.is_action_pressed("ui_right"): inp.x += 1
	if Input.is_action_pressed("ui_left"):  inp.x -= 1
	if Input.is_action_pressed("ui_down"):  inp.y += 1
	if Input.is_action_pressed("ui_up"):    inp.y -= 1
	moving = inp.length() > 0.1
	if moving:
		inp = inp.normalized()
		dir = dir.lerp(inp, 4.0 * delta).normalized()
		velocity = velocity.lerp(dir * speed, 3.5 * delta)
		idle_t = 0.0
	else:
		velocity *= damping
		idle_t += delta
	rotation = lerp_angle(rotation, dir.angle(), rot_speed * delta)

func _animate(delta):
	var swim := velocity.length() / maxf(speed, 1.0)
	tail_ph += (1.4 + swim * 3.5) * delta
	fin_ph += (1.0 + swim * 2.0) * delta
	breath = sin(t * 0.6) * 0.03
	undulate = sin(tail_ph * 0.7) * 1.5

func _draw():
	var da := 1.0
	if dead:
		da = clampf(1.0 - death_t / 1.5, 0.0, 1.0)
		if da <= 0.0:
			return
		modulate.a = da
	else:
		modulate.a = 1.0
	_draw_shadow()
	_draw_trail()

	_draw_tail()
	_draw_fins()
	_draw_body()
	_draw_patches()
	_draw_scales()
	_draw_dorsal()
	_draw_head()
	_draw_eyes()
	_draw_whiskers()
	_draw_glow()

func _draw_shadow():
	_oval(Vector2(4, 6), 22.0, 10.0, Color(0.0, 0.02, 0.08, 0.12), 40)

func _draw_trail():
	for i in trail.size():
		var f := 1.0 - float(i) / 22.0
		var local := trail[i] - global_position
		draw_circle(local, lerpf(0.6, 2.5, f), Color(0.85, 0.95, 1.0, f * 0.15))

# tail fin sway
func _draw_tail():
	var br := 1.0 + breath
	var sw := sin(tail_ph) * 10.0
	var sw2 := sin(tail_ph + 0.5) * 6.0
	var col := Color(0.96, 0.50, 0.15, 0.7)
	draw_colored_polygon(_curve([
		Vector2(-18, 0), Vector2(-22, -2 + sw * 0.3),
		Vector2(-28, -5 + sw * 0.6), Vector2(-36, -10 + sw),
		Vector2(-42, -14 + sw + sw2), Vector2(-38, -8 + sw * 0.8),
		Vector2(-30, -3 + sw * 0.5), Vector2(-22, sw * 0.2), Vector2(-18, 0),
	]), col)
	draw_colored_polygon(_curve([
		Vector2(-18, 0), Vector2(-22, 2 + sw * 0.3),
		Vector2(-28, 5 + sw * 0.6), Vector2(-36, 10 + sw),
		Vector2(-42, 14 + sw + sw2), Vector2(-38, 8 + sw * 0.8),
		Vector2(-30, 3 + sw * 0.5), Vector2(-22, sw * 0.2), Vector2(-18, 0),
	]), col)
	draw_colored_polygon(_curve([
		Vector2(-20, sw * 0.2), Vector2(-28, -3 + sw * 0.6),
		Vector2(-34, -6 + sw * 0.9), Vector2(-30, -2 + sw * 0.5),
		Vector2(-22, sw * 0.15),
	]), Color(1.0, 0.95, 0.88, 0.5))
	draw_colored_polygon(_curve([
		Vector2(-12, -4.5 * br), Vector2(-16, -3 + sw * 0.15),
		Vector2(-20, sw * 0.25), Vector2(-16, 3 + sw * 0.15),
		Vector2(-12, 4.5 * br),
	]), Color(0.96, 0.55, 0.20, 0.85))

func _draw_fins():
	var br := 1.0 + breath
	var w := sin(fin_ph) * 6.0
	var col := Color(0.96, 0.58, 0.25, 0.55)
	var hi := Color(1.0, 0.88, 0.65, 0.25)
	draw_colored_polygon(_curve([
		Vector2(4, -7 * br), Vector2(0, -12 * br + w),
		Vector2(-5, -18 * br + w), Vector2(-8, -22 * br + w * 0.8),
		Vector2(-6, -18 * br + w * 0.6), Vector2(-2, -12 * br + w * 0.3),
		Vector2(2, -7 * br),
	]), col)
	_oval(Vector2(-2, -14 * br + w * 0.6), 3.5, 1.5, hi, 12)
	draw_colored_polygon(_curve([
		Vector2(4, 7 * br), Vector2(0, 12 * br - w),
		Vector2(-5, 18 * br - w), Vector2(-8, 22 * br - w * 0.8),
		Vector2(-6, 18 * br - w * 0.6), Vector2(-2, 12 * br - w * 0.3),
		Vector2(2, 7 * br),
	]), col)
	_oval(Vector2(-2, 14 * br - w * 0.6), 3.5, 1.5, hi, 12)

func _draw_body():
	var br := 1.0 + breath
	var u := undulate
	var pts := _curve([
		Vector2(18 * br, 0), Vector2(16 * br, -5 * br + u),
		Vector2(10 * br, -8.5 * br), Vector2(2, -9 * br),
		Vector2(-5, -8 * br - u * 0.5), Vector2(-10, -6 * br),
		Vector2(-14, -4 * br + u), Vector2(-14, 4 * br + u),
		Vector2(-10, 6 * br), Vector2(-5, 8 * br - u * 0.5),
		Vector2(2, 9 * br), Vector2(10 * br, 8.5 * br),
		Vector2(16 * br, 5 * br + u), Vector2(18 * br, 0),
	], 5)
	draw_colored_polygon(pts, Color(0.97, 0.95, 0.92))
	_oval(Vector2.ZERO, 12.0 * br, 6.0 * br, Color(1.0, 0.98, 0.94, 0.5), 32)

func _draw_patches():
	var br := 1.0 + breath
	_oval(Vector2(10 * br, 0), 8.0 * br, 5.5 * br, Color(0.96, 0.48, 0.12, 0.85), 28)
	_oval(Vector2(-1, -1.5), 7.0 * br, 5.0 * br, Color(0.96, 0.50, 0.15, 0.80), 24)
	_oval(Vector2(-9, 2), 5.0 * br, 3.5 * br, Color(0.94, 0.45, 0.14, 0.7), 20)
	_oval(Vector2(10 * br, 0), 8.5 * br, 6.0 * br, Color(0.85, 0.35, 0.08, 0.15), 28)
	_oval(Vector2(-1, -1.5), 7.5 * br, 5.5 * br, Color(0.85, 0.38, 0.10, 0.12), 24)

func _draw_scales():
	var br := 1.0 + breath
	var sc := Color(0.90, 0.85, 0.80, 0.12)
	var sh := Color(1.0, 0.96, 0.90, 0.08)
	for row in range(-1, 2):
		var yb := row * 3.5 * br
		for i in range(8):
			var x := lerpf(12.0, -10.0, float(i) / 7.0)
			var w := sin(t * 0.4 + i * 0.6 + row) * 0.4
			_arc(Vector2(x, yb + w), 2.2 * br, sc)
			_arc(Vector2(x + 0.5, yb + w - 0.3), 1.5 * br, sh)

func _arc(c: Vector2, r: float, col: Color):
	var pts : PackedVector2Array = []
	for i in range(9):
		var a := PI +(float(i) / 8) * PI
		pts.append(c + Vector2(cos(a) * r, sin(a) * r * 0.6))
	if pts.size() >= 3:
		draw_colored_polygon(pts, col)

func _draw_dorsal():
	var br := 1.0 + breath
	var w := sin(fin_ph * 1.2) * 2.0
	draw_colored_polygon(_curve([
		Vector2(12 * br, 0), Vector2(8, -1.2 + w * 0.3),
		Vector2(2, -1.8 + w * 0.5), Vector2(-4, -1.5 + w * 0.4),
		Vector2(-10, -0.8 + w * 0.2), Vector2(-10, 0.8 + w * 0.2),
		Vector2(-4, 1.5 + w * 0.4), Vector2(2, 1.8 + w * 0.5),
		Vector2(8, 1.2 + w * 0.3), Vector2(12 * br, 0),
	], 3), Color(0.92, 0.50, 0.18, 0.35))

func _draw_head():
	var br := 1.0 + breath
	_oval(Vector2(14 * br, 0), 5.5, 4.5 * br, Color(0.98, 0.94, 0.88, 0.6), 24)
	draw_circle(Vector2(17 * br, -1.5), 0.6, Color(0.4, 0.3, 0.25, 0.3))
	draw_circle(Vector2(17 * br, 1.5), 0.6, Color(0.4, 0.3, 0.25, 0.3))
	draw_line(Vector2(18.5 * br, -0.8), Vector2(18.5 * br, 0.8), Color(0.5, 0.3, 0.2, 0.3), 0.6, true)

func _draw_eyes():
	var br := 1.0 + breath
	var el := Vector2(12, -4.5 * br)
	var er := Vector2(12, 4.5 * br)
	for e in [el, er]:
		draw_circle(e, 2.6, Color(1.0, 1.0, 1.0, 0.95))
		draw_circle(e, 2.0, Color(0.15, 0.12, 0.10, 0.4))
		draw_circle(e + Vector2(0.5, 0), 1.2, Color(0.08, 0.06, 0.12))
		draw_circle(e + Vector2(-0.2, -0.5), 0.55, Color(1.0, 1.0, 1.0, 0.9))

func _draw_whiskers():
	var br := 1.0 + breath
	var w := sin(t * 1.5) * 1.5
	var c := Color(0.7, 0.55, 0.4, 0.35)
	draw_line(Vector2(17 * br, -2.5), Vector2(22 * br, -5 + w), c, 0.5, true)
	draw_line(Vector2(16 * br, -3.0), Vector2(20 * br, -7 + w), c, 0.4, true)
	draw_line(Vector2(17 * br, 2.5), Vector2(22 * br, 5 - w), c, 0.5, true)
	draw_line(Vector2(16 * br, 3.0), Vector2(20 * br, 7 - w), c, 0.4, true)

func _draw_glow():
	var br := 1.0 + breath
	_oval(Vector2.ZERO, 26.0 * br, 14.0 * br, Color(1.0, 0.80, 0.45, 0.04), 28)

func _oval(center: Vector2, rx: float, ry: float, col: Color, segs: int = 32):
	var pts : PackedVector2Array = []
	for i in segs:
		var a := (float(i) / segs) * TAU
		pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, col)

func _curve(points: Array, subdivs: int = 4) -> PackedVector2Array:
	if points.size() < 3:
		var out : PackedVector2Array = []
		for p in points:
			out.append(p)
		return out
	var result: PackedVector2Array = []
	for i in range(points.size()):
		var p0:Vector2 = points[max(i - 1, 0)]
		var p1:Vector2 = points[i]
		var p2:Vector2 = points[min(i + 1, points.size()- 1)]
		var p3:Vector2 = points[min(i + 2, points.size()- 1)]
		for j in range(subdivs):
			var f := float(j) / subdivs
			var ff := f * f
			var fff := ff * f
			result.append(0.5 * (
				(2.0 * p1) + (-p0 + p2) * f +
				(2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * ff +
				(-p0 + 3.0 * p1 - 3.0 * p2 + p3) * fff
			))
	result.append(points[points.size() - 1])
	return result
