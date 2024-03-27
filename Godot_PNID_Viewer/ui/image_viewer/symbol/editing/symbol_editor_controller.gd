# Symbol editor controller
# change transform of "Center" node, followed by handles

class_name SymbolEditorController
extends Node2D

signal tick_update()

@onready var handles = [$TL_Handle, $TR_Handle, $BL_Handle, $BR_Handle, $Rot_Handle, $Translate_Handle]
@onready var center_node = $SymbolRect

var rot_start_angle: float
var rot_start_vec: Vector2

var target_symbol: SymbolObject
var is_actually_edited = false

func _ready():
	for handle in handles:
		handle.indicator_move_started.connect(on_indicator_move_started)
		handle.indicator_moved.connect(on_indicator_moved)
		handle.indicator_move_ended.connect(on_indicator_move_ended)

		if handle.type == Handle.TYPE.TRANSLATE:
			handle.set_initial_handle_size(Vector2.ONE)
		else:
			handle.set_initial_handle_size(Vector2.ONE * Config.EDITOR_HANDLE_SIZE)
			

func initialize(symbol_object: SymbolObject):
	target_symbol = symbol_object
	var symbol_position = target_symbol.get_center()
	var symbol_size = target_symbol.get_size()
	var symbol_angle = deg_to_rad(target_symbol.get_godot_degree())
	center_node.global_position = symbol_position
	center_node.scale = symbol_size
	center_node.rotation = symbol_angle
	
	update_handle_positions()
	is_actually_edited = false


func _draw():
	var color = Config.EDITOR_RECT_COLOR
	var line_width = Config.EDITOR_RECT_LINE_WIDTH

	var right_vec = Vector2.RIGHT.rotated(center_node.rotation)
	var up_vec = Vector2.UP.rotated(center_node.rotation)
	var tl_pos = center_node.global_position + (-right_vec*center_node.scale.x + up_vec*center_node.scale.y)*0.5
	var tr_pos = center_node.global_position + (right_vec*center_node.scale.x + up_vec*center_node.scale.y)*0.5
	var bl_pos = center_node.global_position + (-right_vec*center_node.scale.x - up_vec*center_node.scale.y)*0.5
	var br_pos = center_node.global_position + (right_vec*center_node.scale.x - up_vec*center_node.scale.y)*0.5

	draw_line(tl_pos, tr_pos, color, line_width)
	draw_line(tr_pos, br_pos, color, line_width)
	draw_line(br_pos, bl_pos, color, line_width)
	draw_line(bl_pos, tl_pos, color, line_width)
	
	
func get_handle(handle_type: Handle.TYPE, scale_type: Handle.SCALE_TYPE):
	var result = handles.filter(func(a): return a.type == handle_type and a.scale_type == scale_type)
	return result[0]
	

func process_input(event) -> bool: # return false if edit end
	handles.map(func(h): h.process_input(event))
				
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			for handle in handles: # is editing click
				if handle.on_cursor == true:
					return true
			# if mouse pressed on outside of handles, end editing					
			return false
			
	return true
				
				
func update_handle_positions():
	# rot anchor adjust depending on the zoom level
	var right_vec = Vector2.RIGHT.rotated(center_node.rotation)
	var up_vec = Vector2.UP.rotated(center_node.rotation)
	var up_offset = Config.EDITOR_ROTATION_HANDLE_OFFSET
	
	var tl_pos = center_node.global_position + (-right_vec*center_node.scale.x + up_vec*center_node.scale.y)*0.5
	var tr_pos = center_node.global_position + (right_vec*center_node.scale.x + up_vec*center_node.scale.y)*0.5
	var bl_pos = center_node.global_position + (-right_vec*center_node.scale.x - up_vec*center_node.scale.y)*0.5
	var br_pos = center_node.global_position + (right_vec*center_node.scale.x - up_vec*center_node.scale.y)*0.5
	
	for handle in handles:
		if handle.type == Handle.TYPE.TRANSLATE:
			handle.global_position = center_node.global_position
			handle.scale = center_node.scale
			handle.rotation = center_node.rotation
		elif handle.type == Handle.TYPE.ROTATE:
			handle.global_position = center_node.global_position + up_vec * (center_node.scale.y/2 + up_offset)
		else:
			if handle.scale_type == Handle.SCALE_TYPE.TOP_LEFT:
				handle.global_position = tl_pos + (up_vec - right_vec).normalized()*Config.EDITOR_HANDLE_PADDING
			elif handle.scale_type == Handle.SCALE_TYPE.TOP_RIGHT:
				handle.global_position = tr_pos + (up_vec + right_vec).normalized()*Config.EDITOR_HANDLE_PADDING
			elif handle.scale_type == Handle.SCALE_TYPE.BOTTOM_LEFT:
				handle.global_position = bl_pos + (-up_vec - right_vec).normalized()*Config.EDITOR_HANDLE_PADDING
			elif handle.scale_type == Handle.SCALE_TYPE.BOTTOM_RIGHT:
				handle.global_position = br_pos + (-up_vec + right_vec).normalized()*Config.EDITOR_HANDLE_PADDING
				
	queue_redraw()

	
func on_indicator_move_started(target: Handle, start_pos: Vector2):
	if target.type == Handle.TYPE.ROTATE:
		rot_start_angle = center_node.rotation
		rot_start_vec = (start_pos - center_node.global_position).normalized()
		
	for handle in handles:
		handle.disable_collision()
	
	
func on_indicator_moved(target: Handle, mouse_pos: Vector2, mouse_pos_delta: Vector2):
	var right_vec = Vector2.RIGHT.rotated(center_node.rotation)
	var up_vec = Vector2.UP.rotated(center_node.rotation)
		
	if target.type == Handle.TYPE.TRANSLATE:
		center_node.translate(mouse_pos_delta)
	elif target.type == Handle.TYPE.ROTATE:
		var rot_vec = (mouse_pos - center_node.global_position).normalized()
		var angle = rot_start_vec.angle_to(rot_vec)
		center_node.rotation = rot_start_angle + angle
	elif target.type == Handle.TYPE.SCALING:
		var width_delta = mouse_pos_delta.dot(right_vec)
		var width_vec = right_vec * width_delta
		var height_delta = mouse_pos_delta.dot(up_vec)
		var height_vec = up_vec * height_delta
		if target.scale_type == Handle.SCALE_TYPE.TOP_LEFT:
			center_node.scale += Vector2(-width_delta, height_delta)
		elif target.scale_type == Handle.SCALE_TYPE.TOP_RIGHT:
			center_node.scale += Vector2(width_delta, height_delta)
		elif target.scale_type == Handle.SCALE_TYPE.BOTTOM_LEFT:
			center_node.scale += Vector2(-width_delta, -height_delta)
		elif target.scale_type == Handle.SCALE_TYPE.BOTTOM_RIGHT:
			center_node.scale += Vector2(width_delta, -height_delta)
			
		center_node.global_position += (width_vec + height_vec)*0.5
		
	update_handle_positions()
	update_symbol_box()
	is_actually_edited = true


func on_indicator_move_ended(target: Handle, start_pos: Vector2):
	tick_update.emit()
	for handle in handles:
		handle.enable_collision()


func update_symbol_box():
	target_symbol.set_bndbox_from_rect2(Rect2(center_node.global_position, center_node.scale))
	target_symbol.set_degree_from_godot(center_node.rotation)
	
	

