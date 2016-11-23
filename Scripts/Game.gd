
extends Node

export var inner_grid_size = Vector2(8, 8)
export var perim_thickness = Vector2(1, 1)
export var count_obstacles = Vector2(2, 7)
export var count_items = Vector2(3, 6)
export var count_enemies = Vector2(2, 2)
var __tile_collection
var __grid


class TileCollection:
	var item = {}
	var tile_size


func fetch_tiles(tile_set_filepath, size_node_name):
	self.__tile_collection = TileCollection.new()
	var tile_set = load(tile_set_filepath).instance()
	for node in tile_set.get_children():
		self.__tile_collection.item[node.get_name().to_lower()] = node
	self.__tile_collection.tile_size = (tile_set \
										.get_node(size_node_name) \
										.get_texture() \
										.get_size())


func __rand_tile(tile_set):
	var tiles = tile_set.get_children()
	var r = int(rand_range(0, tiles.size()))
	return tiles[r]


func __add_tile(tile, xy):
	var tile_dup = tile.duplicate()
	tile_dup.set_pos((self.perim_thickness + Vector2(1, 1) + xy) * self.__tile_collection.tile_size)
	self.add_child(tile_dup)


func __add_base_tiles():
	var bounds = {
		xmin = -self.perim_thickness.x - 1, xmax = self.inner_grid_size.x + self.perim_thickness.x,
		ymin = -self.perim_thickness.y - 1, ymax = self.inner_grid_size.y + self.perim_thickness.y
	}
	for x in range(bounds.xmin, bounds.xmax + 1):
		for y in range(bounds.ymin, bounds.ymax + 1):
			var tile
			if (x == bounds.xmin or x == bounds.xmax or y == bounds.ymin or y == bounds.ymax):
				tile = self.__rand_tile(self.__tile_collection.item.walls)
			else:
				tile = self.__rand_tile(self.__tile_collection.item.floors)
			self.__add_tile(tile, Vector2(x, y))


func __add_other_tiles(tile_set, count=Vector2(1, 1)):
	var n = int(rand_range(count.x, count.y))
	while n > 0:
		var xy = Vector2(randi() % int(self.inner_grid_size.x), \
						 randi() % int(self.inner_grid_size.y))
		if not xy in self.__grid:
			var tile = self.__rand_tile(tile_set)
			self.__add_tile(tile, xy)
			self.__grid.push_back(xy)
			n -= 1


func make_board():
	randomize()
	
	self.__grid = []
	
	self.__add_base_tiles()
	self.__add_other_tiles(self.__tile_collection.item.obstacles, count_obstacles)
	self.__add_other_tiles(self.__tile_collection.item.items, count_items)
	self.__add_other_tiles(self.__tile_collection.item.enemies, count_enemies)
	
	self.__add_tile(self.__tile_collection.item.exit, Vector2(self.inner_grid_size.x, -1))
	self.__add_tile(self.__tile_collection.item.player, Vector2(-1, self.inner_grid_size.y))


func _ready():
	self.fetch_tiles('res://Scenes/TileSet.tscn', 'Exit')
	self.make_board()
	self.__set_screen()


func __set_screen():
	var board_size = (2 * (self.perim_thickness + Vector2(1, 1)) \
					  + self.inner_grid_size) * self.__tile_collection.tile_size
	self.get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, \
										SceneTree.STRETCH_ASPECT_KEEP, board_size)
	OS.set_window_size(2 * board_size)