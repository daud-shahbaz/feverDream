extends Node2D

@onready var bg: ColorRect = $ColorRect
@onready var ambient_particles: CPUParticles2D = $AmbientParticles
@onready var player_node: Node2D = $Player
@onready var score_label: Label = $ScoreLabel

var bg_hue: float = 0.6
const SHAPE_SCENE = preload("res://dream_shape.tscn")
const BUBBLE_SCENE = preload("res://bubble.gd")
const SHAPE_COUNT = 22
const BUBBLE_COUNT = 12
const WORLD_BOUNDS = Rect2(-1500, -1500, 3000, 3000)

var rng := RandomNumberGenerator.new()
var score: int = 0

func _ready() -> void:
	rng.randomize()
	_spawn_shapes()
	_setup_ambient_particles()

func _process(delta: float) -> void:
	bg_hue  = fmod(bg_hue + delta * 0.04, 1.0)
	bg.color = Color.from_hsv(bg_hue, 0.6, 0.08)
	ambient_particles.global_position = player_node.global_position
	ambient_particles.color = Color.from_hsv(fmod(bg_hue + 0.3, 1.0), 0.5, 1.0, 0.55)

func _spawn_shapes() -> void:
	for i in SHAPE_COUNT:
		var shape = SHAPE_SCENE.instantiate()
		add_child(shape)

		# Random position anywhere in the world
		shape.position = Vector2(
			rng.randf_range(WORLD_BOUNDS.position.x, WORLD_BOUNDS.end.x),
			rng.randf_range(WORLD_BOUNDS.position.y, WORLD_BOUNDS.end.y)
		)

		shape.bounds = WORLD_BOUNDS
		shape.setup(rng)

func _setup_ambient_particles() -> void:
	var p = ambient_particles

	p.emitting          = true
	p.amount            = 120
	p.lifetime          = 7.0
	p.explosiveness     = 0.0
	p.randomness        = 1.0

	p.emission_shape              = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents       = Vector2(700, 500)

	p.direction                   = Vector2(0.3, -1.0)
	p.spread                      = 180.0
	p.initial_velocity_min        = 8.0
	p.initial_velocity_max        = 35.0
	p.gravity                     = Vector2(0, -4)
	p.damping_min                 = 2.0
	p.damping_max                 = 8.0

	p.scale_amount_min            = 1.5
	p.scale_amount_max            = 4.5
	p.scale_amount_curve          = null

	p.color                       = Color(1, 0.8, 1, 0.6)

	var grad                      = Gradient.new()
	grad.set_color(0, Color(1, 1, 1, 0.0))
	grad.set_color(1, Color(1, 1, 1, 0.0))
	grad.add_point(0.1, Color(1, 1, 1, 0.7))
	grad.add_point(0.9, Color(1, 1, 1, 0.3))
	p.color_ramp                  = grad
