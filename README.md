# Bibliotk

Backend API desarrollado en Ruby on Rails para el sistema de reseñas y calificaciones de Bibliotk.

La aplicación permite crear, editar y eliminar reseñas, consultar libros y sus calificaciones, banear y desbanear usuarios, y estimar el impacto que tendría un baneo antes de realizarlo. Los promedios de los libros se mantienen mediante agregados para que la lectura del catálogo no dependa de la cantidad total de reseñas.

## Stack

* Ruby `3.2.1`
* Ruby on Rails `8.1.2`
* PostgreSQL `18.6`
* RSpec
* FactoryBot

## Instalación

Instalar las dependencias Ruby:

```bash
bundle install
```

La aplicación utiliza PostgreSQL. La configuración de conexión puede ajustarse en `config/database.yml`.

### Crear la base de datos

```bash
bin/rails db:create
```

### Ejecutar las migraciones

```bash
bin/rails db:migrate
```

También es posible realizar ambas operaciones como parte del setup de Rails:

```bash
bin/rails db:prepare
```

## Ejecutar la aplicación

Levantar el servidor de desarrollo:

```bash
bin/rails server
```

Por defecto Rails quedará disponible en:

```text
http://localhost:3000
```

---

# API

La aplicación expone una API REST bajo `/api/v1`.

## Identificación del usuario

Por simplicidad, esta prueba técnica **no implementa un sistema real de autenticación ni autorización**. No se utilizaron soluciones como Devise, Pundit o CanCanCan, ya que incorporar una capa completa de identidad y permisos habría aumentado el alcance sin aportar al problema principal que se busca resolver.

Para las operaciones que necesitan conocer al usuario actual se utiliza el header:

```text
X-User-Id
```

Por ejemplo:

```bash
curl \
  -H "X-User-Id: 1" \
  http://localhost:3000/api/v1/me/reviews
```

`X-User-Id` es deliberadamente una implementación mínima para esta prueba técnica y **no debe considerarse un mecanismo seguro ni apropiado para producción**. Un cliente puede enviar cualquier ID. En producción debería reemplazarse por autenticación real y las operaciones administrativas deberían estar protegidas mediante autorización basada en roles o permisos.

## Endpoints

| Método   | Ruta                            | Descripción                             |
| -------- | ------------------------------- | --------------------------------------- |
| `GET`    | `/api/v1/books`                 | Lista los libros y sus calificaciones   |
| `GET`    | `/api/v1/books/:id`             | Obtiene un libro y sus reseñas públicas |
| `POST`   | `/api/v1/books/:book_id/review` | Crea la reseña del usuario actual       |
| `PATCH`  | `/api/v1/books/:book_id/review` | Edita la reseña del usuario actual      |
| `DELETE` | `/api/v1/books/:book_id/review` | Elimina la reseña del usuario actual    |
| `GET`    | `/api/v1/me/reviews`            | Lista las reseñas del usuario actual    |
| `GET`    | `/api/v1/users/:id/ban_impact`  | Estima el impacto de banear un usuario  |
| `POST`   | `/api/v1/users/:id/ban`         | Banea un usuario                        |
| `POST`   | `/api/v1/users/:id/unban`       | Desbanea un usuario                     |

Las rutas disponibles también pueden inspeccionarse directamente con:

```bash
bin/rails routes
```

## Ejemplos con cURL

### Listar libros

```bash
curl http://localhost:3000/api/v1/books
```

### Obtener un libro

```bash
curl http://localhost:3000/api/v1/books/1
```

### Crear una reseña

El usuario se identifica mediante `X-User-Id`.

```bash
curl -X POST \
  http://localhost:3000/api/v1/books/1/review \
  -H "Content-Type: application/json" \
  -H "X-User-Id: 1" \
  -d '{
    "review": {
      "rating": 5,
      "content": "Excelente libro"
    }
  }'
```

### Editar una reseña

```bash
curl -X PATCH \
  http://localhost:3000/api/v1/books/1/review \
  -H "Content-Type: application/json" \
  -H "X-User-Id: 1" \
  -d '{
    "review": {
      "rating": 4,
      "content": "Muy buen libro, aunque cambié mi calificación"
    }
  }'
```

También puede utilizarse `PUT` si la ruta fue configurada para aceptarlo:

```bash
curl -X PUT \
  http://localhost:3000/api/v1/books/1/review \
  -H "Content-Type: application/json" \
  -H "X-User-Id: 1" \
  -d '{
    "review": {
      "rating": 4,
      "content": "Reseña actualizada"
    }
  }'
```

### Eliminar una reseña

```bash
curl -X DELETE \
  http://localhost:3000/api/v1/books/1/review \
  -H "X-User-Id: 1"
```

### Consultar las reseñas propias

```bash
curl \
  -H "X-User-Id: 1" \
  http://localhost:3000/api/v1/me/reviews
```

Las reseñas de un usuario baneado dejan de participar en el promedio público, pero se conservan. El usuario puede continuar consultando su historial de reseñas.

### Estimar el impacto de un baneo

Esta operación **no banea al usuario ni modifica datos**. Permite consultar cómo cambiarían los libros afectados antes de tomar la decisión.

```bash
curl \
  http://localhost:3000/api/v1/users/1/ban_impact
```

### Banear un usuario

```bash
curl -X POST \
  http://localhost:3000/api/v1/users/1/ban
```

### Desbanear un usuario

```bash
curl -X POST \
  http://localhost:3000/api/v1/users/1/unban
```

En una aplicación de producción, los endpoints de baneo, desbaneo y estimación de impacto deberían estar protegidos mediante autenticación y autorización administrativa.

---

# Tests

La suite utiliza RSpec.

Antes de ejecutar los tests por primera vez, crea la base de datos del entorno de test:

```bash
RAILS_ENV=test bin/rails db:create
```

## Ejecutar toda la suite

```bash
bundle exec rspec
```


## Ejecutar un archivo específico

Por ejemplo:

```bash
bundle exec rspec spec/models/book_spec.rb
```

```bash
bundle exec rspec spec/services/users/ban_spec.rb
```

```bash
bundle exec rspec spec/services/users/estimate_ban_impact_spec.rb
```

```bash
bundle exec rspec spec/services/reviews/review_lifecycle_spec.rb
```

```bash
bundle exec rspec spec/models/review_concurrency_spec.rb
```

```bash
bundle exec rspec spec/services/reviews/concurrency_spec.rb
```

## Ejecutar un test específico por línea

RSpec permite ejecutar solamente el ejemplo que se encuentra alrededor de una línea:

```bash
bundle exec rspec spec/models/book_spec.rb:25
```

La suite cubre, entre otros comportamientos, los bordes del redondeo `half-up`, el umbral mínimo de tres reseñas, el efecto retroactivo de los baneos, el ciclo de creación/edición/eliminación, la unicidad de una reseña por usuario y libro bajo concurrencia y un test de consistencia bajo peticiones de 200 usuarios concurrentes.

---

# Seeds

## Seed principal

El seed principal genera datos de desarrollo con usuarios, 50 libros y reseñas asociadas.

Ejecutar:

```bash
bin/rails db:seed
```

Si se desea reconstruir completamente una base de desarrollo desde cero:

```bash
bin/rails db:reset
```

> `db:reset` elimina y recrea la base de datos, por lo que no debe utilizarse sobre datos que se quieran conservar.

## Stress seed: 500.000 reseñas

Existe además un seed especializado para pruebas de carga. Este selecciona uno de los libros del catálogo y genera **500.000 reseñas**, cada una perteneciente a un usuario diferente para respetar el invariante de una reseña por usuario y libro.

Primero debe haberse ejecutado el seed principal:

```bash
bin/rails db:seed
```

Luego:

```bash
bin/rails runner db/seeds/stress_test.rb
```

Este proceso crea una cantidad considerable de registros y está pensado exclusivamente para desarrollo y pruebas de rendimiento.

---

# Benchmark del listado de libros

El proyecto incluye una tarea para medir el rendimiento del listado de los 50 libros:

```bash
bin/rails benchmark:books_index
```

Puede aumentarse el número de iteraciones:

```bash
ITERATIONS=1000 bin/rails benchmark:books_index
```

La prueba puede ejecutarse antes y después del stress seed:

```bash
bin/rails db:seed

ITERATIONS=1000 bin/rails benchmark:books_index

bin/rails runner db/seeds/stress_test.rb

ITERATIONS=1000 bin/rails benchmark:books_index
```

El objetivo es verificar que incorporar un libro con 500.000 reseñas no haga que el costo de listar el catálogo crezca proporcionalmente a la cantidad de reseñas.

Esto es posible porque el listado no calcula `AVG(rating)` recorriendo `reviews`. Cada libro mantiene:

```text
reviews_sum
reviews_count
```

y el promedio se obtiene a partir de esos agregados. Por lo tanto, la consulta del catálogo depende de los 50 libros que se muestran y no de recorrer cientos de miles de reseñas.

La tarea informa tiempo de ejecución y cantidad de consultas SQL, permitiendo comparar ambas ejecuciones de manera reproducible.

---

# Recalcular la calificación de un libro

`reviews` se considera la fuente de verdad, mientras que `reviews_sum` y `reviews_count` son datos derivados.

El proyecto incluye una tarea de mantenimiento que permite reconstruir los agregados de un libro utilizando sus reseñas válidas:

```bash
bin/rails "books:rebuild_review_stats[BOOK_ID]"
```

Por ejemplo:

```bash
bin/rails "books:rebuild_review_stats[42]"
```

La tarea utiliza internamente `Books::RebuildReviewStats`, por lo que comparte la misma lógica utilizada por la aplicación y excluye del cálculo las reseñas pertenecientes a usuarios baneados.

Puede verificarse la existencia de la tarea con:

```bash
bin/rails -T books
```

---

# Reglas principales del sistema

Las calificaciones son enteros entre 1 y 5 y cada usuario puede escribir como máximo una reseña por libro. El promedio público se muestra con un decimal utilizando redondeo `half-up`; mientras existan menos de tres reseñas válidas, el libro muestra `"Reseñas Insuficientes"`.

Las reseñas de usuarios baneados se conservan pero dejan de aparecer públicamente y no participan en los agregados. Banear o desbanear un usuario reconstruye los libros afectados para mantener sus calificaciones consistentes. El usuario que escribió una reseña conserva acceso a su historial, incluso cuando su cuenta está baneada.

Para mantener eficiente la lectura del catálogo, los libros almacenan `reviews_sum` y `reviews_count`. La tabla `reviews` permanece como fuente de verdad, permitiendo reconstruir estos valores mediante `Books::RebuildReviewStats` cuando sea necesario.

## Decisiones técnicas y de producto

Las decisiones, ambigüedades y trade-offs de la implementación están documentados en:

```text
DECISIONES.md
```

Las decisiones relacionadas con Moderación, Growth, Soporte, comunicación a autores, métricas y reparación de promedios se encuentran en:

```text
PRODUCTO.md
```
