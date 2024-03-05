# Static symbol display
# draw symbols not in editing state

extends Node2D
class_name StaticSymbol

# signal to symbol scene for filtering selection
signal report_static_selected(obj: StaticSymbol)

@onready var area = $Area2D
@onready var collision = $Area2D/CollisionShape2D
@onready var static_symbol_draw = $StaticSymbolDraw

@onready var symbol_selection_interface = $SymbolSelectionInterface
@onready var symbol_edit_interface = $SymbolEditInterface

var xml_id: int
var symbol_object: SymbolObject
var on_cursor: bool = false


func _ready():
	symbol_selection_interface.symbol_selected_received.connect(hide_selected)
	symbol_selection_interface.symbol_deselected_received.connect(show_deselected) 
	symbol_edit_interface.symbol_edited_received.connect(update_edited) 
	update_symbol()
	
	
func update_symbol():
	area.global_position = symbol_object.get_center()
	area.scale = symbol_object.get_size()
	area.rotation = deg_to_rad(symbol_object.degree)
	
	static_symbol_draw.global_position = symbol_object.get_center()
	static_symbol_draw.rotation = deg_to_rad(symbol_object.degree)
	
	var size = symbol_object.get_rect().size
	var color = ProjectManager.active_project.xml_status[xml_id].color
	var width = Config.DEFAULT_LINE_WIDTH
	static_symbol_draw.update_draw(size,color,width)
	

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() and on_cursor:
			report_static_selected.emit(self)
			
			
func _on_area_2d_mouse_entered():
	on_cursor = true


func _on_area_2d_mouse_exited():
	on_cursor = false


# --- selected(received)
func hide_selected(xml_id:int, symbol_id: int) -> void:
	if self.xml_id == xml_id and self.symbol_object.id == symbol_id:
		static_symbol_draw.visible = false
	else:
		static_symbol_draw.visible = true
		

func show_deselected() -> void:
	static_symbol_draw.visible = true


# --- edited(received)
func update_edited(xml_id: int, symbol_id: int):
	if self.xml_id == xml_id and self.symbol_object.id == symbol_id:
		update_symbol()
	





