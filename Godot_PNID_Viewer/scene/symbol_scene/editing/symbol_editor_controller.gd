# Symbol editor controller
# change transform of "Center" node, followed by handles


extends Node2D

@onready var handles = [$TL_Handle, $TR_Handle, $BL_Handle, $BR_Handle, $Rot_Handle, $Translate_Handle]

@onready var center_node = $Center

var rot_start_angle: float
var rot_start_vec: Vector2

var xml_id: int
var symbol_id: int
var target_symbol: SymbolObject

func _ready():
	add_to_group("draw_group")
	SymbolManager.symbol_selected_from_image.connect(on_symbol_selected)
	SymbolManager.symbol_selected_from_tree.connect(on_symbol_selected)
	
	for handle in handles:
		if handle.type == Handle.TYPE.ROTATE or handle.scale_type == Handle.TYPE.TRANSLATE:
			# for rotation and translation, should save initial state when started
			handle.indicator_move_started.connect(on_indicator_move_started)
	
		handle.indicator_moved.connect(on_indicator_moved)

		if handle.type == Handle.TYPE.TRANSLATE:
			handle.set_initial_handle_size(Vector2.ONE)
		else:
			handle.set_initial_handle_size(Vector2.ONE * Config.EDITOR_HANDLE_SIZE)


func on_redraw_requested():
	update_handle_anchor_positions()
	

func _draw():
	var zoom_level = get_viewport().get_camera_2d().zoom
	var color = Config.EDITOR_RECT_COLOR
	var line_width = Config.EDITOR_RECT_LINE_WIDTH

	draw_line($Center/TL_Anchor.global_position, $Center/TR_Anchor.global_position, color, (line_width/zoom_level.x))
	draw_line($Center/TR_Anchor.global_position, $Center/BR_Anchor.global_position, color, (line_width/zoom_level.x))
	draw_line($Center/BR_Anchor.global_position, $Center/BL_Anchor.global_position, color, (line_width/zoom_level.x))
	draw_line($Center/BL_Anchor.global_position, $Center/TL_Anchor.global_position, color, (line_width/zoom_level.x))
	
	
func on_symbol_selected(xml_id: int, symbol_id: int):
	self.xml_id = xml_id
	self.symbol_id = symbol_id
	
	target_symbol = ProjectManager.active_project.xml_status[xml_id].symbol_objects[symbol_id]
	var symbol_position = target_symbol.get_center()
	var symbol_size = target_symbol.get_size()
	var symbol_angle = deg_to_rad(target_symbol.degree)
	center_node.global_position = symbol_position
	center_node.scale = symbol_size
	center_node.rotation = symbol_angle
	update_handle_anchor_positions()
	
	
func get_handle(handle_type: Handle.TYPE, scale_type: Handle.SCALE_TYPE):
	var result = handles.filter(func(a): return a.type == handle_type and a.scale_type == scale_type)
	return result[0]
	

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			# if mouse pressed on outside of handles, end editing
			for handle in handles:
				if handle.on_cursor == true:
					return
					
			SymbolManager.symbol_edit_ended.emit()
				
				
func _process(delta):
	update_handle_anchor_positions()
	queue_redraw()

func update_handle_anchor_positions():
	# rot anchor adjust depending on the zoom level
	var zoom_level = get_viewport().get_camera_2d().zoom
	var up_vec = Vector2.UP.rotated(center_node.rotation)
	var up_offset = Config.EDITOR_ROTATION_HANDLE_OFFSET/zoom_level.x
	$Center/Rot_Anchor.global_position = center_node.global_position + up_vec * (center_node.scale.y/2 + up_offset)
	
	for handle in handles:
		if handle.type == Handle.TYPE.TRANSLATE:
			handle.global_position = center_node.global_position
			handle.scale = center_node.scale
			handle.rotation = center_node.rotation
		elif handle.type == Handle.TYPE.ROTATE:
			handle.global_position = $Center/Rot_Anchor.global_position
		else:
			if handle.scale_type == Handle.SCALE_TYPE.TOP_LEFT:
				handle.global_position = $Center/TL_Anchor.global_position
			elif handle.scale_type == Handle.SCALE_TYPE.TOP_RIGHT:
				handle.global_position = $Center/TR_Anchor.global_position
			elif handle.scale_type == Handle.SCALE_TYPE.BOTTOM_LEFT:
				handle.global_position = $Center/BL_Anchor.global_position
			elif handle.scale_type == Handle.SCALE_TYPE.BOTTOM_RIGHT:
				handle.global_position = $Center/BR_Anchor.global_position
				
	queue_redraw()

	
func on_indicator_move_started(target: Handle, start_pos: Vector2):
	if target.type == Handle.TYPE.ROTATE:
		rot_start_angle = center_node.rotation
		rot_start_vec = (start_pos - center_node.global_position).normalized()
	
	
func on_indicator_moved(target: Handle, mouse_pos: Vector2):
	var right_vec = Vector2.RIGHT.rotated(center_node.rotation)
	var up_vec = -Vector2.UP.rotated(center_node.rotation)
		
	var diag_vec: Vector2
	
	if target.type == Handle.TYPE.TRANSLATE:
		center_node.global_position = mouse_pos
	elif target.type == Handle.TYPE.ROTATE:
		var rot_vec = (mouse_pos - center_node.global_position).normalized()
		var angle = rot_start_vec.angle_to(rot_vec)
		center_node.rotation = rot_start_angle + angle
	elif target.type == Handle.TYPE.SCALING:
		# TODO: a little variation of bottom right when manipulating upper left (because of FORCE_INT_COORD?)
		var changed_position 
		if target.scale_type == Handle.SCALE_TYPE.TOP_LEFT:
			changed_position = (target.global_position + get_handle(target.type, Handle.SCALE_TYPE.BOTTOM_RIGHT).global_position)/2
		elif target.scale_type == Handle.SCALE_TYPE.TOP_RIGHT:
			changed_position = (target.global_position + get_handle(target.type, Handle.SCALE_TYPE.BOTTOM_LEFT).global_position)/2
		elif target.scale_type == Handle.SCALE_TYPE.BOTTOM_LEFT:
			changed_position = (target.global_position + get_handle(target.type, Handle.SCALE_TYPE.TOP_RIGHT).global_position)/2
		elif target.scale_type == Handle.SCALE_TYPE.BOTTOM_RIGHT:
			changed_position = (target.global_position + get_handle(target.type, Handle.SCALE_TYPE.TOP_LEFT).global_position)/2
			
		diag_vec = (target.global_position - changed_position).rotated(-center_node.rotation)
		var new_scale = abs(diag_vec*2)
		new_scale.x = max(Config.EDITOR_MINIMUM_SYMBOL_SIZE, new_scale.x)
		new_scale.y = max(Config.EDITOR_MINIMUM_SYMBOL_SIZE, new_scale.y)
		center_node.global_position = changed_position
		center_node.scale = new_scale
		
	update_handle_anchor_positions()
	report_symbol_edited()


func report_symbol_edited():
	target_symbol.set_bndbox(center_node.global_position, center_node.scale)
	target_symbol.set_degree(center_node.rotation)
	SymbolManager.symbol_edited.emit(xml_id, symbol_id)
	

