class_name SymbolObject

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

var is_text: bool = false
var removed: bool = false

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
	
	
func set_bndbox(center: Vector2, size: Vector2):
	var min_coord = center - size/2
	var max_coord = center + size/2
	
	if Config.FORCE_INT_COORD:
		min_coord = Vector2(min_coord)
		max_coord = Vector2(max_coord)
		
	bndbox = Vector4(min_coord.x, min_coord.y, max_coord.x, max_coord.y)
		
	
func set_degree(angle: float):
	var new_degree = rad_to_deg(angle)
	
	if Config.FORCE_QUANTIZED_DEGREE:
		new_degree = snappedf(new_degree, Config.QUANTIZED_DEGREE_VALUE)
		
	degree = new_degree
