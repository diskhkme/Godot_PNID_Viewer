# 파일 집합으로 로드하는 프로젝트 전체를 관리하는 클래스 (singleton)
extends Node

# currently, assume single text resource for extire project
var symbol_type_set = {} 

var open_projects: Array[Project]
var active_project: Project

func _ready():
	load_symbol_type_definition()

func add_project(paths: PackedStringArray) -> Project:
	var project = Project.new() as Project
	# TODO: Check sanity
	if project.initialize(open_projects.size(), paths) == true:
		open_projects.append(project)
	else:
		print("project init failed")
		return null
		
	active_project = project # 새로 추가된 project를 active로 하는 것이 default
	return project


func make_project_active(project: Project) -> void:
	active_project = project


func get_symbol_in_xml(xml_id:int, symbol_id:int):
	return active_project.xml_status[xml_id].symbol_objects[symbol_id]
	

func get_xml(xml_id:int):
	return active_project.xml_status[xml_id]
	

func load_symbol_type_definition():
	var file = FileAccess.open(Config.SYMBOL_TYPE_TXT_PATH, FileAccess.READ)
	while !file.eof_reached():
		var line = file.get_line()
		var strs = line.split("|")
		if strs[0].is_empty():
			continue
		
		if !symbol_type_set.has(strs[0]):
			symbol_type_set[strs[0]] = [strs[1]]
		else:
			symbol_type_set[strs[0]].append(strs[1])
			
	if !symbol_type_set.has(Config.TEXT_TYPE_NAME):
		symbol_type_set[Config.TEXT_TYPE_NAME] = []
		
		
func is_symbol_type_text(index: int):
	if symbol_type_set.keys()[index] == Config.TEXT_TYPE_NAME:
		return true
		
	return false


