extends Node

# 파일 집합으로 로드하는 프로젝트 전체를 관리하는 클래스 (singleton)
var open_projects: Array
var active_project: Project

func add_project(paths) -> Project:
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



