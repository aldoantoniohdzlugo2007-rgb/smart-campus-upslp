# Integración App Tráfico + Smart Campus

## Flujo implementado

1. La aplicación inicia en el mapa interactivo de App Tráfico.
2. Al pulsar cualquier marcador circular `P` del mapa:
   - se conserva la selección del marcador;
   - se abre la pantalla del croquis Smart Campus mediante `Navigator.push`.
3. El croquis conserva la escucha de Firestore en tiempo real.
4. Para regresar, usa el botón Atrás del navegador o del dispositivo.

## Archivos principales

- `lib/main.dart`: inicializa Firebase y abre el mapa interactivo.
- `lib/screens/mapa_campus_screen.dart`: código visual y funcional de App Tráfico.
- `lib/screens/croquis_estacionamiento_screen.dart`: croquis y Firestore de Smart Campus.
- `lib/firebase_options.dart`: configuración Firebase conservada.
- `assets/croquis_upslp.png`: imagen original conservada.

## Comandos en Codespaces

```bash
flutter clean
flutter pub get
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

## Nota

Actualmente todos los marcadores `P` del mapa interactivo abren el mismo croquis. Esto evita cambiar la estética y permite probar la navegación de inmediato.
