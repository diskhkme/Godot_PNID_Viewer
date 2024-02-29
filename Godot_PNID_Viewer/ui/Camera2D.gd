extends Camera2D


func _ready():
	SymbolManager.symbol_selected_from_tree.connect(focus_symbol)


func focus_symbol(xml_id:int, symbol_id:int) -> void:
	var target_sym = ProjectManager.active_project.xml_status[xml_id].symbol_objects[symbol_id]
	var target_pos = Vector2((target_sym.bndbox.x + target_sym.bndbox.z)/2, 
							(target_sym.bndbox.y + target_sym.bndbox.w)/2)
	global_position = target_pos
