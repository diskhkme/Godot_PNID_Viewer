extends HBoxContainer
class_name MainMenu

signal project_files_opened(args: Variant)
signal active_project_changed(project: Project)

@export var new_project_dialog: FileDialog

@onready var tab_bar = $Left/TabBar

var tab_project_array: Array


func _ready():
	new_project_dialog.files_selected.connect(on_files_selected_to_open)


func _on_open_files_button_pressed():
	if OS.get_name() == "Windows":
		new_project_dialog.popup()
	elif OS.get_name() == "Web":
		var window = JavaScriptBridge.get_interface("window")
		window.input.click()


func on_files_selected_to_open(paths):
	project_files_opened.emit(paths)


func add_project_tab(project: Project):
	tab_project_array.push_back(project)
	tab_bar.add_tab(project.img_filename)
	tab_bar.current_tab = tab_bar.tab_count-1


func _on_tab_bar_tab_changed(tab: int):
	active_project_changed.emit(tab_project_array[tab])


func _on_tab_bar_tab_close_pressed(tab: int):
	tab_bar.remove_tab(tab)
	tab_project_array.remove_at(tab)
