import 'package:flutter/material.dart';

const Color _bhojBg = Color(0xFFF4E8D1);
const Color _bhojCard = Color(0xFFFAF2E4);
const Color _bhojBrown = Color(0xFF5C3A21);
const Color _bhojBorder = Color(0xFF8C6239);

class VratKathaScreen extends StatefulWidget {
  const VratKathaScreen({super.key});

  @override
  State<VratKathaScreen> createState() => _VratKathaScreenState();
}

class _VratKathaScreenState extends State<VratKathaScreen> {
  final List<Map<String, String>> _kathas = [
    {
      'title': 'सत्यनारायण व्रत कथा',
      'subtitle': 'विष्णु पूजा, सुख-शांति एवं मनोकामना पूर्ति',
      'content': 'एक समय नैमिषारण्य तीर्थ में शौनकादि ऋषिगणों ने सूत जी से पूछा कि हे महामुनि! ऐसा कौन सा व्रत है जिसके करने से मनवांछित फल प्राप्त होता है। तब सूत जी ने कहा कि भगवान श्री सत्यनारायण की कथा सभी दुखों को दूर करने वाली है। प्राचीन समय में काशीनगर में एक निर्धन ब्राह्मण रहता था जो भिक्षा मांगकर अपना जीवन चलाता था। उसकी भक्ति से प्रसन्न होकर भगवान श्री विष्णु ने वृद्ध ब्राह्मण का रूप धारण कर उसे सत्यनारायण व्रत का विधान बताया। ब्राह्मण ने विधि-विधान से व्रत किया और अपार धन-धान्य प्राप्त किया। इस कथा के सुनने से मनुष्य के सभी पाप नष्ट होते हैं और अंत में वैकुण्ठ धाम की प्राप्ति होती है।'
    },
    {
      'title': 'प्रदोष व्रत कथा',
      'subtitle': 'भगवान शिव की कृपा, आरोग्यता और पाप नाश',
      'content': 'स्कंद पुराण के अनुसार प्रदोष व्रत त्रयोदशी तिथि को किया जाता है। प्रदोष काल में भगवान शिव की पूजा का विशेष महात्म्य है। प्राचीन काल में एक विधवा ब्राह्मणी अपने पुत्र को लेकर भिक्षा मांगने जाती थी। एक दिन उसे एक घायल राजकुमार मिला जिसे वह अपने घर ले आई। वह राजकुमार गंधर्वराज था। उसने ब्राह्मणी और उसके पुत्र को देवर्षि नारद के कहने पर प्रदोष व्रत का महात्म्य बताया। प्रदोष व्रत के प्रभाव से राजकुमार का राज्य पुनः प्राप्त हुआ और ब्राह्मणी के सभी कष्ट दूर हो गए।'
    },
    {
      'title': 'एकादशी व्रत कथा (विष्णु प्रिया)',
      'subtitle': 'मोक्ष, पाप मुक्ति और श्रीहरि की प्रसन्नता',
      'content': 'युधिष्ठिर ने भगवान श्रीकृष्ण से पूछा कि हे भगवन! पतन और पापों से मुक्ति दिलाने वाली कौन सी एकादशी है? श्रीकृष्ण ने कहा कि वर्ष की सभी एकादशियाँ (जैसे देवशयनी, देवोत्थान, निर्जला, पापमोचनी) मनुष्य के समस्त पापों को हर लेती हैं। एकादशी के दिन अन्न ग्रहण नहीं करना चाहिए, रात्रि जागरण और विष्णु सहस्रनाम का पाठ करना अत्यंत पुण्यदायी है।'
    },
    {
      'title': 'करवा चौथ व्रत कथा',
      'subtitle': 'अखंड सौभाग्य, पति की दीर्घायु और सुखी दांपत्य',
      'content': 'वीरवती नामक एक निपुण रानी ने अपने सातों भाइयों के प्रेम व आग्रह पर चंद्रमा निकलने से पहले ही कृत्रिम चंद्रमा दिखाकर व्रत खोल लिया। इससे उसके पति की तबीयत गंभीर हो गई। गणेश जी और माता करवा की कृपा से उसने पुनः सच्चे मन से विधिपूर्वक चौथ माता का व्रत किया, जिससे उसके पति को पुनर्जीवन प्राप्त हुआ। तभी से यह व्रत अखंड सौभाग्य के लिए किया जाता है।'
    },
    {
      'title': 'संपूर्ण श्री गणेश आरती',
      'subtitle': 'जय गणेश जय गणेश जय गणेश देवा',
      'content': 'जय गणेश जय गणेश जय गणेश देवा, माता जाकी पार्वती पिता महादेवा।
एक दंत दयावंत चार भुजा धारी, मढ़े सिंदूर सोहे मूस की सवारी।
हार चढ़े फूल चढ़े और चढ़े मेवा, लड्डू का भोग लागे संत करें सेवा।
अंधे को आंख देत कोढ़िन को काया, बांझन को पुत्र देत निर्धन को माया।
धूप दीप नैवेद्य चरणों से ध्यावे, सूखे नैन वाले दरस पावे।
बोलो गजानन महाराज की जय!'
    },
    {
      'title': 'संपूर्ण श्री लक्ष्मी आरती',
      'subtitle': 'ओम जय लक्ष्मी माता, मैया जय लक्ष्मी माता',
      'content': 'ओम जय लक्ष्मी माता, मैया जय लक्ष्मी माता। तुमको ध्यावत नैनन सिंदूर रचाता॥
उमद घुमद कर आई हरिवल्लभ माता, स्थिर रहो तुम घर में सुख-शांति विधाता॥
विष्णु प्रिया तुम हो सब सुख की दाता, जो कोई तुमको ध्यावत मनवांछित फल पाता॥
संतोषी तुम हो सबकी रखवाली, भर दो झोली सबकी खाली-खाली॥
ओम जय लक्ष्मी माता।'
    },
    {
      'title': 'संपूर्ण श्री शिव आरती',
      'subtitle': 'ओम जय शिव ओमकारा, स्वामी जय शिव ओमकारा',
      'content': 'ओम जय शिव ओमकारा, स्वामी जय शिव ओमकारा। ब्रह्मा विष्णु सदाशिव अर्द्धांगी धारा॥
एकानन चतुरानन पंचानन राजे, हंसासन गरुड़ासन वाहन साजे॥
दो भुज चार भुज तेह्र रूप धारे, तीनों जनन जगत के काज संवारे॥
अक्षमाला बनमाला मुंडमाल धारी, त्रिपुरारि संहारक भवदुःखहारी॥
ॐ जय शिव ओमकारा।'
    },
    {
      'title': 'संपूर्ण श्री हनुमान आरती',
      'subtitle': 'आरती कीजै हनुमान लूला की, दुष्ट दलन संकट मोचन की',
      'content': 'आरती कीजै हनुमान लूला की, दुष्ट दलन संकट मोचन की।
कंचन थार कपूर की बत्ती, आरती करत अनंता रत्ती॥
लंक विध्वंस किए रघुराई, तुलसीदास प्रभु आस लगाई॥
अंजनि पुत्र महाबलदायी, संतन के प्रभु सदा सहाई॥'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bhojBg,
      appBar: AppBar(
        backgroundColor: _bhojBrown,
        foregroundColor: _bhojBg,
        title: const Text('व्रत कथाएँ एवं सम्पूर्ण आरती संग्रह', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _kathas.length,
        itemBuilder: (context, index) {
          final katha = _kathas[index];
          return Card(
            color: _bhojCard,
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: _bhojBorder, width: 1.2)),
            child: ExpansionTile(
              collapsedIconColor: _bhojBrown,
              iconColor: _bhojBrown,
              title: Text(katha['title']!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: _bhojBrown)),
              subtitle: Text(katha['subtitle']!, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(color: _bhojBorder),
                      const SizedBox(height: 8),
                      Text(
                        katha['content']!,
                        style: const TextStyle(fontSize: 14.5, height: 1.5, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
