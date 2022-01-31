class CurrentLocalesService {
  static _PhotosPreviewScreenLocale get screenPhotosPreview => _PhotosPreviewScreenLocale();
  static _LoginScreenLocale get screenLogin => _LoginScreenLocale();

  static _Errors get errors => _Errors();
}

class _PhotosPreviewScreenLocale {
  _EmptyDescriptionModal get componentEmptyDescriptionModal => _EmptyDescriptionModal();
  _PreviewAppBar get componentPreviewAppBar => _PreviewAppBar();

  get textInputHint => "Description";
}

class _EmptyDescriptionModal {
  get text => "It is better to add a description to an asset";
}

class _PreviewAppBar {
  get textSelect => "select";
  get textNoPhotosSelected => "No photos selected";
  get textDescriptionMissing => "Please add a description to an asset";
  get textUploading => "Uploading, please wait";
  get textSuccessfulUpload => "Successfully uploaded";
}

class _LoginScreenLocale {
  get textEmail => "Email";
  get textPassword => "Password";
  get textLogin => "Login";
}

class _Errors {
  get textUploadFailed => "There was an error uploading photos";
}