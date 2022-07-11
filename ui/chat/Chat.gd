extends Control
class_name Chat

onready var list: MessageList = $v/MessageList

var regexes := [
	[Utils.compile("_([^_]+)_"), "[i]$1[/i]"],
	[Utils.compile("\\*\\*([^\\*\\*]+)\\*\\*"), "[b]$1[/b]"],
	[Utils.compile("\\*([^\\*]+)\\*"), "[i]$1[/i]"],
	[Utils.compile("```([^`]+)```"), "[code]$1[/code]"],
	[Utils.compile("`([^`]+)`"), "[code]$1[/code]"],
	[Utils.compile("~~([^~]+)~~"), "[s]$1[/s]"],
	[Utils.compile("#([^#]+)#"), "[rainbow freq=.3 sat=.7]$1[/rainbow]"],
	[Utils.compile("%([^%]+)%"), "[shake rate=20 level=25]$1[/shake]"],
	[Utils.compile("\\[([^\\]]+)\\]\\(([^\\)]+)\\)"), "[url=$2]$1[/url]"],
	[
		Utils.compile("([-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*))"),
		"[url]$1[/url]"
	],
]


# create smokey centered text
func server(txt: String) -> void:
	list.add_label("[center][i][b][color=#a9a9a9]%s[/color][/b][/i][/center]" % md2bb(txt))


func _init():
	Globals.chat = self


func _exit_tree():
	Globals.chat = null


func _ready():
	PacketHandler.connect("chat", self, "add_label_with")
	server("Welcome!")  # say hello
	yield(get_tree().create_timer(.4), "timeout")
	server("You can use markdown(sort of)!")  # say hello again


func add_label_with(data: Dictionary) -> void:
	var string := "[b]{who}[color=#f0e67e]:[/color][/b] {text}".format(data)
	list.add_label(string)


func send(t: String) -> void:
	t = md2bb(t)
	var name = Creds.get("name") if Creds.get("name") else "Anonymous"
	name += "(%s)" % ("Spectator" if Globals.spectating else Globals.team)
	if PacketHandler.connected:
		PacketHandler.relay_signal({"text": t, "who": name}, PacketHandler.RELAYHEADERS.chat)
	else:
		add_label_with({text = t, who = name})  # for testing


# markdown to bbcode
func md2bb(input: String) -> String:
	for replacement in regexes:
		var result = replacement[0].search(input)
		if result:
			var index = input.find(result.strings[0]) - 1
			var char_before = input[index]
			if not char_before in "\\":  # taboo characters go here
				if replacement[1] == "[url]$1[/url]" and "png" in result.strings[0]:  # url one must avoid recognizing res://
					continue
				input = replacement[0].sub(input, replacement[1], true)
	input = input.replace("\\", "")  # remove escapers
	return input
