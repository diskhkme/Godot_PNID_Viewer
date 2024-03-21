extends HBoxContainer

signal add_xml
signal export_image
signal undo_action
signal redo_action

func _on_add_xml_button_pressed():
	add_xml.emit()

func _on_export_image_button_pressed():
	export_image.emit()

		
func _on_undo_button_pressed():
	undo_action.emit()


func _on_redo_button_pressed():
	redo_action.emit()


