extends Spatial

onready var body = $Body
onready var right_arm = $RightArm
onready var left_arm = $LeftArm
onready var head = $Head

var VIBE_IDLE = 1
var VIBE_LOW = 2
var VIBE_HIGH = 3


var vibe = VIBE_HIGH

var _total_time = randi() % 10

var _original_body_translation : Vector3
var _original_head_translation : Vector3

var _favorite_pattern = []

func _ready():
	_original_body_translation = body.translation
	_original_head_translation = head.translation
	for column_idx in range(3):
		var sum = 0
		for n in _favorite_pattern:
			if n != null:
				sum += n
		if sum >= 3:
			var r = randi() % 3
			if r == 2:
				_favorite_pattern.append(null)
			else:
				_favorite_pattern.append(r - 2)
		elif sum <= -3:
			var r = randi() % 3
			if r == 2:
				_favorite_pattern.append(null)
			else:
				_favorite_pattern.append(r)
		else:
			var r = randi() % 4
			if r == 3:
				_favorite_pattern.append(null)
			else:
				_favorite_pattern.append(r - 1)
	print(_favorite_pattern)


func _process(delta):
	_total_time += delta
	body.translation = _original_body_translation
	body.translation.y += sin(_total_time * vibe*4) / (16 / vibe)
	head.translation = _original_head_translation
	head.translation.y += cos(_total_time * vibe*4) / (32 / vibe)
