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

@onready var collision_rect: CollisionShape2D = $Area2D/CollisionShape2D
@onready var collision_area: Area2D = $Area2D

var is_dragging: bool = false
var on_cursor: bool = false
var reference_size: Vector2

var last_mouse_position

func _ready():
	set_physics_process(false)

func set_initial_handle_size(size: Vector2):
	reference_size = size
	collision_area.scale = size
	

func _draw():
	var color = Config.EDITOR_HANDLE_COLOR
	var line_width = Config.EDITOR_RECT_LINE_WIDTH
	
	if type == TYPE.SCALING:
		draw_circle(Vector2.ZERO, (reference_size.x*0.5), color)
	elif type == TYPE.ROTATE:
		draw_rect(Rect2(-reference_size*0.5, reference_size), color, false, line_width)
		

func process_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			if on_cursor:
				is_dragging = true
				last_mouse_position = get_global_mouse_position()
				indicator_move_started.emit(self, get_global_mouse_position())
		else:
			is_dragging = false
			on_cursor = false
			indicator_move_ended.emit(self,get_global_mouse_position())
		
	if event is InputEventMouseMotion and is_dragging:
		var delta = get_global_mouse_position() - last_mouse_position
		if type != TYPE.ROTATE:
			self.translate(event.relative)
		indicator_moved.emit(self,get_global_mouse_position(),delta)
		last_mouse_position = get_global_mouse_position()


func disable_collision():
	collision_area.free()
	collision_area.disable_mode = CollisionObject2D.DISABLE_MODE_REMOVE
	collision_rect.disabled = true
	
	
func enable_collision():
	collision_area.disable_mode = CollisionObject2D.DISABLE_MODE_REMOVE
	collision_rect.disabled = false


func _on_area_2d_mouse_entered():
	on_cursor = true


func _on_area_2d_mouse_exited():
	on_cursor = false
