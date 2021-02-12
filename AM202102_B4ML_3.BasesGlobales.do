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
	keep r_def loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog h_mud n_ent per n_ren c_res par_c sex eda nac_dia nac_mes nac_anio l_nac_c ingocup per fac cs_p13_1 cs_p13_2 cs_p17  clase* imssissste p1 p1c salario
	qui merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "$bases/2005trim`i'_dta/COE2T`i'05.dta", force
	keep if _merge==3
	keep r_def loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog h_mud n_ent per n_ren c_res par_c sex eda nac_dia nac_mes nac_anio l_nac_c ingocup per fac cs_p13_1 cs_p13_2 cs_p17  clase* imssissste p1 p1c p11_1 p6c p6b2 p6_9 p6a3
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
			qui merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "$bases/20`i'trim`j'_dta/COE1T`j'`i'.dta"
			keep if _merge==3
			keep r_def loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog h_mud n_ent per n_ren c_res par_c sex eda nac_dia nac_mes nac_anio l_nac_c ingocup per fac cs_p13_1 cs_p13_2 cs_p17  clase* imssissste p1 p1c salario
			qui merge 1:1 cd_a ent con v_sel n_hog h_mud n_ren using "$bases/20`i'trim`j'_dta/COE2T`j'`i'.dta"
			keep if _merge==3
			
			* Como la variable que buscamos alterna entre p9_1 y p11_1, tenemos que revisar primero si existe. 
			capture confirm variable p9_1
			if !_rc {
					keep r_def loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog h_mud n_ent per n_ren c_res par_c sex eda nac_dia nac_mes nac_anio l_nac_c ingocup per fac cs_p13_1 cs_p13_2 cs_p17  clase* imssissste p1 p1c p9_1 p6c p6b2 p6_9 p6a3
					tempfile shortSDEMT`j'`i'
					save "`shortSDEMT`j'`i''"
			}
			else {
					keep r_def loc mun est est_d ageb t_loc cd_a ent con upm d_sem n_pro_viv v_sel n_hog h_mud n_ent per n_ren c_res par_c sex eda nac_dia nac_mes nac_anio l_nac_c ingocup per fac cs_p13_1 cs_p13_2 cs_p17  clase* imssissste p1 p1c p11_1 p6c p6b2 p6_9 p6a3
					tempfile shortSDEMT`j'`i'
					save "`shortSDEMT`j'`i''"
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
*egen folio = concat(cd_a ent con v_sel n_hog h_mud n_ren sex nac_dia nac_anio nac_mes)  // folio original
egen foliop = concat(cd_a ent con v_sel n_hog h_mud n_ren)

/* (3.2): Creamos variable año-trimestre y la misma con lag de un año antes. */
gen year = substr(string(per),2,2)
gen trim = substr(string(per),1,1)
egen yeartrim = concat(year trim)
destring yeartrim, replace
gen int yeartrim_lag = .
replace yeartrim_lag = yeartrim - 9
replace yeartrim_lag = yeartrim_lag + 6 if real(substr(string(yeartrim_lag), 2,1))==5 & yeartrim_lag<102
replace yeartrim_lag = yeartrim_lag + 6 if real(substr(string(yeartrim_lag), 3,1))==5 & yeartrim_lag>100
egen base = group(yeartrim)

/* (3.3): Generamos variable caracter de año, mes y fecha.*/
gen anio = "20" + year
destring trim, replace
gen mes = string(trim*3)
replace mes = "0" + mes if strlen(mes)==1
generate str fecha = anio + "-" + mes + "-01"
compress
save "$docs/ENOE_Base Global_Estatica.dta", replace

*******************************************
* (4): Generamos base de datos "dinámica" *
*******************************************
/* (4.1): Tiramos las entrevistas intermedias. */
drop if n_ent!=1 & n_ent!= 4

/* (4.2): Generamos variables de tiempo necesarias. */
gen temp = yeartrim
replace temp = . if yeartrim<61
save "$docs/ENOE_Base Global_Dinamica.dta", replace

/* (4.3): Generamos bases de datos temporales para después unirlas. */
* Seleccionamos solo los años-meses que dejamos en temp.
levelsof temp, local(levels) 

* Por cada año de los permitidos por temp, nos quedamos con aquellas variables que corresponden al año y cuatro trimestres antes
local b = 1
foreach i of local levels {
	use "$docs/ENOE_Base Global_Dinamica.dta", clear
	disp "trabajando para yeartrim `i'"
	tempfile `b'
	qui sum yeartrim_lag if yeartrim==`i'
	scalar M = r(mean)
	qui keep if yeartrim==`i' | yeartrim==r(mean)
	
	* Mantenemos solo a aquellos que tienen entrevista en primer y en cuarto trimestre.
	qui duplicates tag folio, gen(dup)
	qui keep if dup==1
	save "``b''"

	tempfile tempa
	
	* Nos quedamos solo con las observaciones de cuatro trimestres antes.
	qui keep if yeartrim==M
	rename ingocup ingocup1
	rename imssissste imssissste1
	rename clase1 clase1ini
	rename clase2 clase2ini
	rename clase3 clase3ini
	save "`tempa'"
	use "``b''", clear
	
	* Nos quedamos solo con las observaciones del trimestre actual.
	qui keep if yeartrim==`i'
	capture drop _merge
	
	* Juntamos las dos bases.
	qui merge m:m folio using "`tempa'" 
	qui keep if _merge==3
	qui drop dup
	gen basenum = `b'
	save "``b''", replace
	local b = `b' + 1
}

/* (4.4): Juntamos bases. */
use "$docs/ENOE_Base Global_Dinamica.dta", clear
quietly tab temp
scalar an = r(r)

use "`1'", clear
forvalues i = 2/`=scalar(an)' {
	disp "Trabajando para base `i'"
	capture append using "``i''"
	}
	
/* (4.5): Renombramos variables. */
rename ingocup ingocup2
rename imssissste imssissste2
rename clase1 clase1fin
rename clase2 clase2fin
rename clase3 clase3fin
rename fac factor

/* (4.6): Tiramos a ausentes definitivos, nos quedamos con rango de edad de PEA, entrevistas completas y PEA */
drop if r_def!=0
drop if c_res==2
drop if eda<12 | eda==99
keep if clase1ini==1
compress
save "$docs/ENOE_Base Global_Dinamica.dta", replace



