********************
version 15
clear all
set more off
cls
********************
 
/*********************************************************************************************
* Nombre archivo: 		AM202102_B4ML_3.BasesGlobales.do
* Autor:          		Azael Mateo		
* Archivos usados:     
	- Todas las bases de datos ENOE (SDEMT y COE1T/2T) para todos los años disponibles.
* Archivos creados:  
	- ENOE_Base Global_Estatica.dta
	- ENOE_Base Global_Dinamica.dta
* Propósito:
	- Éste archivo genera dos bases de datos que son utilizadas para todos los cálculos 
	  posteriores: una base de datos "estática" que se limita a unir todas las bases de datos
	  disponibles, y una base de datos "dinámica" que compara los resultados de ciertas
	  variables para personas con entrevistas disponibles a lo largo de un año.
	- Importante: la base estática tiene a la población completa, pues borrar la PEA 
	  eliminaría la posibilidad de hacer un análisis de la transición del empleo a la PNEA.
*********************************************************************************************/

******************************
* (1): Definimos directorios *
******************************
/* (1.1): Definimos el directorio en donde se encuentran las bases de datos que utilizaremos
		  y a donde exportaremos la base de datos procesada. */
gl bases = "$root/Bases ENOE"
gl docs  = "$root"


************************************************************************************************************
* (2): Creamos una base unificada (para todo trimestre disponible), haciendo un merge de SDEM, COE1 y COE2 *
************************************************************************************************************
/* (2.1): Primero juntamos las bases del 2005 para tener una base "base". */
forvalues i = 1/4 {
	use "$bases/2005trim`i'_dta/SDEMT`i'05.dta", clear
	qui merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "$bases/2005trim`i'_dta/COE1T`i'05.dta", force
	keep if _merge==3
	*keep cd_a ent con v_sel n_hog h_mud n_ren   // especificar variables de interes para disminuir la carga del proceso
	qui merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "$bases/2005trim`i'_dta/COE2T`i'05.dta", force
	keep if _merge==3
	*keep cd_a ent con v_sel n_hog h_mud n_ren   // especificar variables de interes para disminuir la carga del proceso
	tempfile base`i'
	save "`base`i''"
}

use "`base1'"
append using "`base2'"
append using "`base3'"
append using "`base4'"

save "$docs/ENOE_Base Global_Estatica.dta", replace

/* (2.2): Definimos año actual (para bajar la información hasta donde esté disponible. */
local anio : display %tdY date(c(current_date), "DMY")

/* (2.3): Generamos bases temporales para que al hacer append no ocupen mucho espacio. */
forvalues i = 6/`anio' {
	* Agregamos un 0 a inicio del local i para años anteriores a 2010:
	if strlen(string(`i'))==1 {
		local i = "0" + string(`i')
	}	
	* Corremos loop para cada trimestre
	forvalues j = 1/4 {
		capture confirm file "$bases/20`i'trim`j'_dta/SDEMT`j'`i'.dta"
		if _rc==0 {
			disp "trabajando para año `i' trim `j'"
			use "$bases/20`i'trim`j'_dta/SDEMT`j'`i'.dta", clear
			
			* Verificamos si estamos trabajando para la ENOE_N. En caso de ser así renombramos variables trimestrales.
			capture confirm variable mes_cal
			if !_rc {	
			
			    * Renombramos variables trimestrales
			    rename est_d_tri est_d
			    rename t_loc_tri t_loc
			    rename fac_tri fac
			
			    * Corremos loop especial
				qui merge 1:1 cd_a ent con v_sel tipo mes_cal ca n_hog h_mud n_ren using "$bases/20`i'trim`j'_dta/COE1T`j'`i'.dta"
				keep if _merge==3
				*keep cd_a ent con v_sel tipo mes_cal ca n_hog h_mud n_ren   // especificar variables de interes para disminuir la carga del proceso
				qui merge 1:1 cd_a ent con v_sel tipo mes_cal ca n_hog h_mud n_ren using "$bases/20`i'trim`j'_dta/COE2T`j'`i'.dta"
				keep if _merge==3
				*keep cd_a ent con v_sel tipo mes_cal ca n_hog h_mud n_ren   // especificar variables de interes para disminuir la carga del proceso
			}				
			else {
			use "$bases/20`i'trim`j'_dta/SDEMT`j'`i'.dta", clear
			qui merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "$bases/20`i'trim`j'_dta/COE1T`j'`i'.dta"
			keep if _merge==3
			*keep cd_a ent con v_sel n_hog h_mud n_ren   // especificar variables de interes para disminuir la carga del proceso
			qui merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "$bases/20`i'trim`j'_dta/COE2T`j'`i'.dta"
			keep if _merge==3		
		}
	}
  }
}


/* (2.4): Ya con serie de bases pequeñas procedemos a juntar todas en una base total. */
use "$docs/ENOE_Base Global_Estatica.dta", clear

forvalues i = 6/`anio' {
	* Agregamos un 0 a inicio del local i para años anteriores a 2010:
	if strlen(string(`i'))==1 {
		local i = "0" + string(`i')
	}	
	
	* Corremos loop para cada trimestre
	forvalues j = 1/4 {
		capture confirm file "`shortSDEMT`j'`i''"
		if _rc==0 {
			append using "`shortSDEMT`j'`i''", force
		}
	}
}

****************************************
* (3): Generamos variables importantes *
****************************************
/* (3.1): Generamos identificador único. */
egen foliop = concat(cd_a ent con v_sel n_hog h_mud n_ren)
egen folioh = concat(cd_a ent con v_sel n_hog h_mud)

/* (3.2): Generamos variable clasificador de tipo de localidad. */
gen rururb = cond(t_loc>=1 & t_loc<=3,0,1) 
label define ru 0 "Urbano" 1 "Rural" 
label values rururb ru 
		
/* (3.3): Creamos variable año-trimestre. */
gen year = substr(string(per),2,2)
gen trim = substr(string(per),1,1)
egen yeartrim = concat(year trim)
destring yeartrim, replace
egen base = group(yeartrim)

/* (3.4): Generamos variable caracter de año, mes y fecha.*/
gen anio = "20" + year
destring trim, replace
gen mes = string(trim*3)
replace mes = "0" + mes if strlen(mes)==1
generate str fecha = anio + "-" + mes + "-01"
compress
save "$docs/ENOE_Base Global_Estatica.dta", replace

