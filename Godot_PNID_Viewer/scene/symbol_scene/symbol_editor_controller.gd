# Symbol editor controller
# change transform of "Center" node, followed by change of handles

extends Node2D

@onready var tl_handle = $TL_Handle
@onready var tr_handle = $TR_Handle
@onready var bl_handle = $BL_Handle
@onready var br_handle = $BR_Handle
@onready var rot_handle= $Rot_Handle
@onready var translate_handle = $Translate_Handle

@onready var center_node = $Center

var rot_start_angle: float
var rot_start_vec: Vector2
var translate_start_position: Vector2
var translate_start_mouse_position: Vector2


func _ready():
	rot_handle.indicator_move_started.connect(on_indicator_move_started)
	translate_handle.indicator_move_started.connect(on_indicator_move_started)
	
	tl_handle.indicator_moved.connect(on_indicator_moved)
	tr_handle.indicator_moved.connect(on_indicator_moved)
	bl_handle.indicator_moved.connect(on_indicator_moved)
	br_handle.indicator_moved.connect(on_indicator_moved)
	rot_handle.indicator_moved.connect(on_indicator_moved)
	translate_handle.indicator_moved.connect(on_indicator_moved)
	
	tl_handle.set_handle_size(Vector2(Config.EDITOR_HANDLE_SIZE,Config.EDITOR_HANDLE_SIZE))
	tr_handle.set_handle_size(Vector2(Config.EDITOR_HANDLE_SIZE,Config.EDITOR_HANDLE_SIZE))
	bl_handle.set_handle_size(Vector2(Config.EDITOR_HANDLE_SIZE,Config.EDITOR_HANDLE_SIZE))
	br_handle.set_handle_size(Vector2(Config.EDITOR_HANDLE_SIZE,Config.EDITOR_HANDLE_SIZE))
	rot_handle.set_handle_size(Vector2(Config.EDITOR_HANDLE_SIZE,Config.EDITOR_HANDLE_SIZE))
	translate_handle.set_handle_size(Vector2.ONE)
	
	
func set_target_symbol(symbol_position: Vector2, symbol_size: Vector2, symbol_angle: float):
	center_node.global_position = symbol_position
	center_node.global_scale = symbol_size
	center_node.rotation = symbol_angle
	
	update_handle_positions_as_anchor()
	

func _draw():
	var color = Config.EDITOR_RECT_COLOR
	var line_width = Config.EDITOR_RECT_LINE_WIDTH

	draw_line(tl_handle.global_position, tr_handle.global_position, color, line_width)
	draw_line(tr_handle.global_position, br_handle.global_position, color, line_width)
	draw_line(br_handle.global_position, bl_handle.global_position, color, line_width)
	draw_line(bl_handle.global_position, tl_handle.global_position, color, line_width)


func update_handle_positions_as_anchor():
	tl_handle.global_position = $Center/TL_Anchor.global_position
	tr_handle.global_position = $Center/TR_Anchor.global_position
	bl_handle.global_position = $Center/BL_Anchor.global_position
	br_handle.global_position = $Center/BR_Anchor.global_position
	rot_handle.global_position = $Center/Rot_Anchor.global_position
	translate_handle.global_position = $Center.global_position
	translate_handle.global_scale = $Center.global_scale
	translate_handle.rotation = $Center.rotation
	queue_redraw()
	
	
func on_indicator_move_started(target: Handle, start_pos: Vector2):
	if target.type == Handle.TYPE.ROTATE:
		rot_start_angle = center_node.rotation
		rot_start_vec = (start_pos - center_node.global_position).normalized()
	elif target.type == Handle.TYPE.TRANSLATE:
		translate_start_position = center_node.global_position
		translate_start_mouse_position = start_pos
	
	
func on_indicator_moved(target: Handle, mouse_pos: Vector2):
	var right_vec = Vector2.RIGHT.rotated(center_node.rotation)
	var up_vec = -Vector2.UP.rotated(center_node.rotation)
		
	var diag_vec: Vector2
	
	if target.type == Handle.TYPE.TRANSLATE:
		center_node.global_position = translate_start_position + (mouse_pos - translate_start_mouse_position)
	
	if target.type == Handle.TYPE.ROTATE:
		var rot_vec = (mouse_pos - center_node.global_position).normalized()
		var angle = rot_start_vec.angle_to(rot_vec)
		center_node.rotation = rot_start_angle + angle
	
	if target.type == Handle.TYPE.SCALING:
		var changed_position
		if target == tl_handle:
			changed_position = (target.global_position + br_handle.global_position)/2
		elif target == tr_handle:
			changed_position = (target.global_position + bl_handle.global_position)/2
		elif target == bl_handle:
			changed_position = (target.global_position + tr_handle.global_position)/2
		elif target == br_handle:
			changed_position = (target.global_position + tl_handle.global_position)/2
			
		diag_vec = (target.global_position - changed_position).rotated(-center_node.rotation)
		center_node.global_position = changed_position
		center_node.global_scale = abs(diag_vec*2)
		
	# TODO: width/height가 0이 되지 않도록제
	# TODO: Rotated된 심볼 rect 안그려지는 문
	# TODO: screen space 크기 고정신
	# TODO: 수정값 -> Project -> symbolinfo 지속 갱
				
	update_handle_positions_as_anchor()