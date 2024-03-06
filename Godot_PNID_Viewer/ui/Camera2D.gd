extends Camera2D

func _ready():
	SymbolManager.symbol_selected_from_tree.connect(focus_symbol)


func focus_symbol(xml_id:int, symbol_id:int):
	var target_symbol = ProjectManager.get_symbol_in_xml(xml_id, symbol_id)
	if is_symbol_visible(target_symbol):
		return
		
	global_position = target_symbol.get_center()


func is_symbol_visible(target_symbol: SymbolObject):
	var camera_pos = global_position
	var symbol_center = target_symbol.get_center()
	var cam_center_to_symbol = symbol_center - camera_pos
	var visible_rect = self.get_viewport().get_visible_rect()
	if cam_center_to_symbol.x < visible_rect.size.x and cam_center_to_symbol.y < visible_rect.size.y:
		return true
		
	return false
