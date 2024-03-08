# Note: children should "pass" mouse to detect enter/exit

extends Control

signal poped_up

@export var image_view_camera: ImageViewCamera

@onready var context_menu = $PanelContainer
@onready var add_button = $PanelContainer/VBoxContainer/AddButton
@onready var remove_button = $PanelContainer/VBoxContainer/RemoveButton
@onready var edit_button = $PanelContainer/VBoxContainer/EditButton

var start_mouse_pos
var is_in_parent_canvas
var is_in_context_menu
var context_position_global

var xml_id
var symbol_id

func _ready():
	SymbolManager.symbol_selected_from_image.connect(on_symbol_selected)
	SymbolManager.symbol_deselected.connect(on_symbol_deselected)
	
func _input(event):
	if !is_in_parent_canvas:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if context_menu.visible:
			return
			
		if event.is_pressed():
			start_mouse_pos = event.position
		if event.is_released():
			var dist = (event.position - start_mouse_pos).length_squared()
			if dist < pow(Config.CONTEXT_MENU_THRESHOLD,2):
				context_menu.global_position = event.position
				context_menu.visible = true
				image_view_camera.is_locked = true
				image_view_camera.is_dragging = false
				
	if event is InputEventMouseButton:			
		if event.is_pressed(): 
			if !is_in_context_menu: # cancel context menu
				context_menu.visible = false
				image_view_camera.is_locked = false


func on_symbol_selected(xml_id:int, symbol_id:int):
	self.xml_id = xml_id
	self.symbol_id = symbol_id
	add_button.visible = false
	remove_button.visible = true
	edit_button.visible = true
	context_menu.reset_size()
	

func on_symbol_deselected():
	xml_id = -1
	symbol_id = -1
	add_button.visible = true
	remove_button.visible = false
	edit_button.visible = false
	context_menu.reset_size()


func _on_add_button_pressed():
	# TODO: currently, just add to the first xml
	var xml_stat = ProjectManager.active_project.xml_status[0]
	var new_symbol_id = xml_stat.add_new_symbol(image_view_camera.get_pixel_from_image_canvas(context_menu.global_position))
	SymbolManager.symbol_selected_from_image.emit(0, new_symbol_id)
	context_menu.visible = false
	image_view_camera.is_locked = false


func _on_remove_button_pressed():
	# TODO: if removed, request redraw
	var symbol_object = ProjectManager.get_symbol_in_xml(xml_id, symbol_id)
	var xml_stat = ProjectManager.active_project.xml_status[xml_id]
	xml_stat.remove_symbol(symbol_id)
	SymbolManager.symbol_edit_ended.emit()
	SymbolManager.symbol_deselected.emit()
	context_menu.visible = false
	image_view_camera.is_locked = false


func _on_edit_button_pressed():
	pass # Replace with function body.
	

func _on_mouse_entered():
	is_in_context_menu = true


func _on_mouse_exited():
	is_in_context_menu = false


func _on_image_viewer_mouse_entered():
	is_in_parent_canvas = true
	

func _on_image_viewer_mouse_exited():
	is_in_parent_canvas = false
