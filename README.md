# industrialshields-esp32-customs

Arreglos **no oficiales** para el núcleo Arduino de los **ESP32 PLC de
Industrial Shields** (`framework-industrialshields-esp32`), publicados como un
paquete de PlatformIO listo para usar.

> No es un producto de Industrial Shields ni está respaldado por ellos. Los
> fallos se les han comunicado; cuando los corrijan en una versión oficial,
> conviene volver a ella.

Los arreglos salen de un proyecto con ESP32 PLC 21, módem LTE (SARA-R412M) en
la expansión 1, CAN (MCP2515) en la expansión 2 y MicroSD funcionando a la vez.
Cada uno está reproducido en el PLC. El detalle está en [CHANGELOG.md](CHANGELOG.md)
y en cada fichero de [patches/](patches/).

## Uso con PlatformIO

En el `platformio.ini`, sustituir el paquete del núcleo por el de la release:

```ini
platform = https://github.com/Industrial-Shields/platform-industrialshields-esp32.git#v1.1.0
platform_packages =
  framework-industrialshields-esp32@https://github.com/gbellido-dev/industrialshields-esp32-customs/releases/download/v2.7.1-customs.2/framework-industrialshields-esp32-2.7.1-customs.2.tar.gz
```

El código puede comprobar que usa este núcleo:

```cpp
#if defined(INDUSTRIALSHIELDS_ESP32_CUSTOMS) && INDUSTRIALSHIELDS_ESP32_CUSTOMS >= 2
// arreglos de la release 2 disponibles
#endif
```

## Cómo se construye

El repositorio solo guarda los parches. `scripts/build.sh`:

1. descarga el paquete original 2.7.1 de `apps.industrialshields.com`;
2. comprueba su SHA-256;
3. aplica `patches/*.patch` en orden;
4. cambia la versión de `package.json` a `2.7.1+customs.<N>`;
5. lo empaqueta en `dist/` con su `SHA256SUMS`.

Al subir una etiqueta `v2.7.1-customs.<N>`, GitHub Actions ejecuta el script y
publica la release (`.github/workflows/release.yml`).

Para construirlo en local con un original ya descargado:

```sh
ORIGINAL=industrialshields-boards-esp32-2.7.1.tar.bz2 scripts/build.sh
```

## Licencia

Cada parche modifica un fichero del paquete original y queda bajo la misma
licencia que ese fichero:

- Ficheros de Industrial Shields (`pins_is.h`, `SC16IS752.cpp`,
  `plc-peripherals/`): **LGPL-3.0-or-later**.
- Ficheros de Espressif (`libraries/FS`): **Apache-2.0**.

El paquete publicado incluye el código fuente completo y conserva los avisos de
copyright originales. Los cambios están marcados en el código con el
comentario `industrialshields-esp32-customs`.
