extends Node
# TODO: rotated bbox iou calculation

signal report_progress(progress: float)

enum DIRECTION {TWO, ONE,}

var num_total
var num_current

func calculate_diff(first: Array[SymbolObject], second: Array[SymbolObject], options: Variant) -> Array[SymbolObject]:
	var direction: DIRECTION = options[0]
	var iou_th: float = options[1]
	var include_symbol: bool = options[2]
	var include_text: bool = options[3]
	var compare_string: bool = options[4]
	var compare_degree: bool = options[5]
	
	# remove not included
	first = filter_by_type(first, include_symbol, include_text)
	second = filter_by_type(second, include_symbol, include_text)
	
	if direction == DIRECTION.ONE:
		num_total = first.size()
	else:
		num_total = first.size() + second.size()
	num_current = 0

	Util.log_start("diff calc")
	# Note: Diff xml has reference for original symbols	
	var diffs: Array[SymbolObject] = []
	var ret = await filter_by_iou_string_degree(first, second, iou_th, compare_string, compare_degree)
	diffs.append_array(ret[0])
	second = second.filter(func(s): return not ret[1].has(s))
	first = first.filter(func(f): return not diffs.has(f))
	
	if direction == DIRECTION.TWO:
		var second_filtered = await filter_by_iou_string_degree(second, first, iou_th, compare_string, compare_degree)
		diffs.append_array(second_filtered[0])
	Util.log_end("diff calc")

	return diffs


func filter_by_type(symbol_array: Array[SymbolObject], include_symbol: bool, include_text: bool):
	if !include_symbol:
		symbol_array = symbol_array.filter(func(a): return !a.is_text)
	if !include_text:
		symbol_array = symbol_array.filter(func(a): return a.is_text)
	return symbol_array
	

func filter_by_iou_string_degree(first, second, iou_th, compare_string, compare_degree):
	var filtered = []
	var second_cache = []
	var last_emit = Time.get_ticks_msec()
	for i in range(first.size()):
		var progress = num_current/float(num_total)
		
		var f = first[i]
		var candidate = second.filter(func(s): return check_iou_cond(f, s, iou_th))
		
		if candidate.size() == 0: # if no iou cond meet, store f
			filtered.push_back(f.clone())
			continue
		else: # check remaining condition
			if compare_string and f.is_text:
				candidate = candidate.filter(func(s): return f.cls == s.cls)
			if compare_degree:
				# TODO: parameterize degree threshold?
				candidate = candidate.filter(func(s): return abs(f.degree - s.degree) < 4)
				
		if candidate.size() == 0: # if no cond meet, store f
			filtered.push_back(f.clone())
		else:
			second_cache.append_array(candidate)
			
		num_current += 1
		var current_time = Time.get_ticks_msec()
		if current_time - last_emit >= 100:
			report_progress.emit(progress)
			await get_tree().process_frame
			last_emit = current_time
			
	return [filtered, second_cache]


func check_iou_cond(a: SymbolObject, b: SymbolObject, iou_th:float) -> bool:
	return iou_calc(a.get_rotated_bndbox(), b.get_rotated_bndbox()) > iou_th
	

func iou_calc(box1: Vector4, box2: Vector4):
	var x_inter_min = max(box1[0], box2[0])
	var y_inter_min = max(box1[1], box2[1])
	var x_inter_max = min(box1[2], box2[2])
	var y_inter_max = min(box1[3], box2[3])

	var inter_width = max(0, x_inter_max - x_inter_min)
	var inter_height = max(0, y_inter_max - y_inter_min)

	var intersection_area = inter_width * inter_height

	var box1_area = (box1[2] - box1[0]) * (box1[3] - box1[1])
	var box2_area = (box2[2] - box2[0]) * (box2[3] - box2[1])

	var union_area = box1_area + box2_area - intersection_area

	var iou = intersection_area / union_area if union_area != 0 else 0

	return iou
