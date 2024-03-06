# Symbol scene select filter
# watch symbol scene(s) + symbol editor scene
# i

extends Node2D
class_name SymbolSelectionFilter

signal clear_selected_candidate

var last_selected_candidate: Array[StaticSymbol]
var selected_history = {} # false if excluded from candidate
var watching_scenes: Array[SymbolScene]

func add_watch(symbol_scene: SymbolScene):
	watching_scenes.push_back(symbol_scene)


func _input(event):
	if ProjectManager.active_project == null:
		return
	
	if SymbolManager.is_editing == true:
		return
	
	if event is InputEventMouseButton: # and event.button_index == MOUSE_BUTTON_LEFT:
		if !event.is_pressed():
			var candidates: Array[StaticSymbol] = []
			for scene in watching_scenes:
				candidates.append_array(scene.selected_candidate)
			
			var mouse_pos = get_global_mouse_position()
			var selected = decide_selected(mouse_pos, candidates)
			if selected == null:
				SymbolManager.symbol_deselected.emit()
			else:
				SymbolManager.symbol_selected_from_image.emit(selected.xml_id, selected.symbol_object.id)
				SymbolManager.symbol_edit_started.emit(selected.xml_id, selected.symbol_object.id)
				
			clear_selected_candidate.emit()
			
			
func decide_selected(mouse_pos: Vector2, selected_candidate: Array[StaticSymbol]):
	# select symbol that has closest center
	if selected_candidate.size() == 0:
		return null
		
	var min_dist = 1e10
	var min_object
	for candidate in selected_candidate:
		var dist = (candidate.symbol_object.get_center() - mouse_pos).length()
		if dist < min_dist:
			min_dist = dist
			min_object = candidate
			
	return min_object
		
	# bug? does not sorted properly
	#selected_candidate.sort_custom(func(a,b): 
								#(a.symbol_object.get_center() - mouse_pos).length_squared() > (b.symbol_object.get_center() - mouse_pos).length_squared()
								#)
	#return selected_candidate[0]
	
	
#--------------------------------------------------------
			
			
#func decide_selected(mouse_pos: Vector2):
	## select symbol that has closest edge
	#var selected_symbol
	#var selected_scene
	#var min_dist = 1e10
	#for scene in watching_scenes:
		#if scene.selected_candidate.size() == 0:
			#return
			#
		#scene.selected_candidate.sort_custom(func(a,b): 
											#return point_symbol_min_edge_dist(mouse_pos, a) < point_symbol_min_edge_dist(mouse_pos,b))
														#
		#var min_symbol = scene.selected_candidate[0]
		#var dist = point_symbol_min_edge_dist(mouse_pos, min_symbol)
		#if  dist < min_dist:
			#min_dist = dist
			#selected_symbol = min_symbol
	#
	#return selected_symbol
			#
			#
#func point_symbol_min_edge_dist(point: Vector2, symbol: StaticSymbol):
	#var relative_point = symbol.symbol_object.get_center() - point
	#var rect = symbol.symbol_object.get_rect()
	#if symbol.symbol_object.degree == 0:
		#return min(min(abs(-rect.size.x*0.5 - relative_point.x),
						#abs(rect.size.x*0.5 - relative_point.x)),
					#min(abs(-rect.size.y*0.5 - relative_point.y),
						#abs(rect.size.y*0.5 - relative_point.y)))
	#else:
		#var tl_point = Vector2(-rect.size.x, -rect.size.y)*0.5
		#var tr_point = Vector2(rect.size.x, -rect.size.y)*0.5
		#var bl_point = Vector2(-rect.size.x, rect.size.y)*0.5
		#var br_point = Vector2(rect.size.x, rect.size.y)*0.5
		#var m1 = min(point_line_dist(relative_point, tl_point, tr_point), point_line_dist(relative_point, tr_point, br_point))
		#var m2 = min(point_line_dist(relative_point, br_point, bl_point), point_line_dist(relative_point,bl_point, tl_point))
		#return min(m1,m2)
		#
#
#func point_line_dist(point:Vector2, l1:Vector2, l2:Vector2):
	#return abs((l2.x-l1.x)*(l1.y-point.y) - (l1.x-point.x)*(l2.y-l1.y)) / (l2-l1).length()
			
			
#--------------------------------------------------------

#func update_history(selected_candidate: Array[StaticSymbol]):
	#var new_history = {}
	#for sel in selected_candidate:
		#if sel in selected_history:
			#new_history[sel] = selected_history[sel]
		#else:
			#new_history[sel] = true
	#selected_history = new_history
#
#
#func reset_history(selected_candidate: Array[StaticSymbol]):
	#selected_history.clear()
	#for sel in selected_candidate:
		#selected_history[sel] = true
		#
		#
#func is_same_array(arr1, arr2):
	#if arr1.size() != arr2.size():
		#return false
		#
	#for elem in arr1:
		#if !arr2.has(elem):
			#return false
			#
	#return true
		

#func decide_selected(selected_candidate: Array[StaticSymbol]):
	#if selected_candidate.size() == 0:
		#selected_history.clear()
		#last_selected_candidate.clear()
		#return null
	#
	#if selected_candidate.size() == 1: # if single selected
		#selected_history.clear()
		#last_selected_candidate.clear()
		#return selected_candidate[0]
		#
	#if last_selected_candidate.is_empty(): # if multiple selected first
		#reset_history(selected_candidate)
		#last_selected_candidate = selected_candidate.duplicate()
		#selected_history[selected_candidate[0]] = false
		#return selected_candidate[0]
		#
	#if is_same_array(selected_candidate, last_selected_candidate):
		## if same selected multiple times, simple loop selected
		#for sel in selected_candidate:
			#if selected_history[sel] == true:
				#selected_history[sel] = false
				#return sel
				#
		##if not found, reset history and return first
		#reset_history(selected_candidate)
		#selected_history[selected_candidate[0]] = false
		#return selected_candidate[0]
	#else:
		## if selection changed
		#update_history(selected_candidate)
		#last_selected_candidate = selected_candidate.duplicate()
		#for sel in selected_candidate:
			#if selected_history[sel] == true:
				#selected_history[sel] = false
				#return sel
				#
	##if not in case, return null
	#selected_history.clear()
	#last_selected_candidate.clear()
	#return null
		
		
			
			

