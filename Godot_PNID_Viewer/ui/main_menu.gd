extends HBoxContainer
class_name MainMenu

signal file_opened

@export var open_files_dialog: FileDialog

@onready var _open_files_button: Button = $Left/OpenFilesButton


func _ready():
	open_files_dialog.files_selected.connect(on_files_selected_to_open)
	

func _on_open_files_button_pressed():
	open_files_dialog.popup()


func on_files_selected_to_open(paths):
	file_opened.emit(paths)
