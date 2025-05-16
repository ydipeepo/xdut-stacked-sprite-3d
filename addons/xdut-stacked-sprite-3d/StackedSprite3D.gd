@tool
class_name StackedSprite3D extends GeometryInstance3D

#-------------------------------------------------------------------------------
#	PROPERTIES
#-------------------------------------------------------------------------------

## カラーテクスチャの分割数。[br]
## [br]
## 水平方向に分割しスタックします。
@export_range(1, 512)
var frames := 1:
	get:
		return _mesh.frames
	set(value):
		if _mesh.frames != value:
			_mesh.frames = value
			_mesh_dirty = true

## ボリュームのピクセルサイズ。[br]
## [br]
## ボリューム内の各ピクセルはこの大きさになります。
@export_range(0.0001, 128.0, 0.0001, "suffix:m")
var pixel_size: float = 0.01:
	get:
		return _mesh.pixel_size
	set(value):
		if _mesh.pixel_size != value:
			_mesh.pixel_size = value
			_mesh_dirty = true

## カラーテクスチャ。[br]
## [br]
## このテクスチャは [member texture_slices] で設定した枚数に分割されます。
@export
var albedo_texture: Texture2D = null:
	get:
		return _mesh.albedo_texture
	set(value):
		if _mesh.albedo_texture != value:
			_mesh.albedo_texture = value
			_mesh_dirty = true

## 法線テクスチャ。
@export
var normal_texture: Texture2D = null:
	get:
		return _mesh.normal_texture
	set(value):
		if _mesh.normal_texture != value:
			_mesh.normal_texture = value
			_mesh_dirty = true

@export_group("Material")

## シェーディングを無効にするかどうか。
@export
var unshaded := false:
	get:
		return _mesh.unshaded
	set(value):
		if _mesh.unshaded != value:
			_mesh.unshaded = value
			_mesh_dirty = true

## ボリュームの色合い。
@export
var modulate := Color.WHITE:
	get:
		return _mesh.modulate
	set(value):
		if _mesh.modulate != value:
			_mesh.modulate = value
			_mesh_dirty = true

## ボリュームのエミッション。
@export_color_no_alpha
var emission := Color.BLACK:
	get:
		return _mesh.emission
	set(value):
		if _mesh.emission != value:
			_mesh.emission = value
			_mesh_dirty = true

## ボリュームのエミッションテクスチャ。
@export
var emission_texture: Texture2D = null:
	get:
		return _mesh.emission_texture
	set(value):
		if _mesh.emission_texture != value:
			_mesh.emission_texture = value
			_mesh_dirty = true

## ボリュームのラフネス。
@export_range(0.0, 1.0)
var roughness := 1.0:
	get:
		return _mesh.roughness
	set(value):
		if _mesh.roughness != value:
			_mesh.roughness = value
			_mesh_dirty = true

## ボリュームのラフネステクスチャ。
@export
var roughness_texture: Texture2D = null:
	get:
		return _mesh.roughness_texture
	set(value):
		if _mesh.roughness_texture != value:
			_mesh.roughness_texture = value
			_mesh_dirty = true

## ボリュームのスペキュラ。
@export_range(0.0, 1.0, 0.01)
var specular := 0.5:
	get:
		return _mesh.specular
	set(value):
		if _mesh.specular != value:
			_mesh.specular = value
			_mesh_dirty = true

## ボリュームのスペキュラテクスチャ。
@export
var specular_texture: Texture2D = null:
	get:
		return _mesh.specular_texture
	set(value):
		if _mesh.specular_texture != value:
			_mesh.specular_texture = value
			_mesh_dirty = true

## ボリュームのメタルネス。
@export_range(0.0, 1.0, 0.01)
var metallic := 0.0:
	get:
		return _mesh.metallic
	set(value):
		if _mesh.metallic != value:
			_mesh.metallic = value
			_mesh_dirty = true

## ボリュームのメタルネステクスチャ。
@export
var metallic_texture: Texture2D = null:
	get:
		return _mesh.metallic_texture
	set(value):
		if _mesh.metallic_texture != value:
			_mesh.metallic_texture = value
			_mesh_dirty = true

@export_group("Collision")

## 手前に挿入するかどうか。
@export
var insert_before := false

@export_tool_button("Add shape node", "CollisionShape3D")
var add_collision_shape_button := add_collision_shape

@export_group("Normal Texture")

## カラーテクスチャから法線テクスチャを自動生成する際の最大スキャン距離。[br]
## [br]
## ピクセル単位です。法線テクスチャを自動生成する際に使用されます。
@export_range(1, 10, 1, "suffix:px")
var max_scan_distance := 2

## カラーテクスチャから法線テクスチャを自動生成する際の圧縮モード。
@export_enum(
	"None",
	"ETC",
	"BPTC",
	"ASTC")
var compression_mode := 0

## カラーテクスチャから法線テクスチャを自動生成する際の +X 方向のサンプリングモード。
@export_enum(
	"Border",
	"Clamp",
	"Repeat",
	"Mirror")
var positive_x_sample_mode := 0

## カラーテクスチャから法線テクスチャを自動生成する際の -X 方向のサンプリングモード。
@export_enum(
	"Border",
	"Clamp",
	"Repeat",
	"Mirror")
var negative_x_sample_mode := 0

## カラーテクスチャから法線テクスチャを自動生成する際の +Y 方向のサンプリングモード。
@export_enum(
	"Border",
	"Clamp",
	"Repeat",
	"Mirror")
var positive_y_sample_mode := 0

## カラーテクスチャから法線テクスチャを自動生成する際の -Y 方向のサンプリングモード。
@export_enum(
	"Border",
	"Clamp",
	"Repeat",
	"Mirror")
var negative_y_sample_mode := 0

## カラーテクスチャから法線テクスチャを自動生成する際の +Z 方向のサンプリングモード。
@export_enum(
	"Border",
	"Clamp",
	"Repeat",
	"Mirror")
var positive_z_sample_mode := 0

## カラーテクスチャから法線テクスチャを自動生成する際の -Z 方向のサンプリングモード。
@export_enum(
	"Border",
	"Clamp",
	"Repeat",
	"Mirror")
var negative_z_sample_mode := 0

@export_tool_button("Generate normal texture", "Texture2D")
var generate_normal_texture_button := generate_normal_texture

#-------------------------------------------------------------------------------
#	METHODS
#-------------------------------------------------------------------------------

## メッシュサイズを取得します。
func get_size() -> Vector3:
	return _mesh.get_size()

## コリジョンシェイプを追加します。
func add_collision_shape() -> void:
	var size := _mesh.get_size()
	if size.is_zero_approx():
		printerr("The 'albedo_texture' must be set first.")
		return

	var tree := get_tree()
	if tree == null:
		printerr("Invalid node state.")
		return

	var collision_shape_name := name
	if collision_shape_name.is_empty():
		collision_shape_name = "StackedSprite3D"

	var collision_shape := CollisionShape3D.new()
	collision_shape.name = "%s_Collision" % collision_shape_name
	collision_shape.shape = BoxShape3D.new()
	collision_shape.shape.size = size
	collision_shape.transform = transform
	
	if insert_before:
		var parent := get_parent()
		if parent == null:
			printerr("Invalid node state.")
			return
		add_sibling(collision_shape)
		parent.move_child(collision_shape, collision_shape.get_index() - 1)
	else:
		add_sibling(collision_shape)
	collision_shape.owner = tree.edited_scene_root

## 法線テクスチャを生成します。
func generate_normal_texture() -> void:
	if _mesh.albedo_texture == null:
		printerr("The 'albedo_texture' must be set first.")
		return

	normal_texture = XDUT_StackedSpriteHelper.generate_normal_texture(
		_mesh.albedo_texture,
		_mesh.frames,
		max_scan_distance,
		positive_x_sample_mode,
		negative_x_sample_mode,
		positive_y_sample_mode,
		negative_y_sample_mode,
		positive_z_sample_mode,
		negative_z_sample_mode,
		compression_mode)

#-------------------------------------------------------------------------------

var _mesh := StackedSpriteMesh.new()
var _mesh_dirty := true

func _get_aabb() -> AABB:
	return _mesh.get_aabb()

func _init() -> void:
	set_base(_mesh.get_rid())

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	var camera_projection: int = \
		Camera3D.PROJECTION_PERSPECTIVE \
		if camera == null else \
		camera.projection
	if _mesh.camera_projection != camera_projection:
		_mesh.camera_projection = camera_projection
		_mesh_dirty = true

	if _mesh_dirty:
		_mesh.draw()
		_mesh_dirty = false

		#set_base(_mesh.get_rid())
		#update_gizmos()
