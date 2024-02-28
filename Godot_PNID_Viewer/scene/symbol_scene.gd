extends Node2D

@export var bbox_scene: PackedScene

var selected_candidate: Array

func populate_symbol_bboxes(xml_status: Array) -> void:
	for xml_stat in xml_status:
		for symbol_object in xml_stat.symbol_objects:	
			var box = bbox_scene.instantiate() as SymbolBBox
			box.xml_id = xml_stat.id
			box.symbol_id = symbol_object.id
			box.x = symbol_object.bndbox.x
			box.y = symbol_object.bndbox.y
			box.width = symbol_object.bndbox.z - symbol_object.bndbox.x
			box.height = symbol_object.bndbox.w - symbol_object.bndbox.y
			box.color = xml_stat.color
			box.degree = symbol_object.degree
			self.add_child(box)
			
			box.report_selected.connect(on_symbol_selected_on_image)


func _input(event):
	if ProjectManager.active_project == null:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if !event.is_pressed():
			if selected_candidate.size() > 0:
				# decide unique selection
				decide_selection(get_global_mouse_position())
				SymbolManager.symbol_selected_from_image.emit(selected_candidate[0].xml_id,selected_candidate[0].symbol_id)
				selected_candidate.clear()
			else:
				if SymbolManager.is_editing:
					SymbolManager.symbol_edit_ended.emit()
				elif !SymbolManager.is_editing:
					SymbolManager.symbol_deselected.emit()
			
		
func decide_selection(mouse_position: Vector2) -> void:
	# 마우스를 떼는 위치가 edge에 가장 가까운 심볼을 선택
	selected_candidate.sort_custom(
		func(a,b): return vec_rect_mindist(a.global_rect, mouse_position) < vec_rect_mindist(b.global_rect, mouse_position)
	)
		
		
func on_symbol_selected_on_image(global_mouse_pos: Vector2, symbol: SymbolBBox):
	selected_candidate.push_back(symbol)
	

func vec_rect_mindist(rect: Rect2, pos: Vector2):
	var left = abs(rect.position.x - pos.x)
	var right = abs(rect.position.x + rect.size.x - pos.x)
	var top = abs(rect.position.y - pos.y)
	var bottom = abs(rect.position.y + rect.size.y - pos.y)
	return min(left,right,top,bottom)
	
