# Note: children should "pass" mouse to detect enter/exit

extends Control

signal add_symbol_pressed(pos: Vector2)
signal remove_symbol_pressed()
signal edit_symbol_pressed()

@export var _image_viewer: ImageViewer

@onready var _add_button = $PanelContainer/VBoxContainer/AddButton
@onready var _remove_button = $PanelContainer/VBoxContainer/RemoveButton
@onready var _edit_button = $PanelContainer/VBoxContainer/EditButton

var start_mouse_pos
var is_in_context_menu

func process_input(event, is_symbol_selected):
	if _image_viewer.get_global_rect().has_point(event.position):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				start_mouse_pos = event.position
			if event.is_released() and visible == false:
				var dist = (event.position - start_mouse_pos).length_squared()
				if dist < pow(Config.CONTEXT_MENU_THRESHOLD,2):
					popup(event.position, is_symbol_selected) 

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !is_in_context_menu:
			visible = false
	
	
func popup(pos: Vector2, is_selected: bool):
	if is_selected:
		_add_button.visible = false
		_remove_button.visible = true
		_edit_button.visible = true
	else:
		_add_button.visible = true
		_remove_button.visible = false
		_edit_button.visible = false
		
	position = pos
	visible = true
	

func _on_add_button_pressed():
	var pos = _image_viewer.get_camera().get_pixel_from_image_canvas(position)
	#var new_symbol = ProjectManager.active_project.xml_datas[0].add_symbol(pos_in_image) # TODO: how to set target xml?
	add_symbol_pressed.emit(pos)
	visible = false


func _on_remove_button_pressed():
	remove_symbol_pressed.emit()
	visible = false


func _on_edit_button_pressed():
	edit_symbol_pressed.emit()
	visible = false


func _on_mouse_entered():
	is_in_context_menu = true


func _on_mouse_exited():
	is_in_context_menu = false
