extends Window
class_name MeasureDialog

@onready var _dt_xml = $MarginContainer/FileSelect/HBoxContainer/DTXML
@onready var _gt_xml = $MarginContainer/FileSelect/HBoxContainer/GTXML

@onready var iou_threshold = $MarginContainer/FileSelect/OptionResult/PanelContainer/Options/VBoxContainer/GridContainer/IOUThresholdRange
@onready var compare_string = $MarginContainer/FileSelect/OptionResult/PanelContainer/Options/VBoxContainer/GridContainer4/CompareStringCheckbox
@onready var compare_degree = $MarginContainer/FileSelect/OptionResult/PanelContainer/Options/VBoxContainer/GridContainer4/CompareDegreeCheckbox
@onready var progress_bar = $MarginContainer/FileSelect/Progress/ProgressBar
@onready var result_text_label = $MarginContainer/FileSelect/OptionResult/PanelContainer2/MarginContainer/ResultTextLabel


var filename_id_dict = {}

func _ready():
	MeasureEngine.report_progress.connect(_on_progress_reported)
	

func _gather_calculate_options():
	var iou_th = iou_threshold.value
	var is_string_compare = compare_string.button_pressed
	var is_degree_compare = compare_degree.button_pressed
	
	return [iou_th, is_string_compare, is_degree_compare]
	
	
func _get_xml_data(selected_xml_item):
	var selected_xml_id = ProjectManager.active_project.get_xml_id_from_filename(selected_xml_item.get_item_text(selected_xml_item.get_selected_id()))
	var xml_data = ProjectManager.active_project.xml_datas[selected_xml_id]
	return xml_data
	
	
func initialize_with_selected(selected_xml_data: XMLData):
	var id = filename_id_dict[selected_xml_data.filename]
	_dt_xml.select(id)
	if _gt_xml.get_selected_id() == id and _gt_xml.item_count > 1:
		_gt_xml.select(id % _gt_xml.item_count + 1)
	

func _on_close_requested():
	visible = false
	

func _on_ok_button_pressed():
	progress_bar.visible = true
	var dt_xml_data = _get_xml_data(_dt_xml)
	var gt_xml_data = _get_xml_data(_gt_xml)
	var options = _gather_calculate_options()
		
	var result = await MeasureEngine.calculate_precision_recall(dt_xml_data.symbol_objects, gt_xml_data.symbol_objects, options)
	progress_bar.visible = false
	#diff_calc_completed.emit(result, diff_name.text, first_xml_data, second_xml_data)
	result_text_label.text = result
	
	
func _on_progress_reported(progress: float):
	#print(progress)
	if progress_bar.visible:
		progress_bar.value = progress


func _on_cancel_button_pressed():
	visible = false


func _on_about_to_popup():
	_dt_xml.clear()
	_gt_xml.clear()
	filename_id_dict.clear()
	
	var id = 0
	for xml_data in ProjectManager.active_project.xml_datas:
		filename_id_dict[xml_data.filename] = id
		_dt_xml.add_item(xml_data.filename)
		_gt_xml.add_item(xml_data.filename)
		id += 1
	

