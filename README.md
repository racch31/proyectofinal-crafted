# crafted — Tu proteína, hecha por ti

Proyecto final académico de **tienda en línea** desarrollado con **PHP 8.1+, MySQL 8+ / MariaDB y Bootstrap 5.3.9**. No se utiliza ningún otro framework: JavaScript y CSS son propios.

**Estado:** prototipo académico funcional a nivel de código. **No realiza pagos reales ni está listo para vender, producir o recomendar suplementos para consumo.** La instalación y pruebas dinámicas requieren un servidor PHP con extensiones `pdo_mysql` y `mbstring` y una base de datos MySQL/MariaDB.

## Funciones incluidas

- Catálogo de **35 productos precargados y con existencias positivas**, cada uno con nombre, descripción, imagen SVG ilustrativa única, precio, stock, fabricante y origen; filtros y búsqueda.
- **35 opciones de personalización:** 6 bases proteicas, 8 sabores, 10 complementos, 7 tipos de fibra y 4 presentaciones. Las 35 opciones son distintas de los 35 SKU del catálogo.
- Registro, correo y contraseña; contraseña con `password_hash`/`password_verify`, acceso por sesión y token persistente rotatorio de 30 días, cierre de sesión.
- Perfil y cuestionario optativo con peso, estatura, actividad, entrenamiento, dieta, alergias y objetivos; consentimiento expreso para datos de salud. Recomendaciones **educativas por reglas simples**, no diagnósticas.
- Formulador: escoge base, sabor, extras y gramajes; cálculo de precio en pantalla y validación **también en servidor**; restricciones ilustrativas de presentación, límite técnico de peso por porción y fibra añadida. **No son límites médicos clínicamente validados**.
- Carrito con cambio de cantidad y eliminación, finalización de compra **simulada**, transacción SQL que valida y descuenta existencias y guarda `compras` + `detalle_compra`. Para fórmulas descuenta materias primas en gramos.
- Página del cliente con perfil y órdenes; administrador con reporte de inventario, alta/edición de productos, carga de foto e historial de compras.
- Navegación global y diseño responsive, colores crema, chocolate, oliva y arcilla, marca **crafted** sin punto.

## Plantilla del sitio

El sitio usa como plantilla **Bootstrap 5.3.9** (cargado por CDN) con un tema propio llamado *crafted*:

- **Estructura:** barra de navegación fija arriba (`navbar`), sección principal tipo *hero*, rejilla de tarjetas (`card`) para productos e ingredientes, formularios y pie de página.
- **Tema:** `assets/css/style.css` define los colores (crema, chocolate, oliva y arcilla), la tipografía y los botones.
- **Dónde está:** el encabezado y el pie se generan en `lib.php` (`render_header` y `render_footer`), así que todas las secciones comparten el mismo diseño.
- **Vista previa:** `vista_previa.html` muestra la plantilla sin necesidad de servidor ni base de datos.

## Ejecución con Docker

Requisito: Docker Desktop instalado y abierto. Desde la carpeta del proyecto:

```bash
docker compose up -d --build
```

- Sitio: http://localhost:8090
- phpMyAdmin: http://localhost:8091 (usuario `root`, contraseña `root_pass`)

La primera vez, el contenedor de MySQL crea la base `crafted` y carga `sql/schema.sql` y `sql/seed.sql` automáticamente (tarda alrededor de un minuto). Para detenerlo: `docker compose stop`.

Para crear el usuario administrador:

```bash
docker exec crafted_web php scripts/create_admin.php admin@crafted.local "CAMBIA_ESTA_CONTRASEÑA" "Administrador"
```

## Instalación con XAMPP (Windows)

1. Instala XAMPP con **Apache, MySQL/MariaDB y PHP 8.1 o superior**. Activa Apache y MySQL en XAMPP.
2. Copia la carpeta `crafted` dentro de `C:\xampp\htdocs\`.
3. Abre `http://localhost/phpmyadmin` y selecciona **Importar** para ejecutar primero `sql/schema.sql` y después `sql/seed.sql`. El primero crea la base de datos; el segundo carga **35 SKU, 31 ingredientes y 4 presentaciones**. **Importa seed una sola vez.**
4. La conexión por defecto es `DB_HOST=127.0.0.1`, `DB_PORT=3306`, `DB_NAME=crafted`, `DB_USER=root`, `DB_PASS=` (vacía). Si usas otras credenciales, define esas variables de entorno o adapta los valores por defecto en `lib.php`/`config.php`.
5. En la terminal de XAMPP, dentro de la carpeta del proyecto, crea el usuario administrador. **Usa una contraseña propia y fuerte**:

   ```bash
   php scripts/create_admin.php admin@crafted.local "CAMBIA_ESTA_CONTRASEÑA" "Administrador"
   ```

   > Nota: cambia también el correo por uno real de prueba si lo deseas. No hay contraseña de administrador predefinida.
6. Entra a `http://localhost/crafted/index.php`. Registra un usuario normal para comprobar el flujo completo.

**Sin XAMPP:** importa los mismos SQL, define las variables `DB_*` y ejecuta `php -S localhost:8000` desde la raíz `crafted`, luego visita `http://localhost:8000`.

**Requisitos PHP:** `pdo_mysql`, `mbstring`, `fileinfo`, `session`, `openssl` y compatibilidad con imágenes. Las extensiones vienen generalmente con XAMPP; actívalas en `php.ini` si hace falta.

## Pantallas

| Ruta | Sección |
| --- | --- |
| `index.php` | Inicio / hero / propuestas |
| `index.php?page=catalogo` | Catálogo filtrable |
| `index.php?page=detalle&id=1` | Ficha de producto |
| `index.php?page=ingredientes` | Fichas de ingredientes |
| `index.php?page=registro` | Alta de cuenta |
| `index.php?page=acceso` | Inicio de sesión |
| `index.php?page=perfil` | Datos del usuario |
| `index.php?page=cuestionario` | Actividad, metas y preferencias |
| `index.php?page=recomendaciones` | Sugerencias por reglas |
| `index.php?page=crear` | Configurador de proteína |
| `index.php?page=carrito` | Carrito / compra simulada |
| `index.php?page=pedidos` | Historial de usuario |
| `index.php?page=contacto` | Contacto / privacidad |
| `index.php?page=admin` | Inventario / panel de administrador |
| `index.php?page=admin_producto` | Alta y edición de producto |
| `index.php?page=admin_pedidos` | Historial de ventas |

## Mapeo a los requisitos de la actividad

| Requisito del profesor | Dónde se cumple |
| --- | --- |
| Catálogo con al menos 30 productos, foto y descripción | Tabla `productos`, `sql/seed.sql` (35) + vista `catalogo`/`detalle` |
| Producto guardado en BD y posibilidad de agregar | `productos`, `views/admin_producto.php`, acción `admin_product` |
| Menú permanente | `lib.php` (`render_header`) |
| Registro de usuarios | `usuarios`, `registro.php`, acción `register` |
| Usuario y sus datos | `perfil.php`, `perfiles`, `objetivos_usuarios` |
| Carrito que permita cambiar cantidades | `carrito`, `carrito.php`, acciones `add_cart`, `cart_qty`, `cart_remove` |
| Actualizar almacén al vender | Transacción `checkout` en `actions.php` |
| Historial de compras | `compras`, `detalle_compra`, vista SQL `historial_compras`, `pedidos.php` |
| Admin de productos / inventario / compras | `admin`, `admin_producto`, `admin_pedidos` |
| Correo/contraseña y sesión | `usuarios`, `sesiones_persistentes`, login / logout |
| Contacto e información adicional | `contacto.php` |
| Solo Bootstrap | Bootstrap CSS+JS por CDN; CSS/JS propios, sin React, Vue, etc. |
| Diseño responsivo | Bootstrap grid e imágenes `img-fluid`/clases responsivas |
| Número de tarjeta bancaria | **Adaptación de seguridad:** no se guarda el PAN completo; la columna `tarjeta_ultimos4` está prevista para una pasarela. Checkout es simulado. Consultar nota inferior. |

## Importante: requisito “Número de tarjeta bancaria”

La consigna original menciona almacenar la tarjeta en `Usuarios`. **No es seguro conservar el número completo en una base de datos de una tarea escolar.** En vez de eso, el esquema usa `tarjeta_ultimos4` (dato opcional) y evita pedirlo en el registro; para una tienda real integra un procesador de pagos certificado que devuelva un token. Este proyecto cumple el flujo de compra a través de un **pago simulado**. Si tu profesor exige el campo literal, conviene explicarle esta sustitución antes de entregar.

## Seguridad y límites

- Consultas preparadas con PDO, contraseñas con hash, tokens CSRF, escape de HTML, roles, control de archivos subidos (tipo y tamaño), transacciones y bloqueo de registros para evitar vender sin inventario.
- **No** hay pagos reales, envío real, emails transaccionales ni verificación de correo. Añadirlos supondría integrar servicios y pruebas adicionales.
- Las fórmulas **no están aprobadas nutricional ni regulatoriamente**. Los límites, costos, inventarios, fabricantes y procedencias del SQL son **ficticios**. Ningún ingrediente se anuncia como “orgánico certificado” sin certificado verificado (`organico_certificado=0` en los datos iniciales).
- Se registra consentimiento para el cuestionario, pero para una comercialización real todavía hacen falta evaluación legal, políticas completas, controles sobre datos sensibles, mecanismo de derechos de titulares, controles de calidad y revisión experta.
- Para desplegar fuera de localhost utiliza HTTPS, credenciales de BD no privilegiadas, protección de directorios y configuración de servidor adecuada. No subir `scripts/`, `sql/` ni archivos privados a una raíz pública.

## Modelo de datos

`usuarios` se relaciona con `perfiles`, `objetivos_usuarios`, `carrito`, `formulas` y `compras`. `productos` almacena los SKU prehechos; `ingredientes` y `presentaciones` son el catálogo de opciones personalizables. `formula_ingredientes` vincula una fórmula con ingredientes y gramos por porción. `detalle_compra` permite asociar un pedido tanto con un SKU como con una fórmula personalizada. Ver `docs/MODELO_Y_PRUEBAS.md`.

## Archivos principales

```
crafted/
├── index.php             # Enrutador de páginas
├── actions.php           # POST: CRUD, registro, fórmula, carrito, checkout
├── lib.php               # PDO, sesión, seguridad y layout
├── config.php            # Configuración
├── views/                # Todas las páginas
├── assets/css/style.css  # Estilo crafted
├── assets/js/app.js      # Vista previa del configurador
├── assets/img/           # Imágenes ilustrativas SVG únicas
├── sql/schema.sql        # Base de datos
├── sql/seed.sql          # 35 productos / 35 opciones
├── scripts/create_admin.php
└── docs/MODELO_Y_PRUEBAS.md
```

## Compatibilidad

Preparado para MySQL 8+ / MariaDB moderno, PHP 8.1+ y Bootstrap 5.3.9. En el entorno de generación del proyecto no se dispone de un driver PDO MySQL, por lo que **se validó la sintaxis PHP y la consistencia de archivos/datos, pero no se ejecutó una prueba integrada con MySQL**. La instalación local permitirá completar las pruebas de los escenarios documentados.
