#============================================================
#    Tilemap Util
#============================================================
# - datetime: 2023-02-14 19:48:46
#============================================================
## TileMapLayer 工具类
##
##一些处理 TileMapLayer 数据的功能
class_name TileMapUtil

# tile 和 cell 的区别
# - tile（瓦片）：方法名或变量名带有 “tile” 的可以认为是瓦片的 ID 的值的数据
# - cell（单元格）：获取瓦片的所在行和列的坐标位置。是 Vector2i 类型的数据


##  单元格是连通的。中间过程没有存在其他的单元格
##[br]
##[br][code]tilemap[/code]  TileMapLayer 对象
##[br][code]from[/code]  开始的坐标
##[br][code]to[/code]  到达的坐标
##[br][code][/code]  所在的层
static func cell_is_connected(tilemap: TileMapLayer, from: Vector2, to: Vector2) -> bool:
	if from == to:
		return true
	
	var start = Vector2(from)
	var end = Vector2(to)
	var direction = start.direction_to(end)
	for step in floor(start.distance_to(end) - 1.0):
		start += direction
		var id = tilemap.get_cell_source_id(Vector2i(start))
		if id != -1:
			return false
	return true


##  获取这组点列表可以互相连接的点，两个点之间没有其他瓦片
##[br]
##[br][code]tilemap[/code]  tilemap对象
##[br][code]points[/code]  点列表
##[br][code][/code]  所在的层
##[br]
##[br]返回以下结构的数据列表
##[codeblock]
##{
##    "from": Vector2, 
##    "to": Vector2,
##}
##[/codeblock] 
static func get_connected_cell(tilemap: TileMapLayer, points: Array) -> Array[Dictionary]:
	if points.size() < 2:
		return []
	var list : Array[Dictionary]= []
	for i in points.size() - 1:
		for j in range(i + 1, points.size()):
			if cell_is_connected(tilemap, points[i], points[j]):
				list.append({
					"from": points[i],
					"to": points[j],
				})
	
	for idx in range(list.size() - 1, -1, -1):
		var data := Dictionary(list[idx])
		if (data['from'] == data['to']):
			list.remove_at(idx)
	
	return list


## 获取两边没有瓦片的单元格
static func get_between_no_tile_cell(tilemap: TileMapLayer, coordinate: Vector2i, max_height: int = 1, max_width: int = 1) -> Array[Vector2i]:
	var id = tilemap.get_cell_source_id(coordinate)
	var no_tiles : Array[Vector2i] = []
	if id != -1:
		for width in max_width:
			var left : Vector2i = coordinate + Vector2i(-width, 0)
			var right : Vector2i = coordinate + Vector2i(width, 0)
			for i in (max_height + 1):
				left -= Vector2i(0, i)
				if tilemap.get_cell_source_id(left) > -1:
					no_tiles.append(left)
				right -= Vector2i(0, i)
				if tilemap.get_cell_source_id(right) > -1:
					no_tiles.append(right)
	return no_tiles


## 获取这个坐标点两边的立足点。会返回两个项的数组，第一个为左边的点，第二个为右边的点，若为 null，则代表没有
static func get_foothold_cell(tilemap: TileMapLayer, coordinate: Vector2i) -> Array:
	var used_rect = tilemap.get_used_rect()
	var left : Vector2i
	var right : Vector2i
	var coords : Array = [null, null]
	
	# 左。中上不能有其他瓦片
	if (tilemap.get_cell_source_id(coordinate + Vector2i(-1, -1)) == -1
		and tilemap.get_cell_source_id(coordinate + Vector2i(-1, 0)) == -1
	):
		for i in (used_rect.end.y - coordinate.y):
			left = coordinate + Vector2i(-1, i)
			if tilemap.get_cell_source_id(left) != -1:
				coords[0] = left
				break
		
	# 右。中上不能有其他瓦片
	if (tilemap.get_cell_source_id(coordinate + Vector2i(1, -1)) == -1
		and tilemap.get_cell_source_id(coordinate + Vector2i(1, 0)) == -1
	):
		for i in (used_rect.end.y - coordinate.y):
			right = coordinate + Vector2i(1, i)
			if tilemap.get_cell_source_id(right) != -1:
				coords[1] = right
				break
	
	return coords


## 获取可接触到的单元格点
static func get_touchable_coordinates(tilemap: TileMapLayer, coordinate: Vector2i, touchable_height: int, touchable_width: int) -> Array:
	var list : Array = [null, null]
	
	# 头顶不能有碰撞的单元格
	for i in range(1, touchable_height + 1):
		if tilemap.get_cell_source_id(coordinate + Vector2i(0, -i)) != -1:
			return list
		
	# 从中心向两边扩散，那一边的某列有，那这边是这个单元格可接触
	var left : Vector2i
	var right : Vector2i
	for y in range(1, touchable_height + 1):
		for x in range(1, touchable_width + 1):
			if list[0] == null:
				left = coordinate + Vector2i(-x, -y)
				if (tilemap.get_cell_source_id(left) > -1
					and tilemap.get_cell_source_id(left + Vector2i.UP) == -1
				):
					list[0] = left
			
			if list[1] == null:
				right = coordinate + Vector2i(x, -y)
				if (tilemap.get_cell_source_id(right) > -1
					and tilemap.get_cell_source_id(right + Vector2i.UP) == -1
				):
					list[1] = right
			
			if list[0] != null and list[1] != null:
				break
		
		if list[0] != null and list[1] != null:
			break
	
	return list


## 瓦片替换为节点
static func replace_tile_as_node_by_scene(tilemap: TileMapLayer,  coordinate: Vector2i, scene: PackedScene) -> Node:
	tilemap.set_cell(coordinate, -1, Vector2(0, 0))
	
	# 替换场景节点
	var node = scene.instantiate()
#	node.z_index = -10
	tilemap.add_child(node)
	node.global_position = tilemap.global_position + Vector2(tilemap.tile_set.tile_size * coordinate) 
	return node


## 获取是个地板的单元格
##[br]
##[br][code]tilemap[/code]  数据来源 TileMapLayer
##[br][code][/code]  所在层
##[br][code]ids[/code]  这个单元格的 ID
##[br][code]atlas_coords[/code]  这个单元格图片的坐标
##[br][code]return[/code]  返回符合条件的单元格
static func get_ground_cells(
	tilemap: TileMapLayer, 
	 
	ids: Array[int] = [], 
	atlas_coords: Array[Vector2i] = []
) -> Array[Vector2i]:
	var list : Array[Vector2i] = []
	if ids.is_empty() and atlas_coords.is_empty():
		return tilemap.get_used_cells()
	
	for coordinate in tilemap.get_used_cells():
		if ((ids.is_empty() or tilemap.get_cell_source_id(coordinate) in ids)
			and (atlas_coords.is_empty() or tilemap.get_cell_atlas_coords(coordinate) in atlas_coords)
		):
			if tilemap.get_cell_source_id(coordinate + Vector2i.UP) == -1:
				list.append(coordinate)
	return list


## 获取 TileMapLayer 的中心位置
static func get_global_center(tilemap: TileMapLayer) -> Vector2:
	return tilemap.global_position + Vector2(tilemap.get_used_rect().size / 2 * tilemap.tile_set.tile_size)


## 是否存在这个 ID
static func is_exists_id(tilemap: TileMapLayer, idx: int) -> bool:
	return tilemap.tile_set != null and tilemap.tile_set.get_source(idx) != null


## 添加贴图
##[br]
##[br][code]tilemap[/code]  添加到的 [TileMapLayer]
##[br][code]texture[/code]  添加的图片
##[br][code]atlas_source_id_override[/code]  要覆盖掉的之前的ID。如果为 [code]-1[/code]，则为新增
static func add_texture(
	tilemap: TileMapLayer, 
	texture: Texture2D, 
	atlas_source_id_override: int = -1
) -> void:
	var tile_set : TileSet
	if tilemap.tile_set == null:
		tilemap.tile_set = TileSet.new()
	tile_set = tilemap.tile_set
	
	# 添加 Texture
	var source : TileSetAtlasSource
	if tile_set.has_source(atlas_source_id_override):
		source = tile_set.get_source(atlas_source_id_override)
		source.texture = texture
	else:
		source = TileSetAtlasSource.new()
		source.texture = texture
		source.create_tile(Vector2i())
		tile_set.add_source(source, atlas_source_id_override)

## 这块区域是否有瓦片
static func has_cell_data_by_rect(tilemap: TileMapLayer, rect: Rect2i) -> bool:
	for y in range(rect.position.y, rect.end.y + 1):
		for x in range(rect.position.x, rect.end.x + 1):
			if tilemap.get_cell_source_id(Vector2i(x, y)) != -1:
				return true
	return false


##  获取这片区域的瓦片数据列表
##[br]
##[br][code]tilemap[/code]  地图
##[br][code]rect[/code]  获取区域的区域
##[br][code][/code]  所在层
##[br][code]use_proxies[/code]  如果 [code]use_proxies[/code] 为 [code]false[/code]，
##则忽略 [TileSet]的 tile 代理。请参见 [method TileSet.map_tile_proxy]
##[br][code]return[/code] 返回的数据结构类似如下结构：
##[codeblock]
##{
##    "coords": Vector2i(),
##    "source_id": 0,
##    "alternative_tile": -1,
##    "atlas_coords": Vector2i(),
##}
##[/codeblock]
static func get_cell_data_by_rect(
	tilemap: TileMapLayer, 
	rect: Rect2i, 
) -> Array[CellItemData]:
	var list : Array[CellItemData] = []
	FuncUtil.for_rect(rect, func(coordinate: Vector2i):
		if tilemap.get_cell_source_id(coordinate) != -1:
			list.append_array(get_cell_data(tilemap, coordinate))
	)
	return list


## 这个单元格的数据
class CellItemData:
	var coords : Vector2i
	var source_id : int
	var atlas_coords : Vector2i
	var alternative_tile : int
	
	func _init(data: Dictionary = {}):
		if not data.is_empty():
			JsonUtil.set_property_by_dict(data, self)
	
	func _to_string():
		return JsonUtil.object_to_json(self, "    ")


##  获取这个坐标的单元格的所有数据
##[br]
##[br][code]tilemap[/code]  获取的 tilemap
##[br][code]coordinate[/code]  所在单元格的坐标
##[br][code]use_proxies[/code]  获取代理的数据
static func get_cell_data(
	tilemap: TileMapLayer, 
	coordinate: Vector2i, 
) -> Array[CellItemData]:
	var list : Array[CellItemData] = []
	var item : CellItemData = CellItemData.new()
	item.coords = coordinate
	item.source_id = tilemap.get_cell_source_id(coordinate)
	item.atlas_coords = tilemap.get_cell_atlas_coords(coordinate)
	item.alternative_tile = tilemap.get_cell_alternative_tile(coordinate)
	list.append(item)
	return list


## 设置单元格的数据
##[br]
##[br][code]tilemap[/code]  要设置的 [TileMapLayer]
##[br][code]data[/code]  设置的数据。所需的数据结构为 [method set_cell_data] 方法中的结构
static func set_cell_data(tilemap: TileMapLayer, data: Dictionary) -> void:
	set_cell(
		tilemap, 
		data.get("coords", Vector2i.ZERO),
		data.get("source_id", 0),
		data.get("atlas_coords", Vector2i.ZERO),
	)

## 设置这个单元格位置的数据
static func set_cell(
	tilemap: TileMapLayer,
	coords: Vector2i, 
	source_id: int = 0, 
	atlas_coords: Vector2i = Vector2i.ZERO, 
	alternative_tile: int = 0,
):
	tilemap.set_cell(coords, source_id, atlas_coords, alternative_tile)

static func set_cell_by_points(
	tilemap: TileMapLayer,
	coords_list, 
	source_id: int = 0, 
	atlas_coords: Vector2i = Vector2i.ZERO, 
	alternative_tile: int = 0,
):
	for coords in coords_list:
		tilemap.set_cell(coords, source_id, atlas_coords, alternative_tile)


## 擦除这个单元格
static func clear_cell(tilemap: TileMapLayer, coords: Vector2i):
	tilemap.set_cell(coords, -1, Vector2i(-1, -1))

## 擦除这个单元格
static func clear_cell_by_points(tilemap: TileMapLayer, coords_list):
	for point in coords_list:
		tilemap.set_cell(Vector2i(point), -1, Vector2i(-1, -1))


##  复制 cell 数据到 TileMapLayer 上
##[br]
##[br][code]from_tilemap[/code]  从这个 [TileMapLayer] 中获取数据
##[br][code]from_rect[/code]  获取这个区域的范围的数据
##[br][code]to_tilemap[/code]  复制到这个 [TileMapLayer] 上
##[br][code]to_rect[/code]  复制到这个区域范围内。如果为 Rect2i(0,0,0,0) 则为 from_rect 参数的值
##[br][code]cell_filter[/code]  过滤数据方法。这个参数需要有一个 [Dictionary] 
##类型的参数接受这个单元格上数据，并返回一个 [bool] 类型的值返回是否需要这个数据，如果返回 
##[code]true[/code] 则添加，否则不添加
static func copy_cell_to(
	from_tilemap: TileMapLayer, 
	from_rect: Rect2i, 
	to_tilemap: TileMapLayer, 
	to_rect: Rect2i = Rect2i(), 
	cell_filter: Callable = Callable()
):
	assert(from_rect.size != Vector2i.ZERO, "from_rect 参数值的大小必须要超过 0！")
	if to_rect == Rect2i():
		to_rect = from_rect
	
	# 获取数据
	var dict : Dictionary = {}
	if cell_filter.is_valid():
		FuncUtil.for_rect(from_rect, func(from_coords: Vector2i):
			var list : Array[CellItemData] = []
			for data in get_cell_data(from_tilemap, from_coords):
				if cell_filter.call(data):
					list.append(data)
			if not list.is_empty():
				dict[from_coords] = list
		)
	else:
		FuncUtil.for_rect(from_rect, func(from_coords: Vector2i):
			dict[from_coords] = get_cell_data(from_tilemap, from_coords)
		)
	
	# 复制到另一个 TileMapLayer 上
	var offset : Vector2i = from_rect.position - to_rect.position
	FuncUtil.for_rect(to_rect, func(to_coords: Vector2i):
		var from_coords : Vector2i = to_coords + offset
		if dict.has(from_coords):
			var list : Array[CellItemData] = dict[from_coords]
			for data in list:
				var cell_coord : Vector2i = data.coords - offset
				to_tilemap.set_cell(cell_coord, data.source_id, data.atlas_coords)
		else:
			printerr("没有这个位置：", from_coords)
	)


##  复制所有 Cell 到另一个 [TileMapLayer] 上
##[br]
##[br][code]from[/code]  从这个 [TileMapLayer] 上复制数据
##[br][code]to[/code]  设置到这个 [TileMapLayer] 上
##[br][code]offset_coord[/code]  偏移的坐标位置
static func copy_all_cell_to(from: TileMapLayer, to: TileMapLayer, offset_coord: Vector2i = Vector2i.ZERO):
	for coords in from.get_used_cells():
		to.set_cell(coords + offset_coord, 
			from.get_cell_source_id(coords), 
			from.get_cell_atlas_coords(coords), 
			from.get_cell_alternative_tile(coords), 
		)


## 检测是否有单元格
##[br]
##[br]这个深度的方向一行货列中没有其他瓦片数据时返回 [code]true[/code]，否则返回 [code]false[/code]
##[br]
##[br][code]tilemap[/code]  判断的 [TileMapLayer]
##[br][code]coords[/code]  从这个坐标开始
##[br][code]from_direction[/code]  这个方向为出口方向
##[br][code]depth[/code]  判断深度
static func ray_cast(
	tilemap: TileMapLayer, 
	coords: Vector2i, 
	from_direction: Vector2i, 
	depth : int,
) -> bool:
	assert(depth > 0, "深度必须要超过0")
	var move_direction : Vector2i = from_direction * -1
	for i in depth:
		coords += move_direction
		if has_cell_data(tilemap, coords):
			return false
	return true


static func has_cell_data(tilemap: TileMapLayer, coords) -> bool:
	return tilemap.get_cell_source_id(coords) != -1


## 获取两点之间的连接线
static func get_connect_line_points(from_coords: Vector2i, to_coords: Vector2i) -> Array[Vector2i]:
	var min_coords := Vector2i(MathUtil.get_min_xy([from_coords, to_coords]))
	var max_coords := Vector2i(MathUtil.get_max_xy([from_coords, to_coords]))
	var rect := Rect2i(min_coords, (max_coords - min_coords).abs())
	if rect.size.x == 0:
		rect.size.x = 1
	if rect.size.y == 0: 
		rect.size.y = 1
	
	var direction := Vector2(to_coords - from_coords).normalized()
	var tmp_coords := Vector2(from_coords)
	var tmp_coords_i := Vector2i(from_coords)
	var list : Array[Vector2i]
	while true:
		tmp_coords += direction
		tmp_coords_i = Vector2i(tmp_coords)
		if rect.has_point(tmp_coords_i):
			list.append(tmp_coords_i)
		else:
			if list.is_empty():
				printt(rect, tmp_coords_i, direction)
			if not list.is_empty() and list.back() != to_coords:
				list.append(to_coords)
			break
	return list


## 如果其中没有存在障碍物则返回 -1
static func ray_cell_coords(
	tilemap: TileMapLayer, 
	from: Vector2i, 
	direction: Vector2, 
	max_length: int,
) -> int:
	var length = 0
	var tmp_from = Vector2(from) + direction.sign()
	var result = -1
	while (length < max_length - 1):
		result &= (
			tilemap.get_cell_source_id(Vector2i(tmp_from))
			| tilemap.get_cell_source_id(Vector2i(tmp_from.ceil()) )
		)
		if result != -1:
			break
		
		tmp_from += direction
		# 存在有障碍物
		length += 1
	return result


## 射线射向目标位置
##[br]
##[br][code]coords[/code]  所在位置
##[br][code]direction[/code]  检测方向
##[br][code]length[/code]  长度
##[br][code]return[/code]  返回检测到的瓦片的坐标位置，如果没有检测到瓦片，则返回 [constant MathUtil.VECTOR2I_MAX]
static func ray_to(
	tilemap: TileMapLayer,
	coords: Vector2i,
	direction: Vector2,
	length: float = INF,
) -> Vector2i:
	var rect := tilemap.get_used_rect()
	var tmp_coords := Vector2(coords)
	var tmp_coords_i := Vector2i(coords)
	
	var i : int = -1
	while true:
		i += 1
		if i >= length:
			break
		tmp_coords += direction
		tmp_coords_i = Vector2i(tmp_coords)
		if not rect.has_point(tmp_coords_i):
			break
		if has_cell_data(tilemap, tmp_coords_i):
			return tmp_coords_i
	return MathUtil.VECTOR2I_MAX


## 返回给定参数的所有元格的位置
static func get_used_cells(
	tilemap: TileMapLayer, 
	source_ids: Array[int], 
	atlas_coords_list: Array[Vector2i],
) -> Array[Vector2i]:
	var data = {}
	for source_id in source_ids: 
		for atlas_coords in atlas_coords_list:
			for cell in tilemap.get_used_cells_by_id(source_id, atlas_coords):
				data[cell] = []
	return Array(data.keys(), TYPE_VECTOR2I, "", null)


## 获取整个地图实际矩形像素大小
static func get_rect(tilemap: TileMapLayer) -> Rect2:
	var rect = tilemap.get_used_rect()
	rect.position *= tilemap.tile_set.tile_size
	rect.size *= tilemap.tile_set.tile_size
	rect.position += Vector2i(tilemap.global_position)
	return rect


## 获取全部外侧瓦片坐标列表
static func get_all_edge_coords_list(tile_map: TileMapLayer) -> Array:
	var coords_list = []
	var visited = {}
	var rect = tile_map.get_used_rect().grow(1)
	var tmp_coords
	var last_coords_list = [rect.position] # 从左上角第一个位置开始
	while not last_coords_list.is_empty():
		var next_coords_list = []
		for coords in last_coords_list:
			for direction in MathUtil.get_four_directions_i():
				tmp_coords = coords + direction # 移动到的位置
				if not visited.has(tmp_coords) and rect.has_point(tmp_coords):
					# 判断移动到的位置(tmp_coords)是否是墙
					if tile_map.get_cell_source_id(tmp_coords) == -1:
						next_coords_list.append(tmp_coords)
					else:
						coords_list.append(tmp_coords)
					visited[tmp_coords] = null
		last_coords_list = next_coords_list
		next_coords_list = []
	return coords_list


## 获取全部外侧空白瓦片坐标列表
static func get_all_edge_empty_coords_list(
	tile_map: TileMapLayer, 
	grow: int = 1, # 向外扩展大小
) -> Array:
	var coords_list = []
	var visited = {}
	var rect = tile_map.get_used_rect().grow(grow)
	var tmp_coords
	var last_coords_list = [rect.position] # 从左上角第一个位置开始
	while not last_coords_list.is_empty():
		var next_coords_list = []
		for coords in last_coords_list:
			for direction in MathUtil.get_four_directions_i():
				tmp_coords = coords + direction # 移动到的位置
				if not visited.has(tmp_coords) and rect.has_point(tmp_coords):
					# 判断移动到的位置(tmp_coords)是否是墙
					if tile_map.get_cell_source_id(tmp_coords) == -1:
						next_coords_list.append(tmp_coords)
						coords_list.append(tmp_coords)
					visited[tmp_coords] = null
		last_coords_list = next_coords_list
		next_coords_list = []
	return coords_list


## 获取边界的瓦片坐标列表。
static func get_border_coords_list(
	points: Array, 
	directions: Array = MathUtil.get_eight_directions(),
) -> Array:
	# 不存在的点的位置
	var dict = {}
	for p in points:
		dict[p] = null
	
	var list = []
	var tmp : Vector2
	var border: bool
	for point in points:
		border = false
		for dir in directions:
			tmp = point + dir
			if not dict.has(tmp):
				border = true
				break
		if border:
			list.append(point)
	return list


static func get_inside_coords_list(
	border_coords_dict: Dictionary,  # 边缘坐标点，根据 [method get_border_coords_list] 进行获取
	directions: PackedVector2Array = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN],
) -> Array:
	var min_v = MathUtil.get_min_xy(border_coords_dict.keys())
	var start = min_v + Vector2(1, 1)
	var result = {start: null}
	FuncUtil.path_move(
		start,
		directions,
		func(v): 
			return not border_coords_dict.has(v),
		func(points):
			DataUtil.merge(result, points)
	)
	return result.keys()


## 地图边缘转为多边形点，这个点都是单元格坐标点
static func tile_map_to_polygon(tilemap: TileMapLayer) -> Array:
	# 获取边缘点
	var points = get_all_edge_coords_list(tilemap)
	# 点排序
	return __tile_map_to_polygon_sort_points(points)

static func __tile_map_to_polygon_sort_points(list) -> Array:
	var curr = list[0]
	var visited = {}
	visited[curr] = null
	var l : Array = [curr]
	var tmp
	var moved = false
	while true:
		moved = false
		for dir in [
			Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN,
			Vector2i(-1, -1), Vector2i(-1, 1),
			Vector2i(1, 1), Vector2i(1, -1),
		]:
			tmp = curr + dir
			if not visited.has(tmp) and list.has(tmp):
				l.append(tmp)
				curr = tmp
				visited[tmp] = null
				moved = true
				break
		if not moved:
			break
	return l

 
## 对 [Ti了MapLayer] 进行划分区块，互相连接的单元格划分为一组点
static func adjacent_groups(
	tilemap_layer:TileMapLayer, 
	directions: PackedVector2Array = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN],
) -> Array[PackedVector2Array]:
	var map_rect : Rect2i = tilemap_layer.get_used_rect().grow(1)
	var visited : Dictionary = {}
	FuncUtil.path_move(
		map_rect.position, 
		directions,
		func(next_point): 
			return (map_rect.has_point(Vector2i(next_point)) 
			and tilemap_layer.get_cell_source_id(next_point) == -1
		),
		func(next_points):
			DataUtil.merge(visited, next_points)
	)
	var groups : Array[PackedVector2Array] = []
	FuncUtil.for_rect(
		map_rect.grow(-1),
		func(v):
			if not visited.has(v):
				var list := PackedVector2Array()
				list.append(v)
				visited[v] = null
				FuncUtil.path_move(
					v, 
					directions,
					func(next): 
						return not visited.has(next) and map_rect.has_point(next),
					func(next_points):
						list.append_array(next_points)
						DataUtil.merge(visited, next_points)
				)
				groups.append(list)
	)
	return groups


## 是否为拐角点
static func is_cornet_coords(point: Vector2, map_coords_dict:Dictionary) -> bool:
	return (
		not (map_coords_dict.has(point + Vector2.UP) and map_coords_dict.has(point + Vector2.DOWN) ) 
		and not (map_coords_dict.has(point + Vector2.LEFT) and map_coords_dict.has(point + Vector2.RIGHT) ) 
	)


## 获取拐角坐标点
static func get_corner_coords_list(point_dict: Dictionary) -> Array:
	var map = {}
	for point in point_dict:
		if is_cornet_coords(point, point_dict):
			map[point] = null
	return map.keys()
