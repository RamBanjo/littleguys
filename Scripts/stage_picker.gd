extends PanelContainer

@export var stage_name : String = "default_stage"
@export var stage_preview_texture : CompressedTexture2D
@export var stage_id : String = "beebo"
@export var stage_scene_path : String

@onready var stage_name_label = $VBoxContainer/StageName
@onready var high_score_label = $VBoxContainer/Highscore
@onready var stage_preview = $VBoxContainer/StagePreview

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	stage_name_label.text = stage_name
	stage_preview.texture = stage_preview_texture
	
	update_highscore_label()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_enter_button_pressed() -> void:
	get_tree().change_scene_to_file(stage_scene_path)

func update_highscore_label():
	var hsdict = {"high": GameManager.load_high_score(stage_id)}
	high_score_label.text = "BEST: {high}".format(hsdict)
