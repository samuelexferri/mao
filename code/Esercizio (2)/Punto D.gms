$Title  Modello

$Ontext
Modello di Esercizio (2) - Punto D
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

P1(Impianti, t)          Potenza base
P2(Impianti,t)           Potenza espansione
PEspansa(Impianti)       Capacità di potenza espansa dell'impianto (giornalmente)
CostoPotenza             Costo totale di produzione di energia dagli impianti termoelettrici

Q1(Flusso, t)            Flusso (Portata) base
Q2(Flusso, t)            Flusso (Portata) espansione
QEspansa(Flusso)         Capacità di flusso espansa della turbina (giornalmente)
CostoFlussi              Costo totale di produzione di energia dalle turbine
;

V.up(Bacino,t) = Bacini(Bacino, 'Vmax');
V.lo(Bacino,t) = 0.2*Bacini(Bacino, 'Vmax');

P1.up(Impianti,t) = Centrali(Impianti, 'Pmax');
P2.up(Impianti,t) = Centrali(Impianti,'Massima Espansione');
PEspansa.up(Impianti) = Centrali(Impianti,'Massima Espansione');
CostoPotenza.up = 1000000;

Q1.up(Flusso,t) = Condotte(Flusso, 'Qmax');
Q2.up(Flusso,t) = Condotte(Flusso,'Massima Espansione');
QEspansa.up(Flusso) = Condotte(Flusso,'Massima Espansione');
CostoFlussi.up = 1000000;

Equations
VolumiJ1(t)              Volume del bacino J1 al tempo t
VolumiJ2(t)              Volume del bacino J2 al tempo t

VIniziale(Bacino)        Volume iniziale del bacino
VFinale(Bacino)          Volume finale del bacino

PIniziale(Impianti)      Potenza iniziale

UpRamp                   Massimo salto
DownRamp                 Minimo salto

PEspansaEq(Impianti,t)   Bound sulla capacità espansa di potenza

CostoProdPotenza         Costi totali di produzione della potenza

QIniziale(Flusso)        Flusso iniziale

QEspansaEq(Flusso,t)     Bound sulla capacità espansa di flusso

CostoProdFlussi          Costi totale di produzione dei flussi

EnergiaRichiesta         Bound che garantisce la produzione di energia richiesta
Obiettivo                Definizione della funzione obiettivo
;


*** VOLUMI ***
VolumiJ1(t)$(ord(t) gt 1)..              V('J1',t) =e= V('J1',t-1) + ApportiNaturali(t,'J1') - (Q1('d12',t) + Q2('d12',t)) - (Q1('s13',t) + Q2('s13',t)) ;
VolumiJ2(t)$(ord(t) gt 1)..              V('J2',t) =e= V('J2',t-1) + ApportiNaturali(t,'J2') + (Q1('d12',t) + Q2('d12',t)) - (Q1('d23',t) + Q2('d23',t)) - (Q1('s23',t) + Q2('s23',t)) ;

VIniziale(Bacino)..                      V(Bacino,'0') =e= Bacini(Bacino, 'Vin') ;
VFinale(Bacino)..                        V(Bacino,'12') =e= Bacini(Bacino, 'Vfin') ;


*** POTENZE ***
PIniziale(Impianti)..                    P1(Impianti,'0') =e= Centrali(Impianti, 'P0') ;

UpRamp(Impianti, t)$(ord(t) gt 1)..      (P1(Impianti,t) + P2(Impianti,t)) - (P1(Impianti,t-1) + P2(Impianti,t-1)) =l= Centrali(Impianti, 'RampUp') ;
DownRamp(Impianti, t)$(ord(t) gt 1)..    (P1(Impianti,t-1) + P2(Impianti,t-1)) - (P1(Impianti,t) + P2(Impianti,t)) =l= Centrali(Impianti, 'RampDown') ;

PEspansaEq(Impianti,t)$(ord(t) gt 1)..   P2(Impianti,t) =l= PEspansa(Impianti) ;

CostoProdPotenza..                       CostoPotenza =e= sum((Impianti,t), (P1(Impianti,t) + P2(Impianti,t))*Centrali(Impianti,'CM')) + sum(Impianti, PEspansa(Impianti)*Centrali(Impianti,'CostoEspansione')) ;


*** FLUSSI (PORTATE) ***
QIniziale(Flusso)..                      Q1(Flusso,'0') =e= 0 ;

QEspansaEq(Flusso,t)$(ord(t) gt 1)..     Q2(Flusso,t) =l= QEspansa(Flusso) ;

CostoProdFlussi..                        CostoFlussi =e= sum((Flusso,t), (Q1(Flusso,t) + Q2(Flusso,t))*Condotte(Flusso,'CostoOM')) +  sum(Flusso, QEspansa(Flusso)*Condotte(Flusso,'CostoEspansione')) ;


*** OBIETTIVI ***
EnergiaRichiesta(t)$(ord(t) gt 1)..      Carico(t,'Car') =l=  sum(Impianti, (P1(Impianti,t) + P2(Impianti,t))) + sum(Flusso, Condotte(Flusso,'EnergyCoeff')* (Q1(Flusso,t) + Q2(Flusso,t))) ;

Obiettivo..      z =e= CostoPotenza + CostoFlussi ;


Model input /all/;

input.optcr = 0;
input.optca = 0;

Solve input using mip minimizing z ;

display Bacini, Condotte, ApportiNaturali, Centrali, Carico, ProducibilitaEolica, V.l, P1.l, P2.l, PEspansa.l, Q1.l, Q2.l, QEspansa.l, z.l;
