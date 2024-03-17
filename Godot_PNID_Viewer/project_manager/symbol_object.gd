class_name SymbolObject

# --------------------------------------------------------------------
# --- Properties -----------------------------------------------------
# --------------------------------------------------------------------
var _id: int
var id: int :
	get: return _id
	set(value):
		if _id != value:
			_id = value
			SignalManager.symbol_edited.emit(self)
var _type
var type: String : # TODO: save type and class using id
	get: return _type
	set(value):
		if _type != value:
			_type = value
			if value.to_lower().contains(Config.TEXT_TYPE_NAME):
				is_text = true
			else:
				is_text = false
			SignalManager.symbol_edited.emit(self)
var _cls
var cls: String :
	get: return _cls
	set(value):
		if _cls != value:
			_cls = value
			SignalManager.symbol_edited.emit(self)
var _bndbox
var bndbox: Vector4 :
	get: return _bndbox
	set(value):
		if _bndbox != value:
			_bndbox = value
			SignalManager.symbol_edited.emit(self)
var _is_large
var is_large: bool :
	get: return _is_large
	set(value):
		if _is_large != value:
			_is_large = value
			SignalManager.symbol_edited.emit(self)
var _degree
var degree: float :
	get: return _degree
	set(value):
		if _degree != value:
			_degree = value
			SignalManager.symbol_edited.emit(self)
var _flip
var flip: bool :
	get: return _flip
	set(value):
		if _flip != value:
			_flip = value
			SignalManager.symbol_edited.emit(self)

var source_xml: XMLData
var color: Color
var is_text: bool = false :
	get: return is_text

var _removed
var removed: bool = false :
	get: return removed
	set(value):
		if value != _removed:
			_removed = value
			SignalManager.symbol_edited.emit(self)
			if _removed:
				SignalManager.symbol_deselected.emit()
				
var _is_selected
var is_selected: bool = false :
	get: return _is_selected
	set(value):
		if _is_selected != value: # prevent signal roundtrip
			_is_selected = value
			if _is_selected:
				SignalManager.symbol_selected.emit(self)
			else:
				SignalManager.symbol_deselected.emit(self)

var is_dirty = false

# --------------------------------------------------------------------
# --- Methods    -----------------------------------------------------
# --------------------------------------------------------------------

# TODO: strictly define constructor (prevent missing property)
func _init():
	_bndbox = Vector4(0,0,100,100)
	_is_large = false
	_degree = 0
	_flip = false
	_type = "None"
	_cls = "None"
	
	
func clone():
	# manual copy op
	var symbol = SymbolObject.new()
	symbol._id = _id
	symbol._type = _type
	symbol._cls = _cls
	symbol._bndbox = _bndbox
	symbol._is_large = _is_large
	symbol._degree = _degree
	symbol._flip = _flip
	symbol.source_xml = source_xml
	symbol.color = color
	symbol.is_text = is_text
	symbol._removed = _removed
	symbol._is_selected = _is_selected
	symbol.is_dirty = is_dirty
	return symbol
	
	
func restore(other: SymbolObject):
	id = other.id
	type = other.type
	cls = other.cls
	bndbox = other.bndbox
	is_large = other.is_large
	degree = other.degree
	flip = other.flip
	source_xml = other.source_xml
	color = other.color
	is_text = other.is_text
	removed = other.removed
	#is_selected = other.is_selected
	is_selected = false
	is_dirty = other.is_dirty


func get_rect() -> Rect2:
	var width = bndbox.z-bndbox.x
	var height = bndbox.w-bndbox.y
	return Rect2(bndbox.x, bndbox.y, width, height)


func get_center() -> Vector2:
	return Vector2((bndbox.x + bndbox.z)/2, (bndbox.y + bndbox.w)/2)

	
func get_size() -> Vector2:
	var width = bndbox.z-bndbox.x
	var height = bndbox.w-bndbox.y
	return Vector2(width, height)
	
	
func is_type_class_same(type: String, cls: String):
	if self.type == type and self.cls == cls:
		return true
		
	return false
	
	
func get_rotated_bndbox() -> Vector4:
	var center = get_center()
	var centered = bndbox - Vector4(center.x, center.y, center.x, center.y)
	var rotated_min = Vector2(centered.x, centered.y).rotated(deg_to_rad(-degree))
	var rotated_max = Vector2(centered.z, centered.w).rotated(deg_to_rad(-degree))
	
	var minx = min(rotated_min.x, rotated_max.x) + center.x
	var miny = min(rotated_min.y, rotated_max.y) + center.y
	var maxx = max(rotated_min.x, rotated_max.x) + center.x
	var maxy = max(rotated_min.y, rotated_max.y) + center.y
	
	return Vector4(minx, miny, maxx, maxy)
	
# rotation handiness is different in Godot
func get_godot_degree(): return -degree
	

func set_bndbox_from_rect2(rect: Rect2):
	var min_coord = rect.position - rect.size/2
	var max_coord = rect.position + rect.size/2
	
	if Config.FORCE_INT_COORD:
		min_coord = Vector2(min_coord)
		max_coord = Vector2(max_coord)
		
	bndbox = Vector4(min_coord.x, min_coord.y, max_coord.x, max_coord.y)
	
	
func set_degree_from_godot(angle: float):
	var new_degree = rad_to_deg(angle)
	
	if Config.FORCE_QUANTIZED_DEGREE:
		new_degree = snappedf(new_degree, Config.QUANTIZED_DEGREE_VALUE)
		
	degree = -new_degree
	

	
