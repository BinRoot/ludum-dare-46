extends Spatial

onready var body : MeshInstance = $Body
onready var right_arm : MeshInstance = $RightArm
onready var left_arm : MeshInstance = $LeftArm
onready var head : MeshInstance = $Head
onready var pattern_tween : Tween = $PatternTween
onready var ding : AudioStreamPlayer = $Ding
onready var face : MeshInstance = $Head/Face
onready var chat_panel : Control = $ChatPanel
onready var chat_message : Label = $ChatPanel/ChatMessage
onready var chat_tween : Tween = $ChatTween

var face1_material = preload("res://Materials/Face1.tres")
var face2_material = preload("res://Materials/Face2.tres")
var face3_material = preload("res://Materials/Face3.tres")

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
var _pattern_holder : Panel

var _time_since_aroused = 0

var noise1d
var noise1d_idx = 0

var intents = {
	"yay": [
		"Yay!", "Yes!", "Woohoo!", "YEAA!", "YEA!", "Yea!!!", "Aww yea!",
		"Aww yeaaa!", "LET'S GOOO!", "WOO HOO!", "OHHH YEEAA", "YES",
		"!!!", "Sweet!", "NICE!", "Woah!", "WOOO!"
	],
	"fireworks": [
		"Beautiful!", "I love fireworks!", "Wow! Fireworks!", "Fireworks!",
		"Awesome fireworks!", "The sky is glowing!", "FIREWORKS!"
	],
	"fog": [
		"Fog machine!", "This fog's cool!", "Cool fog!", "Love the mist!",
		"FOG!", "I love fog!"
	],
	"confetti": [
		"So much confetti!", "I love confetti", "CONFETTI!", "It's beautiful!",
		"It's a confetti party!", "CONFETTI PARTY!", "It's like a dream!"
	]
}

func _ready():
	randomize()
	noise1d = OpenSimplexNoise.new()
	noise1d.seed = randi()
	var spatial_material = SpatialMaterial.new()
	spatial_material.albedo_color = Color(randf(), randf(), randf())
	body.set_surface_material(0, spatial_material)
	ding.pitch_scale *= (randf() + 0.1) / 2
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
	_pattern_holder = Panel.new()
	add_child(_pattern_holder)
	for pattern in _favorite_pattern:
		var cr = ColorRect.new()
		cr.rect_min_size = Vector2(PATTERN_SIZE, PATTERN_SIZE)
		add_child(cr)
		_pattern_rects.append(cr)

func pulse_pattern():
	ding.play()
	pattern_tween.interpolate_property(_pattern_holder, "rect_scale",
		Vector2(1, 1), Vector2(1.5, 1.5), 0.2,
		Tween.TRANS_CUBIC, Tween.EASE_OUT)
	pattern_tween.start()
	yield(pattern_tween, "tween_completed")
	pattern_tween.interpolate_property(_pattern_holder, "rect_scale",
		Vector2(1.5, 1.5), Vector2(1, 1), 0.2,
		Tween.TRANS_CUBIC, Tween.EASE_OUT)
	pattern_tween.start()

func pulse_chat(message):
	chat_message.text = message
	chat_panel.visible = true
	var vec2d : Vector2 = get_viewport().get_camera().unproject_position(global_transform.origin)
	chat_panel.rect_position = vec2d
	chat_panel.rect_position -= chat_panel.rect_size / 2
	chat_panel.rect_position.y -= chat_panel.rect_size.y * 3
	chat_tween.interpolate_property(chat_panel, "modulate",
		Color.white, Color.transparent, 2,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	chat_tween.start()
	yield(chat_tween, "tween_completed")
	chat_panel.visible = false

func pulse_chat_yay():
	pulse_chat(intents["yay"][randi() % len(intents["yay"])])

func pulse_chat_fog():
	pulse_chat(intents["fog"][randi() % len(intents["fog"])])
	
func pulse_chat_confetti():
	pulse_chat(intents["confetti"][randi() % len(intents["confetti"])])
	
func pulse_chat_fireworks():
	pulse_chat(intents["fireworks"][randi() % len(intents["fireworks"])])

func arouse():
	_time_since_aroused = 0
	if vibe == VIBE_IDLE:
		vibe = VIBE_LOW
	elif vibe == VIBE_LOW:
		vibe = VIBE_HIGH
	

func handle_pattern(pattern):
	if len(_favorite_pattern) > len(pattern):
		return
	var start = len(pattern) - len(_favorite_pattern)
	var snip = []
	for idx in range(start, start + len(_favorite_pattern)):
		snip.append(pattern[idx])
	if snip == _favorite_pattern:
		arouse()
		pulse_pattern()
		pulse_chat_yay()

func draw_pattern():
	var vec2d : Vector2 = get_viewport().get_camera().unproject_position(global_transform.origin)
	var width = (PATTERN_SIZE + 1) * len(_favorite_pattern)
	vec2d.x -= width / 2
	_pattern_holder.margin_left = vec2d.x  - 1
	_pattern_holder.margin_top = vec2d.y - PATTERN_SIZE - 2
	_pattern_holder.rect_min_size.x = width
	_pattern_holder.rect_min_size.y = width
	_pattern_holder.rect_pivot_offset = _pattern_holder.rect_size / 2
	
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
	_time_since_aroused += delta
	if _time_since_aroused > 10:
		if vibe == VIBE_HIGH:
			vibe = VIBE_LOW
		elif vibe == VIBE_LOW:
			vibe = VIBE_IDLE
		_time_since_aroused = 0
	var noise_sample = noise1d.get_noise_1d(noise1d_idx)
	noise1d_idx += 1
	head.rotation.y = noise_sample * vibe / 2
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
	if vibe == VIBE_IDLE:
		face.set_surface_material(0, face1_material)
	elif vibe == VIBE_LOW:
		face.set_surface_material(0, face2_material)
	else:
		face.set_surface_material(0, face3_material)
	draw_pattern()
	
	
