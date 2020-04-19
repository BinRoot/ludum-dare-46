extends Spatial

signal round_ended

onready var alive_meter : ProgressBar = $Control/AliveMeter
onready var time_label : Label = $Control/TimePanel/TimeLabel
onready var round_end_timer : Timer = $RoundEnd
onready var crowd : Spatial = $Crowd
onready var board : Spatial = $Stage/Board
onready var fireworks : Particles = $Fireworks
onready var fog : Particles = $Fog
onready var confetti : Particles = $Confetti
onready var fireworks_audio : AudioStreamPlayer = $FireworksAudio
onready var fog_audio : AudioStreamPlayer = $FogAudio
onready var confetti_audio : AudioStreamPlayer = $ConfettiAudio

var _fog_original_translation : Vector3
var _confetti_original_translation : Vector3
var _fireworks_original_translation : Vector3

onready var person_scene = preload("res://Scenes/Person.tscn")

var _people
var _is_first_frame = true

func _ready():
	_people = get_tree().get_nodes_in_group("person")
	_fog_original_translation = fog.translation
	_confetti_original_translation = confetti.translation
	_fireworks_original_translation = fireworks.translation
	fog.translation = Vector3(100, 100, 100)
	confetti.translation = Vector3(100, 100, 100)
	fireworks.translation = Vector3(100, 100, 100)
	
func init_inventory(item_dict):
	board.item_dict = item_dict

func populate_people(num):
	for i in range(num):
		_people = get_tree().get_nodes_in_group("person")
		var candidate_vecs = []
		var min_penalty = 99999
		var min_penalty_idx = -1
		for ridx in range(50):
			var candidate_vec = Vector3((randf() - 0.5) * 20, 0, (randf() - 0.5) * 3)
			candidate_vecs.append(candidate_vec);
			var penalty = 0
			for p in _people:
				if (candidate_vec + crowd.global_transform.origin).distance_to(p.global_transform.origin) < 1:
					penalty += 1
			if penalty < min_penalty:
				min_penalty = penalty
				min_penalty_idx = ridx
		var person = person_scene.instance()
		crowd.add_child(person)
		person.translation += candidate_vecs[min_penalty_idx]
		
	_people = get_tree().get_nodes_in_group("person")

func _process(delta):
	if _is_first_frame:
		fireworks.restart()
		fog.restart()
		confetti.restart()
	_is_first_frame = false
	if len(_people) > 0:
		var avg_vibe = 0.0
		for person in _people:
			avg_vibe += person.vibe
		avg_vibe /= len(_people)
		alive_meter.value = (avg_vibe / 3.0) * 100
	time_label.text = str(int(round_end_timer.time_left))

func _on_Board_pattern_emitted(pattern):
	get_tree().call_group("person", "handle_pattern", pattern)


func _on_RoundEnd_timeout():
	var cash = pow(alive_meter.value * len(_people), 1.1)
	emit_signal("round_ended", cash, board.item_dict)


func _on_Board_fireworks_emitted():
	fireworks.translation = _fireworks_original_translation
	fireworks.restart()
	fireworks_audio.play()
	for person in _people:
		if randi() % 2 == 0:
			person.arouse()
			person.arouse()


func _on_Board_fog_emitted():
	fog.translation = _fog_original_translation	
	fog.restart()
	fog_audio.play()
	for person in _people:
		if randi() % 3 == 0:
			person.arouse()
	for person in _people:
		if randi() % 3 == 0:
			person.arouse()


func _on_Board_confetti_emitted():
	confetti.translation = _confetti_original_translation
	confetti.restart()
	confetti_audio.play()
	for person in _people:
		if randi() % 3 == 0:
			person.arouse()
			person.arouse()
