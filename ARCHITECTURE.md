# 🏛️ Arquitectura Elegant Cut Mobile

Este documento explica la estructura de carpetas y la organización del proyecto Flutter para asegurar que sea escalable, mantenible y profesional.

## 📁 Estructura de Carpetas

La lógica del proyecto se encuentra dentro de `lib/src/`, dividida por responsabilidades:

### 1. `api/`
Contiene los servicios que se comunican con el backend (NestJS).
- **Ejemplo**: `auth_service.dart` maneja las peticiones POST de login/registro.
- **Regla**: Aquí no debe haber nada de UI, solo lógica de red y parseo de datos.

### 2. `models/`
Clases que representan tus datos.
- **Objetivo**: Convertir los mapas (JSON) que vienen del servidor en objetos de Dart con tipado fuerte (ej: `UserModel`).

### 3. `pages/`
Contiene las pantallas completas de la aplicación.
- **Ejemplo**: `login_page.dart`.
- **Regla**: Deben ser lo más "tontas" posible, delegando la lógica pesada a los servicios o providers.

### 4. `theme/`
Centraliza el diseño visual de la app.
- **Archivo**: `app_theme.dart`.
- **Ventaja**: Si decides cambiar el color dorado por uno plateado, solo lo cambias en este archivo y se actualiza en TODA la app.

### 5. `utils/`
Herramientas y valores globales.
- **`constants.dart`**: Aquí vive la `baseUrl`. Si cambias de servidor o pasas de local a producción, solo editas una línea aquí.

### 6. `widgets/`
Componentes pequeños y reutilizables.
- **Ejemplo**: Un botón personalizado, un input con estilo madera, o una tarjeta de barbero.

---

## 🚀 Flujo de Trabajo Recomendado

1. **Definir el Modelo**: Si vas a traer servicios, crea primero el `service_model.dart`.
2. **Crear el Servicio API**: Crea el método en `lib/src/api/` para traer los datos.
3. **Maquetar la Página**: Crea la UI en `lib/src/pages/`.
4. **Conectar**: Llama al servicio desde la página y muestra los datos.

## 🔐 Seguridad y Tokens

El backend (NestJS) devuelve un token JWT. En el futuro, usaremos un **Provider** o un **Secure Storage** para guardar ese token en el celular y que el usuario no tenga que loguearse cada vez que abra la app.

---
*Documento generado para el equipo de Elegant Cut.*
