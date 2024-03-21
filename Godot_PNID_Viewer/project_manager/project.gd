extends Node
class_name Project

var id: int
var undo_redo: UndoRedo

class Snapshot:
	var ref: SymbolObject
	var before: SymbolObject
	var after: SymbolObject
	
var snapshot_stack: Array # array of [symbol_object, snapshot_start]
var target_symbol: SymbolObject

var current_action_id: int = 0
var add_symbol_stack: Array
var add_symbol_ref

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
		
# in case of edit symbol, editing is already done by edit controller
# TODO: consider change actual edit action happens here
func symbol_edit_started(symbol_object: SymbolObject):
	print("add stack")
	var snapshot = Snapshot.new()
	snapshot.ref = symbol_object
	snapshot.before = symbol_object.clone()
	snapshot_stack.push_back(snapshot)
	
	
func symbol_edited(symbol_object: SymbolObject):
	snapshot_stack.back().after = symbol_object.clone()
	undo_redo.create_action("Edit symbol")
	undo_redo.add_do_method(do_symbol_edit)
	undo_redo.add_undo_method(undo_symbol_edit)
	undo_redo.commit_action()
	
	
func symbol_edit_canceled(symbol_object: SymbolObject):
	snapshot_stack.pop_back()
		
		
func do_symbol_edit():
	var snapshot = snapshot_stack[current_action_id]
	snapshot.ref.restore(snapshot.after)
	current_action_id += 1
	print("do edit action ", snapshot.ref.id)
	
		
func undo_symbol_edit():
	current_action_id -= 1
	var snapshot = snapshot_stack[current_action_id]
	snapshot.ref.restore(snapshot.before)
	print("undo edit action ", snapshot.ref.id)
	
# in case of add symbol, actual adding happens here
func symbol_added(new_symbol: SymbolObject):
	add_symbol_ref = new_symbol
	undo_redo.create_action("Add symbol")
	undo_redo.add_do_method(do_symbol_add)
	undo_redo.add_undo_method(undo_symbol_add)
	undo_redo.commit_action()
	
	
func do_symbol_add():
	print("do add action ", add_symbol_ref.id)
	xml_datas[0].symbol_objects.push_back(add_symbol_ref)
	add_symbol_ref = null
	
	
func undo_symbol_add():
	var symbol = xml_datas[0].symbol_objects.pop_back()
	SignalManager.symbol_removed.emit(add_symbol_ref)
	print("undo add action ", symbol.id)


