extends Node2D
class_name StaticSymbolDisplay

signal report_selected(global_mouse_pos: Vector2, obj: StaticSymbolDisplay)

@export var symbol_editor_handle: PackedScene #TODO: change hierarchy (directly added to symbol_scene)

var xml_id: int
var symbol_object: SymbolObject
var global_rect: Rect2 # for simple mouse picking

var is_editing: bool = false
var editor_handle

func _ready():
	global_rect = symbol_object.bndbox_to_rect()
	# because of rotation, node should be positioned in world space
	global_position = symbol_object.get_center()
	global_rotation_degrees = symbol_object.degree
	
	SymbolManager.symbol_selected.connect(on_symbol_selected)
	SymbolManager.symbol_deselected.connect(on_symbol_deselected) 
	

func _draw():
	if !is_editing: 
		var rect_size = global_rect.size
		var color = ProjectManager.active_project.xml_status[xml_id].color
		draw_rect(Rect2(-rect_size.x/2, -rect_size.y/2, rect_size.x, rect_size.y), color, false, Config.DEFAULT_LINE_WIDTH)
	else:
		print("Editing symbol")


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var global_mouse_pos = get_global_mouse_position()
			if global_rect.has_point(global_mouse_pos) == true:
				report_selected.emit(self)
			
			
func on_symbol_selected(xml_id:int, symbol_id: int) -> void:
	if self.xml_id == xml_id and self.symbol_object.id == symbol_id:
		is_editing = true
		add_symbol_editor_handle() # TODO: 위와 같음 
	else:
		is_editing = false
		
	queue_redraw()


func on_symbol_deselected() -> void:
	is_editing = false
	if editor_handle != null:
		remove_symbol_editor_handle() # TODO: 위와 같음 
	queue_redraw()
	

func add_symbol_editor_handle(): # TODO: 위와 같음 
	editor_handle = symbol_editor_handle.instantiate()
	self.add_child(editor_handle) # 순서 주의! init symbol 뒤에 와야 
	editor_handle.global_position = Vector2.ZERO # rect draw 문제 때문에 현재는 0,0이어야 함..
	var rect_size = global_rect.size
	editor_handle.init_symbol(symbol_object.get_center(), rect_size, symbol_object.degree)
	
	
func remove_symbol_editor_handle(): # TODO: 위와 같음 
	editor_handle.queue_free()
