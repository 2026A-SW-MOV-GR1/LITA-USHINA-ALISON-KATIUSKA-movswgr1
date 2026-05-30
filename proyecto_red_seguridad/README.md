
# Proyecto: Red y Almacenamiento Seguro móvil

Este proyecto individual contiene la implementación de una aplicación móvil en Flutter que resuelve dos problemas críticos de la ingeniería de software: la conectividad con servidores externos mediante APIs REST de forma asíncrona y la protección de datos confidenciales utilizando los compartimentos de persistencia nativos del sistema operativo Android.

## Tecnologías Utilizadas
* **Framework:** Flutter.
* **Lenguajes:** Dart (interfaz y lógica de red) y soporte nativo en Kotlin.
* **Protocolos de Red:** HTTP (peticiones GET y PUT) con intercambio de datos en formato JSON.
* **Criptografía y Persistencia:** SharedPreferences nativo, emulación de Jetpack DataStore y almacenamiento encriptado con algoritmos AES-256 (Flutter Secure Storage).

---

## Descripción de los Módulos Evaluados

### Módulo 1: Conectividad API REST
* **Consulta (GET):** Permite ingresar un identificador numérico único (ID del 1 al 100) para consumir datos reales desde el servidor de pruebas JSONPlaceholder.
* **Control de Carga (UX):** Bloquea automáticamente todos los campos de texto y botones de la interfaz mientras la petición de red está en tránsito, mostrando un indicador visual de carga (CircularProgressIndicator) para evitar la duplicidad de peticiones.
* **Actualización (PUT):** Permite modificar localmente el título y cuerpo del post cargado, enviando de vuelta un JSON serializado. Captura el código HTTP **200 OK** de respuesta exitosa del servidor para actualizar el estado visual de la pantalla.

### Módulo 3: Almacenamiento Seguro 
Para cumplir con los principios de seguridad de datos, la interfaz opera de forma puramente transaccional (a ciegas), impidiendo el listado público de las llaves en disco duro:
1. **SharedPreferences:** Almacenamiento directo clave-valor en texto plano para configuraciones rápidas de interfaz.
2. **DataStore:** Persistencia asíncrona reactiva estructurada mediante un canal aislado en disco.
3. **EncryptedSharedPreferences:** Caja fuerte criptográfica que cifra automáticamente llaves y valores mediante encriptación de grado militar AES-256 en el almacenamiento local de Android.
* **Validación Genérica:** Si el usuario intenta recuperar una llave inexistente o en un compartimento equivocado, el sistema emite una alerta genérica de error para evitar la filtración de información.

---

## Instrucciones de Ejecución Rapida
1. Clonar este repositorio en su máquina local.
2. Abrir la terminal dentro de la carpeta del proyecto y ejecutar `flutter pub get` para reconstruir los paquetes.
3. Iniciar el emulador de Android (se sugiere ejecutar un Cold Boot si el dispositivo no responde).
4. Correr la aplicación en modo desarrollo usando el comando `flutter run`.