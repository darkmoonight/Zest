import 'package:get/get.dart';
import 'package:zest/translation/ar_ar.dart';
import 'package:zest/translation/de_de.dart';
import 'package:zest/translation/en_us.dart';
import 'package:zest/translation/es_es.dart';
import 'package:zest/translation/fa_ir.dart';
import 'package:zest/translation/fr_fr.dart';
import 'package:zest/translation/it_it.dart';
import 'package:zest/translation/ko_kr.dart';
import 'package:zest/translation/pl_pl.dart';
import 'package:zest/translation/ru_ru.dart';
import 'package:zest/translation/zh_cn.dart';
import 'package:zest/translation/zh_tw.dart';
import 'package:zest/translation/tr_tr.dart';
import 'package:zest/translation/vi_vn.dart';
import 'package:zest/translation/pt_pt.dart';
import 'package:zest/translation/ja_jp.dart';

class Translation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'ru_RU': RuRu().messages,
    'en_US': EnUs().messages,
    'zh_CN': ZhCN().messages,
    'zh_TW': ZhTw().messages,
    'fa_IR': FaIr().messages,
    'ar_AR': ArAr().messages,
    'es_ES': EsEs().messages,
    'fr_FR': FrFr().messages,
    'de_DE': DeDe().messages,
    'it_IT': ItIt().messages,
    'tr_TR': TrTr().messages,
    'vi_VN': ViVn().messages,
    'ko_KR': KoKr().messages,
    'pt_PT': PtPt().messages,
    'pl_PL': PlPl().messages,
    'ja_JP': JaJp().messages,
  };
}
