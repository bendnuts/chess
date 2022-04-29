extends Node

var turn_moves := "1. "
var turns_moves = []

var counter = 0


func _ready():
	Events.connect("turn_over", self, "_on_turn_over")


func _on_turn_over():
	counter += 1
	if counter >= 2:
		counter = 0
		print(turn_moves)
		turns_moves.append(turn_moves)
		turn_moves = str(Globals.white_turns + 1) + ". "


func is_pawn(inode):
	return inode is Pawn


func add_move(move):
	turn_moves = turn_moves + " " + move


func calculate_algebraic_position(real_position):
	var algebraic_string = char(65 + (real_position.x)).to_lower()
	algebraic_string += str(8 - real_position.y)
	return algebraic_string


func get_node_name(node):
	if is_pawn(node):
		return ["♙", "p"] if node.white else ["♟", "p"]
	elif node is King:
		return ["♔", "K"] if node.white else ["♚", "K"]
	elif node is Queen:
		return ["♕", "Q"] if node.white else ["♛", "Q"]
	elif node is Rook:
		return ["♖", "R"] if node.white else ["♜", "R"]
	elif node is Bishop:
		return ["♗", "B"] if node.white else ["♝", "B"]
	elif node is Knight:
		return ["♘", "N"] if node.white else ["♞", "N"]
	else:
		return ["", ""]
