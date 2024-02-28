extends HBoxContainer
class_name SymbolInfoRow

func set_data(symbol_object: SymbolObject) -> void:
	$TypeLabel.text = symbol_object.type
	$ClsLabel.text = symbol_object.cls
	$XMinLabel.text = str(symbol_object.bndbox.x)
	$YMinLabel.text = str(symbol_object.bndbox.y)
	$XMaxLabel.text = str(symbol_object.bndbox.z)
	$YMaxLabel.text = str(symbol_object.bndbox.w)
	$DegreeLabel.text = str(symbol_object.degree)
