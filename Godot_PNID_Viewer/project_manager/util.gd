extends Node

func get_img_path(paths) -> String:
	for path in paths:
		if path.contains(".png"): # cannot open jpeg, currently
			return path
			
	return String()
			

func get_xml_paths(paths) -> PackedStringArray:
	var xml_paths = PackedStringArray()
	for path in paths:
		if path.contains(".xml"): 
			xml_paths.append(path)
			
	return xml_paths
