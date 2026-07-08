import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CounterLifecycleScreen(),
    );
  }
}

class CounterLifecycleScreen extends StatefulWidget {
  const CounterLifecycleScreen({Key? key}) : super(key: key);

  @override
  State<CounterLifecycleScreen> createState() => _CounterLifecycleScreenState();
}

// Añadimos WidgetsBindingObserver para escuchar los eventos del ciclo de vida
class _CounterLifecycleScreenState extends State<CounterLifecycleScreen> with WidgetsBindingObserver {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    // Registramos este widget en el observador del ciclo de vida
    WidgetsBinding.instance.addObserver(this);
    print("LOG_CICLO_VIDA: [Flutter InitState] -> Equivalente a onCreate / Inicializado");
  }

  @override
  void dispose() {
    // Limpiamos el observador cuando el widget muere
    WidgetsBinding.instance.removeObserver(this);
    print("LOG_CICLO_VIDA: [Flutter Dispose] -> Equivalente a onDestroy / Destruido");
    super.dispose();
  }

  // Este método captura los cambios de estado del ciclo de vida en la app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        print("LOG_CICLO_VIDA: AppLifecycleState.resumed -> Equivalente a onResume (App enfocada y visible)");
        break;
      case AppLifecycleState.inactive:
        print("LOG_CICLO_VIDA: AppLifecycleState.inactive -> Equivalente a onPause (App perdiendo foco temporalmente)");
        break;
      case AppLifecycleState.paused:
        print("LOG_CICLO_VIDA: AppLifecycleState.paused -> Equivalente a onStop (App enviada por completo al fondo)");
        break;
      case AppLifecycleState.detached:
        print("LOG_CICLO_VIDA: AppLifecycleState.detached -> La app sigue viva pero desligada de la vista nativa");
        break;
      case AppLifecycleState.hidden:
        print("LOG_CICLO_VIDA: AppLifecycleState.hidden -> La app se ha ocultado visualmente");
        break;
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("LOG_CICLO_VIDA: [Flutter Build] -> Renderizando interfaz gráfica");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taller Ciclo de Vida'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Valor del contador:',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '$_counter',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Incrementar',
        child: const Icon(Icons.add),
      ),
    );
  }
}