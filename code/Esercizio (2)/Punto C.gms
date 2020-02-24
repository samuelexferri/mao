$Title  Modello

$Ontext
Modello di Esercizio (2) - Punto C
$Offtext

Sets
* Non inserisco J3 perchè tanto vale infinito
Bacino   / J1, J2 /
Volume   / Vmax, Vin, Vfin /
Flusso   / d12, d23, s13, s23, p21 /
Impianti / Coal, CCGT, GT, Oil /
t        / 0*12 /
;

Parameter
Bacini(*,*)
Condotte(*,*)
ApportiNaturali(*,*)     NOTA: La terza colonna J3 sono tutti zeri e quindi non è presente

Centrali(*,*)

Carico(*,*)
ProducibilitaEolica(*,*)
;

$onecho > tasks1.txt
par=Bacini rng="Bacini!a2" rdim=1 cdim=1
par=Condotte rng="Condotte!a2" rdim=1 cdim=1
par=ApportiNaturali rng="Apporti Naturali!a2" rdim=1 cdim=1
$offecho
$call GDXXRW.EXE "Idroelettrico.xlsx" trace=3 @tasks1.txt
$GDXIN "Idroelettrico.gdx"
$onUNDF
$LOAD Bacini, Condotte, ApportiNaturali

$onecho > tasks2.txt
par=Centrali rng="Foglio1!a2" rdim=1 cdim=1
$offecho
$call GDXXRW.EXE "Termoelettrico.xlsx" trace=3 @tasks2.txt
$GDXIN "Termoelettrico.gdx"
$onUNDF
$LOAD Centrali

$onecho > tasks3.txt
par=Carico rng="Carico!a2" rdim=1 cdim=1
par=ProducibilitaEolica rng="Producibilità Eolica!a1" rdim=1 cdim=1
$offecho
$call GDXXRW.EXE "Sistema.xlsx" trace=3 @tasks3.txt
$GDXIN "Sistema.gdx"
$onUNDF
$LOAD Carico, ProducibilitaEolica

Variables
z                                        Funzione obiettivo
;

Positive Variables
V(Bacino, t)             Volume

P(Impianti, t)           Potenza
CostoPotenza             Costo totale di produzione di energia dagli impianti termoelettrici

Q(Flusso, t)             Flusso (Portata)
CostoFlussi              Costo totale di produzione di energia dalle turbine
;

V.up(Bacino,t) = Bacini(Bacino, 'Vmax');
V.lo(Bacino,t) = 0.2*Bacini(Bacino, 'Vmax');

P.up(Impianti,t) = Centrali(Impianti, 'Pmax');
CostoPotenza.up = 1000000;

Q.up(Flusso,t) = Condotte(Flusso, 'Qmax');
CostoFlussi.up = 1000000;

Equations
VolumiJ1(t)              Volume del bacino J1 al tempo t
VolumiJ2(t)              Volume del bacino J2 al tempo t

VIniziale(Bacino)        Volume iniziale del bacino
VFinale(Bacino)          Volume finale del bacino

PIniziale(Impianti)      Potenza iniziale

UpRamp                   Massimo salto
DownRamp                 Minimo salto

CostoProdPotenza         Costi totali di produzione della potenza

QIniziale(Flusso)        Flusso iniziale

CostoProdFlussi          Costi totale di produzione dei flussi

Manutenzione             Manutenzione

EnergiaRichiesta         Bound che garantisce la produzione di energia richiesta
Obiettivo                Definizione della funzione obiettivo
;


*** VOLUMI ***
VolumiJ1(t)$(ord(t) gt 1)..              V('J1',t) =e= V('J1',t-1) + ApportiNaturali(t,'J1') - Q('d12',t) - Q('s13', t) ;
VolumiJ2(t)$(ord(t) gt 1)..              V('J2',t) =e= V('J2',t-1) + ApportiNaturali(t,'J2') + Q('d12',t) - Q('d23',t) - Q('s23', t) ;

VIniziale(Bacino)..                      V(Bacino,'0') =e= Bacini(Bacino, 'Vin') ;
VFinale(Bacino)..                        V(Bacino,'12') =e= Bacini(Bacino, 'Vfin') ;


*** POTENZE ***
PIniziale(Impianti)..                    P(Impianti,'0') =e= Centrali(Impianti, 'P0') ;

UpRamp(Impianti, t)$(ord(t) gt 1)..      P(Impianti,t) - P(Impianti,t-1) =l= Centrali(Impianti, 'RampUp') ;
DownRamp(Impianti, t)$(ord(t) gt 1)..    P(Impianti,t-1) - P(Impianti,t) =l= Centrali(Impianti, 'RampDown') ;

CostoProdPotenza..                       CostoPotenza =e= sum((Impianti,t), P(Impianti,t)*Centrali(Impianti,'CM')) ;


*** FLUSSI (PORTATE) ***
QIniziale(Flusso)..                      Q(Flusso,'0') =e= 0 ;

CostoProdFlussi..                        CostoFlussi =e= sum((Flusso,t), Condotte(Flusso,'CostoOM')*Q(Flusso,t)) ;


*** MANUTENZIONE: Abbiamo calcolato a mano i costi totali per ogni intervallo in sequenza ***
Manutenzione..                           P('Oil','1') + P('Oil','2') + P('Oil','3') =e= 0 ;

*** OBIETTIVI ***
EnergiaRichiesta(t)$(ord(t) gt 1)..      Carico(t,'Car') =l=  sum(Impianti, P(Impianti,t)) + sum(Flusso, Condotte(Flusso,'EnergyCoeff')* Q(Flusso,t)) ;

Obiettivo..      z =e= CostoPotenza + CostoFlussi ;


Model input /all/;

input.optcr = 0;
input.optca = 0;

Solve input using mip minimizing z ;

display Bacini, Condotte, ApportiNaturali, Centrali, Carico, ProducibilitaEolica, V.l, P.l, Q.l, z.l;
