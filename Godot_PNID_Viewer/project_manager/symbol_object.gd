class_name SymbolObject

# --------------------------------------------------------------------
# --- Properties -----------------------------------------------------
# --------------------------------------------------------------------
var id: int 
var type: String
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
	
	
func compare(other: SymbolObject) -> bool:
	if id == other.id and type == other.type and cls == other.cls and \
	bndbox == other.bndbox and is_large == other.is_large and \
	degree == other.degree and flip == other.flip and \
	source_xml == other.source_xml and origin_xml == other.origin_xml and \
	is_text == other.is_text and dirty == other.dirty and \
	removed == other.removed and is_new == other.is_new:
		return true
		
	return false
	

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
	
	
func has_point(point: Vector2):
	var symbol_based_vec = point-get_center()
	var canoninal_point = symbol_based_vec.rotated(deg_to_rad(degree)) # minus degree, actually
	if get_rect().has_point(canoninal_point + get_center()):
		return true
	else:
		return false	
	
	
func get_bndbox_from_fourpoint_degree(p1,p2,p3,p4,degree) -> Vector4:
	if degree != 0:
		var a = 1
	
	var center = (p1 + p2 + p3 + p4) / 4.0
	var p1_vec = p1 - center # upper left
	var p3_vec = p3 - center # bottom right
	p1_vec = p1_vec.rotated(deg_to_rad(degree)) # minus degree, actually
	p3_vec = p3_vec.rotated(deg_to_rad(degree)) # minus degree, actually
	
	p1_vec += center
	p3_vec += center
	
	# TODO: currently, does not consider the flip property
	var minx = p1_vec.x if p1_vec.x < p3_vec.x else p3_vec.x
	var miny = p1_vec.y if p1_vec.y < p3_vec.y else p3_vec.y
	var maxx = p1_vec.x if p1_vec.x > p3_vec.x else p3_vec.x
	var maxy = p1_vec.y if p1_vec.y > p3_vec.y else p3_vec.y
		
	var bndbox = Vector4(minx, miny, maxx, maxy)
	return bndbox
	

func get_degree_from_dota_fourpoint(p1,p2,p3,p4):
	var p1_to_p2_vec = p2 - p1
	var angle = p1_to_p2_vec.angle()
	var degree = -rad_to_deg(angle)
	return degree
	
	
func get_rotated_fourpoint():
	var p1 = Vector2(bndbox.x, bndbox.y)
	var p2 = Vector2(bndbox.z, bndbox.y) # z = max_x
	var p3 = Vector2(bndbox.z, bndbox.w) # w = max_y
	var p4 = Vector2(bndbox.x, bndbox.w) # w = max_y
	
	var center = get_center()
	var rotated_p1 = (p1 - center).rotated(deg_to_rad(get_godot_degree())) + center
	var rotated_p2 = (p2 - center).rotated(deg_to_rad(get_godot_degree())) + center
	var rotated_p3 = (p3 - center).rotated(deg_to_rad(get_godot_degree())) + center
	var rotated_p4 = (p4 - center).rotated(deg_to_rad(get_godot_degree())) + center
	
	return [rotated_p1, rotated_p2, rotated_p3, rotated_p4]
	
	
	
	
