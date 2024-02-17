## Manages the saving and loading of game data
extends Node

## Name of the file containing the save data, suffixed with a profile ID
const save_file_name: String = "data"

## The path to the file containing global game settings
const settings_path: String = "user://settings.tres"

## The current settings instance
var settings: Settings = Settings.new()

## The currently loaded save game data
var save_data: Dictionary

## The ID of the selected profile
var selected_profile_id: int = 0

func _init() -> void:
	settings = load_settings()

## Load game data and settings from disk
func load_game(profile_id: int = 0) -> void:
	selected_profile_id = profile_id
	save_data = load_game_data()

## Load game data from disk
func load_game_data() -> Dictionary:
	var save_path = "user://%s%d.json" % [save_file_name, selected_profile_id]
	if not FileAccess.file_exists(save_path):
		print("No save data found, creating new save")
		return {}
		
	var save_file = FileAccess.open(save_path, FileAccess.READ)
	var save_json = JSON.new()
	if save_json.parse(save_file.get_as_text()) != OK:
		printerr("Error parsing save data")
		return {}	

	return save_json.data
	
## Load settings from disk
func load_settings() -> Settings:
	if not ResourceLoader.exists(settings_path):
		return Settings.new()
		
	return ResourceLoader.load(settings_path)

## Save game data and settings to disk
func save_game() -> void:
	save_game_data()
	save_settings()

## Save game data to disk
func save_game_data() -> void:
	var save_path = "user://%s%d.json" % [save_file_name, selected_profile_id]
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("save")
	for save_node in save_nodes:
		if not save_node.has_method("save"):
			continue
		var node_data = save_node.call("save")
		var json_string = JSON.stringify(node_data)
		save_file.store_line(json_string)
	save_file.close()
	
## Save settings to disk
func save_settings() -> void:
	ResourceSaver.save(settings, settings_path)

func _on_tree_exiting() -> void:
	save_game()
