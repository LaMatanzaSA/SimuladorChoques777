class_name LaneController
extends Node
## ÚNICA responsabilidad: guardar en qué carril está el jugador y validar los cambios
## (límites). No sabe de teclas, física, suelo ni cámara: solo anuncia `carril_cambiado`.
## Todo lo que deba reaccionar al cambio (cuerpo, fondo, pistas) se suscribe a la señal.

signal carril_cambiado(indice_anterior: int, indice_nuevo: int)

@export var _config: LaneConfig

## -1 hasta el primer uso; se resuelve de forma perezosa para no depender del orden de los _ready.
var _indice: int = -1

## Configuración compartida por todos los componentes de carriles.
func configuracion() -> LaneConfig:
	if _config == null:
		_config = LaneConfig.new()
	return _config

func indice_actual() -> int:
	if _indice < 0:
		_indice = configuracion().indice_inicial()
	return _indice

## Mueve al carril contiguo. `direccion`: -1 = carril superior, +1 = carril inferior.
## Devuelve false si el cambio se rechazó (ya está en el último carril).
func desplazar(direccion: int) -> bool:
	var destino: int = indice_actual() + signi(direccion)
	# direccion == 0 deja el mismo carril: no hay nada que anunciar.
	return destino != _indice and ir_a_carril(destino)

## Salta a un carril concreto. Devuelve false si no existe o ya está en él.
func ir_a_carril(indice: int) -> bool:
	var anterior: int = indice_actual()
	if indice == anterior or not configuracion().indice_valido(indice):
		return false
	_indice = indice
	carril_cambiado.emit(anterior, _indice)
	return true
