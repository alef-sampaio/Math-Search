extends Control

# --- EDITE no Inspector ---
@export var stage_scenes: Array[String] = [
    "res://Cenas/tela_de_fases.tscn"
]

@export var stage_names: Array[String] = ["Fase 1", "Fase 2", "Fase 3", "Fase 4"]

# Texturas por botão (pelo menos 'normal' é recomendado).
# Você pode deixar arrays menores; o script cuida disso.
@export var tex_normal: Array[Texture2D] = []
@export var tex_hover: Array[Texture2D] = []
@export var tex_pressed: Array[Texture2D] = []
@export var tex_disabled: Array[Texture2D] = []

# Se true: bloqueia o botão após o clique e salva em user://levels.cfg
@export var lock_after_click: bool = false

# --- constantes internas ---
const CFG_PATH := "user://levels.cfg"
const SECTION := "levels"

# --- variáveis internas ---
var locked_states: Array = []
var selected_index: int = -1

# --- referências onready (ajuste nomes se necessário) ---
@onready var center_preview := $Center/Preview as TextureRect
@onready var center_name := $Center/Name as Label
@onready var btn_nodes := [
	$Buttons/StageButton1,
	$Buttons/StageButton2,
	$Buttons/StageButton3,
	$Buttons/StageButton4,
]

func _ready() -> void:
	var n := stage_scenes.size()

	# garantir names/icons com tamanho adequado
	if stage_names.size() < n:
		for i in range(stage_names.size(), n):
			stage_names.append("Stage %d" % (i + 1))

	# garantir arrays de texturas não menores que n (preenchendo com nulls)
	_ensure_array_length(tex_normal, n)
	_ensure_array_length(tex_hover, n)
	_ensure_array_length(tex_pressed, n)
	_ensure_array_length(tex_disabled, n)

	# carregar estados de bloqueio (se ativado) ou inicializar como desbloqueado
	if lock_after_click:
		_load_or_init_states(n)
	else:
		locked_states = []
		for i in range(n):
			locked_states.append(false)

	# configurar botões
	for i in range(n):
		var btn = btn_nodes[i]
		if btn == null:
			push_error("Botão %d não encontrado na cena" % (i + 1))
			continue

		# aplicar texturas se fornecidas
		if tex_normal[i] != null:
			btn.texture_normal = tex_normal[i]
		if tex_hover[i] != null:
			btn.texture_hover = tex_hover[i]
		if tex_pressed[i] != null:
			btn.texture_pressed = tex_pressed[i]
		if tex_disabled[i] != null:
			btn.texture_disabled = tex_disabled[i]

		# aplicar estado disabled inicial
		btn.disabled = locked_states[i]

		# conectar sinais (pressed, mouse_entered, mouse_exited)
		btn.connect("pressed", Callable(self, "_on_stage_pressed"), [i])
		btn.connect("mouse_entered", Callable(self, "_on_button_hovered"), [i])
		btn.connect("mouse_exited", Callable(self, "_on_button_unhovered"), [i])

	# mostrar preview inicial (primeira fase por padrão)
	selected_index = -1
	_update_center_preview(0)
	_update_ui()

# garante que um array tem pelo menos length n (preenche com nulls)
func _ensure_array_length(arr: Array, n: int) -> void:
	while arr.size() < n:
		arr.append(null)

# updates
func _update_center_preview(index: int) -> void:
	if index < 0 or index >= stage_scenes.size():
		center_preview.texture = null
		center_name.text = ""
		return
	# preferir texto 'hover' se existir, senão normal
	if index < tex_hover.size() and tex_hover[index] != null:
		center_preview.texture = tex_hover[index]
	elif index < tex_normal.size() and tex_normal[index] != null:
		center_preview.texture = tex_normal[index]
	else:
		center_preview.texture = null
	center_name.text = stage_names[index]
	selected_index = index

func _update_ui() -> void:
	for i in range(btn_nodes.size()):
		var b = btn_nodes[i]
		if b:
			b.disabled = locked_states[i]

# sinais
func _on_button_hovered(index: int) -> void:
	_update_center_preview(index)

func _on_button_unhovered(index: int) -> void:
	# mantém o preview do selecionado ou volta para a primeira
	if selected_index >= 0:
		_update_center_preview(selected_index)
	else:
		_update_center_preview(0)

func _on_stage_pressed(index: int) -> void:
	if index < 0 or index >= stage_scenes.size():
		return
	if locked_states[index]:
		return

	# bloquear após o clique (opcional)
	if lock_after_click:
		locked_states[index] = true
		_save_states()
		_update_ui()

	# carregar cena
	var scene_path := stage_scenes[index]
	var err := get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("Falha ao carregar cena: %s (err=%d)" % [scene_path, err])

# Save / Load (apenas se lock_after_click == true)
func _load_or_init_states(n: int) -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(CFG_PATH)
	locked_states = []
	if err != OK:
		# padrão: desbloqueia a primeira, bloqueia as demais
		for i in range(n):
			locked_states.append(i != 0)


		for i in range(n):
			cfg.set_value(SECTION, "locked_%d" % i, locked_states[i])
		cfg.save(CFG_PATH)
	else:
		for i in range(n):
		  var key := "locked_%d" % i
		  var val := cfg.get_value(SECTION, key, true)
		  locked_states.append(bool(val))


func _save_states() -> void:
	var cfg := ConfigFile.new()
	for i in range(locked_states.size()):
		cfg.set_value(SECTION, "locked_%d" % i, locked_states[i])
	cfg.save(CFG_PATH)
