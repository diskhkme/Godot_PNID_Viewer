# Symbol scene select filter
# watch symbol scene(s) + symbol editor scene
# (Note) Event gives global mouse position only if this is a children of subviewport

extends Control
class_name SymbolSelectionFilter

signal clear_selected_candidate

var active_xml_scenes: Array
var last_selected

func set_current(active_project_xml_dict): # key: xml_data, value: symbol scene
	active_xml_scenes = active_project_xml_dict.values()
		

func process_input(event):
	if ProjectManager.active_project == null:
		return
	
	if SignalManager.is_editing == true:
		return
	
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT):
		if !event.is_pressed():
			var candidates: Array[StaticSymbol] = []
			for scene in active_xml_scenes:
				if scene.xml_data.is_selectable:
					candidates.append_array(scene.selected_candidate)
			
			# get_global_mouse_position() returns 2d world coord position if it is in subviewport
			var mouse_pos = get_global_mouse_position()
			var selected = decide_selected(mouse_pos, candidates)
			if selected == null:
				if last_selected != null:
					last_selected.symbol_object.set_selected(false)
			else:
				selected.symbol_object.set_selected(true)
				selected.symbol_object.set_edit_status(true)
				last_selected = selected
				
			for scene in active_xml_scenes: # direct call
				scene.clear_candidates()
			
			
# TODO: change selection criteria to closest edge
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
