class_name XMLData 

var id: int
var filename: String
var symbol_objects: Array[SymbolObject]
var dirty: bool # true if any symbol_object is modified
var color: Color

var is_symbol_visible: bool = true 
var is_text_visible: bool = true 
var is_selectable: bool = true
var is_show_label: bool = false

func initialize(id:int, data_filename:String, data_str: String, data_format: String):
	self.id = id
	self.filename = data_filename
	symbol_objects = PnidXmlIo.parse_pnid_data_from_string(data_str, data_format, ProjectManager.active_project.img_filename, ProjectManager.active_project.img.get_width(),ProjectManager.active_project.img.get_height())
	if id < Config.SYMBOL_COLOR_PRESET.size():
		color = Config.SYMBOL_COLOR_PRESET[id]
	else:
		var rand_col = Color(randf(), randf(), randf(), 1)
		color = rand_col
	symbol_objects.map(func(s): s.source_xml = self)
	symbol_objects.map(func(s): s.origin_xml = self)
	
	
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
