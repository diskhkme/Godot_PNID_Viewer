extends Node
class_name Project

var id: int
var undo_redo: UndoRedo

var snapshot_array: Array # array of [symbol_object, snapshot_start]
var is_symbol_actually_edited: bool = false
var snapshot_start: SymbolObject
var snapshot_end: SymbolObject
var snapshot_src: SymbolObject
var current_action_id: int = 0
var add_symbol_stack: Array
var add_symbol_ref

var loaded: bool = false

var img_filename: String
var img: Image
var xml_datas: Array[XMLData]

func _ready():
	SignalManager.symbol_selected.connect(_on_symbol_edit_started)
	SignalManager.symbol_edited.connect(_on_symbol_edited)
	SignalManager.symbol_deselected.connect(_on_symbol_edit_ended)
	SignalManager.symbol_added.connect(_on_symbol_added)


func initialize(id, img_filename, img, num_xml, xml_filenames, xml_strs):
	self.id = id
	self.img_filename = img_filename
	self.img = img
	
	undo_redo = UndoRedo.new()
	xml_datas.clear()
	for i in range(num_xml):
		var xml_data = XMLData.new()
		xml_data.initialize_from_xml_str(xml_datas.size(), xml_filenames[i], xml_strs[i].to_utf8_buffer())
		xml_datas.push_back(xml_data)
			
	return true
	

func get_xml_id_from_filename(filename: String) -> int:
	for xml_data in xml_datas:
		if xml_data.filename == filename:
			return xml_data.id
			
	return -1


func add_xml_from_data(xml_data: XMLData):
	xml_datas.push_back(xml_data)
	SignalManager.xml_added.emit(xml_data)
	
	
func add_xml_from_file(num_xml, xml_filenames, xml_strs):
	for i in range(num_xml):
		var xml_data = XMLData.new()
		xml_data.initialize_from_xml_str(xml_datas.size(), xml_filenames[i], xml_strs[i].to_utf8_buffer())
		xml_datas.push_back(xml_data)
		SignalManager.xml_added.emit(xml_data)
		
# in case of edit symbol, editing is already done by edit controller
# TODO: consider change actual edit action happens here
func _on_symbol_edit_started(symbol_object: SymbolObject):
	snapshot_start = symbol_object.clone()
	is_symbol_actually_edited = false
	
	
func _on_symbol_edit_ended(symbol_object: SymbolObject):
	if is_symbol_actually_edited:
		snapshot_src = symbol_object
		snapshot_end = symbol_object.clone()
		if current_action_id >= snapshot_array.size():
			snapshot_array.push_back([snapshot_src, snapshot_start, snapshot_end])
		else:
			snapshot_array[current_action_id] = [snapshot_src, snapshot_start, snapshot_end]
		
		undo_redo.create_action("Edit symbol")
		undo_redo.add_do_method(do_symbol_editing)
		undo_redo.add_undo_method(undo_symbol_editing)
		undo_redo.commit_action()
		
		snapshot_start = null
		
	
	
func _on_symbol_edited(symbol_object: SymbolObject):
	if snapshot_start == null:
		is_symbol_actually_edited = false
		return
	# in snapshot, clone symbol is saved so check by id and source xml
	if snapshot_start.id == symbol_object.id and snapshot_start.source_xml == symbol_object.source_xml:
		# if stacked symbol is actually edited
		is_symbol_actually_edited = true
		
		
func do_symbol_editing():
	var objects = snapshot_array[current_action_id]
	objects[0].restore(objects[2])
	current_action_id += 1
	print("do edit action ", objects[0].id)
	
		
func undo_symbol_editing():
	current_action_id -= 1
	var objects = snapshot_array[current_action_id]
	objects[0].restore(objects[1])
	print("undo edit action ", objects[0].id)
	
# in case of add symbol, actual adding happens here
func _on_symbol_added(new_symbol: SymbolObject):
	add_symbol_ref = new_symbol
	undo_redo.create_action("Add symbol")
	undo_redo.add_do_method(do_symbol_add)
	undo_redo.add_undo_method(undo_symbol_add)
	undo_redo.commit_action()
	
	
func do_symbol_add():
	print("do add action ", add_symbol_ref.id)
	add_symbol_stack.push_back(add_symbol_ref)
	xml_datas[0].symbol_objects.push_back(add_symbol_ref)
	add_symbol_ref = null
	
	
func undo_symbol_add():
	var symbol = add_symbol_stack.pop_back()
	symbol.removed = true
	print("undo add action ", symbol.id)


