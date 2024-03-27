extends Node

var symbol_type_set = {} 

var open_projects: Array[Project]
var active_project: Project

func _ready():
	symbol_type_set = DataLoader.parse_symbol_type_to_dict(SymbolTypeClassDef.TXT)
	

func add_project(args: Variant) -> Project:
	var project = Project.new() as Project
		
	if project.initialize(open_projects.size(), args[0], args[1], args[2], args[3], args[4]) == true:
		open_projects.append(project)
	else:
		print("project init failed")
		return null
		
	active_project = project # 새로 추가된 project를 active로 하는 것이 default
	return project
	
	
func close_project(project: Project):
	open_projects.erase(project)
	project.free()
	

func make_project_active(project: Project):
	active_project = project
	

func is_symbol_type_text(index: int):
	if symbol_type_set.keys()[index] == Config.TEXT_TYPE_NAME:
		return true
		
	return false
	
	
