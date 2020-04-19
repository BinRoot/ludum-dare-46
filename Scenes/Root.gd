extends Node

onready var current_venue
onready var control = $Control
onready var cash_label = $Control/HBoxContainer/VBoxContainer/Panel/Cash

onready var fog_owned_label = $Control/HBoxContainer/VBoxContainer/HBoxContainer/FogOwned
onready var confetti_owned_label = $Control/HBoxContainer/VBoxContainer/HBoxContainer2/ConfettiOwned
onready var fireworks_owned_label = $Control/HBoxContainer/VBoxContainer/HBoxContainer3/FireworksOwned
onready var fog_price_label = $Control/HBoxContainer/VBoxContainer/HBoxContainer/FogPrice
onready var confetti_price_label = $Control/HBoxContainer/VBoxContainer/HBoxContainer2/ConfettiPrice
onready var fireworks_price_label = $Control/HBoxContainer/VBoxContainer/HBoxContainer3/FireworksPrice
onready var title : Label = $Control/Title
onready var winnings_label : Label = $Control/WinningsPanel/Winnings
onready var winnings_tween : Tween = $WinningsTween
onready var play_button : Button = $Control/PlayButton
onready var warning_label : Label = $Control/Warning
onready var cash_audio : AudioStreamPlayer = $CashAudio
onready var melody_audio : AudioStreamPlayer = $Theme
onready var win_label : Label = $Control/WinLabel

#var venue_scene = preload("res://Scenes/Venue.tscn")
var path = "res://Scenes/Venue.tscn"
var loader
var time_max = 20 # msec

var PRICE_FOG = 100
var PRICE_CONFETTI = 500
var PRICE_FIREWORKS = 1000

var total_cash = 0
var previous_performance = 1
var item_dict = {
	"fireworks": 0,
	"confetti": 0,
	"fog": 0
}

func set_new_scene(scene_resource):
	current_venue = scene_resource.instance()
	add_child(current_venue)
	current_venue.populate_people(pow(previous_performance, 2) + 3)
	current_venue.init_inventory(item_dict)
	current_venue.connect("round_ended", self, "_on_Venue_round_ended")
	warning_label.visible = false
	$Control/HBoxContainer.visible = true
	control.visible = false

func _process(delta):
	update_cash()
	update_items()
	$Control/HBoxContainer.visible = total_cash > 0
	$Control/Subtitle.visible = total_cash == 0
	if loader != null: 
		$Control/HBoxContainer.visible = false
		play_button.visible = false
		var t = OS.get_ticks_msec()
		while OS.get_ticks_msec() < t + time_max:
			var err = loader.poll()
			if err == ERR_FILE_EOF: # load finished
				var resource = loader.get_resource()
				loader = null
				set_new_scene(resource)
				break
			elif err == OK:
				pass
				#update_progress()
			else: # error during loading
				print('loader error')
				#show_error()
				loader = null
				break
	else:
		play_button.visible = true
	

func _ready():
	control.visible = true
	var winnings_panel = winnings_label.get_parent()
	winnings_panel.rect_pivot_offset = winnings_panel.rect_size / 2

func update_items():
	var num_fog_owned = 0
	if 'fog' in item_dict:
		num_fog_owned = item_dict['fog']
	fog_owned_label.text = "  {0} owned".format([num_fog_owned])
	var num_confetti_owned = 0
	if 'confetti' in item_dict:
		num_confetti_owned = item_dict['confetti']
	confetti_owned_label.text = "  {0} owned".format([num_confetti_owned])
	var num_fireworks_owned = 0
	if 'fireworks' in item_dict:
		num_fireworks_owned = item_dict['fireworks']
	fireworks_owned_label.text = "  {0} owned".format([num_fireworks_owned])
	fog_price_label.text = "${0}".format([PRICE_FOG])
	confetti_price_label.text = "${0}".format([PRICE_CONFETTI])
	fireworks_price_label.text = "${0}".format([PRICE_FIREWORKS])

func update_cash():
	cash_label.text = "Cash: ${0}".format([int(total_cash)])

func _on_Venue_round_ended(cash, _item_dict):
	current_venue.queue_free()
	control.visible = true
	melody_audio.play()
	total_cash += cash
	win_label.visible = true
	win_label.text = ""
	if previous_performance == 3:
		win_label.text = "You've WON! But the party NEVER stops!"
		
	if cash > 1000:
		previous_performance = 3
		if win_label.text == "":
			win_label.text = "Ready for the BIG event?"
	elif cash > 300:
		previous_performance = 2
		if win_label.text == "":
			win_label.text = "Your music is going viral!"
	else:
		previous_performance = 1
		if win_label.text == "":
			win_label.text = "Tough crowd! Try again!"
	item_dict = _item_dict
	winnings_label.text = "+ ${0}".format([int(cash)])
	winnings_label.get_parent().visible = true
	cash_audio.play()
	winnings_tween.interpolate_property(winnings_label.get_parent(), "rect_scale",
		Vector2(1, 1), Vector2(1.05, 1.05), 1,
		Tween.TRANS_CIRC, Tween.EASE_IN)
	$Control/HBoxContainer.modulate = Color.transparent
	play_button.modulate = Color.transparent
	winnings_tween.start()
	yield(winnings_tween, "tween_completed")
	winnings_tween.interpolate_property(winnings_label.get_parent(), "rect_scale",
		Vector2(1.1, 1.1), Vector2(0.5, 0.5), 0.4,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	winnings_tween.start()
	yield(winnings_tween, "tween_completed")
	winnings_label.get_parent().rect_scale = Vector2(1, 1)
	winnings_label.get_parent().visible = false
	winnings_tween.interpolate_property($Control/HBoxContainer, "modulate",
		Color.transparent, Color.white, 0.1,
		Tween.TRANS_CUBIC, Tween.EASE_IN)
	winnings_tween.start()
	yield(winnings_tween, "tween_completed")
	winnings_tween.interpolate_property(play_button, "modulate",
		Color.transparent, Color.white, 2,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	winnings_tween.start()

func _on_Button_pressed():
	launch_venue()


func launch_venue():
	melody_audio.stop()
	warning_label.visible = true
	$Control/HBoxContainer.visible = false
	loader = ResourceLoader.load_interactive(path)
	if loader == null: # check for errors
		print('something went wrong')
	


func _on_BuyFog_pressed():
	if total_cash >= PRICE_FOG:
		total_cash -= PRICE_FOG
		if not ('fog' in item_dict):
			item_dict['fog'] = 0
		item_dict['fog'] += 1


func _on_BuyConfetti_pressed():
	if total_cash >= PRICE_CONFETTI:
		total_cash -= PRICE_CONFETTI
		if not ('confetti' in item_dict):
			item_dict['confetti'] = 0
		item_dict['confetti'] += 1


func _on_BuyFireworks_pressed():
	if total_cash >= PRICE_FIREWORKS:
		total_cash -= PRICE_FIREWORKS
		if not ('fireworks' in item_dict):
			item_dict['fireworks'] = 0
		item_dict['fireworks'] += 1
