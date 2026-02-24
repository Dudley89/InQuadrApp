import '../domain/monument.dart';

const localMonuments = <Monument>[
  Monument(
    id: 'obelisco-tagliacozzo',
    idGlobal: 1001,
    name: 'Obelisco',
    description:
        'Arrivare in Piazza dell’Obelisco è come entrare nel “salotto” di Tagliacozzo: spazio aperto, luce piena, voci che rimbalzano tra i palazzi. L’Obelisco al centro ti dà subito un senso di festa e di incontro, perfetto per iniziare a esplorare il borgo senza fretta.',
    deepDive:
        'Fermati qualche minuto: ascolta l’acqua, guarda le linee verticali che guidano lo sguardo verso l’alto, e poi lascia che sia la piazza a raccontarti la città. Qui capisci subito il carattere di Tagliacozzo: elegante ma autentica, viva, fatta di passi lenti, eventi, chiacchiere serali e foto “da cartolina”. È un punto ideale per orientarti e scegliere la direzione della tua passeggiata nel centro storico.',
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/e/e1/La_piazza_dell%27Obelisco.jpg',
    accessibility: ['Testo grande', 'Trascrizione contenuti', 'Alto contrasto'],
    latitude: 42.06842,
    longitude: 13.25421,
  ),
  Monument(
    id: 'chiostro-san-francesco-tagliacozzo',
    idGlobal: 1002,
    name: 'Chiostro del Convento di San Francesco',
    description:
        'Appena entri nel chiostro, cambia tutto: i rumori si abbassano, l’aria sembra più fresca, e i passi diventano più leggeri. È uno di quei luoghi che non “si visitano” soltanto: si respirano.',
    deepDive:
        'Cammina sotto il portico lentamente, come se stessi seguendo un ritmo antico. La luce disegna ombre morbide sulle arcate, e ogni angolo invita a una pausa: una panchina, un dettaglio, un affresco, un silenzio che fa bene. È la tappa perfetta quando vuoi staccare dal movimento del paese e ritrovare un momento di calma, quasi intima, prima di rimetterti in cammino tra vicoli e piazze.',
    imageUrl:
        'https://it.wikipedia.org/wiki/Chiesa_e_convento_di_San_Francesco_(Tagliacozzo)#/media/File:TagliacozzoSFrancescoChiostro2.jpg',
    accessibility: ['Testo grande', 'Trascrizione contenuti', 'Navigazione semplificata'],
    latitude: 42.06896,
    longitude: 13.25329,
  ),
  Monument(
    id: 'statua-dante-tagliacozzo',
    idGlobal: 1003,
    name: 'Statua di Dante Alighieri',
    description:
        'Davanti a Dante, a Tagliacozzo, ti viene naturale rallentare e alzare gli occhi: è come se il poeta stesse “vegliando” sul paese, con quella presenza solenne che trasforma una semplice sosta in un piccolo momento di stupore.',
    deepDive:
        'Avvicinati e prova a leggere le parole sul basamento: qui Dante non è soltanto un simbolo, ma un ponte tra letteratura e territorio. È una tappa che ti invita a pensare, a fare una foto diversa dal solito, e magari a cercare quel verso che lega Tagliacozzo alla sua storia. Se ci passi al tramonto, con la luce calda, l’atmosfera diventa davvero speciale.',
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/3/3f/Dante_Alighieri_Tagliacozzo.jpg',
    accessibility: ['Testo grande', 'Sottotitoli audio guida', 'Alto contrasto'],
    latitude: 42.06812,
    longitude: 13.25373,
  ),
];
