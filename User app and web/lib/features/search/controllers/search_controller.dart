import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/search/domain/models/popular_categories_model.dart';
import 'package:sixam_mart/features/search/domain/models/search_suggestion_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/search/domain/services/search_service_interface.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SearchController extends GetxController implements GetxService {
  final SearchServiceInterface searchServiceInterface;
  SearchController({required this.searchServiceInterface}) {
    _speech = stt.SpeechToText();
  }

  List<Item>? _searchItemList;
  List<Item>? get searchItemList => _searchItemList;
  
  List<Item>? _allItemList;
  List<Item>? get allItemList => _allItemList;
  
  List<Item>? _suggestedItemList;
  List<Item>? get suggestedItemList => _suggestedItemList;
  
  List<Store>? _searchStoreList;
  List<Store>? get searchStoreList => _searchStoreList;
  
  List<Store>? _allStoreList;
  List<Store>? get allStoreList => _allStoreList;
  
  String? _searchText = '';
  String? get searchText => _searchText;
  
  String? _storeResultText = '';
  
  String? _itemResultText = '';
  
  double _lowerValue = 0;
  double get lowerValue => _lowerValue;
  
  double _upperValue = 0;
  double get upperValue => _upperValue;
  
  List<String> _historyList = [];
  List<String> get historyList => _historyList;
  
  bool _isSearchMode = true;
  bool get isSearchMode => _isSearchMode;
  
  final List<String> _sortList = ['ascending'.tr, 'descending'.tr];
  List<String> get sortList => _sortList;
  
  int _sortIndex = -1;
  int get sortIndex => _sortIndex;

  int _storeSortIndex = -1;
  int get storeSortIndex => _storeSortIndex;
  
  int _rating = -1;
  int get rating => _rating;

  int _storeRating = -1;
  int get storeRating => _storeRating;
  
  bool _isStore = false;
  bool get isStore => _isStore;
  
  bool _isAvailableItems = false;
  bool get isAvailableItems => _isAvailableItems;

  bool _isAvailableStore = false;
  bool get isAvailableStore => _isAvailableStore;
  
  bool _isDiscountedItems = false;
  bool get isDiscountedItems => _isDiscountedItems;

  bool _isDiscountedStore = false;
  bool get isDiscountedStore => _isDiscountedStore;
  
  bool _veg = false;
  bool get veg => _veg;

  bool _storeVeg = false;
  bool get storeVeg => _storeVeg;
  
  bool _nonVeg = false;
  bool get nonVeg => _nonVeg;

  bool _storeNonVeg = false;
  bool get storeNonVeg => _storeNonVeg;
  
  String? _searchHomeText = '';
  String? get searchHomeText => _searchHomeText;

  SearchSuggestionModel? _searchSuggestionModel;
  SearchSuggestionModel? get searchSuggestionModel => _searchSuggestionModel;

  List<PopularCategoryModel?>? _popularCategoryList;
  List<PopularCategoryModel?>? get popularCategoryList => _popularCategoryList;

  void toggleVeg() {
    _veg = !_veg;
    update();
  }

  void toggleStoreVeg() {
    _storeVeg = !_storeVeg;
    update();
  }

  void toggleNonVeg() {
    _nonVeg = !_nonVeg;
    update();
  }

  void toggleStoreNonVeg() {
    _storeNonVeg = !_storeNonVeg;
    update();
  }

  void toggleAvailableItems() {
    _isAvailableItems = !_isAvailableItems;
    update();
  }

  void toggleAvailableStore() {
    _isAvailableStore = !_isAvailableStore;
    update();
  }

  void toggleDiscountedItems() {
    _isDiscountedItems = !_isDiscountedItems;
    update();
  }

  void toggleDiscountedStore() {
    _isDiscountedStore = !_isDiscountedStore;
    update();
  }

  void setStore(bool isStore) {
    _isStore = isStore;
    update();
  }

  void setSearchMode(bool isSearchMode, {bool canUpdate = true}) {
    _isSearchMode = isSearchMode;
    if(isSearchMode) {
      _searchText = '';
      _itemResultText = '';
      _storeResultText = '';
      _allStoreList = null;
      _allItemList = null;
      _searchItemList = null;
      _searchStoreList = null;
      _sortIndex = -1;
      _storeSortIndex = -1;
      _isDiscountedItems = false;
      _isDiscountedStore = false;
      _isAvailableItems = false;
      _isAvailableStore = false;
      _veg = false;
      _storeVeg = false;
      _nonVeg = false;
      _storeNonVeg = false;
      _rating = -1;
      _storeRating = -1;
      _upperValue = 0;
      _lowerValue = 0;
    }
    if(_isStore) {
      _isStore = !_isStore;
    }
    if(canUpdate) {
      update();
    }
  }

  void setLowerAndUpperValue(double lower, double upper) {
    _lowerValue = lower;
    _upperValue = upper;
    update();
  }

  void sortItemSearchList() {
    _searchItemList = searchServiceInterface.sortItemSearchList(_allItemList, _upperValue, _lowerValue, _rating, _veg, _nonVeg, _isAvailableItems, _isDiscountedItems, _sortIndex);
    update();
  }

  void sortStoreSearchList() {
    _searchStoreList = searchServiceInterface.sortStoreSearchList(_allStoreList, _storeRating, _storeVeg, _storeNonVeg, _isAvailableStore, _isDiscountedStore, _storeSortIndex);
    update();
  }

  void setSearchText(String text) {
    _searchText = text;
    update();
  }

  void getSuggestedItems() async {
    List<Item>? suggestedItemList = await searchServiceInterface.getSuggestedItems();
    if(suggestedItemList != null) {
      _suggestedItemList = [];
      _suggestedItemList!.addAll(suggestedItemList);
    }
    update();
  }

  Future<void> searchData(String? query, bool fromHome) async {
    if((_isStore && query!.isNotEmpty && query != _storeResultText) || (!_isStore && query!.isNotEmpty && (query != _itemResultText || fromHome))) {
      _searchHomeText = query;
      _searchText = query;
      _rating = -1;
      _storeRating = -1;
      _upperValue = 0;
      _lowerValue = 0;
      if (_isStore) {
        _searchStoreList = null;
        _allStoreList = null;
      } else {
        _searchItemList = null;
        _allItemList = null;
      }
      if (!_historyList.contains(query)) {
        _historyList.insert(0, query);
      }
      searchServiceInterface.saveSearchHistory(_historyList);
      _isSearchMode = false;
      if(!fromHome) {
        update();
      }

      Response response = await searchServiceInterface.getSearchData(query, _isStore);
      if (response.statusCode == 200) {
        if (query.isEmpty) {
          if (_isStore) {
            _searchStoreList = [];
          } else {
            _searchItemList = [];
          }
        } else {
          if (_isStore) {
            _storeResultText = query;
            _searchStoreList = [];
            _allStoreList = [];
            _searchStoreList!.addAll(StoreModel.fromJson(response.body).stores!);
            _allStoreList!.addAll(StoreModel.fromJson(response.body).stores!);
          } else {
            _itemResultText = query;
            _searchItemList = [];
            _allItemList = [];
            _searchItemList!.addAll(ItemModel.fromJson(response.body).items!);
            _allItemList!.addAll(ItemModel.fromJson(response.body).items!);
          }
        }
      }
      update();
    }
  }

  void getHistoryList() {
    _isSearchMode = true;
    _searchText = '';
    _historyList = [];
    _historyList.addAll(searchServiceInterface.getSearchAddress());
  }

  void removeHistory(int index) {
    _historyList.removeAt(index);
    searchServiceInterface.saveSearchHistory(_historyList);
    update();
  }

  void clearSearchHistory() async {
    searchServiceInterface.clearSearchHistory();
    _historyList = [];
    update();
  }

  void setRating(int rate) {
    _rating = rate;
    update();
  }

  void setStoreRating(int rate) {
    _storeRating = rate;
    update();
  }

  void setSortIndex(int index) {
    _sortIndex = index;
    update();
  }

  void setStoreSortIndex(int index) {
    _storeSortIndex = index;
    update();
  }

  void resetFilter() {
    _rating = -1;
    _upperValue = 0;
    _lowerValue = 0;
    _isAvailableItems = false;
    _isDiscountedItems = false;
    _veg = false;
    _nonVeg = false;
    _sortIndex = -1;
    update();
  }

  void resetStoreFilter() {
    _storeRating = -1;
    _isAvailableStore = false;
    _isDiscountedStore = false;
    _storeVeg = false;
    _storeNonVeg = false;
    _storeSortIndex = -1;
    update();
  }

  void clearSearchHomeText() {
    _searchHomeText = '';
    update();
  }

  Future<List<String>> getSearchSuggestions(String searchText) async {
    List<String> items = <String>[];
    _searchSuggestionModel = await searchServiceInterface.getSearchSuggestions(searchText);
    if(_searchSuggestionModel != null) {
      for (var item in _searchSuggestionModel!.items!) {
        items.add(item.name!);
      }
      for (var store in _searchSuggestionModel!.stores!) {
        items.add(store.name!);
      }
    }
    return items;
  }

  Future<void> getPopularCategories() async {
    _popularCategoryList = null;
    _popularCategoryList = await searchServiceInterface.getPopularCategories();
    update();
  }


  ///Voice Search..................

  bool voiceIsListening = false;
  String voiceText = '';
  double voiceSoundLevel = 0.0;
  bool voiceAvailable = false;
  Timer? _voiceAutoSubmitTimer;

  late stt.SpeechToText _speech;

  /// Initialize speech (safe to call multiple times)
  Future<void> initVoice({bool isUpdate = true}) async {
    try {
      final available = await _speech.initialize(onStatus: _onStatus, onError: _onError);
      voiceAvailable = available;
    } catch (e) {
      voiceAvailable = false;
    }
    if(isUpdate) update();
  }

  void _onStatus(String status) {
    if (status == stt.SpeechToText.listeningStatus) {
      setVoiceListening(true);
      cancelVoiceAutoSubmit();
    } else if (status == stt.SpeechToText.doneStatus || status == stt.SpeechToText.notListeningStatus || status == 'not listening') {
      setVoiceListening(false);
      scheduleVoiceAutoSubmit(const Duration(seconds: 2));
    }
  }

  void _onError(dynamic error) {
    setVoiceListening(false);
  }

  /// Start listening and optionally update an external TextEditingController live
  Future<void> startVoiceListening({TextEditingController? externalController}) async {
    cancelVoiceAutoSubmit();

    // clear any previous session
    try {
      if (_speech.isListening) await _speech.stop();
      await _speech.cancel();
    } catch (_) {}

    if (!voiceAvailable) {
      await initVoice();
      if (!voiceAvailable) return;
    }

    // reset
    setVoiceText('');
    setVoiceSoundLevel(0.0);

    try {
      await _speech.listen(
        onResult: (result) {
          final recognized = result.recognizedWords;
          setVoiceText(recognized);
          if (externalController != null) {
            externalController.text = recognized;
            externalController.selection = TextSelection.fromPosition(TextPosition(offset: externalController.text.length));
          }
        },
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 5),
        onSoundLevelChange: (level) {
          final normalized = (level / 50).clamp(0.0, 1.0);
          setVoiceSoundLevel(normalized);
        },
        localeId: '${Get.find<LocalizationController>().locale.languageCode}_${Get.find<LocalizationController>().locale.countryCode}',
        listenOptions: stt.SpeechListenOptions(partialResults: true, cancelOnError: true, listenMode: stt.ListenMode.search),
      );
      if (_speech.isListening) {
        setVoiceListening(true);
      } else {
        setVoiceListening(false);
      }
    } catch (e) {
      setVoiceListening(false);
    }
  }

  /// Stop or cancel listening
  Future<void> stopVoiceListening({bool submit = false}) async {
    cancelVoiceAutoSubmit();
    try {
      await _speech.stop();
    } catch (e) {
      try {
        await _speech.cancel();
      } catch (_) {}
    }
    setVoiceListening(false);
    if (submit) await submitVoiceNow();
  }

  void setVoiceListening(bool value, {bool isUpdate = true}) {
    voiceIsListening = value;
    if(isUpdate) update();
  }

  void setVoiceText(String text, {bool isUpdate = true}) {
    voiceText = text;
    if(isUpdate) update();
  }

  void setVoiceSoundLevel(double level, {bool isUpdate = true}) {
    voiceSoundLevel = level;
    if(isUpdate) update();
  }

  void scheduleVoiceAutoSubmit(Duration duration) {
    _voiceAutoSubmitTimer?.cancel();
    _voiceAutoSubmitTimer = Timer(duration, () async {
      await submitVoiceNow();
    });
  }

  void cancelVoiceAutoSubmit() {
    _voiceAutoSubmitTimer?.cancel();
    _voiceAutoSubmitTimer = null;
  }

  Future<void> submitVoiceNow() async {
    cancelVoiceAutoSubmit();
    final text = voiceText.trim();
    if (text.isNotEmpty) {
      try {
        if ((Get.isBottomSheetOpen ?? false) || (Get.isDialogOpen ?? false)) {
          Get.back();
        }
      } catch (_) {}
      await searchData(text, false);
    }
  }

  @override
  void onClose() {
    _voiceAutoSubmitTimer?.cancel();
    super.onClose();
  }
  
}