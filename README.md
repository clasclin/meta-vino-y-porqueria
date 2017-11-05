# Meta vino y porquería

En cada nuevo proyecto me encuentro repitiendo una serie de pasos,
donde es necesario crear archivos, directorios, permisos, etc.
Este proyecto viene a tratar evitarme escribir varías veces lo mismo
y abre la puerta a nuevos bugs, solo que de maner automática :)

## La estrucura que crea

~~~ 
  Meh/
  |
  |__ lib
  |   |__ Meh.pm
  |
  |___ LICENCE
  |
  |___ meh.pl
  |
  |___ README.md
  |
  |___ t
~~~

## Uso

~~~ sh
$ new-project --project-name NAME
~~~

## Requisitos

~~~
$ cpanm utf8::all
~~~
