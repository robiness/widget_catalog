import 'package:flutter/material.dart';

class CatalogInputField extends StatelessWidget {
  const CatalogInputField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Catalog Name',
        hintText: 'Enter a nice name for the catalog',
      ),
    );
  }
}
