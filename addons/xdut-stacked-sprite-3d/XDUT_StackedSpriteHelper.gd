class_name XDUT_StackedSpriteHelper

#-------------------------------------------------------------------------------
#	CONSTANTS
#-------------------------------------------------------------------------------

enum {
	SHADER_TYPE_STANDARD,
	SHADER_TYPE_UNSHADED,
}

enum {
	SAMPLE_MODE_BORDER,
	SAMPLE_MODE_CLAMP,  # 境界値を引き延ばす
	SAMPLE_MODE_REPEAT, # 繰り返す
	SAMPLE_MODE_MIRROR, # ミラー反転する
}

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

static func get_shader(type: int) -> Shader:
	match type:
		SHADER_TYPE_STANDARD:
			return _SHADER_STANDARD
		SHADER_TYPE_UNSHADED:
			return _SHADER_UNSHADED
	return null

static func generate_mesh_array(size: Vector3) -> Array:
	var vertices := PackedVector3Array()
	vertices.resize(_HALVED_VERTICES.size())
	for i: int in _HALVED_VERTICES.size():
		vertices[i] = _HALVED_VERTICES[i] * size

	var mesh_array := []
	mesh_array.resize(Mesh.ARRAY_MAX)
	mesh_array[Mesh.ARRAY_VERTEX] = vertices
	mesh_array[Mesh.ARRAY_NORMAL] = _NORMALS
	mesh_array[Mesh.ARRAY_INDEX] = _INDICES
	return mesh_array

static func generate_normal_texture(
	albedo_texture: Texture2D,
	frames: int,
	max_scan_distance := 1,
	positive_x_sample_mode := SAMPLE_MODE_BORDER,
	negative_x_sample_mode := SAMPLE_MODE_BORDER,
	positive_y_sample_mode := SAMPLE_MODE_BORDER,
	negative_y_sample_mode := SAMPLE_MODE_BORDER,
	positive_z_sample_mode := SAMPLE_MODE_BORDER,
	negative_z_sample_mode := SAMPLE_MODE_BORDER,
	compression_mode := 0) -> Texture2D:

	return _NormalTextureGenerator \
		.new(
			albedo_texture,
			frames,
			max_scan_distance,
			positive_x_sample_mode,
			negative_x_sample_mode,
			positive_y_sample_mode,
			negative_y_sample_mode,
			positive_z_sample_mode,
			negative_z_sample_mode,
			compression_mode) \
		.build()

#-------------------------------------------------------------------------------

const _SHADER_STANDARD: Shader = preload("StackedSprite_Standard.gdshader")
const _SHADER_UNSHADED: Shader = preload("StackedSprite_Unshaded.gdshader")

const _HALVED_VERTICES: PackedVector3Array = [
	#
	Vector3(-0.5, +0.5, +0.5),
	Vector3(+0.5, +0.5, -0.5),
	Vector3(+0.5, +0.5, +0.5),
	Vector3(-0.5, +0.5, -0.5),
	#
	Vector3(-0.5, -0.5, +0.5),
	Vector3(+0.5, -0.5, -0.5),
	Vector3(+0.5, -0.5, +0.5),
	Vector3(-0.5, -0.5, -0.5),
	#
	Vector3(+0.5, +0.5, +0.5),
	Vector3(-0.5, +0.5, -0.5),
	Vector3(+0.5, +0.5, -0.5),
	Vector3(-0.5, +0.5, +0.5),
	#
	Vector3(+0.5, -0.5, +0.5),
	Vector3(-0.5, -0.5, -0.5),
	Vector3(+0.5, -0.5, -0.5),
	Vector3(-0.5, -0.5, +0.5),
	#
	Vector3(+0.5, +0.5, +0.5),
	Vector3(-0.5, -0.5, +0.5),
	Vector3(-0.5, +0.5, +0.5),
	Vector3(+0.5, -0.5, +0.5),
	#
	Vector3(+0.5, +0.5, -0.5),
	Vector3(-0.5, -0.5, -0.5),
	Vector3(-0.5, +0.5, -0.5),
	Vector3(+0.5, -0.5, -0.5),
]
const _NORMALS: PackedVector3Array = [
	#
	Vector3.BACK,
	Vector3.FORWARD,
	Vector3.BACK,
	Vector3.FORWARD,
	#
	Vector3.BACK,
	Vector3.FORWARD,
	Vector3.BACK,
	Vector3.FORWARD,
	#
	Vector3.RIGHT,
	Vector3.LEFT,
	Vector3.RIGHT,
	Vector3.LEFT,
	#
	Vector3.RIGHT,
	Vector3.LEFT,
	Vector3.RIGHT,
	Vector3.LEFT,
	#
	Vector3.UP,
	Vector3.DOWN,
	Vector3.UP,
	Vector3.DOWN,
	#
	Vector3.UP,
	Vector3.DOWN,
	Vector3.UP,
	Vector3.DOWN,
]
const _INDICES: PackedInt32Array = [
	#
	0, 2, 4,
	2, 6, 4,
	#
	1, 3, 5,
	3, 7, 5,
	#
	8, 10, 12,
	10, 14, 12,
	#
	9, 11, 13,
	11, 15, 13,
	#
	16, 18, 20,
	18, 22, 20,
	#
	17, 19, 21,
	19, 23, 21,
]

class _NormalTextureGenerator:

	func build() -> Texture2D:
		var albedo_image := _albedo_texture.get_image()
		if albedo_image.is_compressed():
			albedo_image = Image.load_from_file(_albedo_texture.resource_path)
		var albedo_image_size := albedo_image.get_size()
		if albedo_image_size.x % _frames != 0:
			return null

		_volume_size.x = albedo_image_size.x / _frames
		_volume_size.y = albedo_image_size.y
		_volume_size.z =                       _frames
		_volume.clear()

		for frame: int in _frames:
			var region := Rect2i(
				_volume_size.x * frame,
				0,
				_volume_size.x,
				_volume_size.y)
			_volume.push_back(albedo_image.get_region(region))

		var normal_image_data := PackedByteArray()
		normal_image_data.resize(albedo_image_size.x * albedo_image_size.y * 3)
		for z: int in _volume_size.z:
			var base_z := z * _volume_size.x
			for y: int in _volume_size.y:
				var base_y := y * _volume_size.x * _frames
				for x: int in _volume_size.x:
					var normal := _get_normal(x, y, z)
					var base := (x + base_y + base_z) * 3
					normal_image_data[base + 0] = clampi(normal.x * 255.0, 0, 255)
					normal_image_data[base + 1] = clampi(normal.y * 255.0, 0, 255)
					normal_image_data[base + 2] = clampi(normal.z * 255.0, 0, 255)

		var normal_image := Image.create_from_data(
			albedo_image_size.x,
			albedo_image_size.y,
			false,
			Image.FORMAT_RGB8,
			normal_image_data)
		match _compression_mode:
			1: # ETC
				normal_image.compress(Image.COMPRESS_ETC)
			2: # BPTC
				normal_image.compress(Image.COMPRESS_BPTC)
			3: # ASTC
				normal_image.compress(Image.COMPRESS_ASTC)
		return ImageTexture.create_from_image(normal_image)

	var _albedo_texture: Texture2D
	var _frames: int
	var _max_scan_distance: int
	var _positive_x_sample_mode: int
	var _negative_x_sample_mode: int
	var _positive_y_sample_mode: int
	var _negative_y_sample_mode: int
	var _positive_z_sample_mode: int
	var _negative_z_sample_mode: int
	var _compression_mode: int
	var _volume: Array[Image] = []
	var _volume_size: Vector3i
	var _scan_plane: Array[Vector2i] = []
	var _scan_delta_positive: Array[float] = []
	var _scan_delta_negative: Array[float] = []

	static func _wrap_clamp(x: int, y: int) -> int:
		return clampi(x, 0, y - 1)

	static func _wrap_repeat_positive(x: int, y: int) -> int:
		return x % y

	static func _wrap_repeat_negative(x: int, y: int) -> int:
		return y - 1 + (x + 1) % y

	static func _wrap_mirror_positive(x: int, y: int) -> int:
		var z := y * 2
		x = _wrap_repeat_positive(x, z)
		return x if x < y else z - x - 1

	static func _wrap_mirror_negative(x: int, y: int) -> int:
		var z := y * 2
		x = _wrap_repeat_negative(x, z)
		return x if x < y else z - x - 1

	func _sample_alpha(x: int, y: int, z: int) -> float:
		if x < 0:
			match _positive_x_sample_mode:
				SAMPLE_MODE_BORDER:
					return 0.0
				SAMPLE_MODE_CLAMP:
					x = _wrap_clamp(x, _volume_size.x)
				SAMPLE_MODE_REPEAT:
					x = _wrap_repeat_negative(x, _volume_size.x)
				SAMPLE_MODE_MIRROR:
					x = _wrap_mirror_negative(x, _volume_size.x)
		elif _volume_size.x <= x:
			match _negative_x_sample_mode:
				SAMPLE_MODE_BORDER:
					return 0.0
				SAMPLE_MODE_CLAMP:
					x = _wrap_clamp(x, _volume_size.x)
				SAMPLE_MODE_REPEAT:
					x = _wrap_repeat_positive(x, _volume_size.x)
				SAMPLE_MODE_MIRROR:
					x = _wrap_mirror_positive(x, _volume_size.x)

		if y < 0:
			match _positive_z_sample_mode:
				SAMPLE_MODE_BORDER:
					return 0.0
				SAMPLE_MODE_CLAMP:
					y = _wrap_clamp(y, _volume_size.y)
				SAMPLE_MODE_REPEAT:
					y = _wrap_repeat_negative(y, _volume_size.y)
				SAMPLE_MODE_MIRROR:
					y = _wrap_mirror_negative(y, _volume_size.y)
		elif _volume_size.y <= y:
			match _negative_z_sample_mode:
				SAMPLE_MODE_BORDER:
					return 0.0
				SAMPLE_MODE_CLAMP:
					y = _wrap_clamp(y, _volume_size.y)
				SAMPLE_MODE_REPEAT:
					y = _wrap_repeat_positive(y, _volume_size.y)
				SAMPLE_MODE_MIRROR:
					y = _wrap_mirror_positive(y, _volume_size.y)

		if z < 0:
			match _negative_y_sample_mode:
				SAMPLE_MODE_BORDER:
					return 0.0
				SAMPLE_MODE_CLAMP:
					z = _wrap_clamp(z, _volume_size.z)
				SAMPLE_MODE_REPEAT:
					z = _wrap_repeat_negative(z, _volume_size.z)
				SAMPLE_MODE_MIRROR:
					z = _wrap_mirror_negative(z, _volume_size.z)
		elif _volume_size.z <= z:
			match _positive_y_sample_mode:
				SAMPLE_MODE_BORDER:
					return 0.0
				SAMPLE_MODE_CLAMP:
					z = _wrap_clamp(z, _volume_size.z)
				SAMPLE_MODE_REPEAT:
					z = _wrap_repeat_positive(z, _volume_size.z)
				SAMPLE_MODE_MIRROR:
					z = _wrap_mirror_positive(z, _volume_size.z)

		return _volume[z].get_pixel(x, y).a

	func _sample_alpha_trilinear(address: Vector3) -> float:
		var a0 := address.floor()
		var a1 := a0 + Vector3.ONE
		var v := address - a0
		var w := Vector3.ONE - v
		return \
			w.x * w.y * w.z * _sample_alpha(a0.x, a0.y, a0.z) + \
			v.x * w.y * w.z * _sample_alpha(a1.x, a0.y, a0.z) + \
			w.x * v.y * w.z * _sample_alpha(a0.x, a1.y, a0.z) + \
			v.x * v.y * w.z * _sample_alpha(a1.x, a1.y, a0.z) + \
			w.x * w.y * v.z * _sample_alpha(a0.x, a0.y, a1.z) + \
			v.x * w.y * v.z * _sample_alpha(a1.x, a0.y, a1.z) + \
			w.x * v.y * v.z * _sample_alpha(a0.x, a1.y, a1.z) + \
			v.x * v.y * v.z * _sample_alpha(a1.x, a1.y, a1.z)

	func _get_normal(x: int, y: int, z: int) -> Vector3:
		if not is_zero_approx(_sample_alpha(x, y, z)):
			var center := Vector3(x, y, z)
			var normal := Vector3.ZERO
			var normal_divisor := 0.0

			for plane: Vector2i in _scan_plane:
				# X+
				for delta: float in _scan_delta_positive:
					var offset := Vector3(_max_scan_distance, plane.x, plane.y) * delta
					if is_zero_approx(_sample_alpha_trilinear(center + offset)):
						normal += offset.normalized()
						normal_divisor += 1.0
						break

				# X-
				for delta: float in _scan_delta_negative:
					var offset := Vector3(_max_scan_distance, plane.x, plane.y) * delta
					if is_zero_approx(_sample_alpha_trilinear(center + offset)):
						normal += offset.normalized()
						normal_divisor += 1.0
						break

				# Y+
				for delta: float in _scan_delta_positive:
					var offset := Vector3(plane.y, _max_scan_distance, plane.x) * delta
					if is_zero_approx(_sample_alpha_trilinear(center + offset)):
						normal += offset.normalized()
						normal_divisor += 1.0
						break

				# Y-
				for delta: float in _scan_delta_negative:
					var offset := Vector3(plane.y, _max_scan_distance, plane.x) * delta
					if is_zero_approx(_sample_alpha_trilinear(center + offset)):
						normal += offset.normalized()
						normal_divisor += 1.0
						break

				# Z+
				for delta: float in _scan_delta_positive:
					var offset := Vector3(plane.x, plane.y, _max_scan_distance) * delta
					if is_zero_approx(_sample_alpha_trilinear(center + offset)):
						normal += offset.normalized()
						normal_divisor += 1.0
						break

				# Z-
				for delta: float in _scan_delta_negative:
					var offset := Vector3(plane.x, plane.y, _max_scan_distance) * delta
					if is_zero_approx(_sample_alpha_trilinear(center + offset)):
						normal += offset.normalized()
						normal_divisor += 1.0
						break

			if not is_zero_approx(normal_divisor):
				normal = (normal / normal_divisor).normalized()
				normal = Vector3(-normal.x, normal.z, -normal.y)
				return (normal + Vector3.ONE) / 2.0

		return Vector3(0.5, 0.5, 0.5)

	func _init(
		albedo_texture: Texture2D,
		frames: int,
		max_scan_distance: int,
		positive_x_sample_mode: int,
		negative_x_sample_mode: int,
		positive_y_sample_mode: int,
		negative_y_sample_mode: int,
		positive_z_sample_mode: int,
		negative_z_sample_mode: int,
		compression_mode: int) -> void:

		assert(albedo_texture != null)
		assert(0 < frames)
		assert(0 < max_scan_distance)

		_albedo_texture = albedo_texture
		_frames = frames
		_max_scan_distance = max_scan_distance
		_positive_x_sample_mode = positive_x_sample_mode
		_negative_x_sample_mode = negative_x_sample_mode
		_positive_y_sample_mode = positive_y_sample_mode
		_negative_y_sample_mode = negative_y_sample_mode
		_positive_z_sample_mode = positive_z_sample_mode
		_negative_z_sample_mode = negative_z_sample_mode
		_compression_mode = compression_mode

		for y: int in range(-max_scan_distance, max_scan_distance + 1):
			for x: int in range(-max_scan_distance, max_scan_distance + 1):
				_scan_plane.push_back(Vector2i(x, y))

		for d: int in range(1, max_scan_distance + 1):
			_scan_delta_positive.push_back(d / float(max_scan_distance))

		for d: int in range(-1, -max_scan_distance - 1, -1):
			_scan_delta_negative.push_back(d / float(max_scan_distance))
