extends BarTextureButton


func _pressed() -> void:
	Globals.grid.flip_board()
