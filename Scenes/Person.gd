extends Spatial

onready var body : MeshInstance = $Body
onready var right_arm : MeshInstance = $RightArm
onready var left_arm : MeshInstance = $LeftArm
onready var head : MeshInstance = $Head

var PATTERN_SIZE = 10

var VIBE_IDLE = 1
var VIBE_LOW = 2
var VIBE_HIGH = 3

var vibe = VIBE_IDLE

var _total_time = randi() % 10

var _original_body_translation : Vector3
var _original_head_translation : Vector3
var _original_left_arm_translation : Vector3
var _original_right_arm_translation : Vector3

var _favorite_pattern = []
var _pattern_rects = []

func _ready():
	_original_body_translation = body.translation
	_original_head_translation = head.translation
	_original_left_arm_translation = left_arm.translation
	_original_right_arm_translation = right_arm.translation
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
	for pattern in _favorite_pattern:
		var cr = ColorRect.new()
		cr.rect_min_size = Vector2(PATTERN_SIZE, PATTERN_SIZE)
		add_child(cr)
		_pattern_rects.append(cr)

func handle_pattern(pattern):
	if len(_favorite_pattern) > len(pattern):
		return
	var start = len(pattern) - len(_favorite_pattern)
	var snip = []
	for idx in range(start, start + len(_favorite_pattern)):
		snip.append(pattern[idx])
	if snip == _favorite_pattern:
		if vibe == VIBE_IDLE:
			vibe = VIBE_LOW
		elif vibe == VIBE_LOW:
			vibe = VIBE_HIGH

func draw_pattern():
	var vec2d : Vector2 = get_viewport().get_camera().unproject_position(global_transform.origin)
	vec2d.x -= (PATTERN_SIZE * len(_favorite_pattern)) / 2
	for i in range(len(_favorite_pattern)):
		var pattern = _favorite_pattern[i]
		var cr : ColorRect = _pattern_rects[i]
		cr.rect_position = vec2d
		cr.rect_position.x += i * (cr.rect_min_size.x + 1)
		if pattern == null:
			cr.color = Color.gray
		else:
			cr.color = Color.red
		if pattern == 1:
			cr.rect_position.y += cr.rect_min_size.y + 1
		elif pattern == -1:
			cr.rect_position.y -= cr.rect_min_size.y + 1
		

func _process(delta):
	_total_time += delta
	body.translation = _original_body_translation
	body.translation.y += sin(_total_time * vibe*4) / (16 / vibe)
	head.translation = _original_head_translation
	head.translation.y += cos(_total_time * vibe*4) / (32 / vibe)
	left_arm.translation = _original_left_arm_translation
	left_arm.rotation_degrees = Vector3(-vibe*10, vibe*10, 0)
	left_arm.translation.y += vibe * 0.3 + sin(_total_time * vibe) / 16
	right_arm.translation = _original_right_arm_translation
	right_arm.rotation_degrees = Vector3(-vibe*10, -vibe*10, 0)
	right_arm.translation.y += vibe * 0.3 + sin(_total_time * vibe) / 16
	draw_pattern()
	
	
