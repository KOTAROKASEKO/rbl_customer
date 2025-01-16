import 'package:flutter/material.dart';

class CustomerSupport extends StatefulWidget{
  const CustomerSupport({super.key});

  @override
  _CustomerSupportState createState() => _CustomerSupportState();
}

class _CustomerSupportState extends State<CustomerSupport>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Support'),
      ),
      body: const Center(
        child: Text('Customer Support'),
      ),
    );
  }
}