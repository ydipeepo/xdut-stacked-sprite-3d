extends MarginContainer

var _total_time := 0.0

func _process(delta: float) -> void:
	%Pivot.rotate_y(-delta)
	%Orange.rotate_y(delta)
	%Cube1.rotate_x(delta)
	%Cube2.rotate_z(delta)
	%Car1.rotate_y(delta)
	%Car2.rotate_x(-delta)

	_total_time += delta

	%Orange.modulate.a = cos(_total_time) * 0.5 + 0.5
	
	%Car1/Tire1.rotation.y = cos(_total_time * 5.0) * PI / 6.0
	%Car1/Tire2.rotation.y = cos(_total_time * 5.0) * PI / 6.0
	%Car2/Tire1.rotation.y = cos(_total_time * 5.0) * PI / 6.0
	%Car2/Tire2.rotation.y = cos(_total_time * 5.0) * PI / 6.0

func _on_button_projection_toggled(toggled_on: bool) -> void:
	if toggled_on:
		if %Button_Perspective.button_pressed:
			%Camera.projection = Camera3D.PROJECTION_PERSPECTIVE
		if %Button_Orthogonal.button_pressed:
			%Camera.projection = Camera3D.PROJECTION_ORTHOGONAL

@warning_ignore("unused_parameter")
func _on_button_light_toggled(toggled_on: bool) -> void:
	%Light_Directional.visible = %Button_DirectionalLight.button_pressed
	%Light_Spot.visible = %Button_SpotLight.button_pressed

func _on_button_shading_toggled(toggled_on: bool) -> void:
	%Orange.unshaded = not %Button_Shading.button_pressed
	%Cube1.unshaded = not %Button_Shading.button_pressed
	%Cube2.unshaded = not %Button_Shading.button_pressed
	%Car1.unshaded = not %Button_Shading.button_pressed
	%Car1/Tire1.unshaded = not %Button_Shading.button_pressed
	%Car1/Tire2.unshaded = not %Button_Shading.button_pressed
	%Car1/Tire3.unshaded = not %Button_Shading.button_pressed
	%Car1/Tire4.unshaded = not %Button_Shading.button_pressed
	%Car2.unshaded = not %Button_Shading.button_pressed
	%Car2/Tire1.unshaded = not %Button_Shading.button_pressed
	%Car2/Tire2.unshaded = not %Button_Shading.button_pressed
	%Car2/Tire3.unshaded = not %Button_Shading.button_pressed
	%Car2/Tire4.unshaded = not %Button_Shading.button_pressed
