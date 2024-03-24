extends Node
class_name Project

signal symbol_action(symbol_object: SymbolObject) # edit/add/remove

var id: int
var undo_redo: UndoRedo

# TODO: consider move undoredo module to separate file
class Snapshot:
	var ref: SymbolObject
	var before: SymbolObject
	var after: SymbolObject
	
var snapshot_stack: Array # array of [symbol_object, snapshot_start]
var current_symbol: SymbolObject

var current_action_id: int = 0

var add_symbol_stack: Array
var add_symbol_ref
var add_action_id: int = 0

var remove_symbol_stack: Array
var remove_symbol_ref
var remove_action_id: int = 0

var dirty: bool = false

var img_filename: String
var img: Image
var xml_datas: Array[XMLData]

func initialize(id, img_filename, img, num_xml, xml_filenames, xml_strs):
	self.id = id
	self.img_filename = img_filename
	self.img = img
	
	undo_redo = UndoRedo.new()
	xml_datas.clear()
	for i in range(num_xml):
		var xml_data = XMLData.new()
		xml_data.initialize_from_string(xml_datas.size(), xml_filenames[i], xml_strs[i])
		xml_datas.push_back(xml_data)
			
	return true
	

func get_xml_id_from_filename(filename: String) -> int:
	for xml_data in xml_datas:
		if xml_data.filename == filename:
			return xml_data.id
			
	return -1

	
func add_xmls(num_xml, xml_filenames, xml_strs):
	for i in range(num_xml):
		var xml_data = XMLData.new()
		xml_data.initialize_from_string(xml_datas.size(), xml_filenames[i], xml_strs[i])
		xml_datas.push_back(xml_data)
		
		
# --------------------------------------------------------------------
# ---Undo/Redo--------------------------------------------------------
# --------------------------------------------------------------------

func get_current_symbol():
	return current_symbol
	
	
func do_symbol_action():
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
	
	symbol_action.emit(current_symbol)
	
# in case of edit symbol, editing is already done by edit controller
# TODO: consider change actual edit action happens here
func symbol_edit_started(symbol_object: SymbolObject):
	var snapshot = Snapshot.new()
	snapshot.ref = symbol_object
	snapshot.before = symbol_object.clone()
	if current_action_id >= snapshot_stack.size():
		snapshot_stack.push_back(snapshot)
		print("add stack ", symbol_object.id)
	else:
		snapshot_stack[current_action_id] = snapshot
	
	
func symbol_edited(symbol_object: SymbolObject):
	symbol_object.dirty = true
	snapshot_stack[current_action_id].after = symbol_object.clone()
	undo_redo.create_action("Edit symbol")
	undo_redo.add_do_method(do_symbol_edit)
	undo_redo.add_undo_method(undo_symbol_edit)
	undo_redo.commit_action()
	
	
func symbol_edit_canceled(symbol_object: SymbolObject):
	print("canceled ", symbol_object.id)
	snapshot_stack.pop_back()
		
		
func do_symbol_edit():
	var snapshot = snapshot_stack[current_action_id]
	snapshot.ref.restore(snapshot.after)
	current_symbol = snapshot.ref
	current_action_id += 1
	do_symbol_action()
	print("do edit action ", snapshot.ref.id)
	
		
func undo_symbol_edit():
	current_action_id -= 1
	var snapshot = snapshot_stack[current_action_id]
	snapshot.ref.restore(snapshot.before)
	current_symbol = snapshot.ref
	do_symbol_action()
	print("undo edit action ", snapshot.ref.id)
	
# in case of add symbol, actual adding happens here
func symbol_add(pos: Vector2, target_xml: XMLData):
	var new_symbol = SymbolObject.new()
	new_symbol.source_xml = target_xml
	new_symbol.bndbox += Vector4(pos.x, pos.y, pos.x, pos.y)
	new_symbol.color = target_xml.get_colors()[0]	
	new_symbol.id = target_xml.symbol_objects.size()
	new_symbol.dirty = true
	
	if add_action_id >= add_symbol_stack.size():
		add_symbol_stack.push_back(new_symbol)
	else:
		add_symbol_stack[add_action_id] = new_symbol
	
	
	undo_redo.create_action("Add symbol")
	undo_redo.add_do_method(do_symbol_add)
	undo_redo.add_undo_method(undo_symbol_add)
	undo_redo.commit_action()
	
	
func do_symbol_add():
	current_symbol = add_symbol_stack[add_action_id]
	var index = current_symbol.source_xml.get_index_of_id(current_symbol.id)
	current_symbol.source_xml.symbol_objects.insert(index, current_symbol)
	add_action_id += 1
	do_symbol_action()
	print("do add action ", current_symbol.id)
	
	
func undo_symbol_add():
	add_action_id -= 1
	current_symbol = add_symbol_stack[add_action_id]
	current_symbol.source_xml.symbol_objects.erase(current_symbol)
	do_symbol_action()
	print("undo add action ", current_symbol.id)
	
	
func symbol_remove(symbol_object: SymbolObject):
	if remove_action_id >= remove_symbol_stack.size():
		remove_symbol_stack.push_back(symbol_object)
	else:
		remove_symbol_stack[remove_action_id] = symbol_object

	undo_redo.create_action("Remove symbol")
	undo_redo.add_do_method(do_symbol_remove)
	undo_redo.add_undo_method(undo_symbol_remove)
	undo_redo.commit_action()
	
	
func do_symbol_remove():
	current_symbol = remove_symbol_stack[remove_action_id]
	current_symbol.source_xml.symbol_objects.erase(current_symbol)
	remove_action_id += 1
	do_symbol_action()
	print("do remove action ", current_symbol.id)
	
	
func undo_symbol_remove():
	remove_action_id -= 1
	current_symbol = remove_symbol_stack[remove_action_id]
	var index = current_symbol.source_xml.get_index_of_id(current_symbol.id)
	current_symbol.source_xml.symbol_objects.insert(index, current_symbol)
	do_symbol_action()
	print("do add action ", current_symbol.id)


