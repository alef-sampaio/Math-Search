extends Control
@onready var coins_counter: Label = $container/coins_container/coins_counter
@onready var timer_counter: Label = $container/timer_container/timer_counter
@onready var score_counter: Label = $container/score_container/score_counter
@onready var life_counter: Label = $container/life_container/life_counter
@onready var clock_timer: Timer = $clock_timer
var minutes = 0
var seconds = 0
@export_range(0,5) var defult_minutes := 1
@export_range(0,59) var defult_seconds := 0

signal time_is_up()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	coins_counter.text = str("%04d" % Globals.coins)
	score_counter.text = str("%06d" % Globals.score)
	life_counter.text = str("%02d" % Globals.player_life)
	timer_counter.text = str("%02d" % defult_minutes) + ":" + str("%02d" % defult_seconds)
	reset_clock_timer()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	coins_counter.text = str("%04d" % Globals.coins)
	score_counter.text = str("%06d" % Globals.score)
	life_counter.text = str("%02d" % Globals.player_life)
	#if minutes == 0 and seconds == 0:
		#emit_signal("time_is_up")


func _on_clock_timer_timeout() -> void:
	if seconds == 0:
		if minutes > 0:
			minutes -= 1
			seconds = 60
	seconds -= 1 
	if minutes == 0 and seconds == 0:
		clock_timer.stop()
		emit_signal("time_is_up")
	timer_counter.text = str("%02d" % minutes) + ":" + str("%02d" % seconds)



func reset_clock_timer():
	minutes = defult_minutes
	seconds = defult_seconds
