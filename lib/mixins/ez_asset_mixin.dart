import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dev_eza_api/main.dart';
import 'package:ffw_photospaces/data_transfer_objects/selectable_photo_wrapper.dart';
import 'package:ffw_photospaces/services/current_locales_service.dart';

mixin EzAssetMixin {
  Future<void> createAssetAndUploadPhotos(List<SelectablePhotoWrapper> photosWrapper, String description) async {
    if (photosWrapper.isEmpty) {
      throw("Empty photos list provided");
      return;
    }

    // creates asset
    var newAsset = await DevEzaApi.ezAssetEndpoints
        .setSet(FormData.fromMap({
      "Data": json.encode({"TypeId": "1"})
    }))
        .then((response) => response.body.results[0]);

    //prints asset ID so I can check it afterwards in eza, and assigns an empty list to .data
    print(newAsset.identifier);
    newAsset.data = [];

    //for each photo create an entry in asset.data and upload just a FILE(photo)
    for (var wrapper in photosWrapper) {
      try {
        await DevEzaApi.ezFileEndpoints.uploadPost(FormData.fromMap(
            {"assetId": newAsset.identifier, "Type": "3", "File": await MultipartFile.fromFile(wrapper.photo.path)}));
      } catch (e) {
        print(CurrentLocalesService.errors.textUploadFailed);
        print(e);
        return;
      }

      // then get that asset again from the API, assign newAsset.data to asset that I fetched from api and try to call set(update) with that asset
      var asset = await DevEzaApi.ezAssetEndpoints.getGet(newAsset.identifier!).then((value) => value.body.results[0]);
      asset.data = newAsset.data;
      String id = newAsset.identifier!;
      try {
        DevEzaApi.ezAssetEndpoints.setSet(FormData.fromMap({
          "data": json.encode({"Identifier": id, "Asset.ReelPart_Description": description})
        }));
      } catch (e) {
        print('error in set $e');
      }
    }

    await DevEzaApi.ezLabelEndpoints.associateWithPost(FormData.fromMap({"Id": "16", "assetId": newAsset.identifier}));
  }
}