extends AudioStreamPlayer

@onready var melody_bgm = $MelodyBGM


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.volume_db = linear_to_db(Options.max_bgm_volume)
	melody_bgm.volume_db = linear_to_db(Options.max_bgm_volume)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_all():
	self.play()
	melody_bgm.play()

func stop_all():
	self.stop()
	melody_bgm.stop()
	
func set_melody_vol(linear_value : float):
	#print({"oldvol": db_to_linear(melody_bgm.volume_db), "newvol": linear_value})
	var new_vol = min(linear_value, Options.max_bgm_volume)
	melody_bgm.set_volume_db(linear_to_db(new_vol))
