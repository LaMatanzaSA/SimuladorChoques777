class_name LaneConfig
extends Resource
## Datos de los carriles. Se inyecta como Resource (.tres): es la ÚNICA fuente de
## verdad de cuántos carriles hay, qué tan separados están y qué capa física usa cada uno.
## Convención: el carril 0 es el SUPERIOR (más alto en pantalla) y los índices crecen hacia abajo.

@export_range(1, 8) var _cantidad_carriles: int = 2
## Distancia vertical entre carriles contiguos, en px. El detector de colisión del
## auto mide 34.5 px de alto: 40 px deja un margen para que dos autos en carriles
## contiguos no se superpongan.
@export var _separacion_vertical: float = 40.0
## Segundos que tarda un cambio entre carriles contiguos.
@export var _duracion_transicion: float = 0.25
@export var _indice_inicial: int = 0
## Primera capa física (1-32) reservada para carriles: el carril i usa la capa `primera + i`.
@export_range(1, 32) var _primera_capa_fisica: int = 2

func cantidad() -> int:
	return _cantidad_carriles

func indice_valido(indice: int) -> bool:
	return indice >= 0 and indice < _cantidad_carriles

func indice_inicial() -> int:
	return clampi(_indice_inicial, 0, _cantidad_carriles - 1)

func separacion() -> float:
	return _separacion_vertical

func duracion_transicion() -> float:
	return maxf(_duracion_transicion, 0.01)

## Desplazamiento vertical del carril respecto al carril 0.
func desplazamiento_y(indice: int) -> float:
	return float(indice) * _separacion_vertical

## Máscara de bits de la capa física del carril.
func mascara_de(indice: int) -> int:
	return 1 << clampi(_primera_capa_fisica - 1 + indice, 0, 31)

## Unión de las capas físicas de todos los carriles.
func mascara_total() -> int:
	var mascara: int = 0
	for indice: int in _cantidad_carriles:
		mascara |= 1 << clampi(_primera_capa_fisica - 1 + indice, 0, 31)
	return mascara
