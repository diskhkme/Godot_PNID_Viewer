class_name SymbolObject

var id: int
var type: String
var cls: String
var bndbox: Vector4i
var is_large: bool
var degree: float
var flip: bool


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
		min_coord = Vector2i(min_coord)
		max_coord = Vector2i(max_coord)
		
	bndbox = Vector4i(min_coord.x, min_coord.y, max_coord.x, max_coord.y)
		
	
func set_degree(angle: float):
	var new_degree = rad_to_deg(angle)
	
	if Config.FORCE_QUANTIZED_DEGREE:
		new_degree = snappedf(new_degree, Config.QUANTIZED_DEGREE_VALUE)
		
	degree = new_degree
