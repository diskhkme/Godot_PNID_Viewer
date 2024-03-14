# Static symbol display
# draw symbols not in editing state

extends Node2D
class_name StaticSymbol

# signal to symbol scene for filtering selection
signal report_static_selected(obj: StaticSymbol)

@onready var area = $Area2D
@onready var collision = $Area2D/CollisionShape2D
@onready var static_symbol_draw = $StaticSymbolDraw


var xml_id: int
var symbol_object: SymbolObject
var on_cursor: bool = false


func _ready():
	SymbolManager.symbol_selected_from_tree.connect(_hide_symbol)
	SymbolManager.symbol_selected_from_image.connect(_hide_symbol)
	SymbolManager.symbol_deselected.connect(_show_symbol) 
	SymbolManager.symbol_edited.connect(_update_symbol) 
	update_symbol()
	
	
func update_symbol():
	area.global_position = symbol_object.get_center()
	area.scale = symbol_object.get_size()
	area.rotation = deg_to_rad(symbol_object.get_degree())
	
	static_symbol_draw.global_position = symbol_object.get_center()
	static_symbol_draw.rotation = deg_to_rad(symbol_object.get_degree())
	
	var size = symbol_object.get_rect().size
	var color = symbol_object.color
	var width = Config.DEFAULT_LINE_WIDTH
	static_symbol_draw.update_draw(size,color,width, symbol_object.removed)
	

func _input(event):
	if SymbolManager.is_editing:
		return
		
	if symbol_object.removed:
		return
	
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT):
		if event.is_pressed() and on_cursor:
			report_static_selected.emit(self)
			
			
func _on_area_2d_mouse_entered():
	on_cursor = true


func _on_area_2d_mouse_exited():
	on_cursor = false


# --- selected(received)
func _hide_symbol(symbol_object: SymbolObject):
	if self.symbol_object == symbol_object:
		static_symbol_draw.visible = false
	else:
		static_symbol_draw.visible = true
		

func _show_symbol() -> void:
	static_symbol_draw.visible = true


# --- edited(received)
func _update_symbol(symbol_object: SymbolObject):
	if self.symbol_object == symbol_object:
		update_symbol()
	





