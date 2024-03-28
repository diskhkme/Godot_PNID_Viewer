extends Control

signal xml_save_as_pressed
signal diff_pressed
signal close_pressed
signal measure_pressed

@export var _project_viewer: ProjectViewer

@onready var save_as_button = $PanelContainer/VBoxContainer/SaveAsButton

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


func _on_save_as_button_pressed():
	xml_save_as_pressed.emit()
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


func _on_measure_button_pressed():
	measure_pressed.emit()
	visible = false
