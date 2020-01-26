import 'package:url_launcher/url_launcher.dart';

class Urls {
  static final String baseUrl = 'https://api.guildwars2.com/v2';

  static final String tokenInfoUrl = '/tokeninfo';
  static final String accountUrl = '/account';

  static final String currencyUrl = '/currencies?ids=all';
  static final String walletUrl = '/account/wallet';

  static final String completedWorldBossesUrl = '/account/worldbosses';
  static final String completedRaidsUrl = '/account/raids';
  static final String completedDungeonsUrl = '/account/dungeons';

  static final String charactersUrl = '/characters?ids=all';
  static final String titlesUrl = '/titles?ids=all';
  static final String professionsUrl = '/professions?ids=all';

  static final String itemsUrl = '/items?ids=';
  static final String skinsUrl = '/skins?ids=';
  static final String minisUrl = '/minis?ids=';

  static final String inventoryUrl = '/account/inventory';
  static final String bankUrl = '/account/bank';
  static final String materialUrl = '/account/materials';
  static final String materialCategoryUrl = '/materials?ids=all';

  static final String tradingPostPriceUrl = '/commerce/prices/';
  static final String tradingPostDeliveryUrl = '/commerce/delivery';
  static final String tradingPostTransactionsUrl = '/commerce/transactions/';
  static final String tradingPostListingsUrl = '/commerce/listings/';

  static final String achievementsUrl = '/achievements?ids=';
  static final String achievementProgressUrl = '/account/achievements';
  static final String achievementCategoriesUrl = '/achievements/categories?ids=all';
  static final String achievementGroupsUrl = '/achievements/groups?ids=all';
  static final String dailiesUrl = '/achievements/daily';
  static final String dailiesTomorrowUrl = '/achievements/daily/tomorrow';

  static final String masteriesUrl = '/masteries?ids=all';
  static final String masteryProgressUrl = '/account/masteries';

  static List<String> divideIdLists(List<int> ids) {
    List<List<int>> output = [[]];
    ids.forEach((id) {
      output.firstWhere((l) => l.length < 150, orElse: () {
        List<int> newList = [];
        output.add(newList);
        return newList;
      }).add(id);
    });
    return output.map((l) => l.join(',')).toList();
  }

  static Future<void> launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}