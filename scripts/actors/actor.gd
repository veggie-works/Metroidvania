## Base class for all actors, e.g players, enemies, NPCs
extends CharacterBody2D
class_name Actor

func _process(_delta: float) -> void:
	move_and_slide()
