import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  const MyButton({super.key, required this.onTap});
  final Function()? onTap;

  @override
  State<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 150,
        height: 45,
        child: Container(
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color.fromRGBO(117, 224, 10, 1),
                    Color.fromRGBO(10, 224, 160, 1)
                  ]),
              borderRadius: BorderRadius.circular(50)),
          child: const Center(
            child: ListTile(
              title: Text(
                'LOGIN',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              trailing: Icon(Icons.arrow_forward),
            ),
          ),
        ),
      ),
    );
  }
}
