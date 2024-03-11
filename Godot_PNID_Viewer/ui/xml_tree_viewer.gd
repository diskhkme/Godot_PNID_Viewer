extends Control

signal request_type_change_window

@onready var tree = $Tree

var xml_stat_item_dict = {}
var symbol_update_cache = {}

const COLUMN_COUNT = 8

func _ready():
	SymbolManager.symbol_selected_from_image.connect(focus_symbol)
	SymbolManager.symbol_deselected.connect(deselect_treeitem)
	SymbolManager.symbol_edited.connect(update_symbol)
	SymbolManager.symbol_added.connect(add_symbol)
	

func set_tree_column_style():
	tree.set_column_title(0, "ID")
	tree.set_column_clip_content(0, true)
	tree.set_column_custom_minimum_width(0, 100)
	tree.set_column_title(1, "Type")
	tree.set_column_clip_content(1, true)
	tree.set_column_custom_minimum_width(1, 100)
	tree.set_column_title(2, "Class")
	tree.set_column_clip_content(2, true)
	tree.set_column_custom_minimum_width(2, 100)
	tree.set_column_title(3, "XMin")
	tree.set_column_title(4, "YMin")
	tree.set_column_title(5, "XMax")
	tree.set_column_title(6, "YMax")
	tree.set_column_title(7, "Deg")
	tree.column_titles_visible = true
	
	for i in range(COLUMN_COUNT):
		if i != 2:
			tree.set_column_expand(i, false)


func use_project(project: Project):
	xml_stat_item_dict.clear()
	tree.clear()
	tree.set_columns(COLUMN_COUNT)
	var root: TreeItem = tree.create_item() 
	tree.hide_root = true
	for xml_stat in project.xml_status:
		var xml_item = tree.create_item(root)
		xml_item.set_text(0,xml_stat.filename)
		xml_item.set_selectable(0,false)
		xml_item.set_selectable(1,false)
		xml_item.set_selectable(2,false)
		xml_item.set_selectable(3,false)
		xml_item.set_selectable(4,false)
		xml_item.set_selectable(5,false)
		xml_item.set_selectable(6,false)
		xml_item.set_selectable(7,false)
		xml_stat_item_dict[xml_stat] = xml_item
		for symbol_object in xml_stat.symbol_objects:
			var symbol_item = create_symbol(xml_item, symbol_object)
			#symbol_item.set_custom_color(1, Config.SYMBOL_COLOR_PRESET[xml_stat.id])
			symbol_item.set_custom_bg_color(0, Config.SYMBOL_COLOR_PRESET[xml_stat.id],true)
	
	set_tree_column_style()
	
	
func create_symbol(parent: TreeItem, symbol_object: SymbolObject) -> TreeItem:
	var symbol_item: TreeItem = tree.create_item(parent)
	fill_treeitem(symbol_item,symbol_object)
	if symbol_object.is_text:
		symbol_item.set_editable(2, true)
		
	return symbol_item

	
func _on_tree_item_selected():
	var selected_symbol_id = tree.get_selected().get_text(0).to_int()
	var selected_xml_filename = tree.get_selected().get_parent().get_text(0)
	var selected_xml_id = ProjectManager.active_project.get_xml_id_from_filename(selected_xml_filename)
	if selected_xml_id != -1 && selected_symbol_id != -1:
		SymbolManager.symbol_selected_from_tree.emit(selected_xml_id,selected_symbol_id)
		SymbolManager.symbol_edit_started.emit(selected_xml_id,selected_symbol_id)
	

func _input(event):
	# limit area to treeviewer
	var rect = get_global_rect()
	var pos = get_global_mouse_position()
	if !rect.has_point(pos):
		return
				
	# bring type class editing window by double clicking
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
	var symbol_items = xml_item.get_children().filter(func(item): return item.get_text(0).to_int() == symbol_id)
	symbol_items[0].select(0)
	tree.scroll_to_item(symbol_items[0])
	
	
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


func change_visibility(xml_id: int):
	# TODO: there's bug when change visibility if more than two projects are opened
	# to keep order consistency, reset tree for every call
	for xml_stat in xml_stat_item_dict:
		tree.get_root().remove_child(xml_stat_item_dict[xml_stat])
	
	for xml_stat in xml_stat_item_dict:
		if !xml_stat.is_visible:
			tree.get_root().remove_child(xml_stat_item_dict[xml_stat])
		else:
			tree.get_root().add_child(xml_stat_item_dict[xml_stat])
			
			
func change_selectability(xml_id: int):
	for xml_stat in xml_stat_item_dict:
		if xml_stat.id != xml_id:
			continue
		
		if !xml_stat.is_selectable:
			for child in xml_stat_item_dict[xml_stat].get_children():
				for i in range(COLUMN_COUNT):
					child.set_selectable(i,false)
		else:
			for child in xml_stat_item_dict[xml_stat].get_children():
				for i in range(COLUMN_COUNT):
					child.set_selectable(i,true)


func _on_tree_column_title_clicked(column, mouse_button_index):
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		for xml_stat in xml_stat_item_dict:
			var xml_item = xml_stat_item_dict[xml_stat]
			# sort symbol object itself
			var symbol_objects = xml_stat.symbol_objects
			symbol_objects.sort_custom(sort_function(column))
			var symbol_items = xml_item.get_children()
			for i in range(symbol_objects.size()):
				fill_treeitem(symbol_items[i], symbol_objects[i])
			
			
func sort_function(column):
	match column:
		0: 
			return func(a,b): return a.id < b.id
		1: 
			return func(a,b): return a.type.naturalnocasecmp_to(b.type) < 0
		2:
			return func(a,b): return a.cls.naturalnocasecmp_to(b.cls) < 0
		3:
			return func(a,b): return a.bndbox.x < b.bndbox.x
		4:
			return func(a,b): return a.bndbox.y < b.bndbox.y
		5:
			return func(a,b): return a.bndbox.z < b.bndbox.z
		6:
			return func(a,b): return a.bndbox.w < b.bndbox.w
		7:
			return func(a,b): return a.degree < b.degree
			
