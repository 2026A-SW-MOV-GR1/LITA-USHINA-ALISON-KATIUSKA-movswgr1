import 'dart:developer' as developer;

class AppLogger {
  // Imprime trazas informativas generales
  static void info(String mensaje) {
    developer.log('🟢 [INFO] $mensaje', name: 'EXAMEN_PERSISTENCIA');
  }

  // Imprime trazas de depuración técnica o cambios de motor
  static void debug(String mensaje) {
    developer.log('🔵 [DEBUG] $mensaje', name: 'EXAMEN_PERSISTENCIA');
  }

  // Imprime trazas críticas ante fallos o excepciones
  static void error(String mensaje, [Object? error]) {
    developer.log('🔴 [ERROR] $mensaje ${error ?? ""}', name: 'EXAMEN_PERSISTENCIA');
  }
}