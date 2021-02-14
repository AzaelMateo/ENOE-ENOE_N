# ENOE-ENOE_N
Este repositorio contiene las do files necesarias para automatizar la construcción de un panel histórico de las tablas de datos "Sociodemográfico", "Cuestionario de ocupación y empleo parte l" y "Cuestionario  de ocupación y empleo parte ll" para todas las ENOE y las ENOE_N (población de 15 años y más de edad) disponibles.

Para construir el panel bastará con cambiar el directorio de "$root" dentro de la do file master y tener las tres do files en el mismo sitio. Una vez hecho esto, y teniendo conexión a internet para poder descargar las bases de datos, se podrá correr todo el proceso sin contratiempos aunque podría tardarse un tiempo exagerado dependiendo de la capacidad del equido donde se corra. Por esto se recomienda especificar después de cada merge las variables de interés que deseamos conservar para eliminar las que no y aligerar la carga del proceso. Si se desea agregar las tablas de datos "Vivienda" y "Hogar" al panel solo debe replicarse la forma en que se agrega cada una de las tablas COE1 y COE2 utilizando las varibles que sirven de llave para cada base.

Contacto: azael.mateo@cide.edu
