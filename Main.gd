extends Control

@export var grid_size: int = 3

var tiles: Array = []
var moves: int = 0

@onready var grid: GridContainer = $Content/Grid
@onready var moves_label: Label = $Content/Moves
@onready var status_label: Label = $Content/Status
@onready var shuffle_button: Button = $Content/Buttons/Shuffle
@onready var reset_button: Button = $Content/Buttons/Reset

func _ready() -> void:
	grid.columns = grid_size
	shuffle_button.pressed.connect(_on_shuffle_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	_create_grid()
	_reset_board()

func _create_grid() -> void:
	for child in grid.get_children():
		child.queue_free()
	tiles.clear()
	for row in range(grid_size):
		var row_tiles: Array = []
		for col in range(grid_size):
			var button := Button.new()
			button.custom_minimum_size = Vector2(100, 100)
			button.theme_override_font_sizes/font_size = 28
			button.pressed.connect(_on_tile_pressed.bind(row, col))
			grid.add_child(button)
			row_tiles.append(false)
		tiles.append(row_tiles)

func _reset_board() -> void:
	moves = 0
	status_label.text = ""
	for row in range(grid_size):
		for col in range(grid_size):
			tiles[row][col] = false
	_update_visuals()
	_update_moves()

func _on_shuffle_pressed() -> void:
	_reset_board()
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var shuffle_moves = rng.randi_range(grid_size * grid_size, grid_size * grid_size * 2)
	for i in range(shuffle_moves):
		var row = rng.randi_range(0, grid_size - 1)
		var col = rng.randi_range(0, grid_size - 1)
		_toggle_with_neighbors(row, col, count_move := false)
	_update_visuals()

func _on_reset_pressed() -> void:
	_reset_board()

func _on_tile_pressed(row: int, col: int) -> void:
	_toggle_with_neighbors(row, col, count_move := true)
	_update_visuals()
	_check_for_win()

func _toggle_with_neighbors(row: int, col: int, count_move: bool) -> void:
	_toggle_tile(row, col)
	_toggle_tile(row - 1, col)
	_toggle_tile(row + 1, col)
	_toggle_tile(row, col - 1)
	_toggle_tile(row, col + 1)
	if count_move:
		moves += 1
		_update_moves()

func _toggle_tile(row: int, col: int) -> void:
	if row < 0 or col < 0 or row >= grid_size or col >= grid_size:
		return
	tiles[row][col] = !tiles[row][col]

func _update_visuals() -> void:
	var index := 0
	for row in range(grid_size):
		for col in range(grid_size):
			var button := grid.get_child(index) as Button
			if tiles[row][col]:
				button.text = "●"
				button.modulate = Color(1, 0.75, 0.2)
			else:
				button.text = "○"
				button.modulate = Color(0.4, 0.45, 0.55)
			index += 1

func _update_moves() -> void:
	moves_label.text = "Moves: %d" % moves

func _check_for_win() -> void:
	for row in range(grid_size):
		for col in range(grid_size):
			if tiles[row][col]:
				status_label.text = ""
				return
	status_label.text = "Puzzle solved! 🎉"
