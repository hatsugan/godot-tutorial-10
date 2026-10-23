class_name StatModResource extends Resource

enum ModMode {ADD, MUL, RESET}

@export var stat_code: Stat.Code
@export var mod_mode: ModMode
@export var mod_add: int = 0
@export var mod_mul: float = 1.0
