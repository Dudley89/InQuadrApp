import '../domain/monument.dart';

const localMonuments = <Monument>[
  Monument(
    id: 'colosseo',
    name: 'Colosseo',
    description:
        'Anfiteatro simbolo di Roma, noto per la sua storia millenaria e la struttura iconica.',
    deepDive:
        'Costruito nel I secolo d.C., ospitava spettacoli pubblici e rappresenta una delle opere più celebri dell’ingegneria romana.',
    accessibility: ['Testo grande', 'Trascrizione contenuti', 'Alto contrasto'],
  ),
  Monument(
    id: 'duomo-milano',
    name: 'Duomo di Milano',
    description:
        'Cattedrale gotica tra le più grandi d’Europa, celebre per guglie e terrazze panoramiche.',
    deepDive:
        'La costruzione si è estesa per secoli: il Duomo unisce arte sacra, scultura e architettura monumentale nel cuore di Milano.',
    accessibility: ['Testo grande', 'Sottotitoli audio guida', 'Alto contrasto'],
  ),
  Monument(
    id: 'ponte-rialto',
    name: 'Ponte di Rialto',
    description:
        'Storico ponte in pietra sul Canal Grande, tra i simboli più riconoscibili di Venezia.',
    deepDive:
        'Completato nel XVI secolo, ha avuto un ruolo centrale nei collegamenti commerciali della città lagunare.',
    accessibility: ['Testo grande', 'Trascrizione contenuti', 'Navigazione semplificata'],
  ),
];
