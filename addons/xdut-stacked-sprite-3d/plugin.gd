@tool
extends EditorPlugin

#-------------------------------------------------------------------------------

func _print(message: String, plugin_name: Variant = null) -> void:
	if OS.has_feature("editor"):
		if plugin_name == null:
			plugin_name = _get_plugin_name()
		print_rich("🧩 [u]", plugin_name, "[/u]: ", message)

func _get_plugin_name() -> String:
	return "XDUT Stacked Sprite 3D"

func _enter_tree() -> void:
	add_custom_type("StackedSprite3D", "MeshInstance3D", preload("StackedSprite3D.gd"), preload("StackedSprite3D.png"))

	_print("Activated.")

func _exit_tree() -> void:
	remove_custom_type("StackedSprite3D")
