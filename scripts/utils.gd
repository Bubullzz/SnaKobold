class_name Utils

static func reverse_dict(dict : Dictionary) -> Dictionary:
	var reversed_dict = {}
	for key in dict.keys():
		reversed_dict[dict[key]] = key
	return reversed_dict