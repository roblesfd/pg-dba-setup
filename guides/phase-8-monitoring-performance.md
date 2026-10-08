# Fase 8: Monitorización y rendimiento de PostgreSQL

## 1. Objetivos

Implementar una estrategia básica de monitorización y diagnóstico de rendimiento en PostgreSQL 17 mediante las vistas estadísticas del sistema, `pg_stat_statements`, el análisis de bloqueos, las estadísticas de índices y los planes de ejecución.

Al finalizar esta fase se deberá poder:

- Consultar las sesiones y conexiones activas.
- Analizar transacciones, lecturas y escrituras.
- Identificar sesiones bloqueadas y sus bloqueadoras.
- Localizar consultas con alto consumo de tiempo.
- Examinar el uso de índices.
- Interpretar planes de ejecución con `EXPLAIN`.
- Preparar pruebas de rendimiento reproducibles.

## 2. Entorno

| Componente | Configuración |
|---|---|
| Sistema operativo | Ubuntu Server 24.04 LTS |
| PostgreSQL | 17 |
| Base de laboratorio | `dvdrental` |
| Extensión de estadísticas | `pg_stat_statements` |
| Scripts | `scripts/monitoring/` |
| Pruebas | `tests/performance/` |

Los scripts de esta fase son de consulta y no deben modificar los datos de las tablas.

## 3. Requisitos previos

Verificar el estado del servidor:

    pg_lsclusters

Comprobar la versión:

    psql --version

Verificar la existencia de la base de datos:

    sudo -u postgres psql -l

Los comandos SQL pueden ejecutarse desde la terminal mediante `psql` o desde una conexión administrativa autorizada.

## 4. Estructura de los scripts

    scripts/
    └── monitoring/
        ├── activity.sql
        ├── locks.sql
        ├── queries.sql
        └── indexes.sql

## 5. Actividad y conexiones

El archivo `activity.sql` consulta `pg_stat_activity` para identificar las sesiones, su estado, duración y eventos de espera.

Ejecución:

    sudo -u postgres psql -d dvdrental -f scripts/monitoring/activity.sql

Se debe prestar atención a:

- Sesiones activas.
- Sesiones inactivas con transacciones abiertas.
- Consultas de larga duración.
- Esperas relacionadas con locks o I/O.

Una sesión `idle` no constituye por sí misma un problema. Debe analizarse su contexto y si mantiene una transacción abierta.

## 6. Bloqueos

El archivo `locks.sql` identifica las sesiones bloqueadas y los procesos que las bloquean mediante `pg_blocking_pids()`.

Ejecución:

    sudo -u postgres psql -d dvdrental -f scripts/monitoring/locks.sql

Una consulta sin resultados puede indicar que no hay sesiones bloqueadas en ese instante. Los bloqueos breves son normales en una base de datos transaccional.

No se deben terminar procesos automáticamente. Primero se debe identificar la consulta, la transacción y las consecuencias de cancelar la sesión.

## 7. Estadísticas de consultas

`pg_stat_statements` recopila estadísticas agregadas de consultas ejecutadas. Permite investigar el tiempo acumulado, el tiempo medio, las llamadas y la actividad de bloques.

### 7.1. Habilitar la extensión

Editar la configuración:

    sudo nano /etc/postgresql/17/main/postgresql.conf

Configurar la biblioteca:

    shared_preload_libraries = 'pg_stat_statements'

Si ya existen otras bibliotecas en esa opción, conservarlas y añadir `pg_stat_statements` separada por comas.

Reiniciar PostgreSQL:

    sudo systemctl restart postgresql

Crear la extensión en la base de laboratorio:

    sudo -u postgres psql -d dvdrental -c 'CREATE EXTENSION IF NOT EXISTS pg_stat_statements;'

Verificar:

    sudo -u postgres psql -d dvdrental -c '\dx pg_stat_statements'

La extensión requiere configuración previa y un reinicio cuando se añade a `shared_preload_libraries`.

### 7.2. Analizar las consultas

El archivo `queries.sql` ordena las consultas por tiempo total acumulado. También incluye un análisis por tiempo medio y estadísticas de bloques.

Ejecución:

    sudo -u postgres psql -d dvdrental -f scripts/monitoring/queries.sql

El tiempo total y el tiempo medio responden a preguntas diferentes. Una consulta con muchas llamadas puede consumir más tiempo acumulado que otra lenta que apenas se ejecuta.

Las estadísticas son acumulativas desde el último reinicio o restablecimiento de estadísticas, según la métrica. No representan necesariamente el rendimiento de la última ejecución.

## 8. Estadísticas de índices

El archivo `indexes.sql` consulta `pg_stat_user_indexes` para mostrar el uso registrado de los índices de las tablas de usuario.

Ejecución:

    sudo -u postgres psql -d dvdrental -f scripts/monitoring/indexes.sql

Un índice con cero exploraciones registradas no debe eliminarse automáticamente. Puede utilizarse en operaciones poco frecuentes, consultas especiales o restricciones de integridad.

Antes de modificar índices se deben revisar las consultas, las restricciones, los tamaños de las tablas y el periodo durante el cual se recopilaron las estadísticas.

## 9. Análisis de planes de ejecución

Ejemplo:

    EXPLAIN
    SELECT c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id)
    FROM customer AS c
    JOIN rental AS r ON r.customer_id = c.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name;

Para ejecutar y medir realmente la consulta:

    EXPLAIN (ANALYZE, BUFFERS)
    SELECT c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id)
    FROM customer AS c
    JOIN rental AS r ON r.customer_id = c.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name;

`EXPLAIN ANALYZE` ejecuta la consulta. Debe utilizarse con precaución en operaciones que modifiquen datos o puedan causar una carga elevada.

Elementos que se deben comparar:

- Filas estimadas frente a filas reales.
- Tipo de escaneo y estrategia de join.
- Tiempo de ejecución.
- Buffers leídos y encontrados en caché.
- Diferencias entre el coste estimado y el comportamiento observado.

Un `Seq Scan` no es necesariamente malo: puede ser la estrategia más eficiente cuando se necesita leer gran parte de una tabla.

## 10. Checkpoints y actividad de la base

Consultar las estadísticas del cluster:

    sudo -u postgres psql -d dvdrental

    SELECT *
    FROM pg_stat_checkpointer;

Consultar estadísticas de la base:

    SELECT
        datname,
        numbackends,
        xact_commit,
        xact_rollback,
        blks_read,
        blks_hit,
        tup_returned,
        tup_fetched,
        tup_inserted,
        tup_updated,
        tup_deleted
    FROM pg_stat_database
    WHERE datname = 'dvdrental';

Estas estadísticas ayudan a comprender la actividad, pero no deben interpretarse de forma aislada. Por ejemplo, `blks_read` no equivale necesariamente a lecturas físicas del disco, ya que intervienen las cachés del sistema operativo y de PostgreSQL.

## 11. Pruebas de rendimiento

Utilizar `pgbench` para generar una carga controlada sobre una base de pruebas separada de los datos de producción.

Registrar para cada ejecución:

- Tamaño de la base y configuración relevante.
- Número de clientes concurrentes.
- Duración de la prueba.
- TPS.
- Latencia media y, cuando esté disponible, percentiles.
- Errores.
- Cambios de configuración o índices.

Repetir las pruebas en condiciones comparables. No se deben comparar resultados obtenidos con cargas, datos o condiciones de caché muy diferentes sin documentar esas diferencias.

## 12. Criterios de finalización

- [ ] PostgreSQL 17 está activo.
- [ ] Los cuatro scripts SQL se ejecutan sin errores.
- [ ] `pg_stat_statements` está habilitada y recopila estadísticas.
- [ ] Se puede consultar la actividad de las sesiones.
- [ ] Se puede identificar una sesión bloqueadora.
- [ ] Se pueden ordenar consultas por tiempo total y medio.
- [ ] Se pueden consultar las estadísticas de índices.
- [ ] Se ha documentado al menos un plan de ejecución.
- [ ] Se ha registrado una prueba de rendimiento reproducible.

## 13. Evidencias y documentación

Guardar los resultados de las consultas relevantes y documentar:

- Fecha y hora de la prueba.
- Comando ejecutado.
- Resultado observado.
- Interpretación.
- Acción correctiva, si procede.
- Resultado después de la corrección.

No se deben guardar contraseñas, secretos ni datos sensibles de las aplicaciones en las evidencias del repositorio.

## 14. Resultado esperado

Al completar la fase, el administrador podrá utilizar las estadísticas de PostgreSQL para investigar problemas de actividad, bloqueos y consultas, interpretar planes de ejecución y fundamentar decisiones de optimización con mediciones verificables.
