import 'package:get/get.dart';
import 'package:drm_admin/translation/bn_in.dart';
import 'package:drm_admin/translation/cs_cz.dart';
import 'package:drm_admin/translation/da_dk.dart';
import 'package:drm_admin/translation/de_de.dart';
import 'package:drm_admin/translation/en_us.dart';
import 'package:drm_admin/translation/es_es.dart';
import 'package:drm_admin/translation/fa_ir.dart';
import 'package:drm_admin/translation/fr_fr.dart';
import 'package:drm_admin/translation/ga_ie.dart';
import 'package:drm_admin/translation/hi_in.dart';
import 'package:drm_admin/translation/hu_hu.dart';
import 'package:drm_admin/translation/it_it.dart';
import 'package:drm_admin/translation/ka_ge.dart';
import 'package:drm_admin/translation/ko_kr.dart';
import 'package:drm_admin/translation/nl_nl.dart';
import 'package:drm_admin/translation/pl_pl.dart';
import 'package:drm_admin/translation/pt_br.dart';
import 'package:drm_admin/translation/ro_ro.dart';
import 'package:drm_admin/translation/ru_ru.dart';
import 'package:drm_admin/translation/sk_sk.dart';
import 'package:drm_admin/translation/tr_tr.dart';
import 'package:drm_admin/translation/ur_pk.dart';
import 'package:drm_admin/translation/zh_ch.dart';
import 'package:drm_admin/translation/zh_tw.dart';

class Translation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'ru_RU': RuRu().messages,
        'en_US': EnUs().messages,
        'fr_FR': FrFr().messages,
        'fa_IR': FaIr().messages,
        'it_IT': ItIt().messages,
        'de_DE': DeDe().messages,
        'tr_TR': TrTr().messages,
        'pt_BR': PtBr().messages,
        'es_ES': EsEs().messages,
        'sk_SK': SkSk().messages,
        'nl_NL': NlNl().messages,
        'hi_IN': HiIn().messages,
        'ro_RO': RoRo().messages,
        'zh_CN': ZhCh().messages,
        'zh_TW': ZhTw().messages,
        'pl_PL': PlPl().messages,
        'ur_PK': UrPk().messages,
        'cs_CZ': CsCz().messages,
        'ka_GE': KaGe().messages,
        'bn_IN': BnIn().messages,
        'ga_IE': GaIe().messages,
        'hu_HU': HuHu().messages,
        'da_DK': DaDk().messages,
        'ko_KR': KoKr().messages,
      };
}
