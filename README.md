#### Guía: Cómo Ejecutar el Script de Optimización 

#### Paso 1: Abrir la Terminal

1. Presiona las teclas Comando (⌘) + Espacio para abrir **Spotlight**.
2. Escribe Terminal y presiona Enter.

#### Paso 2: Navegar hasta tu pendrive "black"

En macOS, todos los discos externos y pendrives se montan en la carpeta /Volumes. Para ir a tu pendrive, ejecuta el siguiente comando: 


cd /Volumes/black

--------------------------------------------------
#### Paso 3: Otorgar permisos de ejecución:
Por seguridad, macOS bloquea la ejecución de scripts nuevos. Debes darle permisos al archivo con este comando: 


chmod +x optimizar_mac_mejorado.sh

---------------------------------------------------
#### Paso 4: Ejecutar el script

Ahora puedes iniciar el proceso de optimización corriendo el script desde el pendrive: 

./optimizar_mac_mejorado.sh


### ⚠️ ¿Qué sucederá durante la ejecución?

1. **Solicitud de contraseña:** La Terminal te pedirá tu contraseña de administrador de la Mac (Password:). 

  * *Nota importante:* Al escribir tu contraseña, **no se verá nada en la pantalla** (ni asteriscos ni letras). Esto es una medida de seguridad de macOS. Escríbela a ciegas y presiona Enter.
2. **Apertura de Finder:** El script abrirá automáticamente la ventana de la caché de tu usuario para que revises los archivos residuales.
3. **Reinicio recomendado:** Una vez que termine el script, se recomienda que **reinicies tu MacBook** para que el sistema aplique la limpieza de las bases de datos de fuentes correctamente.

    ##Creado por rTech
