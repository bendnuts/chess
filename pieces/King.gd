extends Piece
class_name King, "res://assets/pieces/california/wK.png"

var castle_check := true
var can_castle := []


func _ready() -> void:
	Events.connect("just_before_turn_over", self, "just_before_over")


func get_moves(no_enemys := false, check_spots_check := true) -> PoolVector2Array:
	var moves: PoolVector2Array = []
	for i in all_dirs():
		var spot := pos_around(i)
		if is_on_board(spot):
			if no_enemys and at_pos(spot):
				continue
			if check_spots_check and checkcheck(spot):
				continue
			moves.append(spot)
	if castle_check and !Globals.in_check:  # make sure this is only called when clicking
		moves.append_array(castleing())
	return moves


func just_before_over() -> void:  # assign metadata for threefold repetition draw check
	castleing()
	if can_castle.size() > 0:
		for i in can_castle:
			if i[3] == "O-O-O":
				if white:
					Globals.grid.matrix[8].wccl = true
				else:
					Globals.grid.matrix[8].bccl = true
			else:
				if white:
					Globals.grid.matrix[8].wccr = true
				else:
					Globals.grid.matrix[8].bccr = true


func castleing(justcheckrooks := false) -> Array:
	if has_moved:
		return []
	var moves := []
	var rooks := [pos_around(Vector2.RIGHT * 3), pos_around(Vector2.LEFT * 4)]
	var labels = ["Q", "K"]
	var rook_motion := [pos_around(Vector2.RIGHT), pos_around(Vector2.LEFT)]
	var king_moveto_spots := [Vector2.RIGHT, Vector2.LEFT]  # O-O  and O-O-O respectivel
	for i in range(len(rooks)):
		if !is_on_board(rooks[i]):
			continue
		var rook: Piece = at_pos(rooks[i])
		if !rook is Rook:
			continue
		if rook.has_moved:
			continue
		if justcheckrooks:
			moves.append(labels[i])
			continue
		var direction: Vector2 = king_moveto_spots[i]
		var posx2 := pos_around(direction * 2)
		var pos := pos_around(direction)
		if at_pos(posx2) or at_pos(pos) or checkcheck(posx2) or checkcheck(pos):
			continue
		if i == 1:  # 3x check for O-O-O
			var posx3 := pos_around(direction * 3)
			if at_pos(posx3) or checkcheck(posx3):
				continue
		can_castle.append([posx2, rook, rook_motion[i], "O-O-O" if i == 1 else "O-O"])
		moves.append(posx2)
	if justcheckrooks:
		moves.sort()
	return moves


func castle(position: Vector2) -> String:
	var return_string := ""
	if can_castle.size() == 1:
		return_string = can_castle[0][3]
	else:
		for i in can_castle:
			if i[0] == position:
				return_string = i[3]
				break
	can_castle.clear()
	moveto(position, true, false, true)
	return return_string


func can_move() -> bool:  # checks if you can legally move
	castle_check = false
	var can := .can_move()
	castle_check = true
	return can


func get_attacks(check_spots_check := true) -> PoolVector2Array:
	castle_check = false
	var final := .get_attacks(check_spots_check)
	castle_check = true
	return final
