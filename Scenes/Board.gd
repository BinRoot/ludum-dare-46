extends Spatial

onready var timer = $Timer
onready var column_timer = $ColumnTimer
onready var confetti_button = $ConfettiButton
onready var fireworks_button = $FireworksButton
onready var fog_button = $FogButton
onready var boom_timer : Timer = $BoomTimer
onready var boom_audio : AudioStreamPlayer = $BoomAudio

var current_column = 0

signal pattern_emitted
signal fireworks_emitted
signal fog_emitted
signal confetti_emitted

var pattern_raw = []
var item_dict = {}

var light_on_material = preload("res://Materials/LightOn.tres")
var light_material = preload("res://Materials/Light.tres")

func _ready():
	var audio_players = get_tree().get_nodes_in_group("audio")
	var random_factor = 0.5 #(randf() / 5) + 0.9
	for audio_player in audio_players:
		audio_player.pitch_scale *= random_factor

func enable_buttons():
	if 'fog' in item_dict and item_dict['fog'] > 0:
		enable_fog()
	else:
		disable_fog()
	if 'fireworks' in item_dict and item_dict['fireworks'] > 0:
		enable_fireworks()
	else:
		disable_fireworks()
	if 'confetti' in item_dict and item_dict['confetti'] > 0:
		enable_confetti()
	else:
		disable_confetti()

func enable_confetti():
	confetti_button.visible = true
	
func disable_confetti():
	confetti_button.visible = false
	
func enable_fireworks():
	fireworks_button.visible = true
	
func disable_fireworks():
	fireworks_button.visible = false
	
func enable_fog():
	fog_button.visible = true

func disable_fog():
	fog_button.visible = false

func _process(delta):
	enable_buttons()


func _on_Button_flipped_on(row, col):
	for i in range(3):
		if i + 1 != row:
			get_node("Flat/Button_r{0}_c{1}".format([i + 1, col])).flip_off()


func _on_Timer_timeout():
	column_timer.start()

func fix_pattern(pattern_raw):
	var pattern_fixed = []
	for p in pattern_raw:
		if p == null:
			pattern_fixed.append(null)
		else:
			pattern_fixed.append(p - 1)
	return pattern_fixed

# TODO: deprecated
func compute_deltas(pattern_raw):
	var pattern_deltas = []
	var prev_pattern = null
	for p in pattern_raw:
		if p == null:
			pattern_deltas.append(null)
		elif prev_pattern == null:
			pattern_deltas.append(0)
		else:
			pattern_deltas.append(p - prev_pattern)
		prev_pattern = p
	return pattern_deltas

func _on_ColumnTimer_timeout():
	current_column += 1
	var last_column = 5
	if current_column > last_column:
		var light : MeshInstance = get_node("Flat/light_c{0}".format([last_column]))
		light.set_surface_material(0, light_material)
		column_timer.stop()
		current_column = 0
		pattern_raw = []
		timer.start()
	else:
		for column_idx in range(5):
			var light : MeshInstance = get_node("Flat/light_c{0}".format([column_idx + 1]))
			if column_idx + 1 == current_column:
				light.set_surface_material(0, light_on_material)
			else:
				light.set_surface_material(0, light_material)
		var prev_pattern = 0
		var pattern_len = len(pattern_raw)
		for row_idx in range(3):
			var button = get_node("Flat/Button_r{0}_c{1}".format([row_idx + 1, current_column]))
			if button.is_on:
				pattern_raw.append(row_idx)
				for child in button.get_children():
					if child is AudioStreamPlayer:
						child.play()
				break
		if len(pattern_raw) <= pattern_len:
			pattern_raw.append(null)
		var pattern_deltas = fix_pattern(pattern_raw)
		emit_signal("pattern_emitted", pattern_deltas)
		
		


func _on_FireworksButton_flipped_on():
	if 'fireworks' in item_dict and item_dict['fireworks'] > 0:
		emit_signal("fireworks_emitted")
		item_dict['fireworks'] -= 1


func _on_ConfettiButton_flipped_on():
	if 'confetti' in item_dict and item_dict['confetti'] > 0:
		emit_signal("confetti_emitted")
		item_dict['confetti'] -= 1


func _on_FogButton_flipped_on():
	if 'fog' in item_dict and item_dict['fog'] > 0:
		emit_signal("fog_emitted")
		item_dict['fog'] -= 1


func _on_BoomTimer_timeout():
	boom_audio.play()
	if boom_audio.pitch_scale < 0.5:
		boom_audio.pitch_scale = 1
	elif boom_audio.pitch_scale > 2:
		boom_audio.pitch_scale = 1
	boom_audio.pitch_scale *= (randf()/2) + 0.75
