not( X ) :- X, !, fail.
not( _ ).

computeTime( InLat1, InLon1, InLat2, InLon2, HavDistance ) :-
    DeltaY is InLon2 - InLon1,
    DeltaX is InLat2 - inLat1,
    A is sin( DeltaX / 2 ) ** 2
        + cos( InLat1 ) * cos ( InLat2) * sin( DeltaY / 2 ) ** 2,
    Temp is 2 * atan2 ( sqrt ( A ), sqrt( 1 - A )),
    HavDistance is Temp * 3961.

computeDistance( Base, Dest, CurrTime, OutTime) :-
    airport(F, _, Lat1, Lon1),
    airport(T, _, Lat2, Lon2),
    getRadians( Lat1, RadLat1),
    getRadians( Lon1, RadLon1),
    getRadians( Lat2, RadLat2),
    getRadians( Lon2, RadLon2),
    computeTime( RadLat1, RadLon1, RadLat2, Radlon2, Dist),
    TravelTime is (Dist, 1.60934) / (500 / 60),
    OutTime is round((CurrTime + TravelTime)).
    
getRadians(degmin(Deg, Min), Output ) :-
    Temp is (Deg + ( Min / 60)),
    Output is Temp * (pi / 180).
    
getMinutes( Hour, Minute, TotalMins) :-
    TotalMins is (Hour * 60) + Minute.

timeCompare( Hour1, Minute1, Hour2, Minute2 ) :-
    TotalMin1 is Hour1 * 60,
    TotalMin2 is Hour2 * 60,
    Time1 is TotalMin1 + Minute1,
    Time2 is TotalMin2 + Minute2 + 30,
    Time1 > Time2.

fly( Base, Base ) :-
    write( 'Error: duplicate arguments' ), nl, !, fail.

fly( Base, Destination) :-
    findPath( Base, Destination, [Base], Flights, Times ),
    !,
    true.
    
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
    OutHours is trucate(ResultMin/60),
    OutMins is mod(ResultMin, 60),
    findPath( Temp, End, [Curr|Path], OutHours, OutMins, Cdr, MinList ).
    
