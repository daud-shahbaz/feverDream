extends CanvasLayer

var ratio: float = 1.0
var display : float = 1.0
var t: float = 0.0

const BAR_W: float = 200.0
const BAR_H : float = 6.0
const MARGIN: float = 28.0

var bar: Control

func _ready():
	layer = 100
	bar = Control.new()
	bar.set_anchors_preset(Control.PRESET_FULL_RECT)
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.draw.connect(_on_draw)
	add_child(bar)

func _process(delta):
	t += delta
	display = lerpf(display, ratio, 5.0 * delta)
	bar.queue_redraw()

func update_health(current: float, maximum: float):
	ratio = current / maxf(maximum, 1.0)

func _on_draw():
	var vp := bar.get_viewport_rect().size
	var bx := (vp.x - BAR_W) * 0.5
	var by := vp.y - MARGIN - BAR_H
	var rect := Rect2(bx, by, BAR_W, BAR_H)

	bar.draw_rect(rect, Color(0.0, 0.05, 0.15, 0.25), true)

	var fw := BAR_W * clampf(display, 0.0, 1.0)
	if fw > 0.5:
		var col : Color
		if display > 0.55:
			col = Color(0.45, 0.88, 0.65, 0.75).lerp(Color(0.92, 0.78, 0.30, 0.80), (1.0 - display) / 0.45)
		elif display > 0.25:
			col = Color(0.92, 0.78, 0.30, 0.80).lerp(Color(0.90, 0.38, 0.28, 0.85), (0.55 - display) / 0.30)
		else:
			col = Color(0.90, 0.38, 0.28, 0.85)
			col.a = lerpf(0.65, 0.95, (sin(t * 4.0) + 1.0) * 0.5)
		bar.draw_rect(Rect2(bx, by, fw, BAR_H), col, true)
		var glow := Color(0.50, 0.95, 0.70, 0.15 * display)
		bar.draw_rect(Rect2(bx, by, fw, 2.0), glow, true)

	bar.draw_rect(rect, Color(1.0, 1.0, 1.0, 0.08), false, 1.0)

	# fish icon
	var ic := Color(0.96, 0.58, 0.25, 0.6)
	if display < 0.3:
		ic = Color(0.90, 0.38, 0.28, 0.5 + sin(t * 4.0) * 0.2)
	var ip := Vector2(bx - 14, by + BAR_H * 0.5)
	var pts : PackedVector2Array = []
	for i in 12:
		var a := (float(i) / 12) * TAU
		pts.append(ip + Vector2(cos(a) * 5.0, sin(a) * 3.0))
	bar.draw_colored_polygon(pts, ic)
	bar.draw_colored_polygon(PackedVector2Array([ip + Vector2(-5, 0), ip + Vector2(-9, -3), ip + Vector2(-9, 3)]), ic)
	bar.draw_circle(ip + Vector2(2, -0.5), 1.0, Color(1.0, 1.0, 1.0, 0.9))

	# warning text
	if display < 0.3:
		var wa := (sin(t * 3.0) + 1.0) * 0.25
		bar.draw_string(ThemeDB.fallback_font, Vector2(bx + BAR_W * 0.5 - 18, by - 6), "hungry...", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.95, 0.55, 0.35, wa))
