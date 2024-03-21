extends HBoxContainer
class_name MainMenu

signal open_files

signal project_files_open(args: Variant)
signal active_project_change(project: Project)
signal project_tab_close(project: Project)

@onready var tab_bar = $Left/TabBar

var tab_project_array: Array

func _on_open_files_button_pressed():
	open_files.emit()


func on_files_selected_to_open(paths):
	project_files_open.emit(paths)


func add_project_tab(project: Project):
	if tab_project_array.has(project):
		return
		
	tab_project_array.push_back(project)
	tab_bar.add_tab(project.img_filename)
	tab_bar.current_tab = tab_bar.tab_count-1


func _on_tab_bar_tab_changed(tab_id: int):
	active_project_change.emit(tab_project_array[tab_id])


func _on_tab_bar_tab_close_pressed(tab_id: int):
	var project = tab_project_array[tab_id]
	project_tab_close.emit(project)
	
	
func close_project_tab(project: Project):
	var tab_id = tab_project_array.find(project)
	tab_bar.remove_tab(tab_id)
	tab_project_array.remove_at(tab_id)
	return project
