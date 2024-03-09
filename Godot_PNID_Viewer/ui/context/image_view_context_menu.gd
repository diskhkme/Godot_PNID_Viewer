# Note: children should "pass" mouse to detect enter/exit

extends Control

signal context_poped_up
signal context_canceled
signal context_add_clicked(pos: Vector2)
signal context_remove_clicked

@onready var add_button = $PanelContainer/VBoxContainer/AddButton
@onready var remove_button = $PanelContainer/VBoxContainer/RemoveButton

var start_mouse_pos
var is_in_context_menu

var xml_id
var symbol_id

func process_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			start_mouse_pos = event.position
		if event.is_released() and visible == false:
			var dist = (event.position - start_mouse_pos).length_squared()
			if dist < pow(Config.CONTEXT_MENU_THRESHOLD,2):
				popup(event.position, SymbolManager.is_selected) 
				context_poped_up.emit()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !is_in_context_menu:
			close()
			context_canceled.emit()
	
	
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
	context_add_clicked.emit(self.position)
	close()


func _on_remove_button_pressed():
	context_remove_clicked.emit()
	close()


func _on_mouse_entered():
	is_in_context_menu = true


func _on_mouse_exited():
	is_in_context_menu = false
