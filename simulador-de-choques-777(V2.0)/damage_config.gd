class_name DamageConfig
extends Resource
## Parámetros de balance del sistema de daño y las reglas que dependen de ellos.

## Umbral de destrucción total.
@export var _dano_maximo: float = 100.0
## Velocidad que se considera un choque "a fondo".
@export var _fuerza_referencia: float = 400.0
## Daño de un choque muy suave y de un choque a máxima velocidad.
@export var _dano_minimo_por_golpe: float = 10.0
@export var _dano_maximo_por_golpe: float = 40.0

func dano_maximo() -> float:
	return _dano_maximo

## Daño de un golpe según su fuerza.
func dano_por_golpe(fuerza: float) -> float:
	var proporcion: float = clampf(fuerza / _fuerza_referencia, 0.0, 1.0)
	return lerpf(_dano_minimo_por_golpe, _dano_maximo_por_golpe, proporcion)

## Suma un golpe al daño acumulado sin superar el máximo.
func acumular(dano_actual: float, fuerza: float) -> float:
	return minf(dano_actual + dano_por_golpe(fuerza), _dano_maximo)

## true si el daño acumulado destruye el vehículo.
func es_letal(dano: float) -> bool:
	return dano >= _dano_maximo
