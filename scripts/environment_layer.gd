extends TileMapLayer

enum CELL_TYPE {WALL, FLOOR}


var _cell_to_id = {
	CELL_TYPE.WALL : 1,
	CELL_TYPE.FLOOR : 3
}
@warning_ignore("unused_private_class_variable")
var _id_to_cell = Utils.reverse_dict(_cell_to_id)


func is_floor(pos : Vector2i) -> bool:
	return get_cell_source_id(pos) == _cell_to_id[CELL_TYPE.FLOOR]

func is_wall(pos : Vector2i) -> bool:
	return get_cell_source_id(pos) == _cell_to_id[CELL_TYPE.WALL]

func set_floor(pos : Vector2i) -> void:
	set_cell(pos, _cell_to_id[CELL_TYPE.FLOOR], Vector2i(0,0))

func set_wall(pos : Vector2i) -> void:
	set_cell(pos, _cell_to_id[CELL_TYPE.WALL], Vector2i(0,0))
