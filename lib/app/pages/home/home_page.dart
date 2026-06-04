import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      //SafeArea para ajustar
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Image.asset(
                'lib/app/assets/img/LogoLonga.png',
                width: 200,
                height: 75,
              ),
            ),
            const SizedBox(height: 0),

            Padding(
              padding: const EdgeInsetsGeometry.all(20),

              child: SearchBar(
                hintText: 'Buscar produto...',

                elevation: const WidgetStatePropertyAll(0),

                backgroundColor: const WidgetStatePropertyAll(Colors.white),

                trailing: const [Icon(Icons.search)],

                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),

                    side: BorderSide(color: Colors.grey.shade400, width: 1),
                  ),
                ),
                onChanged: (value) => {print(value)},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
