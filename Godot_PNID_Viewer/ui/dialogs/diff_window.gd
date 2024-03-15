extends Window
class_name DiffDialog

@onready var first_xml = $MarginContainer/VBoxContainer/HBoxContainer/FirstXML
@onready var second_xml = $MarginContainer/VBoxContainer/HBoxContainer/SecondXML
@onready var iou_threshold = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/GridContainer/IOUThresholdRange
@onready var include_symbol = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/GridContainer2/IncludeSymbolCheckbox
@onready var include_text = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/GridContainer2/IncludeTextCheckbox
@onready var compare_string = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/GridContainer4/CompareStringCheckbox
@onready var compare_degree = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/GridContainer4/CompareDegreeCheckbox

var filename_id_dict = {}

func gather_calculate_options():
	var iou_th = iou_threshold.value
	var is_symbol_include = include_symbol.button_pressed
	var is_text_include = include_text.button_pressed
	var is_string_compare = compare_string.button_pressed
	var is_degree_compare = compare_degree.button_pressed
	
	return [iou_th, is_symbol_include, is_text_include, is_string_compare, is_degree_compare]
	
	
func get_symbols(selected_xml):
	var selected_xml_id = ProjectManager.active_project.get_xml_id_from_filename(selected_xml.get_item_text(selected_xml.get_selected_id()))
	var symbols = ProjectManager.active_project.xml_datas[selected_xml_id].symbol_objects
	return symbols
	
	
func set_first_selected(selected_xml_data: XMLData):
	var id = filename_id_dict[selected_xml_data.filename]
	first_xml.select(id)
	if second_xml.get_selected_id() == id and second_xml.item_count > 1:
		second_xml.select(id % second_xml.item_count + 1)
	

func clear_items():
	for i in range(first_xml.item_count):
		first_xml.remove_item(i)
		second_xml.remove_item(i)


func _on_close_requested():
	visible = false
	

func _on_ok_button_pressed():
	var first_symbols = get_symbols(first_xml)
	var second_symbols = get_symbols(second_xml)
	var options = gather_calculate_options()
		
	var result = Diff.calculate_diff(first_symbols, second_symbols, options)
	var new_id = ProjectManager.active_project.xml_datas.size()
	var new_name = "Diff"
	
	var xml_data = XMLData.new()
	xml_data.initialize_from_symbols(new_id, new_name, result)
	ProjectManager.active_project.add_xml_data(xml_data)
	visible = false
	pass # Replace with function body.


func _on_cancel_button_pressed():
	visible = false


func _on_about_to_popup():
	clear_items()
	filename_id_dict.clear()
	
	var id = 0
	for xml_data in ProjectManager.active_project.xml_datas:
		filename_id_dict[xml_data.filename] = id
		first_xml.add_item(xml_data.filename)
		second_xml.add_item(xml_data.filename)
		id += 1
	

func _on_include_text_checkbox_toggled(toggled_on):
	compare_string.disabled = !toggled_on
