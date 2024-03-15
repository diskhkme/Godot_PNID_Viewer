# Note: children should "pass" mouse to detect enter/exit

extends Control

@export var image_view_camera: ImageViewCamera

@onready var add_button = $PanelContainer/VBoxContainer/AddButton
@onready var remove_button = $PanelContainer/VBoxContainer/RemoveButton

var start_mouse_pos
var is_in_context_menu

func process_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			start_mouse_pos = event.position
		if event.is_released() and visible == false:
			var dist = (event.position - start_mouse_pos).length_squared()
			if dist < pow(Config.CONTEXT_MENU_THRESHOLD,2):
				popup(event.position, SignalManager.is_selected) 

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !is_in_context_menu:
			close()
	
	
func popup(pos: Vector2, is_selected: bool):
	if is_selected:
		add_button.visible = false
		remove_button.visible = true
	else:
		add_button.visible = true
		remove_button.visible = false
		
	position = pos
	visible = true
	
	
func close():
	visible = false
	

func _on_add_button_pressed():
	var pos_in_image = image_view_camera.get_pixel_from_image_canvas(position)
	var new_symbol = ProjectManager.active_project.xml_datas[0].add_new_symbol(pos_in_image) # TODO: how to set target xml?
	
	SignalManager.symbol_added.emit(new_symbol)
	SignalManager.symbol_selected_from_image.emit(new_symbol)	
	SignalManager.symbol_edit_started.emit(new_symbol)
	SignalManager.symbol_edited.emit(new_symbol)
	close()


func _on_remove_button_pressed():
	var symbol = SignalManager.selected_symbol
	symbol.removed = true
	
	SignalManager.symbol_edited.emit(symbol)
	SignalManager.symbol_deselected.emit()
	SignalManager.symbol_edit_ended.emit()
	close()


func _on_mouse_entered():
	is_in_context_menu = true


func _on_mouse_exited():
	is_in_context_menu = false
