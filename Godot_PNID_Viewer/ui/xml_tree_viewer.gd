extends Control

signal request_type_change_window

@onready var tree = $Tree

var symbol_update_cache = {}


func _ready():
	SymbolManager.symbol_selected_from_image.connect(focus_symbol)
	SymbolManager.symbol_deselected.connect(deselect_treeitem)
	SymbolManager.symbol_edited.connect(update_symbol)
	SymbolManager.symbol_added.connect(add_symbol)
	

func set_tree_column_style():
	tree.set_column_clip_content(0, true)
	tree.set_column_custom_minimum_width(0, 100)
	tree.set_column_clip_content(1, true)
	tree.set_column_custom_minimum_width(1, 100)
	tree.set_column_clip_content(2, true)
	tree.set_column_custom_minimum_width(2, 100)
	
	for i in range(8):
		if i != 2:
			tree.set_column_expand(i, false)


func use_project(project: Project):
	tree.clear()
	tree.set_columns(8)
	var root: TreeItem = tree.create_item() 
	tree.hide_root = true
	for xml_stat in project.xml_status:
		var child = tree.create_item(root)
		child.set_text(0,xml_stat.filename)
		for symbol_object in xml_stat.symbol_objects:
			create_symbol(child, symbol_object)
	
	set_tree_column_style()
	
	
func create_symbol(parent: TreeItem, symbol_object: SymbolObject) -> TreeItem:
	var symbol_child: TreeItem = tree.create_item(parent)
	fill_treeitem(symbol_child,symbol_object)
	if symbol_object.is_text:
		symbol_child.set_editable(2, true)
		
	return symbol_child

	
func _on_tree_item_selected():
	var selected_symbol_id = tree.get_selected().get_text(0).to_int()
	var selected_xml_filename = tree.get_selected().get_parent().get_text(0)
	var selected_xml_id = ProjectManager.active_project.get_xml_id_from_filename(selected_xml_filename)
	if selected_xml_id != -1 && selected_symbol_id != -1:
		SymbolManager.symbol_selected_from_tree.emit(selected_xml_id,selected_symbol_id)
		SymbolManager.symbol_edit_started.emit(selected_xml_id,selected_symbol_id)
	

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.double_click:
			var selected_symbol_id = tree.get_selected().get_text(0).to_int()
			var selected_xml_filename = tree.get_selected().get_parent().get_text(0)
			var selected_xml_id = ProjectManager.active_project.get_xml_id_from_filename(selected_xml_filename)
			var xml_stat = ProjectManager.get_xml(selected_xml_id)
			var symbol_object = ProjectManager.get_symbol_in_xml(selected_xml_id, selected_symbol_id)
			request_type_change_window.emit(xml_stat, symbol_object)
			
			
func focus_symbol(xml_id:int, symbol_id:int):
	var xml_item = tree.get_root().get_children()[xml_id]
	var symbol_item: TreeItem = xml_item.get_children()[symbol_id]
	symbol_item.select(0)
	tree.scroll_to_item(symbol_item)
	
	
func deselect_treeitem():
	tree.deselect_all()


func fill_treeitem(symbol_child: TreeItem, symbol_object: SymbolObject):
	symbol_child.set_text(0, str(symbol_object.id))
	symbol_child.set_text(1, symbol_object.type)
	symbol_child.set_text(2, symbol_object.cls)
	symbol_child.set_text(3, str(floor(symbol_object.bndbox.x)))
	symbol_child.set_text(4, str(floor(symbol_object.bndbox.y)))
	symbol_child.set_text(5, str(floor(symbol_object.bndbox.z)))
	symbol_child.set_text(6, str(floor(symbol_object.bndbox.w)))
	symbol_child.set_text(7, str(symbol_object.degree))
	
	if symbol_object.removed:
		symbol_child.visible = false
	
	
func add_symbol(xml_id:int, symbol_id: int):
	var symbol = ProjectManager.get_symbol_in_xml(xml_id, symbol_id)
	for xml_treeitem in tree.get_root().get_children():
		var xml_filename = xml_treeitem.get_text(0)
		var child_xml_id = ProjectManager.active_project.get_xml_id_from_filename(xml_filename)
		if xml_id == child_xml_id:	
			var symbol_treeitem = create_symbol(xml_treeitem, symbol)
			symbol_update_cache[symbol] = symbol_treeitem


func update_symbol(xml_id: int, symbol_id: int):
	var symbol = ProjectManager.get_symbol_in_xml(xml_id, symbol_id)
	if symbol_update_cache.has(symbol):
		fill_treeitem(symbol_update_cache[symbol], symbol)
	else:
		for xml_treeitem in tree.get_root().get_children():
			var xml_filename = xml_treeitem.get_text(0)
			var child_xml_id = ProjectManager.active_project.get_xml_id_from_filename(xml_filename)
			if xml_id == child_xml_id:
				var symbol_treeitem = find_symbol_item_by_id(xml_treeitem.get_children(), symbol.id)
				fill_treeitem(symbol_treeitem, symbol)
				symbol_update_cache[symbol] = symbol_treeitem


func find_symbol_item_by_id(arr: Array[TreeItem], id: int):
	var result = arr.filter(func(elem): return elem.get_text(0).to_int() == id)
	assert(result.size() != 0, "finding non-existing symbol")
	return result[0]
	
