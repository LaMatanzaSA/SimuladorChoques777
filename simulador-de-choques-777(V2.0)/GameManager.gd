extends Node

# Variables globales para recordar la elección activa del jugador.
# Ponemos rutas por defecto para que el juego siempre arranque con algo cargado.
var auto_seleccionado: String = "res://Sprites/Sprites Autos2.0/AmarilloN.png"
var mapa_seleccionado: String = "res://Sprites/FONDOS REALES/MUNDO 1.png"

# Opcional: Podés agregar funciones para cambiar valores de forma limpia
func cambiar_auto(nueva_ruta: String) -> void:
	if nueva_ruta != "":
		auto_seleccionado = nueva_ruta

func cambiar_mapa(nueva_ruta: String) -> void:
	if nueva_ruta != "":
		mapa_seleccionado = nueva_ruta
