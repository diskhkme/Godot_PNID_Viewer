# Note: children should "pass" mouse to detect enter/exit

extends Control

signal poped_up

@export var image_interaction: ImageInteraction

@onready var context_menu = $PanelContainer

var start_mouse_pos
var is_cursor_inside
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if context_menu.visible:
			return
			
		if event.is_pressed():
			start_mouse_pos = event.position
		if event.is_released():
			var dist = (event.position - start_mouse_pos).length_squared()
			if dist < pow(Config.CONTEXT_MENU_THRESHOLD,2):
				context_menu.position = event.position
				context_menu.visible = true
				image_interaction.is_locked = true
				image_interaction.is_dragging = false
				
	if event is InputEventMouseButton:			
		if event.is_pressed(): 
			if !is_cursor_inside: # cancel context menu
				context_menu.visible = false
				image_interaction.is_locked = false


func _on_add_button_pressed():
	context_menu.visible = false


func _on_remove_button_pressed():
	context_menu.visible = false


func _on_mouse_entered():
	is_cursor_inside = true


func _on_mouse_exited():
	is_cursor_inside = false
