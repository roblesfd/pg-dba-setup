# Base de datos `dvdrental`

## Propósito

`dvdrental` es una base de datos de ejemplo para PostgreSQL que representa las operaciones de un negocio de alquiler de películas en formato DVD.

En este proyecto se utiliza como **base de datos de laboratorio** para practicar administración, seguridad, SQL, permisos, backups, restauración, monitorización y rendimiento de PostgreSQL.

La base contiene un modelo relacional con **15 tablas, 7 vistas, 10 funciones/funciones auxiliares visibles en la instancia, 13 secuencias y funciones asociadas a triggers**.

---

## Esquema

La base utiliza actualmente un único esquema:

    public

El propietario del esquema es:

    pg_database_owner

Las tablas, vistas, funciones y secuencias restauradas pertenecen actualmente al usuario:

    postgres

---

## Tablas

La base contiene 15 tablas:

| Tabla | Propósito |
|---|---|
| `actor` | Información de los actores. |
| `address` | Direcciones utilizadas por clientes y personal. |
| `category` | Categorías de películas. |
| `city` | Ciudades asociadas a direcciones. |
| `country` | Países asociados a ciudades. |
| `customer` | Clientes del servicio de alquiler. |
| `film` | Catálogo de películas. |
| `film_actor` | Relación entre películas y actores. |
| `film_category` | Relación entre películas y categorías. |
| `inventory` | Copias físicas disponibles por tienda. |
| `language` | Idiomas de las películas. |
| `payment` | Pagos realizados por los clientes. |
| `rental` | Historial de alquileres. |
| `staff` | Personal que administra las tiendas y procesa operaciones. |
| `store` | Tiendas del negocio. |

Estas tablas representan las principales entidades y relaciones del negocio de alquiler de películas.

---

## Relaciones principales

El modelo puede entenderse mediante varios grupos relacionados.

### Catálogo

    film
      ├── film_actor ── actor
      ├── film_category ── category
      └── language

`film` representa el catálogo y se relaciona con actores, categorías e idiomas.

Las tablas `film_actor` y `film_category` funcionan como tablas intermedias para relaciones muchos-a-muchos.

### Inventario

    film
      │
      ▼
    inventory
      │
      ▼
    store

Una película puede tener ejemplares físicos en diferentes tiendas mediante `inventory`.

### Clientes y alquileres

    customer
        │
        ▼
      rental
        │
        ├── inventory
        │
        └── staff

`rental` representa las operaciones de alquiler y conecta al cliente, el ejemplar alquilado y el empleado que procesa la operación.

### Pagos

    customer
        │
        ▼
      payment
        │
        ├── rental
        └── staff

`payment` registra los pagos asociados a las operaciones realizadas por los clientes.

### Ubicación

    country
       │
       ▼
     city
       │
       ▼
    address
       │
       ├── customer
       ├── staff
       └── store

Este conjunto representa la información geográfica utilizada por clientes, empleados y tiendas.

### Tiendas

    store
      ├── address
      ├── staff
      └── inventory

Las tiendas representan las unidades físicas donde se mantiene el inventario y se realizan las operaciones.

---

## Flujo principal del negocio

El flujo principal puede representarse como:

    film
      ↓
    inventory
      ↓
    rental
      ↓
    payment

Este flujo será especialmente útil durante las prácticas de SQL, permisos, índices, monitorización y análisis de rendimiento.

---

## Vistas

La instancia contiene 7 vistas:

| Vista | Propósito general |
|---|---|
| `actor_info` | Información consolidada de actores y películas. |
| `customer_list` | Información de clientes y sus datos asociados. |
| `film_list` | Información consolidada del catálogo. |
| `nicer_but_slower_film_list` | Variante más elaborada de información del catálogo. |
| `sales_by_film_category` | Información agregada de ventas por categoría. |
| `sales_by_store` | Información agregada de ventas por tienda. |
| `staff_list` | Información consolidada del personal. |

Las vistas proporcionan una oportunidad para practicar consultas sobre objetos derivados y posteriormente estudiar permisos específicos sobre vistas.

---

## Funciones

La instancia contiene las siguientes funciones y objetos relacionados:

| Función | Propósito |
|---|---|
| `_group_concat` | Función auxiliar para concatenación de valores. |
| `film_in_stock` | Obtiene información sobre disponibilidad de una película en una tienda. |
| `film_not_in_stock` | Identifica disponibilidad ausente de una película en una tienda. |
| `get_customer_balance` | Calcula el balance de un cliente para una fecha determinada. |
| `group_concat` | Agregación para concatenar valores. |
| `inventory_held_by_customer` | Identifica el cliente que mantiene un inventario alquilado. |
| `inventory_in_stock` | Determina si un ejemplar está disponible. |
| `last_day` | Obtiene el último día del mes correspondiente a una fecha. |
| `last_updated` | Función utilizada por el mecanismo de actualización automática. |
| `rewards_report` | Genera información de clientes que cumplen determinados criterios de compras. |

La presencia de funciones permite utilizar `dvdrental` posteriormente para prácticas de **funciones, ejecución, privilegios sobre funciones y seguridad de objetos**.

---

## Secuencias

La base contiene 13 secuencias asociadas principalmente a identificadores generados automáticamente:

    actor_actor_id_seq
    address_address_id_seq
    category_category_id_seq
    city_city_id_seq
    country_country_id_seq
    customer_customer_id_seq
    film_film_id_seq
    inventory_inventory_id_seq
    language_language_id_seq
    payment_payment_id_seq
    rental_rental_id_seq
    staff_staff_id_seq
    store_store_id_seq

Estas secuencias serán relevantes para estudiar permisos de `USAGE`, `SELECT` y `UPDATE` cuando se realicen operaciones de escritura.

---

## Triggers

La base incluye un mecanismo basado en la función:

    last_updated

Este mecanismo permite practicar posteriormente el funcionamiento de triggers y funciones asociadas a ellos.

---

## Modelo de permisos

La base será utilizada con los roles definidos en la Fase 4:

| Rol | Uso |
|---|---|
| `admin` | Administración de la base. |
| `app_readwrite` | Operaciones de lectura y escritura. |
| `app_readonly` | Consultas de solo lectura. |
| `backup_user` | Operaciones relacionadas con backups. |

Los usuarios de conexión se mantienen separados de los roles funcionales.

---

## Uso dentro del proyecto DBA

`dvdrental` será utilizada como base de laboratorio durante las siguientes fases:

### Seguridad y permisos

Prácticas de:

- `GRANT`;
- `REVOKE`;
- privilegios sobre tablas;
- privilegios sobre secuencias;
- privilegios sobre vistas;
- privilegios sobre funciones;
- `ALTER DEFAULT PRIVILEGES`;
- principio de mínimo privilegio.

### Backup y restauración

La base será utilizada para:

- backups lógicos;
- restauraciones;
- pruebas de recuperación;
- medición de tiempos de recuperación;
- análisis de RTO/RPO.

### Monitorización

Se utilizará para estudiar:

- conexiones;
- actividad;
- locks;
- transacciones;
- estadísticas;
- logs.

### Rendimiento

La estructura relacional permite practicar:

- índices;
- `EXPLAIN`;
- `EXPLAIN ANALYZE`;
- análisis de consultas;
- joins;
- agregaciones;
- planes de ejecución.

---

## Estado actual

Base:

    dvdrental

Esquema:

    public

Tablas:

    15

Vistas:

    7

Funciones y funciones auxiliares:

    10

Secuencias:

    13

Propietario principal de los objetos:

    postgres

La base utiliza el dataset estándar de PostgreSQL DVD Rental y constituye el dataset principal de laboratorio del proyecto **De Cero a Producción**.

---

## Fuente del dataset

El dataset `dvdrental` es un ejemplo de base de datos PostgreSQL diseñado para representar las operaciones de un negocio de alquiler de DVD. El esquema estándar está ampliamente utilizado en tutoriales y ejercicios de PostgreSQL.
