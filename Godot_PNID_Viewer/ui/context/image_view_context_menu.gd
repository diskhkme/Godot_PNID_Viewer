# Note: children should "pass" mouse to detect enter/exit

extends Control

signal add_symbol_pressed(pos: Vector2)
signal remove_symbol_pressed()

@export var image_view: ImageViewer

@onready var add_button = $PanelContainer/VBoxContainer/AddButton
@onready var remove_button = $PanelContainer/VBoxContainer/RemoveButton

var start_mouse_pos
var is_in_context_menu

func process_input(event, is_symbol_selected):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			start_mouse_pos = event.position
		if event.is_released() and visible == false:
			var dist = (event.position - start_mouse_pos).length_squared()
			if dist < pow(Config.CONTEXT_MENU_THRESHOLD,2):
				popup(event.position, is_symbol_selected) 

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
	var pos = image_view.get_camera().get_pixel_from_image_canvas(position)
	#var new_symbol = ProjectManager.active_project.xml_datas[0].add_symbol(pos_in_image) # TODO: how to set target xml?
	add_symbol_pressed.emit(pos)
	close()


func _on_remove_button_pressed():
	#var symbol = SignalManager.selected_symbol
	#symbol.removed = true
	remove_symbol_pressed.emit()
	close()


func _on_mouse_entered():
	is_in_context_menu = true


func _on_mouse_exited():
	is_in_context_menu = false
