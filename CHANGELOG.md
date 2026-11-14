# Cambios

## v2.7.1-customs.2

Define `INDUSTRIALSHIELDS_ESP32_CUSTOMS` = 2. Incluye los parches 0001-0004 de customs.1 y:

| Parche | Fichero | Arreglo |
|---|---|---|
| 0005 | `libraries/SD/src/sd_diskio.cpp` | `ff_sd_status()` y `sdcard_uninit()` toman el bus SPI (`AcquireSPI`) como el resto del driver. Sin ello, `sdTransaction()` seleccionaba la tarjeta sin el mutex del bus y, si coincidía con el SC16IS752 (módem y RS-232), quedaban dos chips seleccionados: el módem recibía `0xFF` |

Probado en un ESP32 PLC 21 (LTE en la expansión 1, CAN en la 2, MicroSD):

| Parche | Resultado en el PLC |
|---|---|
| 0001 | Compila con `RS232` y la expansión CAN |
| 0002 | No rompe nada; no hemos podido reproducir de nuevo el fallo, así que no está demostrado que lo arregle |
| 0003 | No rompe nada; el NTP con `NBUDP` de la librería NB sigue fallando con la SD grabando, así que no era (solo) esto |
| 0004 | `SD.remove()` borra con los dos ficheros del montaje abiertos, sin errores |
| 0005 | Con la SD grabando, el módem registra y no recibe ningún `0xFF` sin rodeos en el sketch |

`File::openNextFile()` sigue abriendo cada fichero al listar: para listar con todos los descriptores en uso, usar `opendir()`/`readdir()`.

## v2.7.1-customs.1

Sobre `framework-industrialshields-esp32` 2.7.1 (ESP32 PLC de Industrial Shields).
No oficial. Define `INDUSTRIALSHIELDS_ESP32_CUSTOMS` = 1.

| Parche | Fichero | Arreglo |
|---|---|---|
| 0001 | `variants/esp32plc/pins_is.h` | El RS-232 y `Serial2` solo se pierden si la expansión 2 usa ese UART (GPRS, NB, LTE); con el CAN (SPI) vuelven a estar disponibles |
| 0002 | `plc-peripherals/src/peripheral-mcp23008.c` | Mutex en la lectura-modificación-escritura de `mcp23008_write()` y `mcp23008_set_pin_mode()`: dos tareas ya no se pisan los pines del expansor |
| 0003 | `cores/industrialshields/SC16IS752.cpp` | `write()` espera hasta 20 ms al mutex del chip en vez de devolver 0 sin escribir |
| 0004 | `libraries/FS/src/vfs_api.cpp` | `remove()` y `rmdir()` usan `stat()` en vez de abrir el fichero: funcionan aunque estén en uso todos los descriptores del montaje |

