*Taller 1
*Ejercicio 2
ssc install coefplot
ssc install estout

* Fijar directorio de trabajo
cd "C:\Users\Marlon Angulo\Desktop\Maestría Andes\Econometría Avanzada\Taller 1"

use colonial_trade.dta

*a) Generar variables LN(1+kt)
* Generar variables escaladas 10^a * T_{i,j}

forvalues a = 1/10 {
    gen T_scale_`a' = trade * (10^`a')
}

* Generar transformación log+1 para cada escala
forvalues a = 1/10 {
    gen ln_T1_scale_`a' = ln(1 + T_scale_`a')
}

* Verificar las nuevas variables
summarize T_scale_* ln_T1_scale_*

*b) Modelos:

* Estimar los 10 modelos
forvalues a = 1/10 {
    reg ln_T1_scale_`a' colony lyex lyim ldist
    estimates store model_`a'
}

* Exportar a LaTeX con formato profesional
esttab model_1 model_2 model_3 model_4 model_5 model_6 model_7 model_8 model_9 model_10 ///
    using "resultados.tex", ///
    replace ///
    b(3) se(3) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    keep(colony) ///
    mtitles("k=10" "k=100" "k=1e3" "k=1e4" "k=1e5" "k=1e6" "k=1e7" "k=1e8" "k=1e9" "k=1e10") ///
    coeflabels(colony "Vínculo Colonial") ///
    stats(N r2, fmt(%9.0fc %9.3f) labels("Observaciones" "R-cuadrado")) ///
    title("Sensibilidad del Coeficiente a Cambios de Escala") ///
    addnotes("Errores estándar entre paréntesis" "*** p<0.01, ** p<0.05, * p<0.1") ///
    label



*c) Gráfica de coeficientes:

* Guardar coeficientes e intervalos de confianza
forvalues a = 1/10 {
    reg ln_T1_scale_`a' colony lyex lyim ldist
    estimates store model_`a'
    
    * Extraer coeficiente e intervalo de confianza
    matrix coef_`a' = e(b)
    matrix var_`a' = e(V)
    local b_colony_`a' = coef_`a'[1,1]
    local se_colony_`a' = sqrt(var_`a'[1,1])
    local lb_`a' = `b_colony_`a'' - 1.96 * `se_colony_`a''
    local ub_`a' = `b_colony_`a'' + 1.96 * `se_colony_`a''
}

* Crear base de datos para gráfico
clear
set obs 10
gen a = .
gen coef = .
gen lb = .
gen ub = .

forvalues i = 1/10 {
    replace a = `i' in `i'
    replace coef = `b_colony_`i'' in `i'
    replace lb = `lb_`i'' in `i'
    replace ub = `ub_`i'' in `i'
}

* Graficar coeficientes con intervalos de confianza
twoway (connected coef a, lcolor(blue) mcolor(blue) msymbol(O)) ///
       (rcap ub lb a, lcolor(red)), ///
       title("Coeficiente de Colony") ///
       xtitle("Valor de a (k = 10^a)") ///
       ytitle("Coeficiente de Colony") ///
       xlabel(1 "10" 2 "100" 3 "1000" 4 "10^4" 5 "10^5" 6 "10^6" 7 "10^7" 8 "10^8" 9 "10^9" 10 "10^10") ///
       legend(order(1 "Coeficiente" 2 "IC 95%")) ///
       graphregion(color(white))

* Guardar gráfico
graph export "coefplot_escalas.png", replace width(2000) height(1200)





	
	
