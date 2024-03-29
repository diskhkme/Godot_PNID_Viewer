extends Window
class_name EvaluationDialog

@onready var _dt_xml = %DTXML
@onready var _gt_xml = %GTXML

@onready var iou_threshold = %IOUThresholdRange
@onready var compare_string = %CompareStringCheckbox
@onready var compare_degree = %CompareDegreeCheckbox
@onready var progress_bar = %ProgressBar
@onready var result_text_label = %ResultTextLabel

var filename_id_dict = {}

func _ready():
	EvaluationEngine.report_progress.connect(_on_progress_reported)
	

func _gather_calculate_options():
	var options = EvaluationEngine.EvalOptions.new()
	options.iou_th = float(iou_threshold.value)
	options.is_compare_string = compare_string.button_pressed
	options.is_compare_degree = compare_degree.button_pressed
	options.filename = ProjectManager.active_project.img_filename
	
	return options
	
	
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
	

func _on_progress_reported(progress: float):
	if progress_bar.visible:
		progress_bar.value = progress


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


func _on_run_button_pressed():
	progress_bar.visible = true
	var dt_xml_data = _get_xml_data(_dt_xml)
	var gt_xml_data = _get_xml_data(_gt_xml)
	var options = _gather_calculate_options()
		
	var result = await EvaluationEngine.calculate_precision_recall(dt_xml_data.symbol_objects, gt_xml_data.symbol_objects, options)
	progress_bar.visible = false
	result_text_label.text = result


func _on_close_button_pressed():
	visible = false
