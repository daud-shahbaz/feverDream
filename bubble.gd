extends Node2D

var bobbing_offset: float = 0.0
var bob_speed: float = 2.0
var initial_y: float
var size: float = 8.0

func _ready() -> void:
	initial_y = position.y
	add_child(_create_area())

func _create_area() -> Area2D:
	var area = Area2D.new()
	area.name = "CollectionArea"
	
	var shape = CircleShape2D.new()
	shape.radius = size
	
	var collision = CollisionShape2D.new()
	collision.shape = shape
	
	area.add_child(collision)
	return area

func _physics_process(delta: float) -> void:
	bobbing_offset = sin(get_tree().get_frame() * bob_speed * 0.02) * 4.0
	position.y = initial_y + bobbing_offset
	queue_redraw()

func _draw() -> void:
	# Outer glow
	var glow_color = Color(0.5, 0.8, 1.0, 0.2)
	draw_circle(Vector2.ZERO, size + 6.0, glow_color)
	
	# Main bubble
	var bubble_color = Color(0.3, 0.6, 1.0, 0.8)
	draw_circle(Vector2.ZERO, size, bubble_color)
	
	# Highlight
	var highlight = Color(1.0, 1.0, 1.0, 0.6)
	draw_circle(Vector2(-3, -3), size * 0.4, highlight)

func collect() -> void:
	queue_free()
