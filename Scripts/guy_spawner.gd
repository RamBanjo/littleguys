extends StaticBody2D

class_name GuySpawner

var little_guy_scene = preload("res://Scenes/LittleGuy.tscn")
@onready var spawn = $Spawnpoint

signal guy_spawned

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
#
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("debug_spawn_guy"):
		#spawn_random_guy()

func spawn_specific_guy(guy_data):
	#Instantiate a new little guy
	var new_guy = little_guy_scene.instantiate() as LittleGuy
	
	#Set the position to the spawn point
	new_guy.global_position = spawn.global_position
	
	#Set the guy's properties from GuyData
	new_guy.clone_guy_data(guy_data)	
		
	#Finally, spawn the new guy
	var base_scene = get_tree().get_root().get_child(0)
	
	#Don't forget to update the sprite and setup the collider!
	base_scene.add_child(new_guy)
	
	new_guy.setup_collider()
	new_guy.update_part_graphics()
	
	guy_spawned.emit(new_guy)
	return new_guy
#func spawn_random_guy():
	##Instantiate a new little guy
	#var new_guy = little_guy_scene.instantiate() as LittleGuy
	#
	##Set the position to the spawn point
	#new_guy.global_position = spawn.global_position
	#
	##Pick a random part for every available part
	#for part in LittleGuy.BodyParts.values():
		#new_guy.my_parts[part] = GameManager.grab_part_from_bag(part)
		##print(new_guy.my_parts[part])
	#
	##print(new_guy.my_parts)
	#
	##Finally, spawn the new guy
	#var base_scene = get_tree().get_root().get_child(0)
	#
	##Don't forget to update the sprite and setup the collider!
	#base_scene.add_child(new_guy)
	#
	#new_guy.setup_collider()
	#new_guy.update_part_graphics()
	#
	#guy_spawned.emit(new_guy)
