extends ColorRect

export(PoolColorArray) var colors := [
	Color(0.784314, 0.427451, 0.427451, 1),
	Color(0.913725, 0.847059, 0.403922, 1),
	Color(0.380392, 0.741176, 0.647059, 1),
	Color(0.321569, 0.368627, 0.858824, 1),
	Color(0.843137, 0.133333, 0.133333, 1),
	Color(0.109804, 0.160784, 0.564706, 1),
	Color(0.376471, 0.796078, 0.317647, 1),
	Color(0.8, 0.364706, 0.588235, 1),
	Color(0.984314, 0.858824, 0.282353, 1),
	Color(0.164706, 0.0862745, 0.247059, 1)
]
export(float) var length := 2.8

var tween := Tween.new()
var timer := Timer.new()


static func rand(clr) -> float:
	return clamp(clr + rand_range(0, .1) if randi() % 2 else clr - rand_range(0, .1), 0, 1)


func _ready() -> void:
	randomize()
	add_child(timer)
	add_child(tween)
	timer.connect("timeout", self, "change_color")
	color = colors[randi() % colors.size()]
	change_color()


func change_color() -> void:
	var clr: Color = colors[randi() % colors.size()]
	clr = Color(rand(clr.r), rand(clr.g), rand(clr.b), 1)
	tween.interpolate_property(self, "color", color, clr, length, Tween.TRANS_ELASTIC)
	tween.start()
	timer.start(length)
