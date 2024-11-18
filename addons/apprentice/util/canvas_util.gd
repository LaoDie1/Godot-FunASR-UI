#============================================================
#    Canvas Util
#============================================================
# - author: zhangxuetu
# - datetime: 2023-03-12 18:05:05
# - version: 4.x
#============================================================
class_name CanvasUtil


## 让节点旋转到目标点
##[br]
##[br][code]node[/code]  设置旋转的目标
##[br][code]from[/code]  开始位置
##[br][code]to[/code]  旋转到位置
##[br][code]offset[/code]  旋转偏移位置
static func rotate_to(node: Node2D, from: Vector2, to: Vector2, offset: float = 0.0) -> void:
	node.global_rotation = to.angle_to_point(from) + offset


## 获取节点显示的图像的缩放大小
static func get_canvas_scale(node: CanvasItem) -> Vector2:
	return Vector2(get_canvas_size(node)) * node.scale


## 获取节点显示的图像的大小
static func get_canvas_size(node: CanvasItem) -> Vector2i:
	var texture := get_node_texture(node) as Texture2D
	if texture:
		var image = texture.get_image() as Image
		return image.get_size()
	return Vector2i(0, 0)


## 获取两个节点的大小差异
static func get_canvas_scale_diff(node_a: Node2D, node_b: Node2D) -> Vector2:
	var scale_a = CanvasUtil.get_canvas_scale(node_a)
	var scale_b = CanvasUtil.get_canvas_scale(node_b)
	return scale_a / scale_b


##  根据 [AnimatedSprite2D] 当前的 frame 创建一个 [Sprite2D]
##[br]
##[br][code]animation_sprite[/code]  [AnimatedSprite2D] 类型的节点
##[br][code]return[/code]  返回一个 [Sprite2D] 节点
static func create_sprite_by_animated_sprite_current_frame(animation_sprite: AnimatedSprite2D) -> Sprite2D:
	var anim = animation_sprite.animation
	var idx = animation_sprite.frame
	var texture = animation_sprite.sprite_frames.get_frame_texture(anim, idx)  
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.global_position = animation_sprite.global_position
	sprite.offset = animation_sprite.offset
	return sprite


## 获取 [SpriteFrames] 的动画的播放时长
##[br]
##[br][code]animations[/code]  动画名
static func get_sprite_frames_anim_time(sprite_frames: SpriteFrames, animation: StringName) -> float:
	if sprite_frames:
		var count = sprite_frames.get_frame_count(animation)
		var speed = 1.0 / sprite_frames.get_animation_speed(animation)
		return speed * count
	return 0.0


##  更新动画时间。每个动画帧的 fps 时长
##[br]
##[br][code]frames[/code]  动画资源
##[br][code]animation[/code]  动画名
##[br][code]total_time[/code]  总播放时间
static func update_frames_time(
	frames: SpriteFrames, 
	animation: StringName, 
	total_time: float
) -> Error:
	if frames.has_animation(animation):
		var frame_count = frames.get_frame_count(animation)
		var fps = frame_count / total_time
		frames.set_animation_speed(animation, fps)
		return OK
	else:
		push_error("没有这个动画")
		return ERR_DOES_NOT_EXIST


## 设置 AnimatedSprite2D 节点的动画播放速度。根据这个节点的动画帧和设置的持续时间，设置播放速度
static func update_animated_speed_scale(animated_sprite: AnimatedSprite2D, anim_name: StringName, time: float) -> Error:
	var sprite_frames = animated_sprite.sprite_frames as SpriteFrames
	if sprite_frames.has_animation(anim_name):
		var frame_count = sprite_frames.get_frame_count(anim_name)
		var frame_speed = sprite_frames.get_animation_speed(anim_name)
		var real_time = frame_count / frame_speed # 实际时间
		animated_sprite.speed_scale = real_time / time
		return OK
	else:
		push_error("没有这个动画。animation = ", anim_name)
		return FAILED


## 设置 AnimatedSprite2D 节点的动画播放速度。根据这个节点的动画帧和设置的持续时间，设置播放速度
static func update_sprite_frames_fps_time(sprite_frames: SpriteFrames, anim_name: StringName, time: float) -> Error:
	assert(time > 0, "时间错误，必须超过 0")
	if sprite_frames.has_animation(anim_name):
		var frame_count = sprite_frames.get_frame_count(anim_name)
		var frame_speed = sprite_frames.get_animation_speed(anim_name)
		var real_time = frame_count / frame_speed # 实际时间
		
		var fps_scale = real_time / time
		sprite_frames.set_animation_speed(anim_name, frame_speed * fps_scale)
		
		return OK
	else:
		push_error("没有这个动画。animation = ", anim_name)
		return FAILED


## 绘制网格
static func draw_grid(
	target: CanvasItem, 
	rect: Rect2, 
	cell_size: Vector2, 
	color: Color = Color.WHITE,
	line_width: float = 1.0, 
):
	for y in range(rect.position.y, rect.end.y + 1):
		target.draw_line(Vector2(rect.position.x, y) * cell_size, Vector2(rect.end.x, y) * cell_size, color, line_width)
	for x in range(rect.position.x, rect.end.x + 1):
		target.draw_line(Vector2(x, rect.position.y) * cell_size, Vector2(x, rect.end.y) * cell_size, color, line_width)


#static func generate_sprite_frames_by_size(texture: Texture2D, item_size: Vector2):
	#var image : Image = texture.get_image()
	#var grid = texture.get_size() / item_size
	#var sprite_frame := SpriteFrames.new()
	#sprite_frame.remove_animation(&"default")
	#var coords: Vector2
	#var texture_item: Texture2D
	#var image_item : Image
	#for y in grid.y:
		#var anim_name = "anim_%02d" % y
		#sprite_frame.add_animation(anim_name)
		#for x in grid.x:
			#coords = Vector2(x, y) 
			#image_item = image.get_region(Rect2(coords * item_size, item_size))
			#if not image_item.is_invisible():
				#texture_item = ImageTexture.create_from_image(image_item)
				#sprite_frame.add_frame(anim_name, texture_item)
	#return sprite_frame




## 图片是否是空的
static func is_empty(image: Image) -> bool:
	return image.is_empty() or image.get_used_rect().size == Vector2i.ZERO


## 区域是否为空图像
static func is_empty_in_region(image: Image, region: Rect2i) -> bool:
	return is_empty(image.get_region(region))


##  根据序列列表
##[br]
##[br][code]data[/code]  图片序列数据列表。数据格式：[code]data[anim_name] = Texture2D列表[/code]
static func generate_sprite_frames_by_dict(data: Dictionary) -> SpriteFrames:
	var sprite_frames := SpriteFrames.new()
	sprite_frames.remove_animation("default")
	var idx = 0
	for animation_name in data:
		var sequence = data[animation_name]
		sprite_frames.add_animation(animation_name)
		for texture in sequence:
			# 如果图片区域为空，则不继续添加后面的列
			if is_empty(texture.get_image()):
				continue
			sprite_frames.add_frame(animation_name, texture)
			sprite_frames.set_animation_loop(animation_name, false)
			sprite_frames.set_animation_speed(animation_name, 8)
		if sprite_frames.get_frame_count(animation_name) == 0:
			sprite_frames.remove_animation(animation_name)
		idx += 1
	
	return sprite_frames


##  根据图片划分成表格生成 [SpriteFrames]
##[br]
##[br][code]texture[/code]  切分的图片
##[br][code]cut_size[/code]  切割的格数大小
##[br][code]cut_direction[/code]  切割方向。详见: [method generate_textures_by_direction]
static func generate_sprite_frames_by_size(
	texture: Texture2D, 
	cut_size: Vector2i, 
	cut_direction: int = VERTICAL
) -> SpriteFrames:
	var tile_size = texture.get_image().get_size() / cut_size
	return generate_sprite_frames_by_tile_size(texture, tile_size, cut_direction)


##  固定生成的图片大小生成 [SpriteFrames]
##[br]
##[br][code]texture[/code]  切分的图片
##[br][code]tile_size[/code]  切分后每个图片的大小
##[br][code]cut_direction[/code]  切割方向。详见: [method generate_textures_by_direction]
static func generate_sprite_frames_by_tile_size(
	texture: Texture2D, 
	tile_size: Vector2i, 
	cut_direction: int = HORIZONTAL
) -> SpriteFrames:
	var list = generate_textures_by_direction(texture, tile_size, cut_direction)
	var dict = {}
	for i in list.size():
		dict["anim_%02d" % i] = list[i] 
	return generate_sprite_frames_by_dict(dict)


static func generate_textures_by_count(texture: Texture2D, v_count: Vector2i) -> Array[Image]:
	var image = texture.get_image()
	var size = image.get_size() / v_count
	var list : Array[Image] = []
	for y in v_count.y:
		for x in v_count.x:
			list.append(image.get_region(Rect2(x * size.x, y * size.y, size.x, size.y)))
	return list 

static func generate_textures_by_size(texture: Texture2D, size: Vector2i) -> Array[Image]:
	var image = texture.get_image()
	var v_count = image.get_size() / size
	var list : Array[Image] = []
	for y in v_count.y:
		for x in v_count.x:
			list.append(image.get_region(Rect2(x * size.x, y * size.y, size.x, size.y)))
	return list 


##  生成图片序列列表
##[br]
##[br][code]texture[/code]  生成的贴图
##[br][code]tile_size[/code]  每个图片的大小
##[br][code]cut_direction[/code]  切割方向
##[br]    - [constant @GlobalScope.HORIZONTAL] 水平切割，从左到右的顺序获取一组图片序列
##[br]    - [constant @GlobalScope.VERTICAL] 垂直切割，从上到下的顺序获取一组图片序列
static func generate_textures_by_direction(
	texture: Texture2D, 
	tile_size: Vector2i, 
	cut_direction: int = HORIZONTAL
) -> Array[Array]:
	var image = texture.get_image() as Image
	var grid_size = image.get_size() / tile_size
	
	var x_dir : int
	var y_dir : int
	if cut_direction == HORIZONTAL:
		x_dir = 0
		y_dir = 1
	else:
		x_dir = 1
		y_dir = 0
	
	var list : Array[Array] = []
	for y in grid_size[y_dir]:
		var sequence = []
		for x in grid_size[x_dir]:
			var size = Vector2i()
			size[x_dir] = x
			size[y_dir] = y
			var new_texture := ImageTexture.create_from_image(
				texture.get_image().get_region(Rect2i(size * tile_size, tile_size))
			)
			if not new_texture.get_image().is_empty():
				sequence.append(new_texture)
		list.append(sequence)
	
	return list


## [Texture2D] 转为多边形的点，返回每个区域生成多边形的点的列表
static func generate_polygon_points(texture: Texture2D) -> Array[PackedVector2Array]:
	var bit_map = BitMap.new()
	bit_map.create_from_image_alpha( texture.get_image() )
	return bit_map.opaque_to_polygons( Rect2i(Vector2i.ZERO, bit_map.get_size()) )


## 获取 [AnimatedSprite2D] 当前放的动画的帧的 [Texture]
static func get_animated_sprite_current_frame(animated_sprite: AnimatedSprite2D) -> Texture2D:
	if animated_sprite == null or animated_sprite.sprite_frames == null:
		return null
	var sprite_frames = animated_sprite.sprite_frames as SpriteFrames
	var animation = animated_sprite.animation
	if animated_sprite.is_playing():
		var frame = animated_sprite.frame
		return sprite_frames.get_frame_texture(animation, frame)
	else:
		return sprite_frames.get_frame_texture(animation, 0)


## 修改图片的 alpha 值
static func set_image_alpha(image: Image, alpha: float) -> Image:
	var image_size = image.get_size()
	var color : Color
	for x in image_size.x:
		for y in image_size.y:
			color = image.get_pixel(x, y)
			if color.a > 0:
				# 修改图片的 alpha 值
				color.a = alpha
				image.set_pixel(x, y, color)
	return image


## 图片混合。根据 b_ratio 修改图片的 alpha 展现 b 图片颜色清晰度
static func blend_image_alpha(a: Image, b: Image, b_ratio: float) -> Image:
	assert(b_ratio >= 0 and b_ratio <= 1.0, "比值必须在 0 - 1 之间！")
	var a_image = set_image_alpha(a, 1 - b_ratio) as Image
	var b_image = set_image_alpha(b, b_ratio) as Image
	a_image.blend_rect(
		b_image, 
		Rect2i(Vector2i(0,0), b_image.get_size()), 
		Vector2i(0,0)
	)
	return a_image


## Atlas 类型的贴图转为 Image
static func atlas_to_image(texture: AtlasTexture) -> Image:
	var p_t = texture.atlas as Texture2D
	return p_t.get_image().get_region( texture.region )


## 获取可用的大小范围的图片
static func get_used_rect_image(texture: Texture2D) -> Texture2D:
	var image = texture.get_image()
	if image:
		var rect = image.get_used_rect()
		var new_image = Image.create(rect.size.x, rect.size.y, image.has_mipmaps(), image.get_format())
		new_image.blit_rect(image, rect, Vector2i(0,0))
		return ImageTexture.create_from_image(new_image)
	return null


## 获取节点的 [Texture2D]
static func get_node_texture(node: CanvasItem) -> Texture2D:
	var texture : Texture2D 
	if node is AnimatedSprite2D:
		texture = get_animated_sprite_current_frame(node)
	elif node is Sprite2D or node is TextureRect:
		texture = node.texture
	else:
		print("不是 [AnimatedSprite2D, Sprite2D, TextureRect] 中的类型！")
		return null
	return texture


##  重置大小
##[br]
##[br][code]texture[/code]  贴图
##[br][code]new_size[/code]  新的大小
##[br][code]interpolation[/code]  插值。影响图像的质量
##[br][code]return[/code]  返回新的 [Texture2D]
static func resize_texture(
	texture: Texture2D, 
	new_size: Vector2i
) -> Texture2D:
	var image = Image.new()
	image.copy_from(texture.get_image())
	image.resize(new_size.x, new_size.y, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(image)


## 创建新的图像
static func create_from_image(image: Image) -> Image:
	var new_image = Image.new()
	new_image.copy_from(image)
	return new_image

## 创建新的这个 Texture 图片
static func create_from_texture(texture: Texture2D) -> Image:
	return create_from_image(texture.get_image())


## 创建一个纯色图片
static func create_texture_by_color(size: Vector2, fill_color: Color) -> ImageTexture:
	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(fill_color)
	return ImageTexture.create_from_image(image)


class _PreviewReceiver:
	
	static func preview(path: String, preview_texture: Texture2D, thumbnail_preview: Texture2D, userdata: Callable):
		userdata.call(preview_texture)



##  预览场景图片
##[br]
##[br][code]scene[/code]  预览的场景。这个场景在渲染的时候会添加到场景中，请确保这个场景加载不是很慢的速度
##[br][code]callback[/code]  回调方法，需要一个 [ImageTexture] 参数接收渲染后的图片
static func preview_scene(scene: PackedScene, callback: Callable) -> void:
	# 视图节点
	var viewport = SubViewport.new()
	viewport.name = "__preview_vieport_%s" % [viewport.get_instance_id()]
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	viewport.transparent_bg = true
	viewport.size = Engine.get_main_loop().root.size
	
	var instance = scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	if instance.get_script() != null and ((instance.get_script() as GDScript).is_tool()):
		EditorInterface \
			.get_resource_previewer() \
			.queue_edited_resource_preview(scene, _PreviewReceiver, "preview", callback)
	
	else:
		viewport.add_child(instance)
		
		if instance is CanvasItem:
			instance.position = Engine.get_main_loop().root.size / 2
		Engine.get_main_loop().root.add_child(viewport)
		
		# 视图显示 Texture2D
		var viewport_texture = ViewportTexture.new()
		viewport_texture.viewport_path = viewport.get_path_to(Engine.get_main_loop().root)
		RenderingServer.frame_post_draw.connect(func():
			# 渲染后进行图像回调
			var image : Image = viewport.get_texture().get_image()
			if image.is_empty() or image.get_used_rect().size == Vector2i.ZERO:
				callback.call(EditorUtil.get_editor_theme_icon("PackedScene"))
			else:
				image = image.get_region(image.get_used_rect())
				callback.call(ImageTexture.create_from_image(image))
				viewport.queue_free()
		, Object.CONNECT_ONE_SHOT)


## 描边
##[br]
##[br][code]texture[/code]  描边的图像
##[br][code]outline_color[/code]  描边颜色
##[br][code]threshold[/code]  透明度阈值范围，如果这个颜色周围的颜色在这个范围内，则进行描边
##[br][code]return[/code]  返回生成后的图片
static func outline(
	texture: Texture2D, 
	outline_color: Color, 
	threshold: float = 0.0, 
) -> Texture2D:
	if texture == null:
		return null
	var image = texture.get_image()
	if image == null:
		return null
	
	var offset : Vector2
	var size : Vector2
	
	# 遍历阈值内的像素
	var color : Color
	var empty_pixel_set : Dictionary = {}
	for x in range(0, image.get_size().x):
		for y in range(0, image.get_size().y):
			color = image.get_pixel(x, y)
			if color.a <= threshold:
				empty_pixel_set[Vector2i(x, y)] = null
	
	# 开始描边
	var new_image := Image.create(image.get_width(), image.get_height(), image.has_mipmaps(), Image.FORMAT_RGBA8)
	new_image.copy_from(image)
	
	var coordinate : Vector2i
	for x in range(0, image.get_size().x):
		for y in range(0, image.get_size().y):
			coordinate = Vector2i(x, y)
			if not empty_pixel_set.has(coordinate):
				# 判断周围上下左右是否有阈值内的透明度像素
				for dir in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
					if empty_pixel_set.has(coordinate + dir):
						# 设置新图像的描边
						new_image.set_pixelv(coordinate + dir, outline_color)
	
	return ImageTexture.create_from_image(new_image)
