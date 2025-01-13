extends Node

enum CELL_TYPE {WALL, FLOOR}

var _cell_to_id = {
    CELL_TYPE.WALL : 1,
    CELL_TYPE.FLOOR : 2
}

@warning_ignore("unused_private_class_variable")
var _id_to_cell = Utils.reverse_dict(_cell_to_id)

func is_wall(pos : Vector2i) -> bool:
    return %WallsLayer.get_cell_source_id(pos) == _cell_to_id[CELL_TYPE.WALL]

func set_floor(pos : Vector2i) -> void:
    %FloorLayer.set_cell(pos, _cell_to_id[CELL_TYPE.FLOOR], Vector2i(0,0))

func set_wall(pos : Vector2i) -> void:
    %WallsLayer.set_cell(pos, _cell_to_id[CELL_TYPE.WALL], Vector2i(0,0))

func remove_wall(pos : Vector2i) -> void:
    %WallsLayer.set_cell(pos, -1)

func update_terrain_cells(cells : Array[Vector2i]) -> void:
    BetterTerrain.update_terrain_cells(%WallsLayer, cells)