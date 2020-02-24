$Title  Modello

$Ontext
Modello di Esercizio (1) - Punto A
$Offtext

* DISABILITATO
* Caricamento di Input e Modello Matematico
* $Include "Input.gms"

Sets
Stabilimenti / Pavia, Verona, Ravenna /
PuntiVendita / Milano, Torino, Genova, Firenze, Bologna, Venezia, Bergamo /
;

Parameters
Domanda(PuntiVendita)
/
Milano   100
Torino   50
Genova   20
Firenze  80
Bologna  150
Venezia  30
Bergamo  70
/

CapacitaMensile(Stabilimenti)
/
Pavia    250
Verona   200
Ravenna  150
/

CostoFissoMensile(Stabilimenti)
/
Pavia    700
Verona   600
Ravenna  550
/

CostoUnitarioProd(Stabilimenti)
/
Pavia    5
Verona   4
Ravenna  6
/
;

* COPIA DI TEST
Table CostoTrasportoUnitarioTEST(PuntiVendita, Stabilimenti)
              Pavia      Verona     Ravenna
Milano        4.204       4.018      11.244
Torino        4.142      12.099      19.320
Genova        3.562      11.244      24.417
Firenze      11.244       7.630       5.119
Bologna       5.533       3.803       3.530
Venezia      11.244       3.421       3.803
Bergamo       3.382       3.421      13.942
;

Integer Variables
Produzione(Stabilimenti)                         Quantità prodotta negli stabilimenti
RelazionePVS(PuntiVendita, Stabilimenti)         Quantità spostata
;

* Integer mette un upper bound di 100 alle variabili
Produzione.up(Stabilimenti) = 10000;
RelazionePVS.up(PuntiVendita, Stabilimenti) = 10000;

Positive Variables
CostoVariabile(Stabilimenti)     Costi variabili di ogni singolo stabilimento
CostiTrasportiVar(Stabilimenti)  Costi trasporti di ogni singolo stabilimento
;

Variables
z                                Costo totale
;

Equations
SoddisfacimentoDomanda                           Vincolo sul soddisfacimento della domanda di tutti i punti vendita
SoddisfacimentoDomandaSingolo(PuntiVendita)      Vincolo sul soddisfacimento della domanda del singolo punto vendita
QuantitaSpostata(Stabilimenti)                   Quantità trasportata in ogni punto vendita

UpperBoundProduzione(Stabilimenti)               Upper bound produzione di ogni stabilimento

CostiVariabili(Stabilimenti)                     Costi variabili degli stabilimenti
CostiTrasporti(Stabilimenti)                     Costi trasporti degli stabilimenti
ObiettivoModello                                 Funzione obiettivo (Minimizzazione costi totali)
;

SoddisfacimentoDomanda..                                 sum(PuntiVendita, Domanda(PuntiVendita)) =e= sum(Stabilimenti, Produzione(Stabilimenti)) ;

SoddisfacimentoDomandaSingolo(PuntiVendita)..            sum(Stabilimenti, RelazionePVS(PuntiVendita, Stabilimenti)) =e= Domanda(PuntiVendita) ;

QuantitaSpostata(Stabilimenti)..                         sum(PuntiVendita, RelazionePVS(PuntiVendita, Stabilimenti)) =e= Produzione(Stabilimenti) ;


UpperBoundProduzione(Stabilimenti)..     Produzione(Stabilimenti) =l= CapacitaMensile(Stabilimenti) ;


CostiVariabili(Stabilimenti)..           CostoVariabile(Stabilimenti) =e= CostoUnitarioProd(Stabilimenti)*Produzione(Stabilimenti) ;

CostiTrasporti(Stabilimenti)..           CostiTrasportiVar(Stabilimenti) =e= sum(PuntiVendita, (CostoTrasportoUnitarioTEST(PuntiVendita, Stabilimenti)*RelazionePVS(PuntiVendita, Stabilimenti) ) ) ;

ObiettivoModello..                       z =e= sum(Stabilimenti, (CostoFissoMensile(Stabilimenti) + CostoVariabile(Stabilimenti) + CostiTrasportiVar(Stabilimenti) ) ) ;

*** Modello
Model main /all/;
main.optcr=0;
main.optca=0;

*** Risoluzione del modello
Solve main using mip minimizing z ;

display CostoTrasportoUnitarioTEST, CostoVariabile.l, Produzione.l, RelazionePVS.l, z.l;
