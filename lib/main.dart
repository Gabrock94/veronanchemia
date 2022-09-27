import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:better_player/better_player.dart';
import 'package:carousel_slider/carousel_slider.dart';

final Uri _website = Uri.parse('https://www.veronanchemia.it/');
final Uri _privacy = Uri.parse('https://www.veronanchemia.it/app/privacy.html');

void main() {
  runApp(const MyApp());
}

@immutable
class LocationListItem extends StatelessWidget {
  const LocationListItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.country,
  });

  final String imageUrl;
  final String name;
  final String country;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              _buildParallaxBackground(context),
              _buildGradient(),
              _buildTitleAndSubtitle(),
            ],

          ),
        ),
      ),
    );
  }

  Widget _buildParallaxBackground(BuildContext context) {
    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }

  Widget _buildGradient() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.5, 0.95],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndSubtitle() {
    return Positioned(
      left: 20,
      bottom: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            country,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class Tour {
  final String id;
  final String title;
  final String subtitle;
  final String duration;
  final String len;
  final List steps;
  final String image;
  final String startingpoint;
  final List imageList;
  final Uri map;
  final Video video;
  const Tour(this.id, this.title, this.subtitle, this.duration, this.len, this.steps, this.image, this.startingpoint, this.imageList, this.map, this.video);
}

class Video {
  final String id;
  final String title;
  final String description;
  final String source;
  final String preview;
  const Video(this.id, this.title,  this.description, this.source, this.preview);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verona Anche Mia',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(title: ' Verona Anche Mia'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List _tourslist = [];
  List tours = [];
  List _videoslist = [];
  List videos = [];

  // Fetch content from the json file
  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/database.json');
    final data = await json.decode(response);
    setState(() {
      _tourslist = data["items"];
      _videoslist = data["videos"];
    });

    _tourslist.forEach((tour) {
      tours.add(Tour(tour["id"],
          tour['name'],
          tour['description'],
          tour['duration'],
          tour['length'],
          tour['toursteps'],
          tour['image'],
          tour['startingpoint'],
          tour['gallery'],
          Uri.parse(tour['map']),
          Video(tour['video']['id'],tour['video']['title'],tour['video']['description'],tour['video']['src'],tour['video']['preview'])));
    });
    _videoslist.forEach((video) {
      videos.add(Video(video["id"], video['title'], video['description'], video['src'], video['preview']));
    });

    }

  @override
  void initState() {
    readJson();  //call async function.
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Text(
              "Seleziona un Tour",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Display the data loaded from sample.json
            tours.isNotEmpty ? Expanded(
              child: ListView.builder(
                itemCount: tours.length,
                itemBuilder: (context, index) {
                  return InkWell(
                      onTap: (){
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  tourPage(tour: tours[index])));},
                      child:
                      LocationListItem(
                          imageUrl: tours[index].image,
                          name: tours[index].title,
                          country: tours[index].duration + ' - ' + tours[index].len,
                      ),
                  );
                },
              ),
            )
                : Container()
          ],
        ),
      ),

      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child:
              Container(margin: EdgeInsets.only(left:30.0, top:20.0,right:30.0,bottom:20.0), child: Image.asset('assets/VAM_logo_transp.png'))
            ),
            ListTile(
              title: const Text('Verona Anche Mia'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  intro()));
                //
              },
            ),
            ListTile(
              title: const Text('Galleria Video'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => videoList(videosList: videos)));
                //
              },
            ),
            ListTile(
              title: const Text('Chi Siamo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  aboutUs()));
                //
              },
            ),
            ListTile(
              title: const Text('Privacy'),
              onTap: () {
                _launchUrl(_privacy);
                //
              },
            ),
            ListTile(
              title: const Text('Crediti'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  credits()));
                //
              },
            ),
            Divider(),
            Container(margin: EdgeInsets.only(left:30.0, top:20.0,right:30.0,bottom:20.0),),
            InkWell(
              child: Icon(Icons.language, color: Colors.blue, semanticLabel: 'Clicca qui per aprire il sito di verona anche mia.'),
              onTap: (){
                _launchUrl(_website);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class tourPage extends StatelessWidget {
  const tourPage({super.key, required this.tour});
  final Tour tour;
  final stageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tour.title),
      ),
      body: ListView(
        children: [
          Stack(children: [Image.asset(tour.image, fit: BoxFit.cover, width: double.infinity),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.5, 0.95],
                  ),
                ),
              ),
            ),
        Positioned(
          left: 20,
          bottom: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tour.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )]),
          Padding(padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new Container(
                alignment: FractionalOffset.center,
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>  gallery(imageList: tour.imageList)));
                      },
                      child: Row(
                          children: <Widget>[
                            Icon(Icons.collections),
                            Text(" Gallery")
                          ]
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () {_launchUrl(tour.map);},
                      child: Row(
                          children: <Widget>[
                            Icon(Icons.location_on),
                            Text(" Mappa")
                          ]
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top:20),
                child: RichText(
                  text: TextSpan(text: 'Percorso: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16,),
                    children:  <TextSpan>[
                    TextSpan(text: tour.subtitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                    ],
                  ),
                  )
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RichText(
                  text: TextSpan(text: 'Durata: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16,),
                    children:  <TextSpan>[
                      TextSpan(text: tour.duration, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                    ],
                  ),
                )
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RichText(
                  text: TextSpan(text: 'Lunghezza: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16,),
                    children:  <TextSpan>[
                      TextSpan(text: tour.len, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RichText(
                  text: TextSpan(text: 'Questo tour inizia da: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16,),
                    children:  <TextSpan>[
                      TextSpan(text: tour.startingpoint, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
              ),
              Text("\nApprofondimento Video", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              InkWell(
                onTap: (){

                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  videoPage(video: tour.video)));
                },
                child:
                LocationListItem(
                  imageUrl: tour.video.preview,
                  name: tour.video.title,
                  country: "",
                ),
              ),
              Text("\nInizia il Tour", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              InkWell(
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  stepPage(tour:tour, stageIndex: stageIndex)));
                  },
                child:
                LocationListItem(
                  imageUrl: tour.steps[stageIndex]["image"],
                  name: tour.steps[stageIndex]["title"],
                  country: "Clicca qui per iniziare il tour",
                ),
              ),
              ],
          ),)
        ],
      )
      );
  }
}

class stepPage extends StatelessWidget {
  const stepPage({super.key, required this.tour, required this.stageIndex});
  final Tour tour;
  final int stageIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(tour.steps[stageIndex]['title']),
        ),
        body: ListView(
          children: [
            Stack(children: [Image.asset(tour.steps[stageIndex]['image'], fit: BoxFit.cover, width: double.infinity),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 0.95],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                bottom: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tour.steps[stageIndex]['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )]),
            Padding(padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(tour.steps[stageIndex]['description'], style: const TextStyle(fontSize: 16)),
                  ),
            if(stageIndex < tour.steps.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text("Prossima tappa", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),

            if(stageIndex < tour.steps.length - 1)

              InkWell(
                onTap: (){
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  stepPage(tour: tour, stageIndex: stageIndex + 1)));},
                child:
                LocationListItem(
                imageUrl: tour.steps[stageIndex + 1]["image"],
                name: tour.steps[stageIndex + 1]["title"],
                country: "Clicca qui per proseguire il tour",
                ),
                )
               else
                 Column(
                   children:[
                     Text("\nApprofondimento Video", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                 InkWell(
                    onTap: (){

                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  videoPage(video: tour.video)));
                    },
                    child:
                    LocationListItem(
                    imageUrl: tour.video.preview,
                    name: tour.video.title,
                    country: "",
                    ),
                    ),
                    InkWell(
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>  MyHomePage(title: 'Verona Anche Mia',)));},
                      child:
                      LocationListItem(
                        imageUrl: 'assets/background.jpg',
                        name: "Torna alla home",
                        country: "",
                      ),
                    )]
                 )
                ],
              ),
            ),
          ],
        )
    );
  }
}

class aboutUs extends StatelessWidget {
  const aboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Chi Siamo'),
        ),
        body: ListView(
            children:[
        Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text("AMEntelibera è un’associazione culturale che nasce nel 2008 a San Bonifacio (Verona) e si occupa di promuovere stili di vita sostenibili attraverso esperienze in ambito educativo e di turismo di prossimità in senso inclusivo.\n\nIl progetto Verona Anche Mia è stato ideato dall’associazione con la volontà di dare un contributo per rendere Verona una città più accessibile e alla portata di tutti, realizzando percorsi destinati ai turisti con disabilità sensoriali ma anche ai residenti che vogliono conoscere la città con una modalità nuova, tecnologica e multisensoriale.\n\nAll’interno di AMEntelibera sono presenti figure di professioniste che hanno contribuito a vario titolo alla realizzazione del progetto: Manuela Uber, guida turistica con master di educatore esperto per le disabilità sensoriali e multifunzionali; Anna Corradini, accompagnatore turistico specializzata in organizzazione di eventi ed esperienze di viaggio; Tecla Soave, dottorata in scienze ambientali specializzata in educazione e comunicazione ambientale e valorizzazione del territorio.\n\nAl progetto hanno collaborato come partner istituzionali le associazioni G.O.L.D.VIS. e Genitori Tosti in Tutti i Posti insieme all’Istituto Istruzione Superiore Statale Copernico Pasoli di Verona.\n\nUn ringraziamento per il supporto all’interprete LIS Ornella Piazza.\n\nIl progetto è stato realizzato grazie al finanziamento ricevuto dall’Otto per Mille Valdese 2021.", style: const TextStyle(fontSize: 16)),
            ]
        )
        ),
            ]
        )
    );
  }
}


class credits extends StatelessWidget {
  const credits({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Crediti'),
        ),
        body: ListView(
          children:[
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(text: 'Concettualizzazione: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16,),
                      children:  <TextSpan>[
                        TextSpan(text: "Anna Corradini, Manuela Uber, Tecla Soave.\n", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(text: 'Testi: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16,),
                      children:  <TextSpan>[
                        TextSpan(text: "Anna Corradini, Manuela Uber, Classe 3A 2021-2022 Liceo Scientifico Copernico Pasoli.\n", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(text: 'Foto: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16,),
                      children:  <TextSpan>[
                        TextSpan(text: "Anna Corradini, Manuela Uber, Rui Alves, Cacao90.\n", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(text: 'Video: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16,),
                      children:  <TextSpan>[
                        TextSpan(text: "Sara Pigozzo.\n", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(text: 'Interpreti LIS: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16,),
                      children:  <TextSpan>[
                        TextSpan(text: "Alessia Balzi, Arianna Cattalini.\n", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(text: 'Grafiche: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16,),
                      children:  <TextSpan>[
                        TextSpan(text: "Marco Sartori.\n", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(text: 'Sviluppo: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16,),
                      children:  <TextSpan>[
                        TextSpan(text: "Giulio Gabrieli.\n", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(text: 'Iniziativa realizzata da: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16,),
                      children:[],
                    ),
                  ),
                  Padding(padding: const EdgeInsets.all(15)),
                  Image.asset("assets/mentelibera.png"),
                  RichText(
                    text: TextSpan(text: 'Con il sostegno di: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16,),
                      children:[],
                    ),
                  ),
                  Padding(padding: const EdgeInsets.all(15)),
                  Image.asset("assets/valdese.png"),
                  RichText(
                    text: TextSpan(text: 'In collaborazione con: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16,),
                      children:[],
                    ),
                  ),
                  Padding(padding: const EdgeInsets.all(15)),
                  Image.asset("assets/Goldvis.jpeg"),
                  Padding(padding: const EdgeInsets.all(15)),
                  Image.asset("assets/GenitoriTosti.png"),
                  Padding(padding: const EdgeInsets.all(15)),
                  Image.asset("assets/copernico.png"),
                ]
            )
          ),
        ]
        )
    );
  }
}

class intro extends StatelessWidget {
  const intro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Verona Anche Mia'),
        ),
        body: ListView(
            children:[
              Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: BetterPlayer.network(
                            "https://www.veronanchemia.it/app/videolancio.mp4",
                            betterPlayerConfiguration: BetterPlayerConfiguration(
                              aspectRatio: 16 / 9,
                              autoPlay: true,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 25),
                        ),
                        Text("Verona è spesso chiamata città della musica, dell’amore, dell’arte e grazie alle mura che nei secoli sono state costruite per difenderla, è stata nel 2000 riconosciuta come Patrimonio Unesco.\nDa oltre duemila anni la città è abitata e in ogni piazza e strada si trovano le tracce di questa lunga e interessante storia.\nVi suggeriamo quattro itinerari, della durata variabile tra un’ora e mezza e due ore e mezza. Per ciascuno troverete le tappe con tracciato gps, una descrizione, un video di approfondimento.\n“Verona for all”, il primo itinerario è il  più breve, vi guiderà nel centro della città ed è consigliato  a chi non conosce Verona o non ha molto tempo a disposizione, ma vuole vedere i luoghi imperdibili.\nIl secondo, “Verona for all plus”, di circa due ore, ricalca per alcuni tratti il primo, ma aggiunge tappe in luoghi limitrofi al centro.\nQuesti due itinerari sono accessibili anche a persone con disabilità motorie.\nLa terza proposta, “ Un assaggio di Veronetta”,  vi condurrà nel quartiere  a sinistra Adige, con una tappa  panoramica al colle di Castel San Pietro. Può essere abbinato ai primi due o fatto da solo, è una variazione interessante per chi è già stato in città, ha più tempo o desidera conoscere zone meno note.\nIl quarto percorso “Tre tesori senza tempo: Castelvecchio, San Zeno, Arsenale Austriaco” si svolge nella zona periferica del centro, più tranquilla, tra Castelvecchio e San Zeno e include una visita all’area dell’Arsenale austriaco. Questa ultima tappa è stata pensata e realizzata in collaborazione con una classe terza del Liceo Scientifico dell’Istituto Copernico Pasoli di Verona.\nA voi serve solo un po’ di curiosità! Benvenuti a Verona!", style: const TextStyle(fontSize: 16)),
                      ]
                  )
              ),
            ]
        )
    );
  }
}

class videoList extends StatelessWidget {
  const videoList({super.key, required this.videosList});
  final List videosList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Video'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              // Display the data loaded from sample.json
              videosList.isNotEmpty ? Expanded(
                child: ListView.builder(
                  itemCount: videosList.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: (){

                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>  videoPage(video: videosList[index])));
                      },
                      child:
                      LocationListItem(
                        imageUrl: videosList[index].preview,
                        name: videosList[index].title,
                        country: "",
                      ),
                    );
                  },
                ),
              )
                  : Container()
            ],
          ),
        ),
    );
  }
}

class videoPage extends StatelessWidget {
  const videoPage({super.key, required this.video});
  final Video video;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(video.title),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 25, right: 25),
        child: ListView(
          children: [
            Padding(padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(video.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: BetterPlayer.network(
                      video.source,
                      betterPlayerConfiguration: BetterPlayerConfiguration(
                        aspectRatio: 16 / 9,
                        autoPlay: true,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:12, bottom: 12),
                    child: Text(video.description, style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      );
  }
}

class gallery extends StatelessWidget {
  const gallery({super.key, required this.imageList});
  final List imageList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Gallery'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Implement the image carousel
              CarouselSlider(
                options: CarouselOptions(
                  autoPlay: false,
                  // autoPlayInterval: const Duration(seconds: 2),
                  // autoPlayAnimationDuration: const Duration(milliseconds: 400),
                  // height: 800,
                  viewportFraction: 1,
                ),
                items: imageList.map((item) {
                  return GridTile(
                    child: Image.asset(item["url"], fit: BoxFit.cover),
                    footer: Container(
                        padding: const EdgeInsets.all(15),
                        color: Colors.black54,
                        child: Text(
                          item["caption"],
                          style: const TextStyle(color: Colors.white, fontSize: 20),
                          textAlign: TextAlign.right,
                        )),
                  );
                }).toList(),
              ),
            ],
          ),
        )
    );
  }
}

Future<void> _launchUrl(_url) async {
  print("function called");
  if (!await launchUrl(_url)) {
    throw 'Could not launch $_url';
  }
}