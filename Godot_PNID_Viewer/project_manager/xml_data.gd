class_name XMLData # TODO: separate diff xml

var id: int
var filename: String
var symbol_objects: Array[SymbolObject]
var colors = {}
var dirty: bool # true if any symbol_object is modified

# show and lock controlled by project viewer
var is_visible: bool = true :
	get: return is_visible
	set(value):
		if is_visible != value:
			is_visible = value
			SignalManager.xml_visibility_changed.emit(self)
var is_selectable: bool = true :
	get: return is_selectable
	set(value):
		if is_selectable != value:
			is_selectable = value
			SignalManager.xml_selectability_changed.emit(self)
var is_show_label: bool = false :
	get: return is_show_label
	set(value):
		if is_show_label != value:
			is_show_label = value
			SignalManager.xml_label_visibility_changed.emit(self)

func initialize_from_xml_str(id:int, xml_filename:String, xml_str: PackedByteArray):
	self.id = id
	self.filename = xml_filename
	colors[Config.SYMBOL_COLOR_PRESET[id]] = null
	symbol_objects = PnidXmlIo.parse_pnid_xml_from_byte_array(xml_str)
	symbol_objects.map(func(s): s.color = self.colors.keys()[0])
	symbol_objects.map(func(s): s.source_xml = self)
	var is_sane = check_sanity(symbol_objects) # TODO: what to do if check sanity failes?
	
	
# No constructore overloading...	
func initialize_from_symbols(id: int, filename:String, symbol_objects: Array[SymbolObject]):
	self.id = id
	self.filename = filename
	colors = find_unique_colors(symbol_objects)
	self.symbol_objects = symbol_objects
	var is_sane = check_sanity(symbol_objects) # TODO: what to do if check sanity failes?
	

func find_unique_colors(symbol_objects: Array[SymbolObject]):
	var colors = {}
	for symbol_object in symbol_objects:
		colors[symbol_object.color] = null
	return colors

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


func add_new_symbol(position: Vector2) -> SymbolObject:
	var new_symbol = SymbolObject.new()
	new_symbol.source_xml = self
	var new_symbol_id = symbol_objects.size()
	new_symbol._id = new_symbol_id
	new_symbol._bndbox += Vector4(position.x, position.y, position.x, position.y) # translate min/max
	new_symbol.color = colors.keys()[0]
	
	SignalManager.symbol_added.emit(new_symbol)
	
	return new_symbol
	

