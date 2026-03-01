extends Node2D

var t: float = 0.0
var started := false
var fade: float = 0.0
var ready_input := false
var bubbles: Array = []

var music: AudioStreamPlayer

func _ready():
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in 40:
		bubbles.append({
			"x": rng.randf_range(-300, 300),
			"y": rng.randf_range(-200, 250),
			"r": rng.randf_range(1.5, 5.0),
			"spd": rng.randf_range(8.0, 25.0),
			"ph": rng.randf_range(0, TAU),
			"a": rng.randf_range(0.08, 0.25),
		})
	music = AudioStreamPlayer.new()
	music.bus = "Master"
	music.volume_db = -10.0
	add_child(music)
	var stream = load("res://Aetheric - Echoes of the Fields (freetouse.com).mp3")
	if stream:
		if stream is AudioStreamMP3:
			stream.loop = true
		music.stream = stream
		music.play()
	await get_tree().create_timer(0.8).timeout
	ready_input = true

func _input(event):
	if started or not ready_input:
		return
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		if event.pressed:
			started = true

func _process(delta):
	t += delta
	if started:
		fade = minf(fade + delta * 1.2, 1.0)
		if fade >= 1.0:
			get_tree().change_scene_to_file("res://scenes/main.tscn")
	queue_redraw()

func _draw():
	var vp := get_viewport_rect().size
	var cx := vp.x * 0.5
	var cy := vp.y * 0.5

	# bg gradient
	for i in 50:
		var f := float(i) / 50.0
		var y0 := vp.y * f
		var h := vp.y / 50.0 + 1
		var col : Color
		if f < 0.2:
			col = Color(0.40, 0.82, 0.75).lerp(Color(0.32, 0.72, 0.72), f / 0.2)
		elif f < 0.45:
			col = Color(0.32, 0.72, 0.72).lerp(Color(0.18, 0.50, 0.60), (f - 0.2) / 0.25)
		elif f < 0.7:
			col = Color(0.18, 0.50, 0.60).lerp(Color(0.08, 0.28, 0.45), (f - 0.45) / 0.25)
		else:
			col = Color(0.08, 0.28, 0.45).lerp(Color(0.02, 0.06, 0.14), (f - 0.7) / 0.3)
		draw_rect(Rect2(0, y0, vp.x, h), col)

	# bubbles
	for b in bubbles:
		var bx : float = cx + b["x"] + sin(t * 0.3 + b["ph"]) * 15.0
		var by : float = fmod(b["y"] - t * b["spd"] + 300, 500) - 250 + cy
		var wobble : float = sin(t * 1.5 + b["ph"]) * b["r"] * 0.2
		var r : float = b["r"] + wobble
		var alpha : float = b["a"] * (0.6 + sin(t * 0.8 + b["ph"]) * 0.4)
		draw_circle(Vector2(bx, by), r, Color(0.7, 0.95, 1.0, alpha))
		draw_circle(Vector2(bx - r * 0.25, by - r * 0.3), r * 0.35, Color(1.0, 1.0, 1.0, alpha * 0.6))

	# title
	var title := "The Leviathan"
	var bob := sin(t * 0.8) * 3.0
	var ty := cy - 30 + bob
	var ta := clampf(t * 0.8, 0.0, 1.0)
	var fs := 36
	var tw := ThemeDB.fallback_font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var tx := cx - tw * 0.5
	var offsets := [
		Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1),
		Vector2(-0.7, -0.7), Vector2(0.7, -0.7), Vector2(-0.7, 0.7), Vector2(0.7, 0.7),
	]
	draw_string(ThemeDB.fallback_font, Vector2(tx + 2, ty + 2), title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.0, 0.03, 0.10, 0.4 * ta))
	var tc := Color(0.98, 0.96, 0.92, ta * 0.95)
	for off in offsets:
		draw_string(ThemeDB.fallback_font, Vector2(tx + off.x, ty + off.y), title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, tc)
	draw_string(ThemeDB.fallback_font, Vector2(tx, ty), title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, tc)

	# prompt
	if ready_input and not started:
		var pulse := (sin(t * 2.5) + 1.0) * 0.5
		draw_string(ThemeDB.fallback_font, Vector2(cx - 52, vp.y - 60), "press any key", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.90, 0.95, 0.92, 0.3 + pulse * 0.35))

	# fade overlay
	if fade > 0.0:
		draw_rect(Rect2(0, 0, vp.x, vp.y), Color(0, 0, 0, fade))
