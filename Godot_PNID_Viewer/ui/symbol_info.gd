extends Control

@export var symbol_info_row: PackedScene

@onready var container = $ScrollContainer/VBoxContainer


func use_project(project: Project) -> void:
	var prev = null
	for xml_stat in project.xml_status:
		for symbol_object in xml_stat.symbol_objects:
			var symbol_row_item = symbol_info_row.instantiate() as SymbolInfoRow
			container.add_child(symbol_row_item)
			symbol_row_item.set_data(symbol_object)
			symbol_row_item.focus_mode = Control.FOCUS_ALL
			
			if prev == null:
				prev = symbol_row_item
			else:
				symbol_row_item.focus_previous = symbol_row_item.get_path_to(prev)
				prev.focus_next = prev.get_path_to(symbol_row_item)
				
			prev = symbol_row_item
