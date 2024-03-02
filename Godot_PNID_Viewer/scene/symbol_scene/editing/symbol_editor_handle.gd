# Symbol editor handle
# Translation, Scaling, Rotation handle that follows mouse drag

extends Node2D
class_name Handle

enum TYPE {SCALING, ROTATE, TRANSLATE}
enum SCALE_TYPE {TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT, NONE}

signal indicator_move_started(mouse_pos: Vector2)
signal indicator_moved(mouse_delta: Vector2)
signal indicator_move_ended(mouse_pos: Vector2)

@export var type: TYPE
@export var scale_type: SCALE_TYPE

@onready var collision_rect: CollisionShape2D = $Area2D/CollisionShape2D
@onready var collision_area: Area2D = $Area2D

var is_dragging: bool = false
var on_cursor: bool = false
var mouse_to_object_offset

func _ready():
	add_to_group("draw_group")
	
	
func set_initial_handle_size(size: Vector2):
	var sized_rect = RectangleShape2D.new()
	sized_rect.size = size
	collision_rect.shape = sized_rect
	
func on_redraw_requested():
	update_collision_area_size()
	queue_redraw()
	
	
func update_collision_area_size():
	if type == TYPE.TRANSLATE: # translate area should not change
		return
		
	var zoom_level = get_viewport().get_camera_2d().zoom
	collision_area.scale = Vector2.ONE/zoom_level
	

func _draw():
	var zoom_level = get_viewport().get_camera_2d().zoom
	var color = Config.EDITOR_HANDLE_COLOR
	var line_width = Config.EDITOR_RECT_LINE_WIDTH
	var rect = collision_rect.shape.get_rect()
	
	if type == TYPE.SCALING:
		draw_circle(rect.get_center(), (rect.size.x/2)/zoom_level.x, color)
	elif type == TYPE.ROTATE:
		draw_rect(Rect2(rect.position/zoom_level, rect.size/zoom_level), color, false, line_width/zoom_level.x)
		

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			if on_cursor:
				is_dragging = true
				mouse_to_object_offset = global_position - get_global_mouse_position()
				indicator_move_started.emit(self, get_global_mouse_position())
		else:
			is_dragging = false
			indicator_move_ended.emit(self,get_global_mouse_position())
		
	if event is InputEventMouseMotion and is_dragging:
		if type != TYPE.ROTATE:
			global_position = get_global_mouse_position() + mouse_to_object_offset
		indicator_moved.emit(self,get_global_mouse_position() + mouse_to_object_offset)
		

func _on_area_2d_mouse_entered():
	on_cursor = true


func _on_area_2d_mouse_exited():
	on_cursor = false
