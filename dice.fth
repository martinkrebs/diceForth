\ set up the port register address constants
$24 constant ddrb
$25 constant portb
$23 constant pinb


\ word to create a byte array - see FF docs
: mk-byte-array
    create allot
    does> +
;

\ create dice face pattern array
mk-byte-array diceface 


\ create variable to hold index 1..6 for diceface lookup
variable idiceface


: init
    \ set portb bit4 to input (button) the rest to outputs
    %1110.1111 ddrb c!
    
    \ write dice face patterns to array, patterns are at 
    \ index 1 .. 6, index 0 is not used
    $00 #0 diceface c!
    $08 #1 diceface c!
    $01 #2 diceface c!
    $0a #3 diceface c!
    $03 #4 diceface c!
    $0b #5 diceface c!
    $07 #6 diceface c!

    \ set idiceface index to 6
    #6 idiceface !
;


\ check state of button and leave %0001.0000 (pressed) or 0 at TOS
: button@
    pinb @ %0001.0000 and
;


\ modulo six counter decrement
: idiceface--
    idiceface @ #1 = if #6 idiceface ! else idiceface @ 1- idiceface ! then
;


\ get psuedo random 1..6 in var idiceface by button press during fast count loop
: getprand
    begin
        idiceface--
        button@
    until
;

\ TODO: this first implementation of rolldice word works, but could be refactored to remove repetition.
: rolldice
    #20 for
        idiceface @ diceface @
        portb c!
        #25 ms
        idiceface--
    next
    #20 for
        idiceface @ diceface @
        portb c!
        #50 ms
        idiceface--
    next
    #9 for
        idiceface @ diceface @
        portb c!
        #100 ms
        idiceface--
    next
    #7 for
        idiceface @ diceface @
        portb c!
        #200 ms
        idiceface--
    next
    #7 for
        idiceface @ diceface @
        portb c!
        #400 ms
        idiceface--
    next
;


\ dice main, infinite loop
: main
    init
    begin
        getprand
        rolldice
    again ;


\ set turnkey vector
' main is turnkey
