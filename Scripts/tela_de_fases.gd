extends Control

# --- EDITAR NO INSPECTOR ---
@export var stage_scenes: Array[String] = [
	"res://Cenas/Grassland_level.tscn",
	"res://Cenas/Tropics.tscn",
	"res://Cenas/Autumn_level.tscn",
	"res://Cenas/winter.tscn"
	
]

@export var stage_names: Array[String] = ["Fase 1", "Fase 2", "Fase 3", "Fase 4"]

# Texturas (opcionais)
@export var tex_normal: Array[Texture2D] = []
@export var tex_hover: Array[Texture2D] = []
@export var tex_pressed: Array[Texture2D] = []
@export var tex_disabled: Array[Texture2D] = []

# Se true: bloqueia o botão após o clique e salva em user://levels.cfg
@export var lock_after_click: bool = false

# --- Constantes internas ---
const CFG_PATH := "user://levels.cfg"
const SECTION := "levels"

# --- Variáveis internas ---
var locked_states: Array[bool] = []
var selected_index: int = -1

# --- Referências de nós (ajuste conforme sua cena) ---
@onready var btn_nodes: Array[TextureButton] = [
	$Buttons/Grassland as TextureButton,
	$Buttons/Tropical as TextureButton,
	$Buttons/Autumn as TextureButton,
	$Buttons/Winter as TextureButton,
]

func _ready() -> void:
	var n: int = min(stage_scenes.size(), btn_nodes.size())

	# garantir nomes com tamanho adequado
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

	# 🔒 garantir que locked_states tenha o mesmo tamanho que os botões
	while locked_states.size() < btn_nodes.size():
		locked_states.append(true)  # bloqueia botões extras sem fases
	while locked_states.size() > btn_nodes.size():
		locked_states.pop_back()

	# configurar botões
	for i in range(btn_nodes.size()):
		var btn: TextureButton = btn_nodes[i]
		if btn == null:
			push_error("Botão %d não encontrado na cena" % (i + 1))
			continue

		# desabilitar botões que não têm fase correspondente
		if i >= stage_scenes.size():
			btn.disabled = true
			continue

		# aplicar texturas se fornecidas
		if i < tex_normal.size() and tex_normal[i] != null:
			btn.texture_normal = tex_normal[i]
		if i < tex_hover.size() and tex_hover[i] != null:
			btn.texture_hover = tex_hover[i]
		if i < tex_pressed.size() and tex_pressed[i] != null:
			btn.texture_pressed = tex_pressed[i]
		if i < tex_disabled.size() and tex_disabled[i] != null:
			btn.texture_disabled = tex_disabled[i]

		# aplicar estado disabled inicial
		btn.disabled = locked_states[i]

		# conectar sinais (pressed, mouse_entered, mouse_exited)
		btn.connect("pressed", Callable(self, "_on_stage_pressed").bind(i))
		btn.connect("mouse_entered", Callable(self, "_on_button_hovered").bind(i))
		btn.connect("mouse_exited", Callable(self, "_on_button_unhovered").bind(i))

	# definir índice inicial e atualizar UI
	selected_index = -1
	_update_ui()


# garante que um array tenha pelo menos length n (preenche com nulls)
func _ensure_array_length(arr: Array, n: int) -> void:
	while arr.size() < n:
		arr.append(null)


# atualiza estado visual dos botões
func _update_ui() -> void:
	for i in range(btn_nodes.size()):
		var b: TextureButton = btn_nodes[i]
		if b:
			b.disabled = locked_states[i]


# sinais
func _on_button_hovered(index: int) -> void:
	selected_index = index

func _on_button_unhovered(_index: int) -> void:
	# sem preview, apenas mantém o selecionado
	pass

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

	# carregar cena (se existir)
	var scene_path: String = stage_scenes[index]
	if scene_path == "":
		push_warning("Fase %d ainda não disponível." % (index + 1))
		return

	var err: int = get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("Falha ao carregar cena: %s (err=%d)" % [scene_path, err])


# Save / Load (apenas se lock_after_click == true)
func _load_or_init_states(n: int) -> void:
	var cfg: ConfigFile = ConfigFile.new()
	var err: int = cfg.load(CFG_PATH)
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
			var key: String = "locked_%d" % i
			var val: bool = cfg.get_value(SECTION, key, true)
			locked_states.append(val)

func _save_states() -> void:
	var cfg: ConfigFile = ConfigFile.new()
	for i in range(locked_states.size()):
		cfg.set_value(SECTION, "locked_%d" % i, locked_states[i])
	cfg.save(CFG_PATH)
