class_name XML_Status

var id: int
var filename: String
var symbol_objects: Array[SymbolObject]
var color: Color
var dirty: bool # true if any symbol_object is modified

# show and lock controlled by project viewer
var is_visible: bool
var is_selectable: bool

func initialize_by_xml_str(id:int, xml_filename:String, xml_str: PackedByteArray):
	self.id = id
	self.filename = xml_filename
	symbol_objects = PnidXmlIo.parse_pnid_xml_from_byte_array(xml_str)
	var is_sane = check_sanity(symbol_objects) # TODO: what to do if check sanity failes?
	is_visible = true
	is_selectable = true
	color = Config.SYMBOL_COLOR_PRESET[id]
	
# No constructore overloading...	
func initialize_by_symbols(id: int, filename:String, symbol_objects: Array[SymbolObject]):
	self.id = id
	self.filename = filename
	self.symbol_objects = symbol_objects
	var is_sane = check_sanity(symbol_objects) # TODO: what to do if check sanity failes?
	is_visible = true
	is_selectable = true
	color = Config.SYMBOL_COLOR_PRESET[id]
	

# TODO: add more constraints
func check_sanity(symbol_objects):
	for symbol_object in symbol_objects:
		if !ProjectManager.symbol_type_set.has(symbol_object.type):
			return false
			print("XML has undefined symbol type!")
		if !symbol_object.is_text:
			if !ProjectManager.symbol_type_set[symbol_object.type].has(symbol_object.cls):
				return false
				print("XML has undefined symbol type!")

	return true


# TODO: symbol edtied here?

func remove_symbol(symbol_id: int):
	symbol_objects[symbol_id].removed = true


func add_new_symbol(position: Vector2) -> int:
	var new_symbol = SymbolObject.new()
	new_symbol.bndbox += Vector4(position.x, position.y, position.x, position.y) # translate min/max
	var new_symbol_id = symbol_objects.size()
	new_symbol.id = new_symbol_id
	symbol_objects.push_back(new_symbol)
	
	return new_symbol_id
