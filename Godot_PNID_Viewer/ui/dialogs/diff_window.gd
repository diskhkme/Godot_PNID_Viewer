extends Window
class_name DiffDialog

signal diff_calc_completed(symbol_objects, diff_name, source_xml, target_xml)

@onready var first_xml = $MarginContainer/VBoxContainer/HBoxContainer/FirstXML
@onready var second_xml = $MarginContainer/VBoxContainer/HBoxContainer/SecondXML

@onready var diff_name = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer3/DiffName
@onready var compare_direction = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/DirectionButton
@onready var iou_threshold = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/GridContainer/IOUThresholdRange
@onready var include_symbol = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/GridContainer2/IncludeSymbolCheckbox
@onready var include_text = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/GridContainer2/IncludeTextCheckbox
@onready var compare_string = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/GridContainer4/CompareStringCheckbox
@onready var compare_degree = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/GridContainer4/CompareDegreeCheckbox
@onready var progress_bar = $MarginContainer/VBoxContainer/GridContainer6/ProgressBar

var filename_id_dict = {}

func _ready():
	DiffEngine.report_progress.connect(_on_progress_reported)
	

func _gather_calculate_options():
	var direction = DiffEngine.DIRECTION.TWO if compare_direction.selected == 0 else DiffEngine.DIRECTION.ONE
	var iou_th = iou_threshold.value
	var is_symbol_include = include_symbol.button_pressed
	var is_text_include = include_text.button_pressed
	var is_string_compare = compare_string.button_pressed
	var is_degree_compare = compare_degree.button_pressed
	
	return [direction, iou_th, is_symbol_include, is_text_include, is_string_compare, is_degree_compare]
	
	
func _get_xml_data(selected_xml_item):
	var selected_xml_id = ProjectManager.active_project.get_xml_id_from_filename(selected_xml_item.get_item_text(selected_xml_item.get_selected_id()))
	var xml_data = ProjectManager.active_project.xml_datas[selected_xml_id]
	return xml_data
	
	
func initialize_with_selected(selected_xml_data: XMLData):
	var id = filename_id_dict[selected_xml_data.filename]
	first_xml.select(id)
	if second_xml.get_selected_id() == id and second_xml.item_count > 1:
		second_xml.select(id % second_xml.item_count + 1)
	

func _on_close_requested():
	visible = false
	

func _on_ok_button_pressed():
	progress_bar.visible = true
	var first_xml_data = _get_xml_data(first_xml)
	var second_xml_data = _get_xml_data(second_xml)
	var options = _gather_calculate_options()
		
	var result = await DiffEngine.calculate_diff(first_xml_data.symbol_objects, second_xml_data.symbol_objects, options)
	visible = false
	progress_bar.visible = false
	diff_calc_completed.emit(result, diff_name.text, first_xml_data, second_xml_data)
	
	
func _on_progress_reported(progress: float):
	#print(progress)
	if progress_bar.visible:
		progress_bar.value = progress


func _on_cancel_button_pressed():
	visible = false


func _on_about_to_popup():
	first_xml.clear()
	second_xml.clear()
	filename_id_dict.clear()
	
	var id = 0
	for xml_data in ProjectManager.active_project.xml_datas:
		filename_id_dict[xml_data.filename] = id
		first_xml.add_item(xml_data.filename)
		second_xml.add_item(xml_data.filename)
		id += 1
	

func _on_include_text_checkbox_toggled(toggled_on):
	compare_string.disabled = !toggled_on
