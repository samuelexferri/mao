$Title  Input

$Ontext
Input di Esercizio (1)
$Offtext

Sets
Stabilimenti / Pavia, Verona, Ravenna /
PuntiVendita / Milano, Torino, Genova, Firenze, Bologna, Venezia, Bergamo /
;

Table
Distanze(PuntiVendita, Stabilimenti)
         Pavia   Verona  Ravenna
Milano   40      155     290
Torino   160     300     370
Genova   130     290     410
Firenze  290     240     190
Bologna  200     145     75
Venezia  290     115     145
Bergamo  105     115     320
;

Positive Variables
CostoTrasportoUnitario(PuntiVendita, Stabilimenti)       Costo trasporto tra stabilimenti e puntovendita unitari
;

Set j Index / 1*80 /;

Variables
a Parametro a
b Parametro b
c Parametro c
zi Funzione obiettivo (Somma errori quadratici medi)
e(j) Errore
;

Parameter
Level(*,*)
;

$call gdxxrw.exe "Costi di Trasporto (Modificato).xlsx" par=Level rng=F1!A1:C81  maxDupeErrors=10

$gdxin "Costi di Trasporto (Modificato).gdx"
$load Level
$gdxin

display Level;

Equations
Obiettivo        Definizione della funzione obiettivo
Error(j)         Errore
CostiTrasportiUnitari(PuntiVendita, Stabilimenti)   Costi di trasporto unitari
;

Error(j)..       e(j) =e= (Level(j,'Costo') - a*Level(j,'KM')*Level(j,'KM') - b*Level(j,'KM') - c)*(Level(j,'Costo') - a*Level(j,'KM')*Level(j,'KM') - b*Level(j,'KM') - c) ;

CostiTrasportiUnitari(PuntiVendita, Stabilimenti)..     CostoTrasportoUnitario(PuntiVendita, Stabilimenti) =e= a*Distanze(PuntiVendita, Stabilimenti)*Distanze(PuntiVendita, Stabilimenti) + b*Distanze(PuntiVendita, Stabilimenti) + c ;

Obiettivo..      zi =e= sum(j,e(j)) ;

Model input /all/;

input.optcr = 0;
input.optca = 0;

Solve input using nlp minimizing zi ;

display Level, CostoTrasportoUnitario.l;
