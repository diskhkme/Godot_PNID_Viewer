# Note: children should "pass" mouse to detect enter/exit

extends Control

signal poped_up

@onready var context_menu = $PanelContainer
@onready var symbol_selection_interface = $SymbolSelectionInterface
	
var is_cursor_inside
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			context_menu.position = event.position
			context_menu.visible = true
				
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:			
		if event.is_pressed(): 
			if !is_cursor_inside: # cancel context menu
				context_menu.visible = false


func _on_add_button_pressed():
	context_menu.visible = false


func _on_remove_button_pressed():
	context_menu.visible = false


func _on_mouse_entered():
	is_cursor_inside = true


func _on_mouse_exited():
	is_cursor_inside = false
