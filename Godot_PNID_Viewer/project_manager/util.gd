class_name Util

static var timers = {}
static var is_debug: bool = true

static func get_img_path(paths) -> String:
	for path in paths:
		for img_format in Config.ALLOW_IMG_FORMAT:
			if path.contains(img_format): # cannot open jpeg, currently
				return path
			
	return String()
			

static func get_valid_data_paths(paths) -> PackedStringArray:
	var xml_paths = PackedStringArray()
	for path in paths:
		for data_format in Config.ALLOW_DATA_FORMAT:
			if path.contains(data_format): 
				xml_paths.append(path)
			
	return xml_paths
	
	
static func get_all_file_filter() -> String:
	var str = ""
	for img_format in Config.ALLOW_IMG_FORMAT:
		str += "*" + img_format + ", "
	for data_format in Config.ALLOW_DATA_FORMAT:
		str += "*" + data_format + ", "
	
	str = str.left(str.length()-2)
	return str
	
	
static func get_data_file_filter() -> String:
	var str = ""
	for data_format in Config.ALLOW_DATA_FORMAT:
		str += "*" + data_format + ", "
	str = str.left(str.length()-2)
	return str


static func log_start(log_name: String):
	timers[log_name] = Time.get_ticks_msec()
	
	
static func log_end(log_name: String):
	var time = Time.get_ticks_msec() - timers[log_name]
	if is_debug:
		print(log_name, " %d ms" % time)


static func debug_msg(msg):
	if is_debug:
		print(msg)
