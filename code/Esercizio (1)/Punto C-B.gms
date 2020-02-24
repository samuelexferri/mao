$Title  Modello

$Ontext
Modello di Esercizio (1) - Punto C-B
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

CapacitaMensileVecchia(Stabilimenti)
/
Pavia    250
Verona   200
Ravenna  150
/

IncrementoCapacita(Stabilimenti)
/
Pavia    125
Verona   100
Ravenna  75
/

CostoIntervento(Stabilimenti)
/
Pavia    600
Verona   500
Ravenna  300
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
P1(Stabilimenti)                                 Produzione base di ogni stabilimento
P2(Stabilimenti)                                 Produzione aggiuntiva di ogni stabilimento
L000                                             Quantità aggiuntiva di Pavia minore uguale di 100
L100                                             Quantità aggiuntiva di Pavia maggiore di 100
L200                                             Quantità aggiuntiva di Pavia maggiore di 200
RelazionePVS(PuntiVendita, Stabilimenti)         Quantità spostata
;

* Integer mette un upper bound di 100 alle variabili
P1.up(Stabilimenti) = 10000;
P2.up(Stabilimenti) = 10000;
L000.up = 10000;
L100.up = 10000;
L200.up = 10000;
RelazionePVS.up(PuntiVendita, Stabilimenti) = 10000;

Positive Variables
CostoVariabile(Stabilimenti)     Costi variabili di ogni singolo stabilimento
CostiTrasportiVar(Stabilimenti)  Costi trasporti di ogni singolo stabilimento
;

Variables
bool1                            Binaria: 1 se Produzione('Pavia') è maggiore di 100 e 0 altrimenti
bool2                            Binaria: 1 se Produzione('Pavia') è maggiore di 200 e 0 altrimenti
boolIntervento(Stabilimenti)     Binaria: 1 se l'intervento è stato fatto e 0 altrimenti
z        Costo totale
;

Binary Variables bool1, bool2, boolIntervento(Stabilimenti);

Equations
SoddisfacimentoDomanda                           Vincolo sul soddisfacimento della domanda di tutti i punti vendita
SoddisfacimentoDomandaSingolo(PuntiVendita)      Vincolo sul soddisfacimento della domanda del singolo punto vendita
QuantitaSpostata(Stabilimenti)                   Quantità trasportata in ogni punto vendita

PCoerenza(Stabilimenti)                          Vincolo sulla variabile binaria
PBound1(Stabilimenti)                            Upper bound su P1
PBound2(Stabilimenti)                            Upper bound su P2

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

SoddisfacimentoDomanda..                                 sum(PuntiVendita, Domanda(PuntiVendita)) =e= sum(Stabilimenti, (P1(Stabilimenti) + P2(Stabilimenti))) ;

SoddisfacimentoDomandaSingolo(PuntiVendita)..            sum(Stabilimenti, RelazionePVS(PuntiVendita, Stabilimenti)) =e= Domanda(PuntiVendita) ;

QuantitaSpostata(Stabilimenti)..                         sum(PuntiVendita, RelazionePVS(PuntiVendita, Stabilimenti)) =e= P1(Stabilimenti) + P2(Stabilimenti) ;


PCoerenza(Stabilimenti)..        boolIntervento(Stabilimenti) =l= P1(Stabilimenti)/CapacitaMensileVecchia(Stabilimenti) ;

PBound1(Stabilimenti)..          P1(Stabilimenti) =l= CapacitaMensileVecchia(Stabilimenti) ;

PBound2(Stabilimenti)..          P2(Stabilimenti) =l= (CapacitaMensileVecchia(Stabilimenti) + IncrementoCapacita(Stabilimenti))*boolIntervento(Stabilimenti) ;


ProduzionePV..                   P1('Pavia') + P2('Pavia') =e= L000 + L100 + L200 ;

* Saturare in ordine
Coerenza1..                      bool1 =l= L000/100 ;

Coerenza2..                      bool2 =l= L100/100 ;

Bound0..                         L000 =l= 100 ;

Bound1..                         L100 =l= 100*bool1 ;

Bound2..                         L200 =l= (CapacitaMensileVecchia('Pavia') - 200)*bool2 + IncrementoCapacita('Pavia')*boolIntervento('Pavia') ;


CostiVariabiliPavia..            CostoVariabile('Pavia') =e= L000*CostoUnitarioProd('Pavia') + L100*0.9*CostoUnitarioProd('Pavia') + L200*0.75*CostoUnitarioProd('Pavia') ;

CostiVariabiliVerona..           CostoVariabile('Verona') =e= CostoUnitarioProd('Verona')*(P1('Verona') + P2('Verona')) ;

CostiVariabiliRavenna..          CostoVariabile('Ravenna') =e= CostoUnitarioProd('Ravenna')*(P1('Ravenna') + P2('Ravenna')) ;


CostiTrasporti(Stabilimenti)..           CostiTrasportiVar(Stabilimenti) =e= sum(PuntiVendita, (CostoTrasportoUnitarioTEST(PuntiVendita, Stabilimenti)*RelazionePVS(PuntiVendita, Stabilimenti) ) ) ;

ObiettivoModello..                       z =e= sum(Stabilimenti, (CostoFissoMensile(Stabilimenti) + CostoVariabile(Stabilimenti) + CostiTrasportiVar(Stabilimenti) ) ) ;

*** Modello
Model main /all/;
main.optcr=0;
main.optca=0;

*** Risoluzione del modello
Solve main using mip minimizing z ;

display CostoTrasportoUnitarioTEST, CostoVariabile.l, P1.l, P2.l, L000.l, L100.l, L200.l, RelazionePVS.l, bool1.l, bool2.l, boolIntervento.l, z.l;