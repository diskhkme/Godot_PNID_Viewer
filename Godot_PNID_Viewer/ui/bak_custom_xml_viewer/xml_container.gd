extends VBoxContainer
class_name XMLContainer

@export var symbol_view_control = preload("res://ui/symbol_view_control.tscn")

var xml_stat

func initialize(xml_stat: XML_Status):
	self.xml_stat = xml_stat
	
	# add title label
	var title_label = Label.new()
	title_label.text = xml_stat.filename
	self.add_child(title_label)
	
	# add symbol controls
	var prev
	for symbol_object in xml_stat.symbol_objects:
		var symbol_view_control_instance = symbol_view_control.instantiate() as SymbolViewControl
		self.add_child(symbol_view_control_instance)
		symbol_view_control_instance.initialize(xml_stat.id, symbol_object, xml_stat.symbol_type_set.keys(), xml_stat.symbol_cls_set.keys())
		
		if prev == null:
			prev = symbol_view_control_instance
		else:
			symbol_view_control_instance.focus_previous = symbol_view_control_instance.get_path_to(prev)
			prev.focus_next = prev.get_path_to(symbol_view_control_instance)
			
		prev = symbol_view_control_instance
