not( X ) :- X, !, fail.
not( _ ).

computeTime( InLat1, InLon1, InLat2, InLon2, HavDistance ) :-
    DeltaY is InLon2 - InLon1,
    DeltaX is InLat2 - InLat1,
    A is sin( DeltaX / 2 ) ** 2
        + cos( InLat1 ) * cos( InLat2) * sin( DeltaY / 2 ) ** 2,
    Temp is 2 * atan2( sqrt( A ), sqrt( 1 - A )),
    HavDistance is Temp * 3961.

computeDistance( Base, Dest, CurrTime, OutTime) :-
    airport(Base, _, Lat1, Lon1),
    airport(Dest, _, Lat2, Lon2),
    getRadians( Lat1, RadLat1),
    getRadians( Lon1, RadLon1),
    getRadians( Lat2, RadLat2),
    getRadians( Lon2, RadLon2),
    computeTime( RadLat1, RadLon1, RadLat2, RadLon2, Dist),
    TravelTime is (Dist / 1.60934) / (500 / 60),
    OutTime is round((CurrTime + TravelTime)).
    
getRadians(degmin(Deg, Min), Output ) :-
    Temp is (Deg + ( Min / 60)),
    Output is Temp * (pi / 180).
    
getMinutes( Hour, Minute, TotalMins) :-
    Temp is Hour * 60,
    TotalMins is Temp + Minute.

outputFlight(Base, Dest, Hour, Min) :-
    airport(Base, Temp1, _, _ ),
    write('depart'), 
    tab(2), write(Base), 
    tab(2), write(Temp1),
    tab(2), (Hour < 10 -> write('0'), write( Hour) ; write( Hour) ),
            (Min < 10 -> write(':0'), write( Min), nl ; write(':'), write(Min), nl),

    airport(Dest, Temp2, _, _),
    getMinutes( Hour, Min, Time),
    computeDistance( Base, Dest, Time, OutTime),
    
    OutHour is truncate(OutTime / 60),
    OutMin is mod(OutTime, 60),
    
    write( 'arrive'),
    tab(2), write(Dest),
    tab(2), write(Temp2),
    tab(2), (OutHour < 10 -> write('0'), write( OutHour) ; write(OutHour) ),
            (OutMin < 10 -> write(':0'), write( OutMin), nl ; write( ':'), write( OutMin), nl).

timeCompare( Hour1, Minute1, Hour2, Minute2 ) :-
    TotalMin1 is Hour1 * 60,
    TotalMin2 is Hour2 * 60,
    Time1 is TotalMin1 + Minute1,
    Time2 is TotalMin2 + Minute2 + 30,
    Time1 > Time2.

validateTime(Time) :-
    Time =< 1440.

stdOutList([Head|Tail]) :-
    display(Head), nl,
    displayList(Tail).

buildOutput([], _) :-
    nl.

buildOutput(_, []) :-
    nl.

buildOutput([Base, Dest|Tail], [Minutes|MinList]) :-
    Hours is truncate(Minutes / 60),
    Mins is mod(Minutes, 60),
    outputFlight(Base, Dest, Hours, Mins),
    buildOutput([Dest|Tail], MinList).

fly( Base, Base ) :-
    write( 'Error: duplicate arguments' ), nl, !, fail.

fly( Base, Destination) :-
    findPath( Base, Destination, [Base], 0, 0, Flights, Times ),
    !,
    buildOutput(Flights, Times).
    
fly( _, _) :-
    write( 'Error: null arguments' ), nl,
    !, fail.

findPath( Curr, Curr, _, _, _, [Curr], _ ).
findPath( Curr, End, Path, CurrHour, CurrMin, [Curr|Cdr], [TotalMin|MinList] ) :-
    flight( Curr, Temp, time( Hour, Min) ),
    not( member( Temp, Path)),
    timeCompare( Hour, Min, CurrHour, CurrMin ),
    getMinutes( Hour, Min, TotalMin),
    computeDistance( Curr, Temp, TotalMin, ResultMin),
    validateTime(TotalMin),
    OutHours is truncate(ResultMin/60),
    OutMins is mod(ResultMin, 60),
    findPath( Temp, End, [Curr|Path], OutHours, OutMins, Cdr, MinList ).
    
