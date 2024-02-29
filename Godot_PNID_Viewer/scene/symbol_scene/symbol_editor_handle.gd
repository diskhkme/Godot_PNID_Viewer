extends Node2D
class_name Handle

enum TYPE {SCALING, ROTATE, TRANSLATE}

signal indicator_move_started
signal indicator_moved
signal indicator_move_ended

@export var type: TYPE
@export var line_width: float
@export var color: Color
@export var ref_location: Node2D

@onready var rect_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var indicator_rect: Rect2 = rect_shape.shape.get_rect()


var is_dragging: bool = false
var on_cursor: bool = false
var dragging_start_pos: Vector2

func set_handle_size(size: Vector2):
	var sized_rect = RectangleShape2D.new()
	sized_rect.size = size
	rect_shape.shape = sized_rect


func _draw():
	if type == TYPE.SCALING:
		var rect = rect_shape.shape.get_rect()
		draw_circle(rect.get_center(), rect.size.x/2, color)
	elif type == TYPE.ROTATE:
		print(rect_shape.shape.get_rect().size)
		draw_rect(rect_shape.shape.get_rect(), color, false, line_width)
		

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			if on_cursor:
				is_dragging = true
				dragging_start_pos = get_global_mouse_position()
				indicator_move_started.emit(self, dragging_start_pos)
		else:
			is_dragging = false
			indicator_move_ended.emit(self,get_global_mouse_position())
		
	if event is InputEventMouseMotion and is_dragging:
		if type == TYPE.SCALING:
			global_position = get_global_mouse_position()
		indicator_moved.emit(self,get_global_mouse_position())
		

func _on_area_2d_mouse_entered():
	on_cursor = true


func _on_area_2d_mouse_exited():
	on_cursor = false
