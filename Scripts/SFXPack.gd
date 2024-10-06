extends Node

class_name SFXPlayer

enum SFXType{
	GAME_OVER, HIGH, LEVEL, SPAWN, CLEAR, GOOD_CLEAR, GREAT_CLEAR
}

@onready var sfx_type_to_objects = {
	SFXType.GAME_OVER : $GameOverSound,
	SFXType.HIGH : $HighScoreSound,
	SFXType.LEVEL : $LevelUpSound,
	SFXType.SPAWN : $SpawnSound,
	SFXType.CLEAR : $ClearSound,
	SFXType.GOOD_CLEAR : $Tier2ClearSound,
	SFXType.GREAT_CLEAR : $Tier3ClearSound
}

func _ready() -> void:
	set_max_volume(Options.max_sfx_volume)

func play_sfx(sfxtype : SFXType):
	#print(sfxtype)
	sfx_type_to_objects[sfxtype].play()

func stop_all():
	for sfx_player in sfx_type_to_objects.values():
		var casted_player = sfx_player as AudioStreamPlayer
		casted_player.stop()

func set_max_volume(percentage_value : float):
	#print(percentage_value)
	var new_volume = min(1.0, percentage_value)
	
	for sfx_player in sfx_type_to_objects.values():
		var casted_player = sfx_player as AudioStreamPlayer
		casted_player.volume_db = linear_to_db(new_volume)
