extends Control
class_name StaticLabel

@onready var cls_panel = $ClsPanel
@onready var cls_label = $ClsPanel/ClsLabel

var _symbol_object

func update_label(symbol_object: SymbolObject):
	_symbol_object = symbol_object
	var symbol_center = symbol_object.get_center()
	var symbol_size = symbol_object.get_size()
	
	# panel set
	cls_panel.self_modulate = Color(symbol_object.color, Config.SYMBOL_LABEL_PANEL_ALPHA)
	cls_label.text = ""
	cls_label.text += "T:" if symbol_object.is_text else "S:"
	cls_label.text += symbol_object.cls.left(Config.SYMBOL_LABEL_MAX_LENGTH)
	
	visible = symbol_object.source_xml.is_show_label


func _on_cls_panel_resized():
	var symbol_size = _symbol_object.get_size()
	var panel_size = cls_panel.size
	var offset_ratio = Config.SYMBOL_LABEL_OFFSET_RATIO
	
	if _symbol_object.source_xml.id % 4 == 0: # Bottom Left
		var x_anchor = -symbol_size.x*0.5 - panel_size.x * offset_ratio
		var y_anchor = symbol_size.y*0.5
		cls_panel.position = Vector2(x_anchor, y_anchor) 
	elif _symbol_object.source_xml.id % 4 == 1: # Bottom Right
		var x_anchor = symbol_size.x*0.5 - panel_size.x * offset_ratio
		var y_anchor = symbol_size.y*0.5
		cls_panel.position = Vector2(x_anchor, y_anchor) 
	elif _symbol_object.source_xml.id % 4 == 2: # Top Left
		var x_anchor = -symbol_size.x*0.5 - panel_size.x * offset_ratio
		var y_anchor = -symbol_size.y*0.5 - panel_size.y
		cls_panel.position = Vector2(x_anchor, y_anchor) 
	elif _symbol_object.source_xml.id % 4 == 3: # Top Right
		var x_anchor = symbol_size.x*0.5 - panel_size.x * offset_ratio
		var y_anchor = -symbol_size.y*0.5 - panel_size.y
		cls_panel.position = Vector2(x_anchor, y_anchor) 
