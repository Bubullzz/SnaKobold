extends TileMapLayer


# Shows a visual when snake can jump
func manage_eyes(pos, is_jumping, atlas_coor, atlas_transform):
    var sprite_id = 2 if is_jumping else 1
    if SnakeProps.juice >= SnakeProps.jump_price:
        set_cell(pos, sprite_id, atlas_coor, atlas_transform)
    else:
        set_cell(pos, -1) # If not enoough juice then clear
    


func update(pos, is_jumping, atlas_coor, atlas_transform):
    manage_eyes(pos, is_jumping, atlas_coor, atlas_transform)


func clear_additional_visuals():
    clear()