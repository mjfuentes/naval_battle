# Sinatra App Template

This is a [Sinatra](https://github.com/sinatra/sinatra) application template.

## Definición del template

#### /app.rb

Punto de entrada de la aplicación. En este archivo se define la aplicación Sinatra que es ejecutada por Rack.
Aquí se configura el entorno y se requiren todos los archivos y gemas necesarias para que la aplicación funcione.
Se realizan ademas tareas de inicialización como por ejemplo establecer la conexión con la base de datos.

#### /config

contiene archivos de configuración generales para la aplicación (por ejemplo, configuración de las conexiones a las bases de datos)

#### /models

Contiene la definición de las clases que forman el modelo de la aplicación. Todas los archivos .rb en este directorio (y sub-directorios) son requeridos en por app.rb (ver línea XXXX), de manera que toda clase que se encuentre definida en esta carpeta, puede ser utilizada en la applicación.

#### /views

contiene las vistas, tanto layout como partials, de la aplicación. Se recomienda usar subdirectorios para crear subagrupaciones de vistas relacionadas bajo algún criterio (por ejemplo: todas las vistas del ABM de usuarios van en /views/users)


#### /tasks

Si son necesarias crear tareas Rake, estas deben ir en este directorio. Todos los archivos .rb en este directorio (y sub-directorios) son cargados en por Rakefile (ver línea 4)

#### /public

Los archivos en directorio y sub-directorios son servidos como archivos estáticos por sinatra. Aquí deberán ubicarse los assets (imágenes, hojas de estilo, javascripts). De esta manera un request GET a /css/styles.css, no pasará por el ruteo de Sinatra si existe el archivo en /public/css/styles.css

### ORM

El template tiene configurado como ORM [ActiveRecord](https://github.com/rails/rails/tree/master/activerecord) (usando sqlite3)
Tanto en la [Documentación oficial de Rails](http://api.rubyonrails.org/) como las [guías de rails](http://guides.rubyonrails.org/index.html) hay información detallada sobre su funcionamiento.

### Rake

Se proveen tareas para correr los tests (ver sección [Tests]) y para manejar la integración con el ORM (crear, borrar y modificar (mediante migraciones) las bases de datos).
La gema [sinatra-activerecord](https://github.com/janko-m/sinatra-activerecord) provee varias tareas Rake
para manejar la creación y modificación de la base de datos.
`Lea el readme para saber qué tareas provee y cómo utilizarlas.`

Para ver un listado de las tareas Rake disponibles puede ejecutar:

```bash
$ bundle exec rake -T
```


## Utilización

### Setup

Clonar el repositorio:

```bash
$ git clone git@github.com/TTPS-ruby/sinatra_app_template.git
```

Borrar el origin seteado por git al clonar

```bash
$ git remote rm origin
```

Instalar todas las gemas especificadas en el Gemfile:

```bash
$ bundle install
```

### Tests

Para correr los tests se entrega una tarea rake que corre todos los tests bajo /test. Esta está configurada como la tarea por defecto por lo tanto sólo es necesario ejecutar:

```bash
$ bundle exec rake
```

Si se requiere ejecutar un archivo de test particular puede directamente ejecutar:

```bash
$ bundle exec ruby test/<archivo>
```

Para ejecutar los tests dentro de un archivo cuyo nombre coincida con una expresión regular

```bash
$ bundle exec ruby test/<archivo>.rb -n /<expresión-regular>/
```


### Ejecutar la aplicación

Para ejecutar la aplicación se utiliza el comando `rackup`

```bash
$ bundle exec rackup
```
