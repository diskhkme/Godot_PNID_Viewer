class_name Util

static var timers = {}
static var is_debug: bool = true

static func get_img_path(paths) -> String:
	for path in paths:
		if path.contains(".png"): # cannot open jpeg, currently
			return path
			
	return String()
			

static func get_xml_paths(paths) -> PackedStringArray:
	var xml_paths = PackedStringArray()
	for path in paths:
		if path.contains(".xml"): 
			xml_paths.append(path)
			
	return xml_paths


static func log_start(log_name: String):
	timers[log_name] = Time.get_ticks_msec()
	
	
static func log_end(log_name: String):
	var time = Time.get_ticks_msec() - timers[log_name]
	if is_debug:
		print(log_name, " %d ms" % time)


static func debug_msg(msg):
	if is_debug:
		print(msg)
