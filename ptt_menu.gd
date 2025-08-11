extends Node

const PTT_DIR = "res://ptts/"
var dirs : PackedStringArray
var index : int = 0

func _ready() -> void:
	self.dirs = DirAccess.get_directories_at(PTT_DIR)
	update_label()

func _physics_process(_delta: float) -> void:
	var move : int = 0
	if Input.is_action_just_pressed("ui_up"):
		move = -1
	if Input.is_action_just_pressed("ui_down"):
		move = 1
	if move:
		index = posmod(index + move, len(dirs))
		update_label()
	
	if Input.is_action_just_pressed("ui_accept"):
		print(dirs[index])
		get_tree().change_scene_to_file(
			"res://ptts/%s/main.tscn"
				% dirs[index])

func update_label() -> void:
	$Label.text = ''
	for i in range(len(dirs)):
		$Label.text += "[%s] %s" % [
			"x" if index == i else " ",
			dirs[i]
		]
