class_name VehicleInput
extends Node
## Abstracción de la fuente de control. Cualquier subclase es intercambiable (LSP).

## Devuelve un valor en [-1, 1].
func obtener_direccion() -> float:
	return 0.0
