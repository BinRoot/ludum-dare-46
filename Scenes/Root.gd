extends Node

onready var current_venue
onready var control = $Control
onready var cash_label = $Control/Cash
onready var venue_scene = preload("res://Scenes/Venue.tscn")

var total_cash = 0
var previous_performance = 1
var item_dict = {
	"fireworks": 1
}

func _ready():
	control.visible = true


#func _process(delta):
#	pass


func _on_Venue_round_ended(cash):
	current_venue.queue_free()
	control.visible = true
	total_cash += cash
	cash_label.text = "${0}".format([int(total_cash)])
	if cash > 1000:
		previous_performance = 3
	elif cash > 500:
		previous_performance = 2
	else:
		previous_performance = 1

func _on_Button_pressed():
	launch_venue()


func launch_venue():
	control.visible = false
	current_venue = venue_scene.instance()
	add_child(current_venue)
	current_venue.populate_people(pow(previous_performance, 2) + 5)
	current_venue.init_inventory(item_dict)
	current_venue.connect("round_ended", self, "_on_Venue_round_ended")
	
