%%%%
%%%%  Library for generic noisy OR predicates --- noisy_or.psm
%%%%
%%%%  Copyright (C) 2007,2008
%%%%    Sato Laboratory, Dept. of Computer Science,
%%%%    Tokyo Institute of Technology

%%  When this file included, the following predicates will be available:
%%
%%  - cpt(X,PaVs,V) represents a probabilistic choice where a
%%    random variable X given instantiations PaVs of parents
%%    takes a value V.  If X is an ordinary node, a random
%%    switch bn(X,PaVs) will be used.  On the other hand, if
%%    X is a noisy-OR node, switch cause(X,Y) will be used,
%%    where Y is one of parents of X.
%%
%%  - set_nor_params/0 sets inhibition probabilisties (i.e.
%%    the parameters of switches cause(X,Y)) according to
%%    the specifications for noisy-OR nodes with noisy_or/3.

%%---------------------------------------
%%  Declarations:

% added just for making the results of probabilistic inference
% simple and readable:
:- p_not_table choose_noisy_or/4, choose_noisy_or/6.

%%---------------------------------------
%%  Modeling part:

cpt(X,PaVs,V):-
   ( noisy_or(X,Pa,_) -> choose_noisy_or(X,Pa,PaVs,V)  % for noisy OR nodes
   ; msw(bn(X,PaVs),V)                                 % for ordinary nodes
   ).

choose_noisy_or(X,Pa,PaVs,V):- choose_noisy_or(X,Pa,PaVs,no,no,V).

choose_noisy_or(_,[],[],yes,V,V).
choose_noisy_or(_,[],[],no,_,no).
choose_noisy_or(X,[Y|Pa],[PaV|PaVs],PaHasYes0,ValHasYes0,V):-
   ( PaV=yes ->
       msw(cause(X,Y),V0),
       PaHasYes=yes,
       ( ValHasYes0=no, V0=no -> ValHasYes=no
       ; ValHasYes=yes
       )
   ; PaHasYes=PaHasYes0,
     ValHasYes=ValHasYes0
   ),   % do not insert the cut symbol here
   choose_noisy_or(X,Pa,PaVs,PaHasYes,ValHasYes,V).


%%---------------------------------------
%%  Utility part:

set_nor_params:-
   ( noisy_or(X,Pa,DistList),  % spec for a noisy OR node 
     set_nor_params(X,Pa,DistList),
     fail
   ; true
   ).
set_nor_params(_,[],[]).
set_nor_params(X,[Y|Pa],[Dist|DistList]):-
   set_sw(cause(X,Y),Dist),!,
   set_nor_params(X,Pa,DistList).

