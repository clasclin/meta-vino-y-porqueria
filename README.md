# Meta vino y porquería

En cada nuevo proyecto me encuentro repitiendo una serie de pasos,
donde es necesario crear archivos, directorios, permisos, etc.
Este proyecto viene a tratar evitarme escribir varías veces lo mismo
y abre la puerta a nuevos bugs, solo que de maner automática :)

## La estrucura que crea

Crea los directorios que faltan, los archivos, da permisos de ejecución
(+x) a meh.pl, inicia un repositorio (git init) y finalmente abre meh.pl
en vim para ser editado.

~~~ 
  Meh/
  |__ lib
  |   |__ Meh.pm
  |___ LICENCE
  |___ meh.pl
  |___ README.md
  |___ t
~~~

## Uso

~~~ sh
$ new-project --project-name meh
~~~

## Requisitos

Una versión reciente de perl (5.26), un poco por capricho y otro poco por la
corrección de bugs.

~~~
$ cpanm utf8::all
~~~
