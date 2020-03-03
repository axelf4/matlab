# Lab key

## Standard canned response template

Ser bra ut! - några saker jag gärna ser att ni fixar är dock:
Några saker ni inte behöver fixa men som ni gärna får tänka på fortsättningsvis:

Second:

Ser bra ut!, några grejor ni kanske vill tänka på fortsättningsvis bara

-----

* `a = r.getNumerator();` fungerar, likaså gör `a = r.a;` i samma klass, vilket kanske är tydligare?

* Enligt speccen ska `gcd` slänga iväg fel både för negativa `n` och `m`

* Ni använde regexes för att se om det är OK input vilket är bra, men man kan även använda det för att parse:a:
```
Matcher matcher = Pattern.compile("(?<a>-?\\d+)(?:/(?<b>-?\\d+))?").matcher(s);
if (!matcher.matches()) throw new NumberFormatException();
String a = matcher.group("a"), b = matcher.group("b");
```
Så slipper man krångla med `split`.

* `RatNum.equals(Object)` måste även kolla om `obj` är `null` eller av en annan klass `!(obj instanceof RatNum)`

* Då `RatNum` som implementerad är *immutable* kan ni göra `a` och `b` till final vilket bättre visar avsikten och förhindrar misstag

* Kan göra `a` och `b` till private; skulle vara dåligt om någon som använder er klass råkar skriva `r.b = -42` och bryta invarianter
(utan någon privacy-modifier är members package-private vilket iofs inte är helt fel)

* För `RatNum(String)` hade ni kunnat använda copy-constructorn som så
```
public RatNum(String s) {
    this(parse(s));
}
```
Notera att om man anropar annan konstruktor (`this(...)`) måste det vara första satsen i metodkroppen.

* Det är mer vanligt att använda `&&` ist. för `&`, samma med `||/|`. Skillnaden är att att `&&`, osv. är short-circuiting

* Hade räckt att skriva `a` istället för `this.a` i metoderna `getNumerator()`/etc. Det är inte fel som ni gjort, men kan bli lite kladdigt. Varför man ibland måste skriva `this.a` är för att parametrar i typiskt konstruktorer överskuggar instansvariablerna.

* För att typkonvertera en `int` till en `double` (t.ex. för att undvika heltalsdivision) är det bättre att använda castoperatorn (`(double) denominator` istället för `1.0 * denominator`) då det är mer explicit

* Istället för att skapa variabler av typ `double` bara för att implicit typkonvertera (för att t.ex. undvika heltalsdivision) går det lika bra att typkonvertera explicit med castoperatorn (`(double) denominator`)

* Istället för att jämföra ett booleskt uttryck i en `if`-sats för att sedan returnera om den var sann eller falsk: Bara returnera uttrycket direkt! Istället för t.ex.
```
if (newNum > currentNum) {
    return true;
}
return false;
```
räcker det med bara `return newNum > currentNum;` vilket är tydligare och bättre stil.

* Det ligger med lite irrelevanta filer - får gärna rensa upp så man inte rättar fel saker! :)

* Ni skriver `return(...);` istället för `return ...;` - det är inte fel (och vissa föredrar det), bara ni är med på att `return()` inte är ett metodanrop utan parenteserna är överflödiga

* Enligt specen borde `gcd` slänga iväg ett `IllegalArgumentException` om `n` eller `m` är noll. Bra att läsa noggrant!

* Får gärna lägga till en kommentar att `m` är täljaren osv.

* I `equals`/`lessThan` gör ni jämförelsena på `double`:s. Nog för att följa DRY, men det är viktigt att ni är med på att det blir mycket mer imprecist än nödvändigt (t.ex. två RatNums kan jämföras som samma fastän de inte är det)

* Behöver inte importera `java.lang.Math` då det implicit görs `import java.lang.*`

* Ni använder den boxade varianten (`Boolean`) av den primitiva typen `boolean`, utan att gå in på skillnaden är det `boolean` ni vill använda.

* `//Konstruktor för om två heltal anges` är smått onödig kommentar inte sant ;)
Samma med t.ex. `//Getter för täljare`. Det är bra med kommentarer men om de bara säger vad koden gör blir de bara brus. Dokumentera *hur/varför* och istället för *vad*.

* Koden är lite dåligt formaterad. Alla textredigerare har funktioner för att omformatera allt, se hur ni gör med er - mest för er skull.

* För att typkonvertera en `int` till en sträng skulle `Integer.toString(43)` vara mer explicit än `43 + ""`, men smaksak.

* I `toString()` använder ni `Integer.toString(a) + "/" + ...` där `Integer.toString()` är lite onödigt då string conversion implicit sker ner en av operanderna till `+` är en sträng (se [här](https://docs.oracle.com/javase/specs/jls/se7/html/jls-5.html#jls-5.4))

* Ni för gärna lämna in README:n som en vanlig `.txt` fil - annars är PDF att föredra före ODT

* För att anropa en statisk metod i samma klass: Istället för `RatNum.parse(...)` räcker det med `parse(...)`

* På flera ställen sparar ni resultatet till en temporär variabel för att sedan returnera temporären: Bara returnera resultatet direkt!

* Man brukar reservera `SCREAMING_SNAKE_CASE` för konstanter.

* Det är blandade mellanslag/tabs vilket gjorde att filen såg lite konstig ut till en början

* Får gärna använda `Math#abs`/`Math#signum` istället för att rulla med egna, så blir koden mer lättöverskådlig (skulle kunna använda statiska importer)

* Behöver inte jämföra booleska uttryck med `true/false` - dvs `if (s.isEmpty()) ...` är lite mer nice än `if (s.isEmpty() == true) ...`

* Inget fel med hur ni gjorde för att splitta strängen vid '/', men att använda `s.split("/", 2)` är lite enklare

## Lab 3: Counters

Inherited:
* (BAD) In TestCounterModel you should test that the default constructor sets a maximum value.
* In TestFastCounter you should test that `downMany()` and `upMany()` works both when they wrap around and when they don't.
* In TestFastCounter you should test if `getStep()` returns the correct value.
* In TestFastCounter you should test at least one of each constructor.
* `decrement()` in CounterModel shold take the counter from `0` to `max-1`. (There was a typo in the original PM.)
* The clock crashes going from 23:59:59 to 00:00:00.

Own:

* Kan göra (många) instansvariablerna till private; skulle vara dåligt om någon som använder er klass råkar skriva till exempel `counter.counter = counter.max + 1` och bryta invarianter (är dessutom rätt menlöst att ha en getter om instansvariabeln är `public`)

* Kan använda *constructor chaining* för att tydliggöra att de parameterlösa konstruktorerna endast sätter defaultvärden
  (Även superklasserna kan använda `super(...)`)

* `ChainedCounterModel` antar implicit att man inte skickar in `null` som `next`. Antingen kan ni kasta iväg ett fel i `ChainedCountModel` constructorn om man skickar in `next == null`, eller så kolla i `ChainedCounterModel#increment()` om `next == null`, men `null`-värden är något som man tyvärr måste tänka på i Java. Detta skulle också göra ett bra test.

* I till exempel getters:arna behöver man inte skriva `return this.instanceVariable` utan räcker med `return instanceVariable` Det är inte fel som ni gjort, men kan bli lite kladdigt. Varför man ibland måste skriva `this.a` är för att parametrar i typiskt konstruktorer överskuggar instansvariablerna.

* Några av era egna test misslyckas?

* Logiken för `FastCounter#up-/downMany()` är lite fel. Dels ger `downMany()` fel värde när man wrappar runt, dels kan man t.ex. sätta step till `2 * max + 1` och få negativa värden
  (Tips: Kan använda att vi redan har `CounterModel#increment()`)

* Alternativt hade `FastCounter#up-/downMany()` kunnat anropa `CounterModel#increment()` i en loop istället för att vara mer DRY

* Bland annat `FastCounter#step` kan göras `final`

* Kan tänka sig att man kunnat göra alla instansvariabler `private` och i superklasserna till `CounterModel` använda `super.increment()` och det faktum att `getValue() == 0` omm värder wrappade runt. Stilfråga och diskuterbart otydligare än att använda `protected`.

* I `CounterModel#increment()` hade kanske `counter >= max` varit tydligare?

* Smått onödigt med en getter för `FastCounter#step` som är public. (Varför man kan vilja ha getters i större program är för att man då enklare kan refactorera klassens implementationsdetaljer, iom. att den utåtriktade gränssnittsytan är mindre)

* I `ChainedCounterModel` definierar ni next som
```
CounterModel next = new CounterModel();
```
dvs ger den ett default värde behålls om ingen construktor skriver över det. Skulle dock säga att det är tydligare att lämna värdet som `null` vilket bättre beskriver avsaknaden av `next`, istället för någon random annan counter.

* När man override:ar `increment()` i `ChainedCounterModel` kan man med fördel lägga till `@Override` *annotationen*: Den gör endast så att om man till exempel stavat fel, eller om superklassen byter namn på metoden, så den inte längre override:as så får man ett fel istället, vilket är rätt tacksamt.

* Viktigt: `@Override` *annotationen* gör endast så att om man till exempel stavat fel, eller om superklassen byter namn på metoden, så den inte längre override:as så får man ett fel istället, vilket är ändå är rätt tacksamt.

* Tror det har blivit litet missförstånd angående subklasser: När man skriver `FastCounter extends CounterModel` kan man läsa det som att `FastCounter` *är en* `CounterModel` och lite till. Det betyder bl.a. att den *ärver* alla instansvariabler från `CounterModel`. När ni sedan definierar `counter` på nytt i `FastCounter` *överskuggas* de ärvda variablerna, men de finns fortfarande kvar, det vill säga `FastCounter` kommer ha både `this.counter` och `super.counter`. Men `this.upMany()` fungerar på `this.counter` medan `super.increment()`, på `super.counter` vilket gör att det blir galet när man använder den ena efter den andra.

* Enligt specen ska `FastCounter` ha en getter för `step`

* Enligt specen ska getter:n för `step` heta `getStep()`

* `FastCounter#x` är lite onödigt kryptiskt namn för step, är det inte?

* Gjort det onödigt komplicerat för att hantera fallet då `CounterModel#next == null`. Hade räckt att bara lägga `next.increment()` i en `if`-sats.

* Att använda en `try`-sats med en blanket `catch`-clause för att hantera fallet med en `null` referens är ett bra sätt att göra det jobbigt för sig. :) Om metoden ni kallar råkar kasta iväg några fel så kommer de tyst att ignoreras. Om ni vill testa för `null`, gör det då; förslagsvis med en if-sats.

* Ovanligt att lägga varje källfil i sin egen mapp.

* Instansvariabler i Java skrivs av hävd i camelCase.

* I JUnit kan man använda `@Test(expected = InvalidArgumentException.class)` för att assert:a exceptions

* Hade kunnat förenkla `ChainedCounterModel#increment()` genom att observera att `getValue() == 0` omm den wrappat runt

* Hade kunnat förenkla `ChainedCounterModel#increment()` genom att anropa `super.increment()`

* Koden är väldigt dåligt formatterad vilket drabbar läsbarheten (I IntelliJ IDEA omformatterar `Ctrl+Alt+L` filen)

* (Var inte rädda för lite längre variabelnamn som säger lite mer om var variabeln är.)

## Lab 4: Newtonian Gravity

Bättre också att istället för att spara accelerationen i Planeterna, spara den antingen bredvid eller i ett fält på något sätt. På så vis kan man aldrig läsa av en felaktig accelerationen medan calculateAcceleration() körs, och man slipper resetAcceleration() grejen vilken är lite missbruk av OOP.

Kan skapa en Vector klass så slipper man skriva varje operation två gånger, en för varje komponent
, och testa om längden är =2.

Implementationen av Verlet algoritmen är väldigt plottrig. Tex räknar ni ut accelerationerna väldigt många gånger mer än vad som behövs. Skulle bli bättre att tex. flytta in allt som är specifikt berör algoritmen till PlanetsModel och göra Planet till enkel POC.

Kan få problem då delar med maxAcc

Verlet algoritmen är lite fel. Ni har rätt tanke men måste se över: I) Behöver beräkna accelerationerna 2ggr för varje frame; II) Behöver beräkna accelerationerna i början av tidssteget innan några positioner updateras, annars kommer det bli "fel" värden.

Hade kunnat ha bara `updateVelocity(Vector acc, double dt)` istället och kalla den två 2ggr, vilket kanske varit tydligare.

Ni hade kunnat göra er Vector klass immutable, dvs göra x, y till final. På så sätt slipper ni använda `clone()`.

En sak man säga är väl att metoderna planet.calculateVerletPosition, etc. är lite otydliga, utan updateVerlet metoden så säger de inte särskilt mycket, hade varit bättre med vanliga updatePosition, etc och låta PlanetsModel kalla med rätt argument.

Kan också säga att det varit bättre att istället för att spara accelerations\_old, accelerations som klassvariabler, ha dem som lokala variabler. Blir enkelt att råka använda gamla värden annars. Men visst, koden blir snabbare om man inte allokerar om dem varje frame.

Sedan behöver ni inte spara accelerations\_old utan kan bara göra det steget innan ni räknar om accelerationerna.

(Måste vara försiktig när man delar med `maxAcc`, blir dåligt om den är noll. Då vi handskas med flyttal kommer det dock aldrig hända, såvida man inte placerar två planeter på varandra från början, så egentligen inget fel - kan hända att ni tänkt på det redan.)

    view.showPlanet(sun);
    view.showPlanet(earth);
    view.showPlanet(jupiter);
    view.showPlanet(venus);
    view.showPlanet(merkurius);
    view.showPlanet(mars);
    view.showPlanet(saturnus);

Säg att man skriver en ny klass som inte använder Verlet algoritmen. Då är beteendet av `Planet#updatePosition()` lite konstigt, dvs att mult med `dt*dt/2`. Tänk till om det går att fixa på något bättre sätt

* Kan skapa en metod som beräknar alla planeters acceleration istället för att upprepa den 2ggr

* Istället för att skapa ett fält där index 0 är x, 1 är y, och 2 är massa: Skapa en enkel POC anonym klass. PSS kan man ge namn åt sakerna och slippa fibbla med index
