extends Node2D

class_name GameManager

##The score for this level.
static var score : int = 0

##The number of cleared guys.
static var cleared_guys : int = 0

##The high score for this map.
static var high_score : int= 0

## The 1st level requires you to clear 10 Guys. Each level requires you to clear 5 more guys than the last.
## For each level, the timer ticks faster by 5% (multiplicative).
static var level : int = 0
static var guy_drop_scale_level: int = 3

static var current_level_progress : int = 0
static var level_threshold : int = 10

var game_started = false
			
static var game_over = false

##Modify this value to create chaos. Clamped between 1 and 10.
var guy_spawned_per_guy_click = 2:
	get:
		return guy_spawned_per_guy_click
	set(value):
		guy_spawned_per_guy_click = value
		guy_spawned_per_guy_click = clamp(guy_spawned_per_guy_click, 1, 10)		

const SKIP_BONUS = 10
const LEVEL_RAMP : int = 5
const LEVEL_TIMER_DECAY : float = 0.90

static var spawn_queue = []

@export var map_name = "basic_blocks"

@export var guyspawner_list : Array[GuySpawner]
@onready var hud = $FullInterface
#var hud
@onready var spawn_timer = $AutoSpawnTimer

@onready var game_bgm = $MainBGM

@onready var sfx_player = $SFXPlayer

var score_explosion_scene = preload("res://Scenes/ScoreExplosion.tscn")

enum GameMode{
	TIME_ATTACK=0, STRATEGIC=1, CHILL=2, CRUEL=3
}

static var current_game_mode : GameMode = GameMode.TIME_ATTACK

## These are settings for each mode.
## mode_id: The id that this mode will use to creat the score file specific to this mode.
## no_timer: If set to true, the AutoSpawnTimer will not count down, the timer in the score panel will be hidden, manual spawning will not give points, and the game gives you a Guy instantly after clicking the start button.
## start_timer: The initial time for the timer (in seconds).
## preview_guys: How many guy previews you can see. The rest are hidden.
## strategic_scaling: If set to true, for every 3 levels, the number of guys spawned per click will increase by 1.
## click_penalty: The inital number of guys spawned per click.
## bgm_melody: The main melody of the BGM that mutes on pause.
## bgm_backing: The backing BGM that doesn't stop, even on pause.

static var time_attack_settings_dict = {
	"mode_id": "time_attack",
	"no_timer": false,
	"start_timer": 2.0,
	"preview_guys": 5,
	"strategic_scaling": false,
	"click_penalty": 2,
	"bgm_melody": load("res://Audio/BGM/Move Forward 90bpm Melody Only.mp3"),
	"bgm_backing": load("res://Audio/BGM/Move Forward 90bpm Backing+Percussion.mp3")
}

static var strategic_settings_dict = {
	"mode_id": "strategic",
	"no_timer": true,
	"start_timer": 2.0,
	"preview_guys": 10,
	"strategic_scaling": true,
	"click_penalty": 3,
	"bgm_melody": load("res://Audio/BGM/Ambler 146 Melody Only.mp3"),
	"bgm_backing": load("res://Audio/BGM/Ambler 146 Backing+Percussion.mp3")
}

static var chill_settings_dict = {
	"mode_id": "chill",
	"no_timer": true,
	"start_timer": 2.0,
	"preview_guys": 10,
	"strategic_scaling": false,
	"click_penalty": 3,
	"bgm_melody": load("res://Audio/BGM/Mellowtron 124 Melody.mp3"),
	"bgm_backing": load("res://Audio/BGM/Mellowtron 124 Backing.mp3")	
}

static var cruel_settings_dict = {
	"mode_id": "cruel",
	"no_timer": false,
	"start_timer": 1.0,
	"preview_guys": 3,
	"strategic_scaling": true,
	"click_penalty": 3,
	"bgm_melody": load("res://Audio/BGM/Jaunty Gumption 180 Melody.mp3"),
	"bgm_backing": load("res://Audio/BGM/Jaunty Gumption 180 Backing+Percussion.mp3")	
	
}

static var game_mode_settings_dict = {
	GameMode.TIME_ATTACK: time_attack_settings_dict,
	GameMode.STRATEGIC: strategic_settings_dict,
	GameMode.CHILL: chill_settings_dict,
	GameMode.CRUEL: cruel_settings_dict
}

const DEFAULT_BAG = {
	LittleGuy.BodyParts.BODY: [LittleGuy.LittleGuyBody.CIRCLE,LittleGuy.LittleGuyBody.CIRCLE, LittleGuy.LittleGuyBody.SQUARE, LittleGuy.LittleGuyBody.SQUARE, LittleGuy.LittleGuyBody.TRIANGLE, LittleGuy.LittleGuyBody.TRIANGLE, LittleGuy.LittleGuyBody.HEXAGON, LittleGuy.LittleGuyBody.HEXAGON],
	LittleGuy.BodyParts.EYES: [LittleGuy.LittleGuyEyes.ROUND,LittleGuy.LittleGuyEyes.ROUND,LittleGuy.LittleGuyEyes.GLASSES,LittleGuy.LittleGuyEyes.GLASSES,LittleGuy.LittleGuyEyes.HEART,LittleGuy.LittleGuyEyes.HEART,LittleGuy.LittleGuyEyes.CYCLOPS,LittleGuy.LittleGuyEyes.CYCLOPS],
	LittleGuy.BodyParts.MOUTH: [LittleGuy.LittleGuyMouth.W,LittleGuy.LittleGuyMouth.W,LittleGuy.LittleGuyMouth.LIP,LittleGuy.LittleGuyMouth.LIP,LittleGuy.LittleGuyMouth.MOUSTACHE,LittleGuy.LittleGuyMouth.MOUSTACHE,LittleGuy.LittleGuyMouth.TEETH,LittleGuy.LittleGuyMouth.TEETH],
}

static var parts_bag = {
	LittleGuy.BodyParts.BODY: [LittleGuy.LittleGuyBody.CIRCLE,LittleGuy.LittleGuyBody.CIRCLE, LittleGuy.LittleGuyBody.SQUARE, LittleGuy.LittleGuyBody.SQUARE, LittleGuy.LittleGuyBody.TRIANGLE, LittleGuy.LittleGuyBody.TRIANGLE, LittleGuy.LittleGuyBody.HEXAGON, LittleGuy.LittleGuyBody.HEXAGON],
	LittleGuy.BodyParts.EYES: [LittleGuy.LittleGuyEyes.ROUND,LittleGuy.LittleGuyEyes.ROUND,LittleGuy.LittleGuyEyes.GLASSES,LittleGuy.LittleGuyEyes.GLASSES,LittleGuy.LittleGuyEyes.HEART,LittleGuy.LittleGuyEyes.HEART,LittleGuy.LittleGuyEyes.CYCLOPS,LittleGuy.LittleGuyEyes.CYCLOPS],
	LittleGuy.BodyParts.MOUTH: [LittleGuy.LittleGuyMouth.W,LittleGuy.LittleGuyMouth.W,LittleGuy.LittleGuyMouth.LIP,LittleGuy.LittleGuyMouth.LIP,LittleGuy.LittleGuyMouth.MOUSTACHE,LittleGuy.LittleGuyMouth.MOUSTACHE,LittleGuy.LittleGuyMouth.TEETH,LittleGuy.LittleGuyMouth.TEETH],	
}

func _init():
	
	game_started = false
	game_over = false
	score = 0
	current_level_progress = 0
	level_threshold = 10
	level = 0
	cleared_guys = 0
	guy_spawned_per_guy_click = game_mode_settings_dict[current_game_mode]["click_penalty"]
	
	#hud = $FullInterface
	initialize_queue()
	
	for part in LittleGuy.BodyParts.values():
		refill_bag(part)
	
	#update_next_preview()
	
func _ready() -> void:
	
	update_next_preview()
	high_score = load_high_score(self.map_name)
	hud.high_label.text = str(high_score)
	
	if game_mode_settings_dict[current_game_mode]["no_timer"]:
		spawn_timer.stop()
		hud.spawn_timer_bar.hide()
	else:	
		spawn_timer.wait_time = game_mode_settings_dict[current_game_mode]["start_timer"]
		spawn_timer.start()
		hud.spawn_timer_bar.max_value = spawn_timer.wait_time
		
	hud.set_number_of_next_preview_shown(game_mode_settings_dict[current_game_mode]["preview_guys"])
	hud.set_number_of_next_highlight_shown(guy_spawned_per_guy_click)
	
	game_bgm.stream = game_mode_settings_dict[current_game_mode]["bgm_backing"]
	game_bgm.melody_bgm.stream = game_mode_settings_dict[current_game_mode]["bgm_melody"]
	
	get_tree().paused = true
	
func _process(delta: float) -> void:
	hud.spawn_timer_bar.value = spawn_timer.time_left
	hud.spawn_timer_label.text = ("{time_left}".format({"time_left": spawn_timer.time_left}).pad_decimals(2)) + "s"

func gain_score(guys_cleared : int):
	cleared_guys += guys_cleared
	score += calculate_score(guys_cleared)
	current_level_progress += guys_cleared
	
	while current_level_progress >= level_threshold:
		level_up()
		
	hud.count_label.text = str(cleared_guys)
	hud.score_label.text = str(score)
	hud.level_val.text = str(level)

func level_up():
	current_level_progress -= level_threshold
	level_threshold += LEVEL_RAMP
	level += 1
	spawn_timer.wait_time *= LEVEL_TIMER_DECAY
	hud.spawn_timer_bar.max_value = spawn_timer.wait_time
	
	if game_mode_settings_dict[current_game_mode]["strategic_scaling"] and level % guy_drop_scale_level == 0:
		guy_spawned_per_guy_click += 1
		hud.set_number_of_next_highlight_shown(guy_spawned_per_guy_click)
		
	sfx_player.play_sfx(SFXPlayer.SFXType.LEVEL)

func calculate_score(guys_cleared : int):
	if guys_cleared <= 3:
		sfx_player.play_sfx(SFXPlayer.SFXType.CLEAR)
		return guys_cleared * 50
	elif guys_cleared <= 7:
		sfx_player.play_sfx(SFXPlayer.SFXType.GOOD_CLEAR)
		return guys_cleared * 75
	else:
		sfx_player.play_sfx(SFXPlayer.SFXType.GREAT_CLEAR)
		return guys_cleared	* 100
	
static func grab_part_from_bag(part : LittleGuy.BodyParts):
	#print(parts_bag)
	#Look into the bag of the part we want
	
	#If we check that the bag is empty, we must refill it.
	if parts_bag[part].is_empty():
		refill_bag(part)
		
	parts_bag[part].shuffle()
	return parts_bag[part].pop_front()

static func refill_bag(part : LittleGuy.BodyParts):
	parts_bag[part] = DEFAULT_BAG[part].duplicate()

func initialize_queue():
	for i in 10:
		spawn_queue.append(make_random_guy_from_bag())
	#update_next_preview()
	
func update_next_preview():
	for i in 10:
		var guy_in_preview = hud.next_preview[i] as LittleGuy
		guy_in_preview.clone_guy_data(spawn_queue[i])
		guy_in_preview.update_part_graphics()	

static func make_random_guy_from_bag():
	var guy_data = Dictionary()
	for part in LittleGuy.BodyParts.values():
		guy_data[part] = GameManager.grab_part_from_bag(part)			
		
	return guy_data

func _input(event: InputEvent) -> void:
	#print(get_tree())
	if event.is_action_pressed("debug_spawn_guy"):
		
		if not game_mode_settings_dict[current_game_mode]["no_timer"]:
			var bonus_score = int(float(SKIP_BONUS) * (spawn_timer.time_left / spawn_timer.wait_time))
			#print(bonus_score)
			score += bonus_score
			hud.score_label.text = str(score)
		spawn_guy_at_random_spawner()
		
func spawn_guy_at_random_spawner():
	sfx_player.play_sfx(SFXPlayer.SFXType.SPAWN)
	
	var chosen_spawner = guyspawner_list.pick_random() as GuySpawner
	chosen_spawner.spawn_specific_guy(spawn_queue.pop_front())
	spawn_queue.append(make_random_guy_from_bag())
	update_next_preview()
	
	if not game_mode_settings_dict[current_game_mode]["no_timer"]:
		spawn_timer.start()
	
func _on_guy_spawner_guy_spawned(spawned_guy : LittleGuy) -> void:
	spawned_guy.guy_fell_off.connect(_on_guy_fall_off.bind())
	spawned_guy.guy_clicked.connect(_on_guy_click.bind())
	
func _on_guy_fall_off():
	#print("L + You Fell Off")
	
	game_bgm.stop_all()
	sfx_player.stop_all()
	
	game_over = true
	
	var new_high = false
	if score > high_score:
		
		new_high = true
		high_score = score
		save_high_score()
		
		hud.high_label.text = str(high_score)
		
		sfx_player.play_sfx(SFXPlayer.SFXType.HIGH)
	else:
		sfx_player.play_sfx(SFXPlayer.SFXType.GAME_OVER)
	get_tree().paused = true
	hud.show_game_over(new_high)
	
func _on_guy_click(guys_count: int):
	gain_score(guys_count)
	var new_score_ex = score_explosion_scene.instantiate()
	new_score_ex.position = get_global_mouse_position()
	new_score_ex.guy_count = guys_count
	
	
	add_child(new_score_ex)
	new_score_ex.set_score_text()
	
	for i in guy_spawned_per_guy_click:
		spawn_guy_at_random_spawner()

	
func _on_timer_timeout() -> void:	
	spawn_guy_at_random_spawner() # Replace with function body.

func save_high_score():
	var score_save_path = "user://{map_name}_{gamemode}_hs.save".format({"map_name":self.map_name, "gamemode": current_game_mode})
	var save_file = FileAccess.open(score_save_path, FileAccess.WRITE)
	var node_data = {"high_score": high_score}
	var json_string = JSON.stringify(node_data)
	save_file.store_line(json_string)

static func load_high_score(map_name : String):
	var score_save_path = "user://{map_name}_{gamemode}_hs.save".format({"map_name":map_name, "gamemode": current_game_mode})
	
	if not FileAccess.file_exists(score_save_path):
		return 0 # Error! We don't have a save to load.
		
	var save_file = FileAccess.open(score_save_path, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object.
		var node_data = json.data
		return node_data["high_score"]

func _on_full_interface_game_start() -> void:
	game_started = true
	get_tree().paused = false
	game_bgm.play_all()
	
	if game_mode_settings_dict[current_game_mode]["no_timer"]:
		spawn_guy_at_random_spawner()

func _on_full_interface_toggle_pause() -> void:
	if game_started and not game_over:
		var pause_status = get_tree().paused
		var new_pause_status = not pause_status
		hud.pause_panel.visible = new_pause_status
		
		var lin_value = 1
		if new_pause_status:
			lin_value = 0
		
		
		
		game_bgm.set_melody_vol(lin_value)
		
		get_tree().paused = new_pause_status
		
		
		
