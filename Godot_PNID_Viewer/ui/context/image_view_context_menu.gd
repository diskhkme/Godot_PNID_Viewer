# Note
# to propagate pressed input from this node to other, 
# that node should be this one's parent and mouse filter(of Control2D node)
# should be set to pass
# 이론상 그런데 의도한대로 동작 안함...(의존 추가됨 ㅜㅜ)

extends Control

signal poped_up

@onready var context_menu = $MenuButton
	
var press_position
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			press_position = event.global_position
		if event.is_released():
			if (press_position - event.global_position).length_squared() < 10:
				self.global_position = event.global_position
				context_menu.show_popup() # TODO: Figure out how button pressed event handled...
				context_menu.visible = true
				poped_up.emit()
			

func _on_popup_menu_id_pressed(id):
	if id == 0:
		print("Add Pressed")
	elif id == 1:
		print("Remove Pressed")
