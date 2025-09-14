class_name Utils

static func reverse_dict(dict : Dictionary) -> Dictionary:
	var reversed_dict = {}
	for key in dict.keys():
		reversed_dict[dict[key]] = key
	return reversed_dict


static func unit_vec(vec: Vector2i)-> Vector2i:
	return Vector2i(unit(vec.x), unit(vec.y))

static func unit(val: int)-> int:
	if val == 0:
		return 0
	return val / abs(val)
