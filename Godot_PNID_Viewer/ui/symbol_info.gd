extends PanelContainer

@onready var tree: Tree = $Tree

var selected_symbol_id = null
var selected_xml_id = null


func use_project(project: Project) -> void:
	tree.set_columns(8)
	var root: TreeItem = tree.create_item() 
	tree.hide_root = true
		
	for xml_stat in project.xml_status:
		var child = tree.create_item(root)
		child.set_text(0,xml_stat.filename)
		for symbol_object in xml_stat.symbol_objects:
			var symbol_child: TreeItem = tree.create_item(child)
			symbol_child.set_text(0, str(symbol_object.id))
			symbol_child.set_text(1, symbol_object.type)
			symbol_child.set_text(2, symbol_object.cls)
			symbol_child.set_text(3, str(symbol_object.bndbox.x))
			symbol_child.set_text(4, str(symbol_object.bndbox.y))
			symbol_child.set_text(5, str(symbol_object.bndbox.z))
			symbol_child.set_text(6, str(symbol_object.bndbox.w))
			symbol_child.set_text(7, str(symbol_object.degree))
	
	tree.set_column_clip_content(0, true)
	tree.set_column_custom_minimum_width(0, 100)
	tree.set_column_clip_content(1, true)
	tree.set_column_custom_minimum_width(1, 100)
	tree.set_column_clip_content(2, true)
	tree.set_column_custom_minimum_width(2, 100)
	
	ProjectManager.active_project.symbol_selected_from_image.connect(focus_symbol)
	ProjectManager.active_project.symbol_deselect.connect(on_symbol_deselected) 


func _on_tree_item_selected():
	selected_symbol_id = tree.get_selected().get_text(0).to_int()
	var selected_xml_filename = tree.get_selected().get_parent().get_text(0)
	selected_xml_id = ProjectManager.active_project.get_xml_id_from_filename(selected_xml_filename)
	if selected_xml_id != -1 && selected_symbol_id != -1:
		ProjectManager.active_project.symbol_selected_from_tree.emit(selected_xml_id,selected_symbol_id)
	
	
func focus_symbol(xml_id:int, symbol_id:int):
	var xml_item = tree.get_root().get_children()[xml_id]
	var symbol_item: TreeItem = xml_item.get_children()[symbol_id]
	symbol_item.select(0)
	tree.scroll_to_item(symbol_item)
	
	
func on_symbol_deselected():
	tree.deselect_all()


