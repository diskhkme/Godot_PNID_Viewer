extends Node2D
class_name SymbolBBox

signal report_selected

@export var symbol_editor_handle: PackedScene
@export var line_width = 3.0

@onready var collision = $Area2D

var xml_id
var symbol_id
var x
var y
var width
var height
var degree
var color

var global_rect: Rect2 # for mouse picking
var is_editing: bool = false
var editor_handle

func _ready():
	global_rect = Rect2(x,y,width,height)
	
	global_position = get_center_point(x,y,width,height)
	global_rotation_degrees = degree
	
	SymbolManager.symbol_selected_from_tree.connect(on_symbol_selected) # TODO
	SymbolManager.symbol_deselected.connect(on_symbol_deselected) 
	

func _draw():
	if !is_editing:
		draw_rect(Rect2(-width/2,-height/2,width,height), color, false, line_width)
	else:
		print("Editing symbol")


func get_center_point(x,y,w,h) -> Vector2:
	return Vector2(x+w/2,y+h/2)


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var global_mouse_pos = get_global_mouse_position()
			if global_rect.has_point(global_mouse_pos) == true:
				report_selected.emit(global_mouse_pos, self)
			
			
func on_symbol_selected(xml_id:int, symbol_id: int) -> void:
	if self.xml_id == xml_id and self.symbol_id == symbol_id:
		is_editing = true
		add_symbol_editor_handle()
		queue_redraw()


func on_symbol_deselected() -> void:
	is_editing = false
	if editor_handle != null:
		remove_symbol_editor_handle()
	queue_redraw()
	

func add_symbol_editor_handle():
	editor_handle = symbol_editor_handle.instantiate()
	self.add_child(editor_handle) # 순서 주의! init symbol 뒤에 와야 
	editor_handle.global_position = Vector2.ZERO # rect draw 문제 때문에 현재는 0,0이어야 함..
	editor_handle.init_symbol(Vector2(x+width/2,y+height/2), Vector2(width, height), degree)
	
	
func remove_symbol_editor_handle():
	editor_handle.queue_free()
