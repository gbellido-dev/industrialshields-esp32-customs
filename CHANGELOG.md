# Cambios

## v2.7.1-customs.1

Sobre `framework-industrialshields-esp32` 2.7.1 (ESP32 PLC de Industrial Shields).
No oficial. Define `INDUSTRIALSHIELDS_ESP32_CUSTOMS` = 1.

| Parche | Fichero | Arreglo |
|---|---|---|
| 0001 | `variants/esp32plc/pins_is.h` | El RS-232 y `Serial2` solo se pierden si la expansión 2 usa ese UART (GPRS, NB, LTE); con el CAN (SPI) vuelven a estar disponibles |
| 0002 | `plc-peripherals/src/peripheral-mcp23008.c` | Mutex en la lectura-modificación-escritura de `mcp23008_write()` y `mcp23008_set_pin_mode()`: dos tareas ya no se pisan los pines del expansor |
| 0003 | `cores/industrialshields/SC16IS752.cpp` | `write()` espera hasta 20 ms al mutex del chip en vez de devolver 0 sin escribir |
| 0004 | `libraries/FS/src/vfs_api.cpp` | `remove()` y `rmdir()` usan `stat()` en vez de abrir el fichero: funcionan aunque estén en uso todos los descriptores del montaje |

Pendiente para una release siguiente: la SD y el SC16IS752 se pisan en el bus SPI (`sd_diskio.cpp`), y `File::openNextFile()` abre cada fichero al listar.
