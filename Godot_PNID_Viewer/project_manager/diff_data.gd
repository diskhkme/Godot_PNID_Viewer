extends XMLData
class_name DiffData

var source_xml: XMLData
var target_xml: XMLData

func initialize_diff(id: int, filename:String, symbol_objects: Array[SymbolObject], source_xml, target_xml):
	self.id = id
	self.filename = filename
	self.symbol_objects = symbol_objects
	self.symbol_objects.map(func(s): s.source_xml = self) 
	self.source_xml = source_xml
	self.target_xml = target_xml
	
