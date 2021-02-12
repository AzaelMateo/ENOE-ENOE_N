********************
version 15
clear all
set more off
cls
********************
 
/*********************************************************************************************
* Nombre archivo: 		AM202102_B4ML_1.MasterDoAll
* Autor:				Azael Mateo
* Propósito:
	- Éste archivo define el directorio global en donde se guardarán las bases de datos y
	  corre el resto de las do files. Es necesario correr el archivo antes que el resto.
*********************************************************************************************/

******************************
* (1): Definimos directorios *
******************************
/* (1.1): Definimos el directorio principal. */
gl root  = "E:\Azael Personal\Documentos\CEEY\8. Invierno 2020\4. Boletín de Movlidad Laboral"

/* (1.2): Cambiamos el directorio de trabajo. */
cd "$root"

**************************
* (2): Corremos do files *
**************************
do "AM202102_B4ML_2.DescCondBases.do"
cd "$root"
do "AM202102_B4ML_3.BasesGlobales.do"	

exit, clear

