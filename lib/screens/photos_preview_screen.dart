import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dev_eza_api/main.dart';
import 'package:dio/dio.dart';
import 'package:ffw_photospaces/data_transfer_objects/file_data_transfer_object.dart';
import 'package:ffw_photospaces/main.dart';
import 'package:ffw_photospaces/screens/photo_preview_screen.dart';
import 'package:ffw_photospaces/widgets/base_outlined_button.dart';
import 'package:ffw_photospaces/widgets/animated_photo_dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class PhotosPreviewScreen extends StatefulWidget {
  final List<FileDataTransferObject<XFile>> _photosDTO;

  const PhotosPreviewScreen(this._photosDTO, {Key? key}) : super(key: key);

  @override
  State<PhotosPreviewScreen> createState() => _PhotosPreviewScreenState();
}

class _PhotosPreviewScreenState extends State<PhotosPreviewScreen> {
  List<FileDataTransferObject<XFile>> _selectedPhotos = [];
  bool isSelectMode = true;
  var successFullUploadsCount = 0;
  double GRIDTILE_WIDTH = 129;
  double GRIDTILE_HEIGHT = 129;

  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedPhotos = List<FileDataTransferObject<XFile>>.from(widget._photosDTO);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        body: Column(children: [
          Expanded(
            child: buildPhotosGrid(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
                    child: TextField(
                      decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.edit),
                        hintText: 'Description',
                        isDense: true,
                      ),
                      controller: _textEditingController,
                      textAlign: TextAlign.left,
                      maxLength: 60,
                      maxLengthEnforcement: MaxLengthEnforcement.none,
                    ),
                  ),
                )

                /*
                buildAddDescriptionButton(),
                if (!isSelectMode) buildUploadAllButton(context),
                if (_selectedPhotos.length != widget._photosDTO.length && isSelectMode) buildSelectAllButton(),
                if (isSelectMode && _selectedPhotos.isNotEmpty) buildUnselectAllButton()*/
              ],
            ),
          )
        ]));
  }

  GridView buildPhotosGrid() {
    return GridView.builder(
      itemCount: widget._photosDTO.length,
      scrollDirection: Axis.vertical,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: (MediaQuery.of(context).size.width / GRIDTILE_WIDTH).round(),
          crossAxisSpacing: 0,
          mainAxisSpacing: 0),
      itemBuilder: (BuildContext context, int index) {
        var photoDTO = widget._photosDTO[index];

        return Padding(
          padding: const EdgeInsets.all(0.8),
          child: GridTile(
            child: GestureDetector(
              onTap: () => togglePhotoSelect(photoDTO),
              onDoubleTap: () => navigateToPhotoPreviewScreen(context, photoDTO),
              onLongPress: () async {
                await animateGridTileWidth();
                await Future.delayed(const Duration(milliseconds: 150), () {
                  showDialog(
                      context: context,
                      builder: (_) => AnimatedPhotoDialogBox(
                        photoDTO: photoDTO, callback: () => setState(() {
                        widget._photosDTO.remove(photoDTO);
                        }),
                      ));
                  Vibrate.feedback(FeedbackType.impact);
                });

              },
              child: Stack(children: [
                Positioned(
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: GRIDTILE_WIDTH,
                        height: GRIDTILE_HEIGHT,
                        child: Image.file(
                          File(photoDTO.file.path),
                          cacheHeight: 1000,
                          cacheWidth: 1000,
                        ))),
                if (isSelectMode)
                  _selectedPhotos.contains(photoDTO)
                      ? Positioned(
                          bottom: 6,
                          right: 6,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Icon(
                                Icons.check_circle,
                                size: 20,
                                color: Theme.of(context).unselectedWidgetColor,
                              ),
                            ),
                          ))
                      : Positioned(
                          bottom: 6,
                          right: 6,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Icon(
                                Icons.radio_button_unchecked,
                                size: 20,
                                color: Theme.of(context).unselectedWidgetColor,
                              ),
                            ),
                          ))
              ]),
            ),
          ),
        );
      },
    );
  }

  Future<void> animateGridTileWidth() async {
    setState(() {
      GRIDTILE_WIDTH -= 10;
    });
    await Future.delayed(const Duration(milliseconds: 150), null);
    setState(() {
      GRIDTILE_WIDTH += 10;
    });
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      actions: [
        IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/mockHomeScreen', (_) => _.settings.name == '/mockHomeScreen');
            },
            icon: const Icon(Icons.cancel)),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.08,
        ),
        BaseOutlinedButton(
          'select',
          null,
          toggleSelectionMode,
          initialSelected: true,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.07,
        ),
        IconButton(
            onPressed: () async {
              if (_selectedPhotos.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No photos selected')));
                return;
              }

              if (_textEditingController.text.isEmpty) {
                showModalBottomSheet(context: context, builder: (context) => buildDescriptionIsEmptyModal(context));
              } else {
                await handleUploadAndShowSnackBars(context);
                popAllAndNavigateToMockScreen(context);
              }

              successFullUploadsCount = 0;
            },
            icon: const Icon(Icons.check_circle)),
      ],
    );
  }

  void popAllAndNavigateToMockScreen(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/mockHomeScreen', (route) => false);
  }

  Widget buildAddDescriptionButton() {
    return BaseOutlinedButton(
      null,
      Text(currentLocalesService.photo_preview_screen['add_description']),
      () {
        showModalBottomSheet(context: context, builder: buildAddDescriptionModal);
      },
      ignoreClick: true,
    );
  }

  Widget buildUnselectAllButton() {
    return BaseOutlinedButton(
      null,
      const Text(
        'Unselect all',
        style: TextStyle(fontSize: 14),
      ),
      () async {
        setState(() {
          _selectedPhotos = [];
        });
      },
      ignoreClick: true,
    );
  }

  Widget buildSelectAllButton() {
    return BaseOutlinedButton(
      null,
      Text(
        currentLocalesService.photos_preview_screen['select_all'],
        style: const TextStyle(fontSize: 14),
      ),
      () async {
        setState(() {
          _selectedPhotos = List<FileDataTransferObject<XFile>>.from(widget._photosDTO);
          isSelectMode = true;
        });
      },
      ignoreClick: true,
    );
  }

  Widget buildUploadAllButton(BuildContext context) {
    return BaseOutlinedButton(
      null,
      Text(
        currentLocalesService.photos_preview_screen['upload_all'],
        style: const TextStyle(fontSize: 16),
      ),
      () async {
        _selectedPhotos = List<FileDataTransferObject<XFile>>.from(widget._photosDTO);
        if (_textEditingController.text.isEmpty) {
          showModalBottomSheet(context: context, builder: (context) => buildDescriptionIsEmptyModal(context));
        } else {
          await handleUploadAndShowSnackBars(context);
        }
      },
      ignoreClick: true,
    );
  }

  SnackBar showSnackBarWithText(String text) {
    return SnackBar(
      content: Text(text),
    );
  }

  Widget buildAddDescriptionModal(context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Text(currentLocalesService.photo_preview_screen['description']),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              controller: _textEditingController,
              textAlign: TextAlign.center,
              maxLength: 60,
              maxLengthEnforcement: MaxLengthEnforcement.none,
            ),
          ),
          ElevatedButton(
              onPressed: () {
                if (_textEditingController.text.length > 60) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(currentLocalesService.photo_preview_screen['max_char_exceeded'])));
                  return;
                }
                setState(() {});
                Navigator.of(context).pop();
              },
              child: const Text('Add'))
        ],
      ),
    );
  }

  Widget buildDescriptionIsEmptyModal(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              'It is better to add a description to an asset.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(context: context, builder: (context) => buildAddDescriptionModal(context))
                      .then((value) => Navigator.pop(context));
                },
                child: const Text('Add description'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green.shade900,
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    await handleUploadAndShowSnackBars(context);
                    popAllAndNavigateToMockScreen(context);
                  },
                  child: const Text('Upload anyway'))
            ],
          ),
        )
      ],
    );
  }

  Future<void> handleUploadAndShowSnackBars(BuildContext context) async {
    ScaffoldMessenger.of(context)
        .showSnackBar(showSnackBarWithText(currentLocalesService.photos_preview_screen['uploading']));
    await createAssetAndUploadPhotos()
        .onError((error, stackTrace) => showSnackBarWithText('there was an error uploading photos: $error'));
    ScaffoldMessenger.of(context).showSnackBar(
        showSnackBarWithText('Successfully uploaded $successFullUploadsCount of ${_selectedPhotos.length} pictures.'));
  }

  Future<void> createAssetAndUploadPhotos() async {
    successFullUploadsCount = 0;
    if (_selectedPhotos.isEmpty) {
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
    for (var fileDTO in _selectedPhotos) {
      try {
        await DevEzaApi.ezFileEndpoints.uploadPost(FormData.fromMap(
            {"assetId": newAsset.identifier, "Type": "3", "File": await MultipartFile.fromFile(fileDTO.file.path)}));
      } catch (e) {
        print('error in uploadFile');
        print(e);
      }

      // then get that asset again from the API, assign newAsset.data to asset that I fetched from api and try to call set(update) with that asset
      var asset = await DevEzaApi.ezAssetEndpoints.getGet(newAsset.identifier!).then((value) => value.body.results[0]);
      asset.data = newAsset.data;
      String id = newAsset.identifier!;

      try {
        DevEzaApi.ezAssetEndpoints.setSet(FormData.fromMap({
          "data": json.encode({"Identifier": id, "Asset.ReelPart_Description": _textEditingController.text})
        }));
      } catch (e) {
        print('error in set $e');
      }
      successFullUploadsCount++;
    }

    await DevEzaApi.ezLabelEndpoints.associateWithPost(FormData.fromMap({"Id": "16", "assetId": newAsset.identifier}));
  }

  void toggleSelectionMode() {
    setState(() {
      if (!isSelectMode) {
        _selectedPhotos = [];
        _selectedPhotos = List<FileDataTransferObject<XFile>>.from(widget._photosDTO);
      }

      isSelectMode = !isSelectMode;
    });
  }

  void startSelectionModeAndAddPhotoToSelectedPhotos(FileDataTransferObject<XFile> photoDTO) {
    return setState(() {
      isSelectMode = true;
      if (_selectedPhotos.contains(photoDTO)) {
        return;
      }
      _selectedPhotos.add(photoDTO);
    });
  }

  Future<dynamic> navigateToPhotoPreviewScreen(BuildContext context, FileDataTransferObject<XFile> photoDTO) {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PhotoPreviewScreen(widget._photosDTO, widget._photosDTO.indexOf(photoDTO),
                updateParentsDTOCallback: (description) => setState(() => photoDTO.description = description))));
  }

  void togglePhotoSelect(FileDataTransferObject<XFile> fileDTO) => isSelectMode
      ? setState(() {
          !_selectedPhotos.contains(fileDTO) ? _selectedPhotos.add(fileDTO) : _selectedPhotos.remove(fileDTO);
        })
      : null;
}
