class_name SymbolObject

# --------------------------------------------------------------------
# --- Properties -----------------------------------------------------
# --------------------------------------------------------------------
var id: int 
var type: String :  # TODO: save type and class using id
	get: return type
	set(value):
		type = value
		if type.to_lower().contains(Config.TEXT_TYPE_NAME):
			is_text = true
		else:
			is_text = false
var cls: String
var bndbox: Vector4
var is_large: bool 
var degree: float 
var flip: bool 

var source_xml: XMLData
var origin_xml: XMLData
var is_text: bool 
var dirty = false
var removed = false
var is_new = false

# --------------------------------------------------------------------
# --- Methods    -----------------------------------------------------
# --------------------------------------------------------------------

# TODO: strictly define constructor (prevent missing property)
func _init():
	type = "None"
	cls = "None"
	bndbox = Vector4(0,0,100,100)
	is_large = false
	degree = 0
	flip = false
	dirty = false
	

func clone():
	var symbol_object = SymbolObject.new()
	symbol_object.id = id
	symbol_object.type = type
	symbol_object.cls = cls
	symbol_object.bndbox = bndbox
	symbol_object.is_large = is_large
	symbol_object.degree = degree
	symbol_object.flip = flip
	symbol_object.source_xml = source_xml
	symbol_object.origin_xml = origin_xml
	symbol_object.is_text = is_text
	symbol_object.dirty = dirty
	symbol_object.removed = removed
	symbol_object.is_new = is_new
	return symbol_object
	
	
func restore(other: SymbolObject):
	id = other.id
	type = other.type
	cls = other.cls
	bndbox = other.bndbox
	is_large = other.is_large
	degree = other.degree
	flip = other.flip
	source_xml = other.source_xml
	origin_xml = other.origin_xml
	is_text = other.is_text
	dirty = other.dirty
	removed = other.removed
	is_new = other.is_new
	

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
	

	
