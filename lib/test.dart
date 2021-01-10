import 'dart:ffi';

class Man {
  int age;
  String name;
}

Future<void> getVoid() {
  // But i can't use captial Null
  var a = null;
  // it also default returning null
  return a;
}

main(List<String> args) {
  print(getVoid().runtimeType); // return null
  String a = "12";
}

// main(List<String> args) {
// Man man = Man()
//   ..age = 22
//   ..name = "Yeasin";
// print("${man.name} Age: ${man.age}");

// Man man2 = Man();
// man2.age = 23;
// man2.name = "Sheikh";
// print("${man2.name} Age: ${man2.age}");
// }
