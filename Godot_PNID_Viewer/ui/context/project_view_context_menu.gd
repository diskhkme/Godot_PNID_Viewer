extends Control

signal xml_save_as_pressed
signal diff_pressed

@export var project_viewer: ProjectViewer

@onready var save_as_button = $PanelContainer/VBoxContainer/SaveAsButton

var is_in_context_menu: bool

func process_input(event):
	reset_size()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if !event.is_pressed() and !visible and project_viewer.selected_xml != null:
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
	#diff_dialog.popup()
	#diff_dialog.initialize_with_selected(project_viewer.selected_xml)
	visible = false
	

func _on_mouse_entered():
	is_in_context_menu = true


func _on_mouse_exited():
	is_in_context_menu = false
