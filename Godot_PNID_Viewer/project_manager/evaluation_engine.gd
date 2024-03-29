extends Node

signal report_progress(progress: float)

class EvalOptions:
	var filename: String
	var iou_th: float
	var is_compare_string: bool
	var is_compare_degree: bool
	

var num_total
var num_current

func calculate_precision_recall(dt_symbols: Array[SymbolObject], gt_symbols: Array[SymbolObject], options: EvalOptions) -> String:
	var gt_symbols_cpy: Array
	gt_symbols_cpy.resize(gt_symbols.size())
	range(gt_symbols.size()).map(func(i): gt_symbols_cpy[i] = gt_symbols[i].clone())
	
	var result = {}
	gt_symbols_cpy.map(func(d): put_new_symbol_to_result(d, result, true))
			
	var total_num = dt_symbols.size()
			
	var last_emit = Time.get_ticks_msec()
	for i in range(dt_symbols.size()):
		var f = dt_symbols[i]
		var candidate = gt_symbols_cpy.filter(func(s): return check_iou_cond(f, s, options.iou_th))
		
		if candidate.size() == 0: # if no iou cond meet, store f
			put_new_symbol_to_result(f, result, false, true)
			continue
		else: # check remaining condition
			if options.is_compare_string and f.is_text:
				candidate = candidate.filter(func(s): return f.cls == s.cls)
			if options.is_compare_degree:
				candidate = candidate.filter(func(s): return abs(f.degree - s.degree) < Config.DEGREE_MATCH_THRESHOLD)
				
		if candidate.size() == 0: # if no cond meet, store f
			put_new_symbol_to_result(f, result, false, true)
		else: 
			put_new_symbol_to_result(candidate[0], result, false) # only one symbol is considered as corerct
			gt_symbols_cpy.erase(candidate[0])
			for j in range(1, candidate.size()):
				put_new_symbol_to_result(f, result, false, true)
				
		var current_time = Time.get_ticks_msec()
		if current_time - last_emit >= Config.AWAIT_MSEC:
			report_progress.emit(float(i)/total_num)
			await get_tree().process_frame
			last_emit = current_time
			
	return summarize_result(result, options)
	
	
func put_new_symbol_to_result(symbol, result, is_gt, nonmatched = false):
	if not nonmatched:
		if symbol.is_text: 
			if result.has(symbol.type):
				if is_gt: result[symbol.type].y += 1
				else: result[symbol.type].x += 1
			else:
				result[symbol.type] = Vector2i.ZERO # x: num_dt_matched / y: num_gt
				if is_gt: result[symbol.type].y += 1
				else: result[symbol.type].x += 1
		else:
			if result.has(symbol.cls):
				if is_gt: result[symbol.cls].y += 1
				else: result[symbol.cls].x += 1
			else:
				result[symbol.cls] = Vector2i.ZERO
				if is_gt: result[symbol.cls].y += 1
				else: result[symbol.cls].x += 1
	else:
		if symbol.is_text: 
			if result.has("nonmatched_text"):
				result["nonmatched_text"].x += 1
			else:
				result["nonmatched_text"] = Vector2i.ZERO
		else:
			if result.has("nonmatched_symbol"):
				result["nonmatched_symbol"].x += 1
			else:
				result["nonmatched_symbol"] = Vector2i.ZERO
				

func summarize_result(result, options) -> String:
	var sym_tp = 0
	var text_tp = 0
	var sym_tp_plus_fp = 0
	var text_tp_plus_fp = 0
	var sym_fn = 0
	var text_fn = 0
	var str_result = ""
	str_result += "Filename: %s\n" % options.filename
	str_result += "Options: \n"
	str_result += "\tIoU Threshold: %f\n" % options.iou_th
	str_result += "\tIs Compare String: %s\n" % options.is_compare_string
	str_result += "\tIs Compare Degree: %s\n" % options.is_compare_degree
	str_result += "-------------------------------------------------------\n"
	
	var sorted_key = result.keys()
	sorted_key.sort_custom(func(a,b): return a.naturalnocasecmp_to(b) < 0)
	for r in sorted_key:
		if r == "nonmatched_text" or r == "nonmatched_symbol":
			continue
			
		if r == Config.TEXT_TYPE_NAME:
			text_tp += result[r].x
		else:
			sym_tp += result[r].x
			
		if r == Config.TEXT_TYPE_NAME:
			text_tp_plus_fp += result[r].y
		else:
			sym_tp_plus_fp += result[r].y
			
		if r != Config.TEXT_TYPE_NAME:
			str_result += "%s: %d / %d\n" % [r, result[r].x, result[r].y]
		
	str_result += "%s: %d / %d\n" % [Config.TEXT_TYPE_NAME, result[Config.TEXT_TYPE_NAME].x, result[Config.TEXT_TYPE_NAME].y]
	str_result += "%s: %d / %d\n" % ["nonmatched_symbol", result["nonmatched_symbol"].x, result["nonmatched_symbol"].y]
	str_result += "%s: %d / %d\n" % ["nonmatched_text", result["nonmatched_text"].x, result["nonmatched_text"].y]
	
	sym_fn = result["nonmatched_symbol"].x
	text_fn = result["nonmatched_text"].x
		
	var total_tp = sym_tp + text_tp
	var total_tp_plus_fp = sym_tp_plus_fp + text_tp_plus_fp
	var total_fn = sym_fn + text_fn
	str_result += "-------------------------------------------------------\n"
	str_result += "Precition: %f (%d/%d)\n" % [(float(total_tp)/total_tp_plus_fp), total_tp, total_tp_plus_fp]
	str_result += "Recall: %f (%d/%d)\n" % [(float(total_tp)/(total_tp+total_fn)), total_tp, (total_tp+total_fn)]
	str_result += "\tSymbol Precition: %f (%d/%d)\n" % [(float(sym_tp)/sym_tp_plus_fp), sym_tp, sym_tp_plus_fp]
	str_result += "\tSymbol Recall: %f (%d/%d)\n" % [(float(sym_tp)/(sym_tp+sym_fn)), sym_tp, (sym_tp+sym_fn)]
	str_result += "\tText Precition: %f (%d/%d)\n" % [(float(text_tp)/text_tp_plus_fp), text_tp, text_tp_plus_fp]
	str_result += "\tText Recall: %f (%d/%d)\n" % [(float(text_tp)/(text_tp+text_fn)), text_tp, (text_tp+text_fn)]
		
	return str_result
	

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
				candidate = candidate.filter(func(s): return abs(f.degree - s.degree) < Config.DEGREE_MATCH_THRESHOLD)
				
		if candidate.size() == 0: # if no cond meet, store f
			filtered.push_back(f.clone())
		else:
			second_cache.append_array(candidate)
			
		num_current += 1
		var current_time = Time.get_ticks_msec()
		if current_time - last_emit >= Config.AWAIT_MSEC:
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

