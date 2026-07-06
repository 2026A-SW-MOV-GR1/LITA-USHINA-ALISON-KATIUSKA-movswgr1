# Taller: Native UI Re-Engineering & UX Analysis - SoundCloud Clone
**Estudiante:** Alison Katiuska Lita Ushiña  
**Institución:** Escuela Politécnica Nacional  
**Facultad:** Ingeniería de Sistemas  
**Materia:** Aplicaciones Móviles

---

## Fase A: Selección y Análisis (Entregable 1)

### 1. Definición de Mercado Objetivo
SoundCloud está dirigida principalmente a un segmento de **jóvenes y adultos jóvenes (15 a 35 años)**. Sus usuarios clave incluyen:
* **Creadores de contenido y DJs independientes:** Personas que buscan subir sus maquetas, podcasts o mezclas sin las restricciones de las discográficas tradicionales.
* **Oyentes entusiastas de nicho:** Usuarios con un nivel socioeconómico medio-alto, con acceso a planes de datos móviles estables, que buscan activamente música alternativa, géneros emergentes (como Lo-Fi, Synthwave, Trap underground) y remezclas que no se encuentran en plataformas comerciales tradicionales.

### 2. Psicología del Color (Identificación y Justificación)
* **Color Primario (Naranja - `#FF5500`):** Evoca emociones de creatividad, entusiasmo, juventud y accesibilidad. Es un color enérgico que rompe de forma disruptiva con los azules y verdes corporativos, conectando con el espíritu independiente y vibrante de su comunidad artística.
* **Color de Fondo (Negro Absoluto - `#000000`):** Siguiendo las tendencias actuales de interfaces móviles, se utiliza para reducir la fatiga visual en sesiones de escucha prolongadas (frecuentemente nocturnas) y optimizar el consumo de batería en pantallas OLED/AMOLED.
* **Colores Secundarios/Acentos (Gris Claro y Blanco - `#FFFFFF` / `#9E9E9E`):** Proporcionan un contraste nítido y limpio para la legibilidad de títulos, metadatos y estados secundarios de los íconos sin competir con la jerarquía del color de marca.

### 3. Auditoría de Componentes (Estructura de Listas Nativas)
Para garantizar el estándar de **60 FPS** demandado, se identificaron y replicaron los siguientes componentes perezosos (*Lazy Loading*) que evitan el sobrecalentamiento de la memoria:
1.  **Lista 1 (Horizontal - Carrusel de Recomendados):** Implementada mediante `ListView.builder` con orientación horizontal para renderizar dinámicamente las carátulas cuadradas y títulos de álbumes.
2.  **Lista 2 (Vertical - Tendencias Globales):** Renderizada perezosamente mediante celdas personalizadas (`TrackTileWidget`) estructurando de forma limpia el ranking de pistas más escuchadas.
3.  **Lista 3 (Vertical - Recomendaciones de Artistas):** Reutiliza la lógica de reciclaje de celdas para listar canciones recomendadas basadas en el historial simlativo.

---

## Fase C: Crítica y Propuesta de Mejora (Entregable Final)

### 1. Análisis Crítico (Falla de UX Detectada)
En la aplicación original de SoundCloud, la transición entre explorar listas de reproducción extensas y activar la escucha de un tema carece en ocasiones de un **feedback visual e interactivo inmediato**. La interfaz se mantiene estática hasta que el reproductor global se inicializa por completo, lo que puede dar la falsa percepción de retraso (*lag*) o falta de respuesta al tacto del usuario en conexiones móviles inestables.

### 2. Propuesta Tecnológica e Implementación en el Clon
Se diseñó e implementó un mecanismo de **micro-interacciones fluidas y reactivas al tacto** en cada celda vertical (`TrackTileWidget`):
* **Micro-animación de Escala (*Scale Animation*):** Al presionar cualquier canción, la fila completa experimenta un sutil efecto de "hundido" o compresión neumática (escala de `1.0` a `0.95`) en un intervalo de **100 milisegundos** gracias al widget nativo `AnimatedScale`. Esto le confirma instantáneamente al sistema nervioso del usuario que su pulsación fue registrada con éxito por el hardware gráfico.
* **Retroalimentación de Estado Dinámica (Color de Marca):** El elemento seleccionado cambia instantáneamente su tipografía e íconos principales al **Naranja oficial (`#FF5500`)**, mutando además el botón de menú lateral por un botón interactivo de pausa (`Icons.pause_circle_filled`). Esto soluciona de raíz la monotonía cromática y asienta visualmente qué pista se encuentra en ejecución en ese instante exacto.