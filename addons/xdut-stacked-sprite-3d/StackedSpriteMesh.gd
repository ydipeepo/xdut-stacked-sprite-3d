class_name StackedSpriteMesh extends ArrayMesh

#-------------------------------------------------------------------------------
#	PROPERTIES
#-------------------------------------------------------------------------------

## カラーテクスチャの分割数。[br]
## [br]
## 水平方向に分割しスタックします。
@export_range(1, 512)
var frames := 1:
	get:
		return _frames
	set(value):
		if _frames != value:
			_frames = value
			_vertex_dirty = true

## ボリュームのピクセルサイズ。[br]
## [br]
## ボリューム内の各ピクセルはこの大きさになります。
@export_range(0.0001, 128.0, 0.0001, "suffix:m")
var pixel_size := 0.01:
	get:
		return _pixel_size
	set(value):
		if _pixel_size != value:
			_pixel_size = value
			_vertex_dirty = true

## カラーテクスチャ。[br]
## [br]
## このテクスチャは [member texture_slices] で設定した枚数に分割されます。
@export
var albedo_texture: Texture2D = null:
	get:
		return _albedo_texture
	set(value):
		if _albedo_texture != value:
			_albedo_texture = value
			_vertex_dirty = true

## 法線テクスチャ。
@export
var normal_texture: Texture2D = null:
	get:
		return _normal_texture
	set(value):
		if _normal_texture != value:
			_normal_texture = value
			_shader_dirty = true

## カメラのプロジェクションタイプ。
@export_enum(
	"Perspective",
	"Orthogonal",
	"Frustum")
var camera_projection: int = Camera3D.PROJECTION_PERSPECTIVE

@export_group("Material")

## シェーディングを無効にするかどうか。
@export
var unshaded := false:
	get:
		return _unshaded
	set(value):
		if _unshaded != value:
			_unshaded = value
			_shader_dirty = true

## ボリュームの色合い。
@export
var modulate := Color.WHITE

## ボリュームのエミッション。
@export_color_no_alpha
var emission := Color.BLACK

## ボリュームのエミッションテクスチャ。
@export
var emission_texture: Texture2D = null:
	get:
		return _emission_texture
	set(value):
		if _emission_texture != value:
			_emission_texture = value
			_shader_dirty = true

## ボリュームのラフネス。
@export_range(0.0, 1.0)
var roughness := 1.0

## ボリュームのラフネステクスチャ。
@export
var roughness_texture: Texture2D = null:
	get:
		return _roughness_texture
	set(value):
		if _roughness_texture != value:
			_roughness_texture = value
			_shader_dirty = true

## ボリュームのスペキュラ。
@export_range(0.0, 1.0, 0.01)
var specular := 0.5

## ボリュームのスペキュラテクスチャ。
@export
var specular_texture: Texture2D = null:
	get:
		return _specular_texture
	set(value):
		if _specular_texture != value:
			_specular_texture = value
			_shader_dirty = true

## ボリュームのメタルネス。
@export_range(0.0, 1.0, 0.01)
var metallic := 0.0

## ボリュームのメタルネステクスチャ。
@export
var metallic_texture: Texture2D = null:
	get:
		return _metallic_texture
	set(value):
		if _metallic_texture != value:
			_metallic_texture = value
			_shader_dirty = true

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

## ボリュームサイズを取得します。
func get_size() -> Vector3:
	return _size

## ボリュームメッシュを作成します。
func draw() -> void:
	if _vertex_dirty:
		clear_surfaces()

		if _albedo_texture == null or _frames <= 0:
			_size = Vector3.ZERO
			return

		var albedo_texture_size := Vector2(_albedo_texture.get_size())
		_size.x = _pixel_size * albedo_texture_size.x / float(_frames)
		_size.y = _pixel_size *                         float(_frames)
		_size.z = _pixel_size * albedo_texture_size.y

		var mesh_array := XDUT_StackedSpriteHelper.generate_mesh_array(_size)
		add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_array)
		surface_set_material(0, _material)

		_vertex_dirty = false

	if _shader_dirty:
		_material.shader = XDUT_StackedSpriteHelper.get_shader(
			XDUT_StackedSpriteHelper.SHADER_TYPE_STANDARD
			if not _unshaded and is_instance_valid(_normal_texture) else
			XDUT_StackedSpriteHelper.SHADER_TYPE_UNSHADED)

		_shader_dirty = false

	_material.set_shader_parameter("albedo_texture", _albedo_texture)
	_material.set_shader_parameter("frames", _frames)
	_material.set_shader_parameter("is_perspective", camera_projection == Camera3D.PROJECTION_PERSPECTIVE)
	_material.set_shader_parameter("modulate", modulate)

	if not _unshaded and is_instance_valid(_normal_texture):
		_material.set_shader_parameter("normal_texture", _normal_texture)
		_material.set_shader_parameter("emission", emission)
		_material.set_shader_parameter("emission_texture", _emission_texture)
		_material.set_shader_parameter("roughness", roughness)
		_material.set_shader_parameter("roughness_texture", _roughness_texture)
		_material.set_shader_parameter("specular", specular)
		_material.set_shader_parameter("specular_texture", _specular_texture)
		_material.set_shader_parameter("metallic", metallic)
		_material.set_shader_parameter("metallic_texture", _metallic_texture)

#-------------------------------------------------------------------------------

var _material := ShaderMaterial.new()
var _size := Vector3.ZERO
var _vertex_dirty := true
var _shader_dirty := true
var _pixel_size := 0.01
var _unshaded := false
var _albedo_texture: Texture2D = null
var _normal_texture: Texture2D = null
var _emission_texture: Texture2D = null
var _roughness_texture: Texture2D = null
var _specular_texture: Texture2D = null
var _metallic_texture: Texture2D = null
var _frames := 1
