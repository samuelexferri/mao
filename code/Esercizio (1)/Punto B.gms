$Title  Modello

$Ontext
Modello di Esercizio (1) - Punto B
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
Pavia    2050
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
L000                                             Quantità aggiuntiva di Pavia minore uguale di 100
L100                                             Quantità aggiuntiva di Pavia maggiore di 100
L200                                             Quantità aggiuntiva di Pavia maggiore di 200
RelazionePVS(PuntiVendita, Stabilimenti)         Quantità spostata
;

* Integer mette un upper bound di 100 alle variabili
Produzione.up(Stabilimenti) = 10000;
L000.up = 10000;
L100.up = 10000;
L200.up = 10000;
RelazionePVS.up(PuntiVendita, Stabilimenti) = 10000;

Positive Variables
CostoVariabile(Stabilimenti)     Costi variabili di ogni singolo stabilimento
CostiTrasportiVar(Stabilimenti)  Costi trasporti di ogni singolo stabilimento
;

Variables
bool1    Binaria: 1 se Produzione('Pavia') è maggiore di 100 e 0 altrimenti
bool2    Binaria: 1 se Produzione('Pavia') è maggiore di 200 e 0 altrimenti
z        Costo totale
;

Binary Variables bool1, bool2;

Equations
SoddisfacimentoDomanda                           Vincolo sul soddisfacimento della domanda di tutti i punti vendita
SoddisfacimentoDomandaSingolo(PuntiVendita)      Vincolo sul soddisfacimento della domanda del singolo punto vendita
QuantitaSpostata(Stabilimenti)                   Quantità trasportata in ogni punto vendita

UpperBoundProduzione(Stabilimenti)               Upper bound produzione di ogni stabilimento

ProduzionePV                                     Produzione Pavia
Coerenza1                                        Vincolo sulla variabile binaria
Coerenza2                                        Vincolo sulla variabile binaria
Bound0                                           Upper bound su L000
Bound1                                           Upper bound su L100
Bound2                                           Upper bound su L200

CostiVariabiliPavia                              Costi variabili dello stabilimento di Pavia
CostiVariabiliVerona                             Costi variabili dello stabilimento di Verona
CostiVariabiliRavenna                            Costi variabili dello stabilimento di Ravenna
CostiTrasporti(Stabilimenti)                     Costi trasporti degli stabilimenti
ObiettivoModello                                 Funzione obiettivo (Minimizzazione costi totali)
;

SoddisfacimentoDomanda..                                 sum(PuntiVendita, Domanda(PuntiVendita)) =e= sum(Stabilimenti, Produzione(Stabilimenti)) ;

SoddisfacimentoDomandaSingolo(PuntiVendita)..            sum(Stabilimenti, RelazionePVS(PuntiVendita, Stabilimenti)) =e= Domanda(PuntiVendita) ;

QuantitaSpostata(Stabilimenti)..                         sum(PuntiVendita, RelazionePVS(PuntiVendita, Stabilimenti)) =e= Produzione(Stabilimenti) ;


UpperBoundProduzione(Stabilimenti)..                     Produzione(Stabilimenti) =l= CapacitaMensile(Stabilimenti) ;


ProduzionePV..                   Produzione('Pavia') =e= L000 + L100 + L200 ;

* Saturare in ordine
Coerenza1..                      bool1 =l= L000/100 ;

Coerenza2..                      bool2 =l= L100/100 ;

Bound0..                         L000 =l= 100 ;

Bound1..                         L100 =l= 100*bool1 ;

Bound2..                         L200 =l= (CapacitaMensile('Pavia') - 200)*bool2 ;


CostiVariabiliPavia..            CostoVariabile('Pavia') =e= L000*CostoUnitarioProd('Pavia') + L100*0.9*CostoUnitarioProd('Pavia') + L200*0.75*CostoUnitarioProd('Pavia') ;

CostiVariabiliVerona..           CostoVariabile('Verona') =e= CostoUnitarioProd('Verona')*Produzione('Verona') ;

CostiVariabiliRavenna..          CostoVariabile('Ravenna') =e= CostoUnitarioProd('Ravenna')*Produzione('Ravenna') ;


CostiTrasporti(Stabilimenti)..           CostiTrasportiVar(Stabilimenti) =e= sum(PuntiVendita, (CostoTrasportoUnitarioTEST(PuntiVendita, Stabilimenti)*RelazionePVS(PuntiVendita, Stabilimenti) ) ) ;

ObiettivoModello..                       z =e= sum(Stabilimenti, (CostoFissoMensile(Stabilimenti) + CostoVariabile(Stabilimenti) + CostiTrasportiVar(Stabilimenti) ) ) ;

*** Modello
Model main /all/;
main.optcr=0;
main.optca=0;

*** Risoluzione del modello
Solve main using mip minimizing z ;

display CostoTrasportoUnitarioTEST, CostoVariabile.l, Produzione.l, L000.l, L100.l, L200.l, RelazionePVS.l, bool1.l, bool2.l, z.l;
