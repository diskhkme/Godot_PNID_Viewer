# Symbol scene select filter
# watch symbol scene(s) + symbol editor scene
# (Note) Event gives global mouse position only if this is a children of subviewport

extends Control
class_name SymbolSelectionFilter

var target_xml_scenes: Array
var last_selected

func set_target_xml_scene(xml_scenes): # key: xml_data, value: symbol scene
	target_xml_scenes = xml_scenes
		

func process_input(event):
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT):
		if !event.is_pressed():
			var candidates: Array[StaticSymbol] = []
			for scene in target_xml_scenes:
				if scene.get_xml_data().is_selectable:
					candidates.append_array(scene.get_candidate())
			
			clear_candidates()

			# get_global_mouse_position() returns 2d world coord position if it is in subviewport
			var mouse_pos = get_global_mouse_position()
			return decide_selected(mouse_pos, candidates)
			

func clear_candidates():
	for scene in target_xml_scenes: 
		scene.clear_candidates() # direct call

			
# Decide the symbol that has closest upper edge
func decide_selected(mouse_pos: Vector2, selected_candidate: Array[StaticSymbol]):
	if selected_candidate.size() == 0:
		return null
		
	var min_dist = 1e10
	var min_object
	for candidate in selected_candidate:
		var rect_size = candidate.symbol_object.get_size()
		var upper_left = Vector2(-rect_size.x*0.5, -rect_size.y*0.5)
		var upper_right = Vector2(rect_size.x*0.5, -rect_size.y*0.5)
		
		upper_left = upper_left.rotated(deg_to_rad(candidate.symbol_object.get_godot_degree()))
		upper_right = upper_right.rotated(deg_to_rad(candidate.symbol_object.get_godot_degree()))
		
		var centered_mouse_pos = mouse_pos - candidate.symbol_object.get_center()
		
		var dist = line_point_dist(centered_mouse_pos, upper_left, upper_right)
		if dist < min_dist:
			min_dist = dist
			min_object = candidate
			
	return min_object.symbol_object
	
	
func line_point_dist(p:Vector2, l1: Vector2, l2: Vector2):
	var num = absf((l2.x-l1.x)*(l1.y - p.y) - (l1.x - p.x)*(l2.y - l1.y))
	return num / (l2-l1).length()
	
