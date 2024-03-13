extends Control

@export var project_viewer: ProjectViewer

@onready var save_as_button = $PanelContainer/VBoxContainer/SaveAsButton

var is_in_context_menu

var xml_id
var symbol_id

func process_input(event):
	reset_size()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if !event.is_pressed() and !visible and project_viewer.selected != null:
			position = event.position
			visible = true
			
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !is_in_context_menu:
			visible = false


func _on_save_as_button_pressed():
	print("save_as pressed")
	visible = false


func _on_mouse_entered():
	is_in_context_menu = true


func _on_mouse_exited():
	is_in_context_menu = false
