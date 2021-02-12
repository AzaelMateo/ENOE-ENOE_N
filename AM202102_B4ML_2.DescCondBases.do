********************
version 15
clear all
set more off
cls
********************
 
/**********************************************************************************************************************************
* Fecha: 				11/febrero/2021
* Nombre archivo: 		AM202102_B4ML_2.DescCondBases
* Autor:          		Azael Mateo		
* Archivos creados:  
	- Bases de datos de sitio web INEGI
* Propósito:
	- Éste archivo baja las bases de datos de la ENOE del 2005 hasta la última fecha disponible 
	  y comprime las bases de datos para ser utilizadas más adelante.
	- A partir del 2020-3T baja las bases de datos de la ENOE-N hasta la última fecha disponible.
***********************************************************************************************************************************/

******************************
* (1): Definimos directorios *
******************************
/* (1.1): Definimos el directorio en donde guardaremos las bases de datos. */
cap mkdir "$root/Bases ENOE"
gl bases = "$root/Bases ENOE"


***************************************************
* (2): Bajar y comprimir bases de datos de la ENOE*
***************************************************
/* (2.1): Definimos el último año disponible para bajar la ENOE. */
local anio = 20

/* (2.2): Bajamos bases de datos. */
forvalues i = 5/`anio' {
	* Agregamos un 0 a inicio del local i para años anteriores a 2010:
	if strlen(string(`i'))==1 {
		local i = "0" + string(`i')
	}	
	forvalues j = 1/4 {
		disp "Trabajando para bases año 20`i' trimestre `j'"
		* Creamos directorios y bajamos archivos:
		capture mkdir	"$bases/20`i'trim`j'_dta"
		cd		"$bases/20`i'trim`j'_dta"
		
		* Revisamos si existen bases de datos para no volver a bajar
		capture confirm file "COE1T`j'`i'.dta"
		if _rc!=0 {	
			copy "https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/microdatos/20`i'trim`j'_dta.zip"  20`i'trim`j'_dta.zip
			
			* Revisamos tamaño de archivo para ver si existe el año indicado. Si no existe, paramos, si existe, seguimos:
			qui checksum 20`i'trim`j'_dta.zip
			if r(filelen)/1000000 < 1 {
				disp "Aún no existen archivos para el año 20`i' trimestre `j'"
				break
			}
			else {
				unzipfile	20`i'trim`j'_dta.zip
				
				******* COMPRESIÓN DE BASES *******
				* Primero base COE1T Y COE2T
				use "COE1T`j'`i'.dta", clear
				rename *, lower
				qui compress
				save, replace
				use "COE2T`j'`i'.dta", clear
				rename *, lower
				qui compress
				save, replace

				* Segundo base hogar
				if `i'==11 & `j'==2 {
					use "HOGT211_1.dta", clear
					rename *, lower
				}
				else {
					use "HOGT`j'`i'.dta", clear
					rename *, lower
				}
				qui compress
				save, replace

				* Tercero base sociodemográficos
				use "SDEMT`j'`i'.dta", clear
				rename *, lower
				qui compress
				save, replace

				* Por último base de vivienda
				use "VIVT`j'`i'.dta", clear
				rename *, lower
				qui compress
				save, replace
			}
			* Por último, se borra el archivo zip:
			erase 20`i'trim`j'_dta.zip 
		}
	}
}


*****************************************************
* (3): Bajar y comprimir bases de datos de la ENOE-N*
*****************************************************
/* (3.1): Definimos año actual (para bajar la información hasta donde esté disponible. */
local anio : display %tdY date(c(current_date), "DMY")

/* (3.2): Bajamos bases de datos. */
forvalues i = 20/`anio' {
	forvalues j = 1/4 {
		disp "Trabajando para bases año 20`i' trimestre `j'"
		* Creamos directorios y bajamos archivos:
		capture mkdir	"$bases/20`i'trim`j'_dta"
		cd		"$bases/20`i'trim`j'_dta"
		
		* Revisamos si existen bases de datos para no volver a bajar
		capture confirm file "COE1T`j'`i'.dta"
		if _rc!=0 {	
			copy "https://www.inegi.org.mx/contenidos/programas/enoe/15ymas/microdatos/enoe_n_20`i'_trim`j'_dta.zip"  enoe_n_20`i'_trim`j'_dta.zip
			
			* Revisamos tamaño de archivo para ver si existe el año indicado. Si no existe, paramos, si existe, seguimos:
			qui checksum enoe_n_20`i'_trim`j'_dta.zip
			if r(filelen)/1000000 < 1 {
				disp "Aún no existen archivos para el año 20`i' trimestre `j'"
				break
			}
			else {
				unzipfile	enoe_n_20`i'_trim`j'_dta.zip
				
				******* COMPRESIÓN DE BASES *******
				* Primero base COE1T Y COE2T
				use "enoen_coe1t`j'`i'.dta", clear
				rename *, lower
				qui compress
				save "COE1T`j'`i'.dta", replace
				erase enoen_coe1t`j'`i'.dta
				use "enoen_coe2t`j'`i'.dta", clear
				rename *, lower
				qui compress
				save "COE2T`j'`i'.dta", replace
				erase enoen_coe2t`j'`i'.dta

				* Segundo base hogar
				use "enoen_hogt`j'`i'.dta", clear
				rename *, lower
				qui compress
				save "HOGT`j'`i'.dta", replace
				erase enoen_hogt`j'`i'.dta

				* Tercero base sociodemográficos
				use "enoen_sdemt`j'`i'.dta", clear
				rename *, lower
				qui compress
				save "SDEMT`j'`i'.dta", replace
				erase enoen_sdemt`j'`i'.dta

				* Por último base de vivienda
				use "enoen_vivt`j'`i'.dta", clear
				rename *, lower
				qui compress
				save "VIVT`j'`i'.dta", replace
				erase enoen_vivt`j'`i'.dta
			}
			* Por último, se borra el archivo zip:
			erase enoe_n_20`i'_trim`j'_dta.zip
		}
	}
}

cd "$root"

/* (3.3): Eliminamos directorios donde no existe data. */
shell rd "$bases/2020trim2_dta/" /s /q

forvalues i = 1/4 {
	shell rd "$bases/2021trim`i'_dta/" /s /q
}
