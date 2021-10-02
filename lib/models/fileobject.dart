import 'dart:io';

class Fileobject {
  static File? fileimage;
  static int index = 0;

  static void setFile(File i) {
    fileimage = i;
  }

  static File getFile() {
    return fileimage!;
  }

  static void set(int i) {
    index = i;
  }

  static int get() {
    return index;
  }
}
