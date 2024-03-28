# Symbol editor handle
# Translation, Scaling, Rotation handle that follows mouse drag

extends Node2D
class_name Handle

enum TYPE {SCALING, ROTATE, TRANSLATE}
enum SCALE_TYPE {TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT, NONE}

signal indicator_move_started(target: Handle,mouse_pos: Vector2)
signal indicator_moved(target: Handle, mouse_pos: Vector2, mouse_pos_delta: Vector2)
signal indicator_move_ended(target: Handle,mouse_pos: Vector2)

@export var type: TYPE
@export var scale_type: SCALE_TYPE

#@onready var collision_rect: CollisionShape2D = $Area2D/CollisionShape2D
@onready var _collision_area: Area2D = $Area2D

var on_cursor: bool = false
var _is_dragging: bool = false
var _reference_size: Vector2

var last_mouse_position

func _ready():
	add_to_group("draw")
	set_physics_process(false)


func set_initial_handle_size(size: Vector2):
	_reference_size = size
	_collision_area.scale = size


func redraw():
	queue_redraw()
	

func _draw():
	var zoom_factor = get_viewport().get_camera_2d().zoom.x
	var color = Config.EDITOR_HANDLE_COLOR
	var line_width = Config.EDITOR_RECT_LINE_WIDTH / zoom_factor
	
	if type == TYPE.SCALING:
		_collision_area.scale = _reference_size / zoom_factor
		draw_circle(Vector2.ZERO, (_reference_size.x * 0.5 / zoom_factor), color)
	elif type == TYPE.ROTATE:
		_collision_area.scale = _reference_size / zoom_factor
		draw_rect(Rect2(-_reference_size * 0.5 / zoom_factor, _reference_size / zoom_factor), color, false, line_width)
		

func process_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			if on_cursor:
				_is_dragging = true
				last_mouse_position = get_global_mouse_position()
				indicator_move_started.emit(self, get_global_mouse_position())
		else:
			if _is_dragging:
				_is_dragging = false
				on_cursor = false
				indicator_move_ended.emit(self,get_global_mouse_position())
		
	if event is InputEventMouseMotion and _is_dragging:
		var delta = get_global_mouse_position() - last_mouse_position
		if type != TYPE.ROTATE:
			self.translate(event.relative)
		indicator_moved.emit(self,get_global_mouse_position(),delta)
		last_mouse_position = get_global_mouse_position()


func disable_collision():
	remove_child(_collision_area)
	
	
func enable_collision():
	add_child(_collision_area)


func _on_area_2d_mouse_entered():
	on_cursor = true


func _on_area_2d_mouse_exited():
	on_cursor = false
