extends Control

signal xml_save_as_pressed(is_twopoint: bool)
signal diff_pressed
signal close_pressed
signal eval_pressed

@export var _project_viewer: ProjectViewer

var is_in_context_menu: bool

func process_input(event):
	if _project_viewer.get_global_rect().has_point(event.position):
		reset_size()
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
			if !event.is_pressed() and !visible and _project_viewer.selected_xml != null:
				position = event.position
				visible = true
				
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !is_in_context_menu:
			visible = false


func _on_diff_button_pressed():
	diff_pressed.emit()
	visible = false
	
	
func _on_close_button_pressed():
	close_pressed.emit()
	visible = false


func _on_mouse_entered():
	is_in_context_menu = true


func _on_mouse_exited():
	is_in_context_menu = false


func _on_eval_button_pressed():
	eval_pressed.emit()
	visible = false


func _on_twopoint_save_as_button_pressed():
	xml_save_as_pressed.emit(true)
	visible = false


func _on_fourpoint_save_as_button_pressed():
	xml_save_as_pressed.emit(false)
	visible = false
