import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:dev_eza_api/main.dart';
import 'package:dev_eza_api/response_parts/base_response.dart';
import 'package:dio/dio.dart';
import 'package:ffw_photospaces/data_transfer_objects/selectable_photo_wrapper.dart';

mixin EzAssetMixin {
  Future<void> createAssetAndUploadPhotos(List<XFile> photoWrappers, String description) async {
    if (photoWrappers.isEmpty) {
      throw Exception('empty wrappers');
    }

    EzAsset newAsset = await _createAsset();

    newAsset.data = [];

    for (var wrapper in photoWrappers) {
      await _uploadPhoto(newAsset, wrapper);

      // then get that asset again from the API, assign newAsset.data to asset that I fetched from api and try to call set(update) with that asset
      var asset = await _getAsset(newAsset.identifier!);
      asset.data = newAsset.data;

      await _updateAssetDescription(newAsset.identifier!, description);

      await _associateWithLabel(newAsset, 16.toString());
    }
  }
}

Future<BaseResponse<EzLabelAssociateWithResponse>> _associateWithLabel(EzAsset newAsset, String labelId) async =>
    await DevEzaApi.ezLabelEndpoints
        .associateWithPost(FormData.fromMap({"Id": labelId, "assetId": newAsset.identifier}));

Future<BaseResponse<EzAsset>> _updateAssetDescription(String id, String description) {
  return DevEzaApi.ezAssetEndpoints.setSet(FormData.fromMap({
    "data": json.encode({"Identifier": id, "Asset.ReelPart_Description": description})
  }));
}

Future<EzAsset> _getAsset(String id) async =>
    await DevEzaApi.ezAssetEndpoints.getGet(id).then((value) => value.body.results[0]);

Future<BaseResponse<EzWasSuccessResponse>> _uploadPhoto(EzAsset newAsset, XFile photo) async {
  return await DevEzaApi.ezFileEndpoints.uploadPost(FormData.fromMap(
      {"assetId": newAsset.identifier, "Type": "3", "File": await MultipartFile.fromFile(photo.path)}));
}

Future<EzAsset> _createAsset() async {
  return await DevEzaApi.ezAssetEndpoints
      .setSet(FormData.fromMap({
        "Data": json.encode({"TypeId": "1"})
      }))
      .then((response) => response.body.results[0]);
}
