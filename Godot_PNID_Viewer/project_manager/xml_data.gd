class_name XMLData # TODO: separate diff xml

var id: int
var filename: String
var symbol_objects: Array[SymbolObject]
var dirty: bool # true if any symbol_object is modified

var is_visible: bool = true 
var is_selectable: bool = true
var is_show_label: bool = false


func initialize_from_string(id:int, xml_filename:String, xml_str: PackedByteArray):
	self.id = id
	self.filename = xml_filename
	symbol_objects = PnidXmlIo.parse_pnid_xml_from_byte_array(xml_str)
	symbol_objects.map(func(s): s.color = Config.SYMBOL_COLOR_PRESET[id])
	symbol_objects.map(func(s): s.source_xml = self)
	var is_sane = check_sanity(symbol_objects) # TODO: what to do if check sanity failes?
	
	
func initialize_from_diff_symbols(id: int, filename:String, symbol_objects: Array[SymbolObject]):
	self.id = id
	self.filename = filename
	self.symbol_objects = symbol_objects
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
	var new_symbol = SymbolObject.new(symbol_objects.size())
	new_symbol.source_xml = self
	new_symbol.bndbox += Vector4(position.x, position.y, position.x, position.y) # translate min/max
	new_symbol.color = Config.SYMBOL_COLOR_PRESET[id]
	
	SignalManager.symbol_added.emit(new_symbol)
	
	return new_symbol
	

func get_colors():
	var colors = {}
	symbol_objects.map(func(a): colors[a.color] = null)
	return colors.keys()
