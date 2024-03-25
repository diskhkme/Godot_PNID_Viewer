class_name XMLData # TODO: separate diff xml

var id: int
var filename: String
var symbol_objects: Array[SymbolObject]
var dirty: bool # true if any symbol_object is modified
var color: Color

var is_visible: bool = true 
var is_selectable: bool = true
var is_show_label: bool = false


func _init(id:int, xml_filename:String, xml_str: PackedByteArray):
	self.id = id
	self.filename = xml_filename
	symbol_objects = PnidXmlIo.parse_pnid_xml_from_byte_array(xml_str)
	if id < Config.SYMBOL_COLOR_PRESET.size():
		color = Config.SYMBOL_COLOR_PRESET[id]
	else:
		var rand_col = Color(randf(), randf(), randf(), 1)
		color = rand_col
	symbol_objects.map(func(s): s.source_xml = self)
	symbol_objects.map(func(s): s.origin_xml = self)
	var is_sane = check_sanity(symbol_objects) # TODO: what to do if check sanity failes?
	
	
# TODO: add more constraints
func check_sanity(symbol_objects):
	for symbol_object in symbol_objects:
		if !ProjectManager.symbol_type_set.has(symbol_object.type):
			print("XML has undefined symbol type!")
			return false
		if !symbol_object.is_text:
			if !ProjectManager.symbol_type_set[symbol_object.type].has(symbol_object.cls):
				print("XML has undefined symbol type!")
				return false

	return true


func add_symbol(position: Vector2):
	var new_symbol = SymbolObject.new()
	new_symbol.id = symbol_objects.size()
	new_symbol.source_xml = self
	new_symbol.bndbox += Vector4(position.x, position.y, position.x, position.y) # translate min/max
	new_symbol.color = Config.SYMBOL_COLOR_PRESET[id]
	return new_symbol
	
	
func update_dirty():
	var dirty_symbols = symbol_objects.filter(func(a): return a.dirty == true)
	if dirty_symbols.size() > 0:
		dirty = true
	else:
		dirty = false
	

func get_index_of_id(id: int):
	var next = symbol_objects.filter(func(a): return a.id > id)
	if next.size() == 0: # last
		return symbol_objects.size()
	else:
		var index = symbol_objects.find(next[0])
		return index
