import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main(List<String> args) {
  const About();
}

class About extends StatelessWidget {
  const About({super.key});
  static const names = [
    'Peter',
    'Chizoba',
    'Ugwuoke',
    'Kate',
    'Gift',
    'Onyinye',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: names.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(names[index]),
                const Divider(
                  color: Colors.black12,
                )
              ],
            ),
            leading: Text('${index + 1}.'),
            trailing: const Icon(Icons.person_add),
            textColor: const Color.fromARGB(255, 1, 50, 70),
          );
        });
  }
}
