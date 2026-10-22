class_name SpeciesResource extends Resource

# Info
@export var image: Texture2D
@export var name: String

# Type and Moves
@export var type: MonsterType.Type
@export var starter_moves: Array[MoveResource]

# Stats
@export var base_max_hp: int
@export var base_attack: int
@export var base_defence: int
@export var base_speed: int
