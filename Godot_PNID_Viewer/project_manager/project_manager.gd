# 파일 집합으로 로드하는 프로젝트 전체를 관리하는 클래스 (singleton)
extends Node

# TODO: Consider re-factoring these signals  (move to project)
signal xml_visibility_changed(xml_data: XMLData)
signal xml_selectability_changed(xml_data: XMLData)
signal xml_added(xml_data: XMLData)

var symbol_type_set = {} 

var open_projects: Array[Project]
var active_project: Project

func _ready():
	symbol_type_set = DataLoader.parse_symbol_type_to_dict(SymbolTypeClassDef.TXT)
	

func add_project(args: Variant) -> Project:
	var project = Project.new() as Project
	
	var data
	if OS.get_name() == "Web":
		data = args
	if OS.get_name() == "Windows":
		data = DataLoader.data_load_from_paths(args)
		
	if project.initialize(open_projects.size(), data[0], data[1], data[2], data[3], data[4]) == true:
		open_projects.append(project)
	else:
		print("project init failed")
		return null
		
	active_project = project # 새로 추가된 project를 active로 하는 것이 default
	return project
	
	
func add_xml_data(xml_data: XMLData):
	active_project.xml_datas.push_back(xml_data)
	xml_added.emit(xml_data)


func make_project_active(project: Project) -> void:
	active_project = project


#func get_symbol_in_xml(xml_id:int, symbol_id:int):
	#var target_xml_data = active_project.xml_datas.filter(func(xml_data): return xml_data.id == xml_id)
	#var target_symbol = target_xml_data[0].symbol_objects.filter(func(symbol_object): return symbol_object.id == symbol_id)
	#return target_symbol[0]
	

#func get_xml(xml_id:int):
	#return active_project.xml_datas[xml_id]
	

func is_symbol_type_text(index: int):
	if symbol_type_set.keys()[index] == Config.TEXT_TYPE_NAME:
		return true
		
	return false


