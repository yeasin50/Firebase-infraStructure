class Man {
  int age;
  String name;
}

main(List<String> args) {
  Man man = Man()
    ..age = 22
    ..name = "Yeasin";
  print("${man.name} Age: ${man.age}");

  Man man2 = Man();
  man2.age = 23;
  man2.name = "Sheikh";
  print("${man2.name} Age: ${man2.age}");
}
