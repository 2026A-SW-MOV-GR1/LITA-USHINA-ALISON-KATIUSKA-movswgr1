class ElementoModel {
  final int? id; // SQL usa enteros autoincrementables; en NoSQL se mapea igual
  final String titulo;
  final String descripcion;

  ElementoModel({
    this.id,
    required this.titulo,
    required this.descripcion,
  });

  // Transforma el objeto de Flutter a un Mapa para poder guardarlo en SQL o un archivo JSON
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
    };
  }

  // Toma un mapa de la base de datos (sea SQL o NoSQL) y lo vuelve a transformar en un objeto de Flutter
  factory ElementoModel.fromMap(Map<String, dynamic> map) {
    return ElementoModel(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descripcion: map['descripcion'] as String,
    );
  }
}