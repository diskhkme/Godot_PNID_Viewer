extends Camera2D

func _ready():
	SymbolManager.symbol_selected_from_tree.connect(focus_symbol)


func focus_symbol(xml_id:int, symbol_id:int, from_image:bool):
	var target_symbol = ProjectManager.get_symbol_in_xml(xml_id, symbol_id)
	var target_pos = Vector2((target_symbol.bndbox.x + target_symbol.bndbox.z)/2, 
							(target_symbol.bndbox.y + target_symbol.bndbox.w)/2)
	global_position = target_pos
