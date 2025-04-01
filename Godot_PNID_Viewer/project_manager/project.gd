class_name Project

signal symbol_action(symbol_object: SymbolObject) # edit/add/remove

var id: int
var dirty: bool = false
var img_filename: String
var img: Image
var xml_datas: Array[XMLData]

var undoredo_mgr: UndoRedoManager

func initialize(id, img_filename, img):
	self.id = id
	self.img_filename = img_filename
	self.img = img
	
	undoredo_mgr = UndoRedoManager.new()
	xml_datas.clear()
			
	return true
	

func get_xml_id_from_filename(filename: String) -> int:
	for xml_data in xml_datas:
		if xml_data.filename == filename:
			return xml_data.id
			
	return -1

func add_datas(num_xml, xml_filenames, xml_strs, format):
	for i in range(num_xml):
		var xml_data = XMLData.new()
		print(xml_strs[i])
		xml_data.initialize(xml_datas.size(), xml_filenames[i], xml_strs[i], format)
		xml_datas.push_back(xml_data)
		

func add_diff_xml(symbol_objects, diff_name, source_xml, target_xml):
	var xml_id = xml_datas.size()
	var new_name = diff_name
	
	var xml_data = DiffData.new()
	xml_data.initialize_diff(xml_id, new_name, symbol_objects, source_xml, target_xml)
	xml_datas.push_back(xml_data)


func close_xml(removed_xml: XMLData):
	undoredo_mgr.filter_closed_xml_history(removed_xml)
			
	removed_xml.symbol_objects.clear()
	xml_datas.erase(removed_xml)		


func update_dirty():
	var has_dirty = false
	for xml_data in xml_datas:
		var dirty_symbols = xml_data.symbol_objects.filter(func(a): return a.dirty == true)
		if dirty_symbols.size() > 0:
			xml_data.dirty = true
			has_dirty = true
		else:
			xml_data.dirty = false
			
	if has_dirty:
		self.dirty = true
	else:
		self.dirty = false
	
	
func has_undo():
	return undoredo_mgr.has_undo()
	
	
func has_redo():
	return undoredo_mgr.has_redo()
	
	
func undo():
	undoredo_mgr.undo()
	update_dirty()
	symbol_action.emit(undoredo_mgr.latest_symbol)
	

func redo():
	undoredo_mgr.redo()
	update_dirty()
	symbol_action.emit(undoredo_mgr.latest_symbol)
	
	
func symbol_edit_started(symbol_object: SymbolObject):
	undoredo_mgr.cache_snapshot(symbol_object)
	
	
func symbol_edited(symbol_object: SymbolObject):
	undoredo_mgr.commit_edit_action(symbol_object)
	update_dirty()
	symbol_action.emit(undoredo_mgr.latest_symbol)
	
	
func symbol_edit_canceled():
	undoredo_mgr.cancel_snapshot()
	
	
func symbol_add(pos: Vector2, target_xml: XMLData):
	var new_symbol = SymbolObject.new()
	new_symbol.source_xml = target_xml
	new_symbol.origin_xml = target_xml
	new_symbol.bndbox += Vector4(pos.x, pos.y, pos.x, pos.y)
	new_symbol.id = target_xml.symbol_objects.size()
	new_symbol.dirty = true
	new_symbol.is_new = true
	undoredo_mgr.commit_add_action(new_symbol)
	update_dirty()
	symbol_action.emit(undoredo_mgr.latest_symbol)
