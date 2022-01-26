class FileDataTransferObject<T> {
  T file;
  String? description;

  FileDataTransferObject.withDescription(this.file, this.description);
  FileDataTransferObject(this.file);
}