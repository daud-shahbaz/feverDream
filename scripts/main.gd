extends Node2D

const AIR = preload("res://scripts/air.gd")
const FOOD = preload("res://scripts/food.gd")
const HUD_S = preload("res://scripts/hud.gd")
const LILY = preload("res://scripts/lilypad.gd")

@onready var player: CharacterBody2D = $Player
@onready var cam: Camera2D = $Camera2D
var hud: CanvasLayer
var music: AudioStreamPlayer
@export var world_radius: float = 1500.0

var p_min: float = 3.0
var p_max : float = 7.0
var p_timer: float = 0.0
var p_next : float = 2.0

var f_min: float = 4.0
var f_max: float = 9.0
var f_timer : float = 0.0
var f_next: float = 3.0

var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	cam.global_position = player.global_position
	cam.zoom = Vector2(1.5, 1.5)
	cam.enabled = true

	var overlay := Node2D.new()
	overlay.set_script(LILY)
	overlay.ocean_bg = $OceanBackground
	add_child(overlay)

	hud = CanvasLayer.new()
	hud.set_script(HUD_S)
	add_child(hud)
	if player:
		player.health_changed.connect(hud.update_health)
		hud.update_health(player.hp, player.max_hp)

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

func _process(delta):
	# camera follow
	if player:
		cam.global_position = cam.global_position.lerp(player.global_position, 3.0 * delta)
		var lim := world_radius - 50
		player.global_position = player.global_position.clamp(Vector2(-lim, -lim), Vector2(lim, lim))

	# spawn air pockets
	p_timer += delta
	if p_timer >= p_next:
		p_timer = 0.0
		p_next = rng.randf_range(p_min, p_max)
		_spawn_pocket()

	f_timer += delta
	if f_timer >= f_next:
		f_timer = 0.0
		f_next = rng.randf_range(f_min, f_max)
		_spawn_food()

func _spawn_pocket():
	var p := Node2D.new()
	p.set_script(AIR)
	add_child(p)
	var ang := rng.randf() * TAU
	var dist := rng.randf_range(0, world_radius * 0.85)
	p.global_position = Vector2(cos(ang), sin(ang)) * dist
	var depth := dist / world_radius
	p.max_r = rng.randf_range(40, 160) * (1.0 - depth * 0.4)

func _spawn_food():
	var count := rng.randi_range(1, 3)
	var center := Vector2.ZERO
	if player:
		var ahead := Vector2.from_angle(player.rotation) * rng.randf_range(80, 200)
		center = player.global_position + ahead
		center += Vector2(rng.randf_range(-120, 120), rng.randf_range(-120, 120))
	var lim := world_radius - 100
	center = center.clamp(Vector2(-lim, -lim), Vector2(lim, lim))
	for i in count:
		var f := Area2D.new()
		f.set_script(FOOD)
		add_child(f)
		f.z_index = 5
		f.global_position = center + Vector2(rng.randf_range(-30, 30), rng.randf_range(-30, 30))
