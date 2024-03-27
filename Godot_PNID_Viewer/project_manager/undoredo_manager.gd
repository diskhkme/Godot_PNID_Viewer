class_name UndoRedoManager

var _undo_redo: UndoRedo

class Snapshot:
	var ref: SymbolObject
	var before: SymbolObject
	var after: SymbolObject
var _snapshot_stack: Array # array of snapshot
var _snapshot_ref: Snapshot
var _edit_action_id: int = 0

var _add_symbol_stack: Array
var _add_action_id: int = 0 # TODO: consider merge add_symbol_stack with _snapshot_stack

var current_symbol: SymbolObject

func _init():
	_undo_redo = UndoRedo.new()
	

func filter_closed_xml_history(removed_xml: XMLData):
	var remaining_undo_count = _rewind_history(removed_xml)
	_undo_redo = _replay_history(removed_xml, remaining_undo_count)


func _rewind_history(removed_xml: XMLData) -> int: # return undo count
	var undo_count_except_removed = 0
	# redo all to check how many replay requred
	while _undo_redo.has_redo():
		_undo_redo.redo()
		if _undo_redo.get_current_action_name() == "Edit symbol":
			if removed_xml != _snapshot_stack[_edit_action_id-1].ref.source_xml:
				undo_count_except_removed += 1
		if _undo_redo.get_current_action_name() == "Add symbol":
			if removed_xml != _add_symbol_stack[_add_action_id-1].source_xml:
				undo_count_except_removed += 1
		
	# undo all to start
	while _undo_redo.has_undo():
		_undo_redo.undo()
		
	return undo_count_except_removed
	
	
func _replay_history(removed_xml: XMLData, remaining_undo_count: int):
	var new_undo_redo = UndoRedo.new()
	var new_snapshot_stack: Array
	var new_add_symbol_stack: Array
	
	# replay do except closed xml
	_edit_action_id = 0
	_add_action_id = 0
	var replay_edit_action_id = 0
	var replay_add_action_id = 0
	for i in range(_undo_redo.get_history_count()):
		if _undo_redo.get_action_name(i) == "Edit symbol":
			if removed_xml != _snapshot_stack[_edit_action_id].ref.source_xml:
				new_snapshot_stack.push_back(_snapshot_stack[_edit_action_id])
				new_undo_redo.create_action("Edit symbol")
				new_undo_redo.add_do_method(_do_symbol_edit)
				new_undo_redo.add_undo_method(_undo_symbol_edit)
				new_undo_redo.commit_action()
				replay_edit_action_id += 1
			else:
				_edit_action_id += 1
		if _undo_redo.get_action_name(i) == "Add symbol":
			if removed_xml != _add_symbol_stack[_add_action_id].source_xml:
				new_add_symbol_stack.push_back(_add_symbol_stack[_add_action_id])
				new_undo_redo.create_action("Add symbol")
				new_undo_redo.add_do_method(_do_symbol_add)
				new_undo_redo.add_undo_method(_undo_symbol_add)
				new_undo_redo.commit_action()
				replay_add_action_id += 1
			else:
				_add_action_id += 1
				
	# replay undos except closed xml
	_edit_action_id = replay_edit_action_id
	_add_action_id = replay_add_action_id
	_snapshot_stack = new_snapshot_stack
	_add_symbol_stack = new_add_symbol_stack
	for i in range(remaining_undo_count):
		new_undo_redo.undo()

	return new_undo_redo
	
	
func undo():
	_undo_redo.undo()
	
	
func redo():
	_undo_redo.redo()
	
	
func has_undo() -> bool:
	return _undo_redo.has_undo()


func has_redo() -> bool:
	return _undo_redo.has_redo()
	
	
func cache_snapshot(symbol_object: SymbolObject):
	var snapshot = Snapshot.new()
	snapshot.ref = symbol_object
	snapshot.before = symbol_object.clone()
	_snapshot_ref = snapshot
	
	
func commit_edit_action(symbol_object: SymbolObject):
	assert(_snapshot_ref.ref == symbol_object, "not expected")
	if symbol_object.compare(_snapshot_ref.before):
		return # do nothing if nothing changed

	_snapshot_ref.after = symbol_object.clone()
	if _edit_action_id >= _snapshot_stack.size():
		_snapshot_stack.push_back(_snapshot_ref)
	else:
		_snapshot_stack[_edit_action_id] = _snapshot_ref
		
	_undo_redo.create_action("Edit symbol")
	_undo_redo.add_do_method(_do_symbol_edit)
	_undo_redo.add_undo_method(_undo_symbol_edit)
	_undo_redo.commit_action()
	
	
func cancel_snapshot():
	_snapshot_stack[_edit_action_id].ref.restore(_snapshot_stack[_edit_action_id].before)
	#_snapshot_stack.pop_back()
	
	
func _do_symbol_edit():
	var snapshot = _snapshot_stack[_edit_action_id]
	snapshot.ref.restore(snapshot.after)
	current_symbol = snapshot.ref
	_edit_action_id += 1
	#print("do edit action ", snapshot.ref.id)
	
		
func _undo_symbol_edit():
	_edit_action_id -= 1
	var snapshot = _snapshot_stack[_edit_action_id]
	snapshot.ref.restore(snapshot.before)
	current_symbol = snapshot.ref
	#print("undo edit action ", snapshot.ref.id)
	
# in case of add symbol, actual adding happens here
func commit_add_action(new_symbol: SymbolObject):
	if _add_action_id >= _add_symbol_stack.size():
		_add_symbol_stack.push_back(new_symbol)
	else:
		_add_symbol_stack[_add_action_id] = new_symbol
		
	_undo_redo.create_action("Add symbol")
	_undo_redo.add_do_method(_do_symbol_add)
	_undo_redo.add_undo_method(_undo_symbol_add)
	_undo_redo.commit_action()
	
	
func _do_symbol_add():
	current_symbol = _add_symbol_stack[_add_action_id]
	var index = current_symbol.source_xml.get_index_of_id(current_symbol.id)
	current_symbol.source_xml.symbol_objects.insert(index, current_symbol)
	_add_action_id += 1
	#print("do add action ", current_symbol.id)
	
	
func _undo_symbol_add():
	_add_action_id -= 1
	current_symbol = _add_symbol_stack[_add_action_id]
	current_symbol.source_xml.symbol_objects.erase(current_symbol)
	#print("undo add action ", current_symbol.id)
	

