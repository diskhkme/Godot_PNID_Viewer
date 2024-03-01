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
	SymbolManager.symbol_selected_from_image.connect(on_symbol_selected)
	SymbolManager.symbol_selected_from_tree.connect(on_symbol_selected)
	
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
	
	
func on_symbol_selected(xml_id: int, symbol_id: int):
	var target_symbol_object = ProjectManager.active_project.xml_status[xml_id].symbol_objects[symbol_id]
	var symbol_position = target_symbol_object.get_center()
	var symbol_size = target_symbol_object.get_size()
	var symbol_angle = deg_to_rad(target_symbol_object.degree)
	set_target_symbol(symbol_position, symbol_size, symbol_angle)
	#SymbolManager.symbol_edit_started.emit()
	
	
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


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			# if mouse pressed on outside of handles, end editing
			if (tl_handle.on_cursor or tr_handle.on_cursor or br_handle.on_cursor or 
			bl_handle.on_cursor or rot_handle.on_cursor or translate_handle.on_cursor) == false:
				SymbolManager.symbol_edit_ended.emit()
				

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
