@echo off
:: Script para configurar Firewall de Bacula (Puertos agrupados)
:: Ejecutar como Administrador

echo.
echo ==========================================
echo   CONFIGURANDO REGLA: bacula-fd
echo ==========================================
echo.

:: 1. Regla de ENTRADA (Todos los puertos juntos)
echo Creando regla de ENTRADA para puertos 9101, 9102, 903...
netsh advfirewall firewall add rule name="bacula-fd" dir=in action=allow protocol=TCP localport=9101,9102,903

:: 2. Regla de SALIDA (Todos los puertos juntos)
echo Creando regla de SALIDA para puertos 9101, 9102, 903...
netsh advfirewall firewall add rule name="bacula-fd" dir=out action=allow protocol=TCP localport=9101,9102,903

echo.
echo ==========================================
echo   VERIFICACION
echo ==========================================
:: Muestra las reglas creadas para confirmar
netsh advfirewall firewall show rule name="bacula-fd" | findstr "Nombre Dirección Puerto"

echo.
echo Proceso finalizado.
pause