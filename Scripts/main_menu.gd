extends Node2D

##For when you want to export to the web. I'm thinking Web Export might break if I change resolution.
@export var skip_screen_options : bool = false

@onready var guy_spawner : GuySpawner = $GuySpawner
@onready var guy_timer : Timer = $AutoSpawnTimer

@onready var main_menu_canvas = $MainMenuCanvas
@onready var tutorial_canvas = $TutorialCanvas
@onready var tutorial_canvas_2 = $TutorialCanvas2
@onready var level_picker_canvas = $LevelPickerCanvas
@onready var options_canvas = $OptionsCanvas
@onready var credits_canvas = $CreditsCanvas

@onready var bgm_slider = $OptionsCanvas/BGMSlider
@onready var sfx_slider = $OptionsCanvas/SFXSlider
@onready var resolution_list = $OptionsCanvas/ResList
@onready var resolution_button = $OptionsCanvas/ConfirmResolutionButton
@onready var full_screen_button = $OptionsCanvas/FullScreenToggleButton

@onready var bgm_object = $AudioStreamPlayer
@onready var sfx_player = $SFXPlayer

static var preset_res = {
	0: Vector2(800, 450),
	1: Vector2(1280, 720),
	2: Vector2(1600, 900),
	3: Vector2(1920, 1080)
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_settings()
	bgm_object.play()
	
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initialize_settings():
	var config = ConfigFile.new()
	var err = config.load("user://options.cfg")
	
	if err != OK:
		
		config.set_value("option", "bgm", 1)
		config.set_value("option", "sfx", 1)
		
		if not skip_screen_options:
			config.set_value("option", "res", Vector2(1600, 900))
			config.set_value("option", "fullscreen", false)
		
		config.save("user://options.cfg")
		#Default Settings
	
	Options.max_bgm_volume = config.get_value("option", "bgm")
	Options.max_sfx_volume = config.get_value("option", "sfx")
	
	if not skip_screen_options:
		Options.resolution = config.get_value("option", "res")
		Options.fullscreen = config.get_value("option", "fullscreen")
	
	bgm_object.volume_db = linear_to_db(Options.max_bgm_volume)
	sfx_player.set_max_volume(Options.max_sfx_volume)
	
	bgm_slider.value = Options.max_bgm_volume * bgm_slider.max_value
	sfx_slider.value = Options.max_sfx_volume * sfx_slider.max_value
	
	if not skip_screen_options:
		set_resolution(Options.resolution)
		
		if Options.fullscreen:
			get_tree().root.mode = Window.MODE_FULLSCREEN
		
		resolution_button.disabled = Options.fullscreen
	
func _on_play_button_pressed() -> void:
	main_menu_canvas.hide()
	level_picker_canvas.show()
	toggle_background_guy_fountain(false)

func _on_tutorial_button_pressed() -> void:
	main_menu_canvas.hide()
	tutorial_canvas.show()
	toggle_background_guy_fountain(false)

func _on_options_button_pressed() -> void:
	main_menu_canvas.hide()
	options_canvas.show()
	toggle_background_guy_fountain(false)

func _on_credits_button_pressed() -> void:
	main_menu_canvas.hide()
	credits_canvas.show()
	toggle_background_guy_fountain(false)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_tutorial_back_button_pressed() -> void:
	tutorial_canvas_2.hide()
	tutorial_canvas.show()
	pass # Replace with function body.

func _on_tutorial_next_button_pressed() -> void:
	tutorial_canvas.hide()
	tutorial_canvas_2.show()
	pass

func _on_close_tutorial_button_pressed() -> void:
	tutorial_canvas.hide()
	main_menu_canvas.show()
	toggle_background_guy_fountain(true)

func _on_close_tutorial_button_2_pressed() -> void:
	tutorial_canvas_2.hide()
	main_menu_canvas.show()
	toggle_background_guy_fountain(true)

func _on_close_level_picker_button_pressed() -> void:
	level_picker_canvas.hide()
	main_menu_canvas.show()
	toggle_background_guy_fountain(true)

func _on_close_options_button_pressed() -> void:
	options_canvas.hide()
	main_menu_canvas.show()
	toggle_background_guy_fountain(true)

func _on_close_credit_button_pressed() -> void:
	credits_canvas.hide()
	main_menu_canvas.show()
	toggle_background_guy_fountain(true)



#func make_guy_from_game_manager():
	#var guy_data = Dictionary()
	#for part in LittleGuy.BodyParts.values():
		#guy_data[part] = GameManager.grab_part_from_bag(part)			
		#
	#return guy_data

func toggle_background_guy_fountain(enable: bool):
	
	if enable:
		
		for stage_object in get_tree().get_nodes_in_group("stage_object"):
			stage_object.show()
		
		guy_timer.start()
		
	else:

		for stage_object in get_tree().get_nodes_in_group("stage_object"):
			stage_object.hide()

		for little_guy in get_tree().get_nodes_in_group("little_guy"):
			little_guy.queue_free()
			
		guy_timer.stop()
		
			
		pass

func _on_auto_spawn_timer_timeout() -> void:
	var guy_spawned = guy_spawner.spawn_specific_guy(GameManager.make_random_guy_from_bag())
	guy_spawned.input_pickable = false

func _on_confirm_resolution_button_pressed() -> void:
	var new_res = preset_res[resolution_list.get_selected_items()[0]]
	set_resolution(new_res)
	save_current_settings()

func set_resolution(new_res: Vector2):
	Options.resolution = new_res
	get_tree().root.size = new_res

func _on_full_screen_toggle_button_pressed() -> void:
	
	if Options.fullscreen:
		get_tree().root.mode = Window.MODE_WINDOWED
		Options.fullscreen = false
	else:
		get_tree().root.mode = Window.MODE_FULLSCREEN
		Options.fullscreen = true
		
	resolution_button.disabled = Options.fullscreen
	
	save_current_settings()

func _on_bgm_slider_drag_ended(value_changed: bool) -> void:
	bgm_slider.set_focus_mode(Control.FOCUS_NONE)
	
	Options.max_bgm_volume = bgm_slider.value / bgm_slider.max_value
	
	bgm_object.volume_db = linear_to_db(Options.max_bgm_volume)
	
	save_current_settings()
	
func _on_sfx_slider_drag_ended(value_changed: bool) -> void:
	sfx_slider.set_focus_mode(Control.FOCUS_NONE)

	Options.max_sfx_volume = sfx_slider.value / sfx_slider.max_value
	
	sfx_player.set_max_volume(Options.max_sfx_volume)
	sfx_player.play_sfx(SFXPlayer.SFXType.GREAT_CLEAR)
	
	save_current_settings()

func save_current_settings():
	var config = ConfigFile.new()
	
	config.set_value("option", "bgm", Options.max_bgm_volume)
	config.set_value("option", "sfx", Options.max_sfx_volume)
	config.set_value("option", "res", Options.resolution)
	config.set_value("option", "fullscreen", Options.fullscreen)
	
	config.save("user://options.cfg")
