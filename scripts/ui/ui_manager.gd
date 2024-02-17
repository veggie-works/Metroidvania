## Manager for all user interfaces
extends Control

## A list of all UI scenes that can be instantiated
@export var ui_scenes: Array[PackedScene] = []

## The UI canvas layer that will hold all child UIs
@onready var ui_layer: CanvasLayer = $ui_layer

## A list of all instantiated UIs
var instantiated_uis: Array[BaseUI] = []

## A list of all instantiated and open UIs
var opened_uis: Array[BaseUI]:
	get:
		return instantiated_uis.filter(func(ui): return ui.visible)

## Close a UI
func close_ui(ui: GDScript) -> void:
	if opened_uis.has(ui):
		opened_uis[opened_uis.find(ui)].close()

## Create a new instance of a UI
func create_ui(ui: GDScript) -> BaseUI:
	var ui_scene = ui_scenes.filter(func(scene):
			var scene_state = scene.get_state()
			for i in range(0, scene_state.get_node_property_count(0)):
				var prop_name = scene_state.get_node_property_name(0, i)
				var prop_value = scene_state.get_node_property_value(0, i)
				if prop_name == "script":
					return prop_value == ui
			return false
	)[0]
	
	if ui_scene == null:
		printerr("UI \"%s\" not found", ui.name)
		return null
	
	var instantiated_ui = ui_scene.instantiate()
	ui_layer.add_child(instantiated_ui)
	instantiated_uis.append(instantiated_ui)
	return instantiated_ui

## Delete a UI from the scene tree
func delete_ui(ui: GDScript) -> void:
	var ui_to_delete: BaseUI = get_ui(ui)
	if ui_to_delete != null:
		ui_to_delete.close()
		ui_layer.remove_child(ui_to_delete)
		ui_to_delete.queue_free()
		
	instantiated_uis.erase(ui_to_delete.name)

## Fetch a UI instance
func get_ui(ui) -> BaseUI:
	if instantiated_uis.has(ui):
		return instantiated_uis[instantiated_uis.find(ui)]
	return null

## Open a UI
func open_ui(ui: GDScript) -> BaseUI:
	var ui_to_open: BaseUI = get_ui(ui)
	if ui_to_open == null:
		ui_to_open = create_ui(ui)
	ui_to_open.open()
	return ui_to_open

## Close all open UIs
func close_all_uis() -> void:
	for ui in opened_uis:
		ui.close()
