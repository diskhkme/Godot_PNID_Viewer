extends Control

signal edit_pressed

@export var xml_tree_view: XMLTreeViewer

@onready var edit_button = $PanelContainer/VBoxContainer/EditButton

var is_in_context_menu: bool

func process_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if !event.is_pressed() and !visible and xml_tree_view.selected_symbol != null:
			position = event.position
			visible = true
			
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !is_in_context_menu:
			visible = false
	

func _on_mouse_entered():
	is_in_context_menu = true


func _on_mouse_exited():
	is_in_context_menu = false


func _on_edit_button_pressed():
	edit_pressed.emit()
	visible = false


func _on_edit_button_mouse_entered():
	pass # Replace with function body.


func _on_edit_button_mouse_exited():
	pass # Replace with function body.
