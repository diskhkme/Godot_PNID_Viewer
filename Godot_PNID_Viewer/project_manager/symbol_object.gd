class_name SymbolObject

# TODO: save type and class using id
var id: int
var type: String :
	get: return type
	set(value):
		if value.to_lower().contains(Config.TEXT_TYPE_NAME):
			is_text = true
		else:
			is_text = false
		type = value
var cls: String
var bndbox: Vector4
var is_large: bool
var degree: float
var flip: bool

var source_xml: XMLData
var color: Color

var is_text: bool = false
var removed: bool = false 

var selected: bool = false
var editing: bool = false # if currently editing

# TODO: strictly define constructor (prevent missing property)
func _init():
	bndbox = Vector4(0,0,100,100)
	is_large = false
	degree = 0
	flip = false
	type = "None"
	cls = "None"


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
func get_degree(): return -degree
	

# -------------------------------------------------------------------------------
# ----- Setters (emits signal) --------------------------------------------------
# -------------------------------------------------------------------------------
func set_bndbox(center: Vector2, size: Vector2):
	var min_coord = center - size/2
	var max_coord = center + size/2
	
	if Config.FORCE_INT_COORD:
		min_coord = Vector2(min_coord)
		max_coord = Vector2(max_coord)
		
	bndbox = Vector4(min_coord.x, min_coord.y, max_coord.x, max_coord.y)
	SignalManager.symbol_edited.emit(self)
	
	
func set_degree(angle: float):
	var new_degree = rad_to_deg(angle)
	
	if Config.FORCE_QUANTIZED_DEGREE:
		new_degree = snappedf(new_degree, Config.QUANTIZED_DEGREE_VALUE)
		
	degree = -new_degree
	SignalManager.symbol_edited.emit(self)
	
	
func set_edit_status(is_editing: bool):
	editing = is_editing
	if editing:
		SignalManager.symbol_edit_started.emit(self)
	else:
		SignalManager.symbol_edit_ended.emit()
	
	
func set_selected(is_selected: bool):
	selected = is_selected
	if selected:
		SignalManager.symbol_selected_from_image.emit(self)
	else:
		SignalManager.symbol_deselected.emit()


func set_removed(is_removed: bool):
	removed = is_removed
	if removed:
		SignalManager.symbol_edited.emit(self)
		SignalManager.symbol_deselected.emit()
		SignalManager.symbol_edit_ended.emit()
		
		
func set_type(new_type: String):
	type = new_type
	SignalManager.symbol_edited.emit(self)
	
	
func set_cls(new_cls: String):
	cls = new_cls
	SignalManager.symbol_edited.emit(self)
