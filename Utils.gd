extends Node

var internet := false  # is internet available


static func compile(src: String) -> RegEx:
	var regex := RegEx.new()
	regex.compile(src)
	return regex


static func str_bool(string: String) -> bool:
	return string.to_lower().strip_edges() in ["true", "1", "on", "yes", "y", ""]


func expand_color(color: String) -> String:
	return "white" if color == "w" else "black"


func get_args() -> Dictionary:
	var arguments := {}
	for argument in OS.get_cmdline_args():
		var key_value = argument.split("=")
		if len(key_value) == 2:
			arguments[key_value[0].lstrip("--")] = key_value[1]
		else:
			arguments[key_value[0].lstrip("--")] = "true"
	return arguments


func _ready() -> void:
	request()  # check internet ok?
	cli()


func cli() -> void:
	var args = get_args()
	if "help" in args or "h" in args:
		print("usage: ./chess%s [-help] [-debug [enabled]] [--host=gamecode | --join=gamecode]" % exec_ext())
		var options = """options:
	--help:             show this help message and exit
	--debug=enabled:    enable/disable debug mode
	--host=game_code:   host a game with the given game code
	--join=game_code:   join a game with the given game code
		"""
		print(options)
		get_tree().quit()  # dont wait
	if "host" in args or "join" in args:
		if !internet:
			printerr("No internet")
			get_tree().quit()
		yield(PacketHandler, "connection_established")
		if "host" in args && args.host:
			print("hosting game: %s" % args.host)
			if PacketHandler.lobby.validate_text(args.host):
				var move_list = Pgn.parse(OS.get_environment("MOVES"), false).moves
				if move_list:
					print("with moves: %s" % move_list)
				PacketHandler.host_game(args.host, true, move_list)
				return
		elif "join" in args && args.join:
			print("joining game: %s" % args.join)
			if PacketHandler.lobby.validate_text(args.join):
				PacketHandler.join_game(args.join)
				return
		PacketHandler.lobby.set_buttons(true)
		printerr("error: invalid game code")
		get_tree().quit()  # dont wait
	# "debug" is handled by Debug.gd


static func exec_ext() -> String:
	if OS.has_feature("Windows"):
		return ".exe"
	elif OS.has_feature("OSX"):
		return ".app/Contents/MacOS/chess"
	elif OS.has_feature("X11"):
		return ".x86_64"
	elif OS.has_feature("web"):
		return ".html"
	return ""


func request() -> int:  # returns err
	var http := HTTPRequest.new()
	add_child(http)
	var httpurl: String = PacketHandler.url.replace("wss://", "http://")
	var error := http.request(httpurl, [], true, HTTPClient.METHOD_GET)
	http.free()
	internet = error == OK
	return error


func walk_dir(path := "res://assets/pieces", only_dir := true, exclude := []) -> PoolStringArray:  # walk the directory, finding the asset packs
	var files := []  # init the files
	var dir := Directory.new()  # init the directory
	if dir.open(path) == OK:  # open the directory
		dir.list_dir_begin(true)  # list the directory
		var file_name := dir.get_next()  # get the next file
		while file_name != "":  # while there is a file
			if only_dir:
				if dir.current_is_dir():  # if the current is a directory
					files.append(file_name)  # add the folder
			else:
				var split = file_name.split(".")
				if split[-1] == "import" and !split[0] in exclude:
					files.append(split[0])  # add the file
			file_name = dir.get_next()  # get the next file
	else:
		Log.err("An error occurred when trying to access the path " + path)  # print the error
	files.sort()  # sort the files
	return PoolStringArray(files)  # return the files


func format_seconds(time: float, use_milliseconds: bool = false) -> String:
	return "%02d:%04.1f" if use_milliseconds else "%02d:%02d" % [time / 60, fmod(time, 60)]


func _notification(what: int) -> void:
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST or what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		Log.debug("Bye!")


static func col_pos(col: String) -> int:
	return "abcdefgh".find(col)


static func row_pos(row: String) -> int:
	return 8 - int(row)


static func from_algebraic(pos: String) -> Vector2:
	return Vector2(col_pos(pos[0]), row_pos(pos[1]))


static func to_str(type: int) -> String:
	return "PNBRQK"[type]


# cant wait for 4.0 dict.merge(dict) :C
static func append_dict(dict: Dictionary, newdict: Dictionary) -> Dictionary:
	for key in newdict:
		dict[key] = newdict[key]
	return dict


static func sort(arr: Array) -> Array:
	arr.sort()
	return arr


static func value_types(arr: Array) -> Array:
	var types = []
	for value in arr:
		types.append(typeof(value))
	types.sort()
	return types


static func dict_cmp(d1: Dictionary, d2: Dictionary) -> bool:
	return (
		len(d1) == len(d2)
		and sort(d1.keys()) == sort(d2.keys())
		and value_types(d1.values()) == value_types(d2.values())
	)
