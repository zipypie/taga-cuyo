import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';

class TermsAndConditionsDialog extends StatelessWidget {
  const TermsAndConditionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dialog title
            Text(
              'Mga Termino at Kundisyon',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mangyaring basahin nang mabuti ang mga Termino at Kundisyong ito bago gamitin ang TAGA-CUYO: Tagalog Cuyonon Translator at Learning Application na pinapatakbo ng aming kumpanya.\n\n'
                      'Sa pag-access o paggamit ng aming Serbisyo, sumasang-ayon kang sumunod sa mga Termino. Kung hindi ka sang-ayon sa anumang bahagi ng mga Termino, hindi mo maaaring gamitin ang Serbisyo.\n\n',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '1. Pagtanggap sa mga Termino',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Sa pag-access o paggamit ng TAGA-CUYO, sumasang-ayon ka sa mga Termino na bumubuo ng isang ligal na kasunduan sa pagitan mo bilang user at ng aming kumpanya. Pinamamahalaan ng mga Termino na ito ang iyong paggamit ng aming Serbisyo, kabilang ang anumang mga update o bagong tampok na ibinibigay.\n\n',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '2. Account ng User',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '• Maaaring kailanganin mong gumawa ng account upang ma-access ang ilang mga tampok ng Serbisyo.\n'
                      '• Sumasang-ayon kang magbigay ng tumpak, kasalukuyan, at kumpletong impormasyon sa pagrehistro.\n'
                      '• Ikaw ay responsable sa pagpapanatili ng pagiging kompidensiyal ng iyong account at password, at sa pagbabawal ng access sa iyong device. Tinanggap mo ang responsibilidad sa lahat ng mga aktibidad na nangyayari sa ilalim ng iyong account.\n\n',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '3. Paggamit ng Serbisyo',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '• Ang Serbisyo ay inilaan para sa personal na, hindi pang-komersyal na paggamit.\n'
                      '• Hindi mo maaaring gamitin ang Serbisyo para sa anumang ilegal o hindi awtorisadong layunin.\n'
                      '• Sumasang-ayon kang huwag subukang kopyahin, baguhin, baligtarin ang inhenyeriya, o ipamahagi ang anumang bahagi ng Serbisyo.\n'
                      '• Hindi mo dapat abusuhin ang Serbisyo sa pamamagitan ng sadya o hindi sinasadyang pagpapakilala ng mga virus o iba pang mapanganib na materyal.\n\n',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '4. Ipinagbabawal na Gawain',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '• Paglabag sa anumang lokal, pambansa, o internasyonal na batas.\n'
                      '• Paggamit ng Serbisyo sa paraang makakapinsala, makakapag-disable, makakapagpabigat, o makakapinsala sa kakayahan nito.\n'
                      '• Pag-abala sa kasiyahan ng ibang mga gumagamit ng Serbisyo.\n'
                      '• Pagkolekta o pagkuha ng personal na datos mula sa Serbisyo nang walang pahintulot.\n\n',
                      style: TextStyle(fontSize: 16),
                    ),
                    // Magdagdag pa ng mga seksyon kung kinakailangan
                  ],
                ),
              ),
            ),
            const Divider(),
            // Bottom row for buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cancel button
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.black,
                  ),
                  child: Text('Kanselahin',
                        style: TextStyle(
                            fontSize: 19,
                            fontFamily: AppFonts.fcr,
                            fontWeight: FontWeight.bold)),
                ),
                // Agree button
                ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.primaryBackground),
                    child: Text('Sumang-ayon',
                        style: TextStyle(
                            fontSize: 19,
                            fontFamily: AppFonts.fcr,
                            fontWeight: FontWeight.bold))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
